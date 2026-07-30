import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:green_trash_project/features/customer/address_book/data/reverse_geocoding_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('parseNominatimAddress', () {
    test('maps Vietnamese structured address fields', () {
      final address = parseNominatimAddress({
        'display_name':
            '12 Nguyễn Văn Bảo, Phường 4, Gò Vấp, Thành phố Hồ Chí Minh',
        'address': {
          'house_number': '12',
          'road': 'Nguyễn Văn Bảo',
          'quarter': 'Phường 4',
          'city_district': 'Gò Vấp',
          'city': 'Thành phố Hồ Chí Minh',
        },
      });

      expect(address.detail, '12 Nguyễn Văn Bảo');
      expect(address.ward, 'Phường 4');
      expect(address.district, 'Gò Vấp');
      expect(address.city, 'Thành phố Hồ Chí Minh');
    });

    test('uses display name when the road field is unavailable', () {
      final address = parseNominatimAddress({
        'display_name': 'Cổng chính IUH, Phường 4, Gò Vấp',
        'address': {'ward': 'Phường 4', 'district': 'Gò Vấp'},
      });

      expect(address.detail, 'Cổng chính IUH');
      expect(address.ward, 'Phường 4');
      expect(address.district, 'Gò Vấp');
    });

    test('does not infer a district from an unreliable city field', () {
      final address = parseNominatimAddress({
        'display_name':
            'Hẻm 189 Đường Lý Thường Kiệt, Phường Minh Phụng, '
            'Thành phố Thủ Đức, Thành phố Hồ Chí Minh, Việt Nam',
        'address': {
          'road': 'Hẻm 189 Đường Lý Thường Kiệt',
          'suburb': 'Phường Minh Phụng',
          'city': 'Thành phố Thủ Đức',
        },
      });

      expect(address.ward, 'Phường Minh Phụng');
      expect(address.district, isEmpty);
      expect(address.city, 'Thành phố Thủ Đức');
    });

    test('maps GeocodeJSON without inventing a district', () {
      final address = parseNominatimAddress({
        'features': [
          {
            'properties': {
              'geocoding': {
                'label':
                    '822 Trường Chinh, Phường Tân Sơn, '
                    'Thành phố Hồ Chí Minh, Việt Nam',
                'name': 'Đường Trường Chinh',
                'housenumber': '822',
                'district': 'Phường Tân Sơn',
                'city': 'Thành phố Hồ Chí Minh',
                'admin': {
                  'level6': 'Phường Tân Sơn',
                  'level4': 'Thành phố Hồ Chí Minh',
                },
              },
            },
          },
        ],
      });

      expect(address.detail, '822 Đường Trường Chinh');
      expect(address.ward, 'Phường Tân Sơn');
      expect(address.district, isEmpty);
      expect(address.city, 'Thành phố Hồ Chí Minh');
    });

    test('falls back to the label when separate street fields are empty', () {
      final address = parseNominatimAddress({
        'features': [
          {
            'properties': {
              'geocoding': {
                'label':
                    '25 Đường Tân Sơn, Phường Tân Sơn, '
                    'Thành phố Hồ Chí Minh, Việt Nam',
                'street': '',
                'name': '',
                'district': 'Phường Tân Sơn',
                'city': 'Thành phố Hồ Chí Minh',
              },
            },
          },
        ],
      });

      expect(address.detail, '25 Đường Tân Sơn');
    });

    test('does not duplicate a house number already included in street', () {
      final address = parseNominatimAddress({
        'features': [
          {
            'properties': {
              'geocoding': {
                'label':
                    '25 Đường Tân Sơn, Phường Tân Sơn, '
                    'Thành phố Hồ Chí Minh, Việt Nam',
                'housenumber': '25',
                'street': '25 Đường Tân Sơn',
                'district': 'Phường Tân Sơn',
                'city': 'Thành phố Hồ Chí Minh',
              },
            },
          },
        ],
      });

      expect(address.detail, '25 Đường Tân Sơn');
    });
  });

  test('reverse sends the expected Nominatim request', () async {
    late http.Request capturedRequest;
    final service = ReverseGeocodingService(
      minimumInterval: Duration.zero,
      client: MockClient((request) async {
        capturedRequest = request;
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'display_name':
                  '12 Nguyễn Văn Bảo, Phường 4, Gò Vấp, Thành phố Hồ Chí Minh',
              'address': {
                'house_number': '12',
                'road': 'Nguyễn Văn Bảo',
                'ward': 'Phường 4',
                'city_district': 'Gò Vấp',
                'city': 'Thành phố Hồ Chí Minh',
              },
            }),
          ),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );
    addTearDown(service.close);

    final result = await service.reverse(
      latitude: 10.8221234,
      longitude: 106.6875678,
    );

    expect(result.detail, '12 Nguyễn Văn Bảo');
    expect(capturedRequest.url.path, '/reverse');
    expect(capturedRequest.url.queryParameters['format'], 'geocodejson');
    expect(capturedRequest.url.queryParameters['addressdetails'], '1');
    expect(capturedRequest.url.queryParameters['accept-language'], 'vi');
    expect(capturedRequest.url.queryParameters['layer'], 'address');
    expect(capturedRequest.headers['Accept'], 'application/json');
  });

  test('reverse reports rate limiting clearly', () async {
    final service = ReverseGeocodingService(
      minimumInterval: Duration.zero,
      client: MockClient((_) async => http.Response('', 429)),
    );
    addTearDown(service.close);

    expect(
      () => service.reverse(latitude: 10, longitude: 106),
      throwsA(
        isA<ReverseGeocodingException>().having(
          (error) => error.code,
          'code',
          'rate-limited',
        ),
      ),
    );
  });
}
