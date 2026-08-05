import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/app_models.dart';
import '../../../../providers/app_providers.dart';
import '../data/firestore_billing_service.dart';
import '../data/firestore_customer_service.dart';
import '../data/firestore_package_service.dart';
import '../domain/customer_billing_models.dart';

final firestoreCustomerServiceProvider = Provider<FirestoreCustomerService>((
  ref,
) {
  return FirestoreCustomerService();
});

final _firestorePackageServiceProvider = Provider<FirestorePackageService>((
  ref,
) {
  return FirestorePackageService();
});

final _firestoreBillingServiceProvider = Provider<FirestoreBillingService>((
  ref,
) {
  return FirestoreBillingService();
});

final customerSecondarySubscriptionsProvider =
    StateNotifierProvider<
      CustomerSubscriptionController,
      List<PackageSubscription>
    >((ref) {
      final controller = CustomerSubscriptionController(
        service: ref.watch(_firestorePackageServiceProvider),
        initialSubscriptions: ref.watch(subscriptionsProvider),
      );
      final user = ref.watch(currentUserProvider);
      if (user != null) {
        unawaited(controller.load(user.userId));
      }
      return controller;
    });

final customerSecondaryCurrentSubscriptionProvider =
    Provider<PackageSubscription?>((ref) {
      final user = ref.watch(currentUserProvider);
      if (user == null) return null;
      for (final subscription in ref.watch(
        customerSecondarySubscriptionsProvider,
      )) {
        if (subscription.khachHangId == user.userId &&
            {'CON_HL', 'CON_HIEU_LUC'}.contains(subscription.trangThai)) {
          return subscription;
        }
      }
      return null;
    });

final customerBillingProvider =
    StateNotifierProvider<CustomerBillingController, CustomerBillingState>((
      ref,
    ) {
      final customerId = ref.watch(currentUserProvider)?.userId;
      final initialPayments = _samplePayments
          .where((item) => item.khachHangId == customerId)
          .toList();
      final paymentIds = initialPayments
          .map((item) => item.thanhToanId)
          .toSet();
      final initialInvoices = _sampleInvoices
          .where((item) => paymentIds.contains(item.thanhToanId))
          .toList();
      final controller = CustomerBillingController(
        service: ref.watch(_firestoreBillingServiceProvider),
        customerId: customerId,
        initialPayments: initialPayments,
        initialInvoices: initialInvoices,
      );
      unawaited(controller.load());
      return controller;
    });

final customerPaymentsProvider = Provider<List<CustomerPayment>>((ref) {
  return ref.watch(customerBillingProvider).payments;
});

final customerInvoicesProvider = Provider<List<CustomerInvoice>>((ref) {
  return ref.watch(customerBillingProvider).invoices;
});

class CustomerSubscriptionController
    extends StateNotifier<List<PackageSubscription>> {
  CustomerSubscriptionController({
    required FirestorePackageService service,
    required List<PackageSubscription> initialSubscriptions,
  }) : _service = service,
       super([...initialSubscriptions]);

  final FirestorePackageService _service;

  Future<void> load(String customerId) async {
    try {
      final remote = await _service.getSubscription(customerId);
      if (remote != null) _replace(remote);
    } catch (error) {
      debugPrint('Khong the tai goi thang: $error');
    }
  }

  Future<void> subscribeOrRenew({
    required String khachHangId,
    required PickupPackage package,
  }) async {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    PackageSubscription? current;
    for (final item in state) {
      if (item.khachHangId == khachHangId) {
        current = item;
        break;
      }
    }
    final subscription = PackageSubscription(
      dangKyGoiId: current?.dangKyGoiId ?? 'DKG_$khachHangId',
      khachHangId: khachHangId,
      goiId: package.goiId,
      thangNam: '${now.year}-$month',
      soKgDaDung: 0,
      soKgConLai: package.hanMucKgThang.toDouble(),
      trangThai: 'CON_HL',
    );
    await _service.saveSubscription(subscription);
    _replace(subscription);
  }

  void _replace(PackageSubscription subscription) {
    state = [
      for (final item in state)
        if (item.khachHangId == subscription.khachHangId)
          subscription
        else
          item,
      if (!state.any((item) => item.khachHangId == subscription.khachHangId))
        subscription,
    ];
  }
}

class CustomerBillingState {
  const CustomerBillingState({
    this.payments = const [],
    this.invoices = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<CustomerPayment> payments;
  final List<CustomerInvoice> invoices;
  final bool isLoading;
  final String? errorMessage;
}

class CustomerBillingController extends StateNotifier<CustomerBillingState> {
  CustomerBillingController({
    required FirestoreBillingService service,
    required String? customerId,
    required List<CustomerPayment> initialPayments,
    required List<CustomerInvoice> initialInvoices,
  }) : _service = service,
       _customerId = customerId,
       super(
         CustomerBillingState(
           payments: initialPayments,
           invoices: initialInvoices,
         ),
       );

  final FirestoreBillingService _service;
  final String? _customerId;

  Future<void> load() async {
    final customerId = _customerId;
    if (customerId == null) return;
    state = CustomerBillingState(
      payments: state.payments,
      invoices: state.invoices,
      isLoading: true,
    );
    try {
      final payments = await _service.getPayments(customerId);
      final invoices = await _service.getInvoicesForPayments(
        payments.map((item) => item.thanhToanId).toList(),
      );
      state = CustomerBillingState(
        payments: payments.isEmpty ? state.payments : payments,
        invoices: invoices.isEmpty ? state.invoices : invoices,
      );
    } catch (error) {
      debugPrint('Khong the tai lich su thanh toan: $error');
      state = CustomerBillingState(
        payments: state.payments,
        invoices: state.invoices,
        errorMessage: 'Khong the tai lich su thanh toan',
      );
    }
  }

  Future<void> reload() => load();
}

final _samplePayments = [
  CustomerPayment(
    thanhToanId: 'TT_001',
    maDon: 'DON_001',
    khachHangId: 'USER_KH_001',
    soTien: 42500,
    phuongThuc: 'VI_DIEN_TU',
    maGiaoDichNgoai: 'MOMO_20260708001',
    trangThai: 'DA_THANH_TOAN',
    thoiGian: DateTime(2026, 7, 8, 9, 5),
  ),
  CustomerPayment(
    thanhToanId: 'TT_002',
    maDon: 'DON_002',
    khachHangId: 'USER_KH_001',
    soTien: 15000,
    phuongThuc: 'TIEN_MAT',
    trangThai: 'CHO_THANH_TOAN',
    thoiGian: DateTime(2026, 7, 9, 10),
  ),
];

final _sampleInvoices = [
  CustomerInvoice(
    hoaDonId: 'HD_001',
    maDon: 'DON_001',
    thanhToanId: 'TT_001',
    soKgThucTe: 8.5,
    donGia: 5000,
    tongTien: 42500,
    thoiGianTao: DateTime(2026, 7, 8, 9, 6),
  ),
];
