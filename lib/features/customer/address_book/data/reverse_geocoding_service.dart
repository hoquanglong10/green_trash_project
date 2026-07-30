import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'reverse_geocoding_request_io.dart'
    if (dart.library.js_interop) 'reverse_geocoding_request_web.dart';

class ReverseGeocodedAddress {
  const ReverseGeocodedAddress({
    required this.detail,
    required this.ward,
    required this.district,
    required this.city,
    required this.displayName,
  });

  final String detail;
  final String ward;
  final String district;
  final String city;
  final String displayName;

  bool get hasStructuredAddress =>
      detail.isNotEmpty ||
      ward.isNotEmpty ||
      district.isNotEmpty ||
      city.isNotEmpty;
}

class ReverseGeocodingService {
  ReverseGeocodingService({
    http.Client? client,
    Uri? endpoint,
    Duration minimumInterval = const Duration(seconds: 1),
  }) : _client = client ?? http.Client(),
       _endpoint =
           endpoint ?? Uri.https('nominatim.openstreetmap.org', '/reverse'),
       _minimumInterval = minimumInterval;

  final http.Client _client;
  final Uri _endpoint;
  final Duration _minimumInterval;
  DateTime? _lastRequestAt;

  Future<ReverseGeocodedAddress> reverse({
    required double latitude,
    required double longitude,
  }) async {
    await _respectRateLimit();
    final uri = _endpoint.replace(
      queryParameters: {
        'format': 'geocodejson',
        'lat': latitude.toStringAsFixed(7),
        'lon': longitude.toStringAsFixed(7),
        'addressdetails': '1',
        'zoom': '18',
        'layer': 'address',
        'accept-language': 'vi',
      },
    );
    _lastRequestAt = DateTime.now();
    late final http.Response response;
    try {
      response =
          await performReverseGeocodingRequest(
            client: _client,
            uri: uri,
            headers: {
              'Accept': 'application/json',
              if (!kIsWeb) 'User-Agent': 'GreenTrashCourseProject/1.0',
            },
          ).timeout(
            const Duration(seconds: 12),
            onTimeout: () => throw const ReverseGeocodingException(
              'timeout',
              'Tra cứu địa chỉ mất quá nhiều thời gian. Vui lòng thử lại.',
            ),
          );
    } on TimeoutException {
      throw const ReverseGeocodingException(
        'timeout',
        'Tra cứu địa chỉ mất quá nhiều thời gian. Vui lòng thử lại.',
      );
    } on http.ClientException {
      throw const ReverseGeocodingException(
        'network',
        'Không thể kết nối dịch vụ bản đồ.',
      );
    }

    if (response.statusCode == 429) {
      throw const ReverseGeocodingException(
        'rate-limited',
        'Dịch vụ địa chỉ đang giới hạn truy cập. Vui lòng thử lại sau.',
      );
    }
    if (response.statusCode != 200) {
      throw ReverseGeocodingException(
        'http-${response.statusCode}',
        'Không thể tra cứu địa chỉ từ bản đồ.',
      );
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map<String, dynamic>) {
      throw const ReverseGeocodingException(
        'invalid-response',
        'Dịch vụ bản đồ trả về dữ liệu không hợp lệ.',
      );
    }
    final result = parseNominatimAddress(decoded);
    if (!result.hasStructuredAddress) {
      throw const ReverseGeocodingException(
        'address-not-found',
        'Không tìm thấy địa chỉ phù hợp gần vị trí hiện tại.',
      );
    }
    return result;
  }

  Future<void> _respectRateLimit() async {
    final previous = _lastRequestAt;
    if (previous == null) return;
    final remaining = _minimumInterval - DateTime.now().difference(previous);
    if (remaining > Duration.zero) await Future<void>.delayed(remaining);
  }

  void close() => _client.close();
}

ReverseGeocodedAddress parseNominatimAddress(Map<String, dynamic> data) {
  final features = data['features'];
  if (features is List && features.isNotEmpty) {
    final feature = features.first;
    if (feature is Map) {
      final properties = feature['properties'];
      if (properties is Map) {
        final geocoding = properties['geocoding'];
        if (geocoding is Map) {
          return _parseGeocodeJson(
            geocoding.map((key, value) => MapEntry(key.toString(), value)),
          );
        }
      }
    }
  }

  final rawAddress = data['address'];
  final address = rawAddress is Map
      ? rawAddress.map(
          (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
        )
      : const <String, String>{};
  final houseNumber = _firstValue(address, const ['house_number']);
  var road = _firstValue(address, const [
    'road',
    'pedestrian',
    'residential',
    'footway',
    'path',
  ]);
  final displayName = data['display_name']?.toString().trim() ?? '';
  if (road.isEmpty && displayName.isNotEmpty) {
    road = displayName.split(',').first.trim();
  }
  final detail = [
    houseNumber,
    road,
  ].where((value) => value.isNotEmpty).join(' ');
  final ward = _firstValue(address, const [
    'ward',
    'quarter',
    'suburb',
    'neighbourhood',
    'village',
  ]);
  final district = _firstValue(address, const [
    'city_district',
    'district',
    'state_district',
    'county',
    'municipality',
  ]);
  final city = _firstValue(address, const [
    'state',
    'province',
    'city',
    'town',
  ]);
  return ReverseGeocodedAddress(
    detail: detail,
    ward: ward,
    district: district,
    city: city,
    displayName: displayName,
  );
}

ReverseGeocodedAddress _parseGeocodeJson(Map<String, dynamic> geocoding) {
  final displayName = geocoding['label']?.toString().trim() ?? '';
  final houseNumber = geocoding['housenumber']?.toString().trim() ?? '';
  final street = _firstNonEmptyValue([geocoding['street'], geocoding['name']]);
  final adminValues = <String>[];
  final rawAdmin = geocoding['admin'];
  if (rawAdmin is Map) {
    adminValues.addAll(
      rawAdmin.values
          .map((value) => value?.toString().trim() ?? '')
          .where((value) => value.isNotEmpty),
    );
  }
  final districtValue = geocoding['district']?.toString().trim() ?? '';
  final locality = geocoding['locality']?.toString().trim() ?? '';
  final ward = _firstMatchingAdministrativePart(
    [districtValue, locality, ...adminValues],
    const ['Phường ', 'Xã ', 'Thị trấn '],
  );
  final district = _firstMatchingAdministrativePart(
    [
      geocoding['county']?.toString().trim() ?? '',
      districtValue,
      ...adminValues,
    ],
    const ['Quận ', 'Huyện ', 'Thị xã '],
  );
  final city =
      geocoding['city']?.toString().trim() ??
      geocoding['state']?.toString().trim() ??
      '';
  final structuredDetail = _joinHouseNumberAndStreet(houseNumber, street);
  final labelDetail = displayName.split(',').first.trim();
  final detail = structuredDetail.isNotEmpty ? structuredDetail : labelDetail;

  return ReverseGeocodedAddress(
    detail: detail,
    ward: ward,
    district: district,
    city: city,
    displayName: displayName,
  );
}

String _firstNonEmptyValue(Iterable<Object?> values) {
  for (final value in values) {
    final text = value?.toString().trim() ?? '';
    if (text.isNotEmpty) return text;
  }
  return '';
}

String _joinHouseNumberAndStreet(String houseNumber, String street) {
  if (street.isEmpty) return '';
  if (houseNumber.isEmpty) return street;
  final normalizedHouseNumber = houseNumber.toLowerCase();
  final normalizedStreet = street.toLowerCase();
  if (normalizedStreet == normalizedHouseNumber ||
      normalizedStreet.startsWith('$normalizedHouseNumber ')) {
    return street;
  }
  return '$houseNumber $street';
}

String _firstValue(Map<String, String> values, List<String> keys) {
  for (final key in keys) {
    final value = values[key]?.trim() ?? '';
    if (value.isNotEmpty) return value;
  }
  return '';
}

String _firstMatchingAdministrativePart(
  Iterable<String> values,
  List<String> prefixes,
) {
  for (final value in values) {
    if (prefixes.any(value.startsWith)) {
      return value;
    }
  }
  return '';
}

class ReverseGeocodingException implements Exception {
  const ReverseGeocodingException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'ReverseGeocodingException($code): $message';
}
