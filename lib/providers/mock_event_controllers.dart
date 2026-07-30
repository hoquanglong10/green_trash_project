import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_models.dart';

class ActivityLogController extends StateNotifier<List<ActivityLog>> {
  ActivityLogController(super.initialLogs);

  void add(ActivityLog log) {
    state = [log, ...state];
  }
}

class NotificationController extends StateNotifier<List<AppNotification>> {
  NotificationController(super.initialNotifications);

  void add(AppNotification notification) {
    state = [notification, ...state];
  }
}

class CustomerAddressController extends StateNotifier<List<CustomerAddress>> {
  CustomerAddressController(super.initialAddresses);

  String save({
    String? addressId,
    required String customerId,
    required String detail,
    required String ward,
    required String district,
    required String city,
    required double latitude,
    required double longitude,
    required bool isDefault,
  }) {
    final id = addressId ?? 'DC_LOCAL_${DateTime.now().microsecondsSinceEpoch}';
    CustomerAddress? existing;
    for (final address in state) {
      if (address.diaChiId == id) {
        existing = address;
        break;
      }
    }
    final customerAddresses = state.where(
      (address) => address.khachHangId == customerId,
    );
    final shouldBeDefault =
        isDefault || customerAddresses.isEmpty || (existing?.macDinh ?? false);
    final saved = CustomerAddress(
      diaChiId: id,
      khachHangId: customerId,
      diaChiChiTiet: detail,
      phuongXa: ward,
      quanHuyen: district,
      tinhThanh: city,
      toaDoLat: latitude,
      toaDoLng: longitude,
      macDinh: shouldBeDefault,
    );

    state = [
      for (final address in state)
        if (address.diaChiId == id)
          saved
        else if (shouldBeDefault && address.khachHangId == customerId)
          _withDefault(address, false)
        else
          address,
      if (existing == null) saved,
    ];
    return id;
  }

  void setDefault({required String customerId, required String addressId}) {
    state = [
      for (final address in state)
        if (address.khachHangId == customerId)
          _withDefault(address, address.diaChiId == addressId)
        else
          address,
    ];
  }

  void delete({required String customerId, required String addressId}) {
    CustomerAddress? removed;
    for (final address in state) {
      if (address.khachHangId == customerId && address.diaChiId == addressId) {
        removed = address;
        break;
      }
    }
    final remaining = state
        .where((address) => address.diaChiId != addressId)
        .toList();
    if (removed?.macDinh == true) {
      for (var index = 0; index < remaining.length; index++) {
        final address = remaining[index];
        if (address.khachHangId == customerId) {
          remaining[index] = _withDefault(address, true);
          break;
        }
      }
    }
    state = remaining;
  }

  CustomerAddress _withDefault(CustomerAddress address, bool value) {
    return CustomerAddress(
      diaChiId: address.diaChiId,
      khachHangId: address.khachHangId,
      diaChiChiTiet: address.diaChiChiTiet,
      phuongXa: address.phuongXa,
      quanHuyen: address.quanHuyen,
      tinhThanh: address.tinhThanh,
      toaDoLat: address.toaDoLat,
      toaDoLng: address.toaDoLng,
      macDinh: value,
    );
  }
}

class CollectionRecordController
    extends StateNotifier<Map<String, CollectionRecord>> {
  CollectionRecordController() : super(const {});

  void save(CollectionRecord record) {
    state = {...state, record.maDon: record};
  }

  void markPaid(String maDon) {
    final record = state[maDon];
    if (record == null) return;
    state = {
      ...state,
      maDon: record.copyWith(trangThaiThanhToan: 'DA_THANH_TOAN'),
    };
  }
}

class PaymentRecordController
    extends StateNotifier<Map<String, PaymentRecord>> {
  PaymentRecordController() : super(const {});

  void save(PaymentRecord payment) {
    state = {...state, payment.maDon: payment};
  }

  void markPaid(String maDon, {DateTime? paidAt}) {
    final payment = state[maDon];
    if (payment == null || payment.trangThai == 'DA_THANH_TOAN') return;
    state = {
      ...state,
      maDon: payment.copyWith(
        trangThai: 'DA_THANH_TOAN',
        thoiGianThanhToan: paidAt ?? DateTime.now(),
      ),
    };
  }
}

class PackageSubscriptionController
    extends StateNotifier<List<PackageSubscription>> {
  PackageSubscriptionController(super.initialSubscriptions);

  void consume({required String customerId, required double kg}) {
    if (kg <= 0) return;
    state = [
      for (final subscription in state)
        if (subscription.khachHangId == customerId &&
            subscription.trangThai == 'CON_HL')
          subscription.copyWith(
            soKgDaDung: subscription.soKgDaDung + kg,
            soKgConLai: (subscription.soKgConLai - kg)
                .clamp(0, double.infinity)
                .toDouble(),
          )
        else
          subscription,
    ];
  }
}

class StaffProfileController extends StateNotifier<List<StaffProfile>> {
  StaffProfileController(super.initialProfiles);

  void setWorkStatus(String staffId, String status) {
    state = [
      for (final profile in state)
        if (profile.nhanVienId == staffId)
          profile.copyWith(trangThaiLamViec: status)
        else
          profile,
    ];
  }
}
