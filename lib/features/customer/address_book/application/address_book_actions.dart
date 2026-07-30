import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/app_models.dart';
import '../../../../providers/app_providers.dart';
import '../../../reference_data/application/reference_data_providers.dart';

final addressBookActionsProvider = Provider<AddressBookActions>(
  AddressBookActions.new,
);

class AddressBookActions {
  AddressBookActions(this._ref);

  final Ref _ref;

  Future<String> save({
    CustomerAddress? existing,
    required String detail,
    required String ward,
    required String district,
    required String city,
    required double latitude,
    required double longitude,
    required bool isDefault,
  }) async {
    final user = _requireCustomer();
    if (_ref.read(firebaseEnabledProvider)) {
      return _ref
          .read(referenceDataRepositoryProvider)
          .saveCustomerAddress(
            addressId: existing?.diaChiId,
            customerId: user.userId,
            detail: detail,
            ward: ward,
            district: district,
            city: city,
            latitude: latitude,
            longitude: longitude,
            isDefault: isDefault,
          );
    }
    return _ref
        .read(customerAddressControllerProvider.notifier)
        .save(
          addressId: existing?.diaChiId,
          customerId: user.userId,
          detail: detail,
          ward: ward,
          district: district,
          city: city,
          latitude: latitude,
          longitude: longitude,
          isDefault: isDefault,
        );
  }

  Future<void> setDefault(String addressId) async {
    final user = _requireCustomer();
    if (_ref.read(firebaseEnabledProvider)) {
      await _ref
          .read(referenceDataRepositoryProvider)
          .setDefaultCustomerAddress(
            customerId: user.userId,
            addressId: addressId,
          );
      return;
    }
    _ref
        .read(customerAddressControllerProvider.notifier)
        .setDefault(customerId: user.userId, addressId: addressId);
  }

  Future<void> delete(String addressId) async {
    final user = _requireCustomer();
    if (_ref.read(firebaseEnabledProvider)) {
      await _ref
          .read(referenceDataRepositoryProvider)
          .deleteCustomerAddress(customerId: user.userId, addressId: addressId);
      return;
    }
    _ref
        .read(customerAddressControllerProvider.notifier)
        .delete(customerId: user.userId, addressId: addressId);
  }

  AppUser _requireCustomer() {
    final user = _ref.read(currentUserProvider);
    if (user == null || user.role != UserRole.customer) {
      throw StateError('Phiên khách hàng không còn hợp lệ.');
    }
    return user;
  }
}
