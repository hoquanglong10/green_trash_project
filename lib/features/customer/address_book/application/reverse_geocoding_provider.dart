import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/reverse_geocoding_service.dart';

final reverseGeocodingServiceProvider = Provider<ReverseGeocodingService>((
  ref,
) {
  final service = ReverseGeocodingService();
  ref.onDispose(service.close);
  return service;
});
