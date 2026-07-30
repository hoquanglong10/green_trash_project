import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:green_trash_project/features/customer/address_book/data/address_search_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('parses a coordinate query without network access', () async {
    var requested = false;
    final service = AddressSearchService(
      client: MockClient((_) async {
        requested = true;
        return http.Response('', 500);
      }),
    );
    addTearDown(service.close);

    final results = await service.search('10.814808, 106.632410');

    expect(requested, isFalse);
    expect(results, hasLength(1));
    expect(results.single.latitude, closeTo(10.814808, 0.000001));
    expect(results.single.longitude, closeTo(106.632410, 0.000001));
    expect(results.single.isCoordinate, isTrue);
  });

  test('search uses Photon location bias and parses suggestions', () async {
    late http.Request capturedRequest;
    final service = AddressSearchService(
      client: MockClient((request) async {
        capturedRequest = request;
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'features': [
                {
                  'properties': {
                    'name': 'Trường Chinh',
                    'street': 'Trường Chinh',
                    'housenumber': '822',
                    'district': 'Phường Tân Sơn',
                    'city': 'Thành phố Hồ Chí Minh',
                  },
                  'geometry': {
                    'type': 'Point',
                    'coordinates': [106.6324099, 10.814808],
                  },
                },
              ],
            }),
          ),
          200,
        );
      }),
    );
    addTearDown(service.close);

    final results = await service.search(
      '822 Trường Chinh',
      latitude: 10.81,
      longitude: 106.63,
    );

    expect(results.single.title, '822 Trường Chinh');
    expect(results.single.ward, 'Phường Tân Sơn');
    expect(results.single.city, 'Thành phố Hồ Chí Minh');
    expect(capturedRequest.url.host, 'photon.komoot.io');
    expect(capturedRequest.url.queryParameters['countrycode'], 'VN');
    expect(capturedRequest.url.queryParameters['limit'], '5');
    expect(capturedRequest.url.queryParameters['lat'], '10.8100000');
    expect(capturedRequest.url.queryParameters['lon'], '106.6300000');
  });
}
