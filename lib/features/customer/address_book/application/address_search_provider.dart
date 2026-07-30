import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/address_search_service.dart';

final addressSearchServiceProvider = Provider<AddressSearchService>((ref) {
  final service = AddressSearchService();
  ref.onDispose(service.close);
  return service;
});
