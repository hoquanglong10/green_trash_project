import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/address_search_suggestion.dart';

class AddressSearchService {
  AddressSearchService({http.Client? client, Uri? endpoint})
    : _client = client ?? http.Client(),
      _endpoint = endpoint ?? Uri.https('photon.komoot.io', '/api/');

  final http.Client _client;
  final Uri _endpoint;

  Future<List<AddressSearchSuggestion>> search(
    String query, {
    double? latitude,
    double? longitude,
  }) async {
    final normalizedQuery = query.trim();
    final coordinate = parseCoordinateSuggestion(normalizedQuery);
    if (coordinate != null) return [coordinate];
    if (normalizedQuery.length < 3) return const [];

    final response = await _client
        .get(
          _endpoint.replace(
            queryParameters: {
              'q': normalizedQuery,
              'limit': '5',
              'countrycode': 'VN',
              if (latitude != null) 'lat': latitude.toStringAsFixed(7),
              if (longitude != null) 'lon': longitude.toStringAsFixed(7),
              if (latitude != null && longitude != null) 'zoom': '16',
              if (latitude != null && longitude != null)
                'location_bias_scale': '0.15',
            },
          ),
          headers: const {
            'Accept': 'application/json',
            'Accept-Language': 'vi',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw AddressSearchException(
        'http-${response.statusCode}',
        'Không thể tìm địa chỉ lúc này.',
      );
    }
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map<String, dynamic>) {
      throw const AddressSearchException(
        'invalid-response',
        'Dữ liệu gợi ý địa chỉ không hợp lệ.',
      );
    }
    return parsePhotonSuggestions(decoded);
  }

  void close() => _client.close();
}

List<AddressSearchSuggestion> parsePhotonSuggestions(
  Map<String, dynamic> data,
) {
  final rawFeatures = data['features'];
  if (rawFeatures is! List) return const [];

  final suggestions = <AddressSearchSuggestion>[];
  for (final rawFeature in rawFeatures) {
    if (rawFeature is! Map) continue;
    final geometry = rawFeature['geometry'];
    final properties = rawFeature['properties'];
    if (geometry is! Map || properties is! Map) continue;
    final rawCoordinates = geometry['coordinates'];
    if (rawCoordinates is! List || rawCoordinates.length < 2) continue;
    final longitude = _asDouble(rawCoordinates[0]);
    final latitude = _asDouble(rawCoordinates[1]);
    if (latitude == null ||
        longitude == null ||
        !_isValidCoordinate(latitude, longitude)) {
      continue;
    }

    final values = properties.map(
      (key, value) => MapEntry(key.toString(), value?.toString().trim() ?? ''),
    );
    final houseNumber = values['housenumber'] ?? '';
    final street = _firstValue(values, const ['street', 'name']);
    final name = values['name'] ?? '';
    final detail = _joinAddressPart(houseNumber, street);
    final ward = _firstMatchingValue(
      [values['district'] ?? '', values['locality'] ?? ''],
      const ['Phường ', 'Xã ', 'Thị trấn '],
    );
    final district = _firstMatchingValue(
      [values['county'] ?? '', values['district'] ?? ''],
      const ['Quận ', 'Huyện ', 'Thị xã '],
    );
    final city = _firstValue(values, const ['city', 'state']);
    final title = detail.isNotEmpty ? detail : name;
    final subtitle = _uniqueNonEmpty([
      if (name != title) name,
      ward,
      district,
      city,
    ]).join(', ');
    if (title.isEmpty && subtitle.isEmpty) continue;

    suggestions.add(
      AddressSearchSuggestion(
        latitude: latitude,
        longitude: longitude,
        title: title.isEmpty ? subtitle : title,
        subtitle: subtitle,
        detail: detail,
        ward: ward,
        district: district,
        city: city,
      ),
    );
  }
  return suggestions;
}

AddressSearchSuggestion? parseCoordinateSuggestion(String query) {
  final match = RegExp(
    r'^\s*(-?\d{1,2}(?:\.\d+)?)\s*[,; ]\s*(-?\d{1,3}(?:\.\d+)?)\s*$',
  ).firstMatch(query);
  if (match == null) return null;
  final latitude = double.tryParse(match.group(1)!);
  final longitude = double.tryParse(match.group(2)!);
  if (latitude == null ||
      longitude == null ||
      !_isValidCoordinate(latitude, longitude)) {
    return null;
  }
  final label =
      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  return AddressSearchSuggestion(
    latitude: latitude,
    longitude: longitude,
    title: 'Tọa độ $label',
    subtitle: 'Chọn để tra cứu địa chỉ tại điểm này',
    isCoordinate: true,
  );
}

double? _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

bool _isValidCoordinate(double latitude, double longitude) {
  return latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180;
}

String _firstValue(Map<String, String> values, List<String> keys) {
  for (final key in keys) {
    final value = values[key] ?? '';
    if (value.isNotEmpty) return value;
  }
  return '';
}

String _firstMatchingValue(Iterable<String> values, Iterable<String> prefixes) {
  for (final value in values) {
    if (prefixes.any(value.startsWith)) return value;
  }
  return '';
}

String _joinAddressPart(String houseNumber, String street) {
  if (street.isEmpty) return '';
  if (houseNumber.isEmpty || street.startsWith('$houseNumber ')) return street;
  return '$houseNumber $street';
}

List<String> _uniqueNonEmpty(Iterable<String> values) {
  final seen = <String>{};
  return [
    for (final value in values)
      if (value.isNotEmpty && seen.add(value)) value,
  ];
}

class AddressSearchException implements Exception {
  const AddressSearchException(this.code, this.message);

  final String code;
  final String message;
}
