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
