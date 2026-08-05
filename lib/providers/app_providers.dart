import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import '../models/app_models.dart';
import '../repositories/green_trash_repository.dart';
import '../services/firestore_customer_service.dart';
import '../services/firestore_package_service.dart';
import '../services/firestore_notification_service.dart';
import '../services/firestore_billing_service.dart';
import '../services/firestore_catalog_service.dart';

final greenTrashRepositoryProvider = Provider<GreenTrashRepository>((ref) {
  return MockGreenTrashRepository();
});

final firestorePackageServiceProvider = Provider<FirestorePackageService>((
  ref,
) {
  return FirestorePackageService();
});
final firestoreNotificationServiceProvider =
    Provider<FirestoreNotificationService>((ref) {
      return FirestoreNotificationService();
    });
final firestoreBillingServiceProvider = Provider<FirestoreBillingService>((
  ref,
) {
  return FirestoreBillingService();
});
final firestoreCustomerServiceProvider = Provider<FirestoreCustomerService>((
  ref,
) {
  return FirestoreCustomerService();
});
final firestoreCatalogServiceProvider = Provider<FirestoreCatalogService>((
  ref,
) {
  return FirestoreCatalogService();
});
final currentSessionProvider = StateProvider<AppSession?>((ref) => null);

final usersProvider = Provider<List<AppUser>>((ref) {
  return ref.watch(greenTrashRepositoryProvider).users;
});

final currentUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(currentSessionProvider)?.user;
});

final staffProfilesProvider = Provider<List<StaffProfile>>((ref) {
  return ref.watch(greenTrashRepositoryProvider).staff;
});

final customerAddressesProvider = Provider<List<CustomerAddress>>((ref) {
  final user = ref.watch(currentUserProvider);
  final addresses = ref.watch(greenTrashRepositoryProvider).addresses;
  if (user == null) return const [];
  return addresses
      .where((address) => address.khachHangId == user.userId)
      .toList();
});

final allAddressesProvider = Provider<List<CustomerAddress>>((ref) {
  return ref.watch(greenTrashRepositoryProvider).addresses;
});

final catalogProvider = StateNotifierProvider<CatalogController, CatalogState>((
  ref,
) {
  final repository = ref.watch(greenTrashRepositoryProvider);

  final controller = CatalogController(
    service: ref.watch(firestoreCatalogServiceProvider),
    initialWasteTypes: repository.wasteTypes,
    initialPrices: repository.prices,
    initialPackages: repository.packages,
  );

  controller.initialize();

  return controller;
});

final wasteTypesProvider = Provider<List<WasteType>>((ref) {
  return ref.watch(catalogProvider).wasteTypes;
});

final pricesProvider = Provider<List<PriceItem>>((ref) {
  return ref.watch(catalogProvider).prices;
});

final packagesProvider = Provider<List<PickupPackage>>((ref) {
  return ref.watch(catalogProvider).packages;
});

final subscriptionsProvider =
    StateNotifierProvider<
      PackageSubscriptionController,
      List<PackageSubscription>
    >((ref) {
      final repository = ref.watch(greenTrashRepositoryProvider);

      final user = ref.watch(currentUserProvider);

      final controller = PackageSubscriptionController(
        initialSubscriptions: repository.subscriptions,
        service: ref.watch(firestorePackageServiceProvider),
      );

      if (user != null) {
        controller.loadCustomerSubscription(user.userId);
      }

      return controller;
    });

final currentSubscriptionProvider = Provider<PackageSubscription?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  for (final subscription in ref.watch(subscriptionsProvider)) {
    if (subscription.khachHangId == user.userId) {
      return subscription;
    }
  }
  return null;
});
final customerBillingProvider =
    StateNotifierProvider<CustomerBillingController, CustomerBillingState>((
      ref,
    ) {
      final user = ref.watch(currentUserProvider);
      final repository = ref.watch(greenTrashRepositoryProvider);

      final customerId = user?.userId;

      final initialPayments = customerId == null
          ? <PaymentRecord>[]
          : repository.payments
                .where((payment) => payment.khachHangId == customerId)
                .toList();

      final paymentIds = initialPayments
          .map((payment) => payment.thanhToanId)
          .toSet();

      final initialInvoices = repository.invoices
          .where(
            (invoice) =>
                invoice.thanhToanId != null &&
                paymentIds.contains(invoice.thanhToanId),
          )
          .toList();

      final controller = CustomerBillingController(
        service: ref.watch(firestoreBillingServiceProvider),
        customerId: customerId,
        initialPayments: initialPayments,
        initialInvoices: initialInvoices,
      );

      controller.initialize();

      return controller;
    });

final customerPaymentsProvider = Provider<List<PaymentRecord>>((ref) {
  return ref.watch(customerBillingProvider).payments;
});

final customerInvoicesProvider = Provider<List<Invoice>>((ref) {
  return ref.watch(customerBillingProvider).invoices;
});
final notificationsProvider =
    StateNotifierProvider<NotificationController, List<AppNotification>>((ref) {
      final user = ref.watch(currentUserProvider);
      final repository = ref.watch(greenTrashRepositoryProvider);

      final userId = user?.userId;

      final initialNotifications = userId == null
          ? <AppNotification>[]
          : repository.notifications
                .where((notification) => notification.nguoiNhanId == userId)
                .toList();

      final controller = NotificationController(
        service: ref.watch(firestoreNotificationServiceProvider),
        userId: userId,
        initialNotifications: initialNotifications,
      );

      controller.initialize();

      return controller;
    });

final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref
      .watch(notificationsProvider)
      .where((notification) => notification.trangThaiDoc == 'CHUA_DOC')
      .length;
});

final activityLogsProvider = Provider<List<ActivityLog>>((ref) {
  return ref.watch(greenTrashRepositoryProvider).activityLogs;
});

final timeSlotsProvider = Provider<List<String>>((ref) {
  return ref.watch(greenTrashRepositoryProvider).timeSlots;
});

final orderControllerProvider =
    StateNotifierProvider<OrderController, List<PickupOrder>>((ref) {
      final repository = ref.watch(greenTrashRepositoryProvider);
      return OrderController(
        initialOrders: repository.initialOrders,
        staff: repository.staff,
        addresses: repository.addresses,
      );
    });

final customerOrdersProvider = Provider<List<PickupOrder>>((ref) {
  final user = ref.watch(currentUserProvider);
  final orders = ref.watch(orderControllerProvider);
  if (user == null) return const [];
  return orders.where((order) => order.khachHangId == user.userId).toList()
    ..sort((a, b) => b.ngayTao.compareTo(a.ngayTao));
});

final staffOrdersProvider = Provider<List<PickupOrder>>((ref) {
  final user = ref.watch(currentUserProvider);
  final orders = ref.watch(orderControllerProvider);
  if (user == null) return const [];
  return orders
      .where((order) => order.nhanVienHienTaiId == user.userId)
      .toList()
    ..sort((a, b) => a.ngayThuGom.compareTo(b.ngayThuGom));
});

final staffOfferOrdersProvider = Provider<List<PickupOrder>>((ref) {
  final user = ref.watch(currentUserProvider);
  final orders = ref.watch(orderControllerProvider);
  if (user == null) return const [];
  return orders
      .where(
        (order) =>
            order.trangThai == 'CHO_XU_LY' &&
            order.nhanVienDeXuatId == user.userId,
      )
      .toList()
    ..sort((a, b) => a.ngayThuGom.compareTo(b.ngayThuGom));
});

final adminOrdersProvider = Provider<List<PickupOrder>>((ref) {
  return [...ref.watch(orderControllerProvider)]
    ..sort((a, b) => b.ngayTao.compareTo(a.ngayTao));
});

class OrderController extends StateNotifier<List<PickupOrder>> {
  OrderController({
    required List<PickupOrder> initialOrders,
    required List<StaffProfile> staff,
    required List<CustomerAddress> addresses,
  }) : _staff = staff,
       _addresses = addresses,
       super(initialOrders);

  final List<StaffProfile> _staff;
  final List<CustomerAddress> _addresses;

  PickupOrder createOrder({
    required String khachHangId,
    required String diaChiId,
    required String loaiRacId,
    required double khoiLuongDuKien,
    required DateTime ngayThuGom,
    required String khungGio,
    required String hinhThucTinhPhi,
    required String ghiChu,
  }) {
    final suggestedStaffId = _nextStaffForAddress(
      diaChiId,
      rejectedStaffIds: const [],
    );
    final order = PickupOrder(
      maDon: 'DON_${(state.length + 1).toString().padLeft(3, '0')}',
      khachHangId: khachHangId,
      diaChiId: diaChiId,
      loaiRacId: loaiRacId,
      nhanVienDeXuatId: suggestedStaffId,
      khoiLuongDuKien: khoiLuongDuKien,
      ngayThuGom: ngayThuGom,
      khungGio: khungGio,
      hinhThucTinhPhi: hinhThucTinhPhi,
      trangThai: 'CHO_XU_LY',
      ghiChu: ghiChu,
      ngayTao: DateTime.now(),
    );

    state = [order, ...state];
    return order;
  }

  void assignStaff({required String maDon, required String nhanVienId}) {
    _updateOrder(
      maDon,
      (order) => order.copyWith(
        nhanVienHienTaiId: nhanVienId,
        clearNhanVienDeXuatId: true,
        trangThai: 'CHO_NHAN',
      ),
    );
  }

  void acceptOrder(String maDon) {
    _updateOrder(
      maDon,
      (order) => order.copyWith(
        nhanVienHienTaiId: order.nhanVienHienTaiId ?? order.nhanVienDeXuatId,
        clearNhanVienDeXuatId: true,
        trangThai: 'DA_NHAN',
        gioChot: DateTime.now(),
      ),
    );
  }

  void acceptOffer({required String maDon, required String nhanVienId}) {
    _updateOrder(maDon, (order) {
      if (order.nhanVienDeXuatId != nhanVienId ||
          order.trangThai != 'CHO_XU_LY') {
        return order;
      }
      return order.copyWith(
        nhanVienHienTaiId: nhanVienId,
        clearNhanVienDeXuatId: true,
        trangThai: 'DA_NHAN',
        gioChot: DateTime.now(),
      );
    });
  }

  void rejectOffer({required String maDon, required String nhanVienId}) {
    _updateOrder(maDon, (order) {
      if (order.nhanVienDeXuatId != nhanVienId ||
          order.trangThai != 'CHO_XU_LY') {
        return order;
      }

      final rejected = {...order.nhanVienTuChoiIds, nhanVienId}.toList();
      final nextStaffId = _nextStaffForAddress(
        order.diaChiId,
        rejectedStaffIds: rejected,
      );

      return order.copyWith(
        nhanVienDeXuatId: nextStaffId,
        clearNhanVienDeXuatId: nextStaffId == null,
        nhanVienTuChoiIds: rejected,
      );
    });
  }

  void updateStatus(String maDon, String status) {
    _updateOrder(maDon, (order) => order.copyWith(trangThai: status));
  }

  void completeOrder(String maDon) {
    _updateOrder(maDon, (order) => order.copyWith(trangThai: 'HOAN_THANH'));
  }

  void cancelOrder(String maDon) {
    _updateOrder(maDon, (order) => order.copyWith(trangThai: 'HUY'));
  }

  void _updateOrder(String maDon, PickupOrder Function(PickupOrder) update) {
    state = [
      for (final order in state)
        if (order.maDon == maDon) update(order) else order,
    ];
  }

  String? _nextStaffForAddress(
    String diaChiId, {
    required List<String> rejectedStaffIds,
  }) {
    final address = _findAddress(diaChiId);
    final availableStaff = _staff
        .where(
          (profile) =>
              profile.trangThaiLamViec == 'SAN_SANG' &&
              !rejectedStaffIds.contains(profile.nhanVienId),
        )
        .toList();

    if (availableStaff.isEmpty) return null;
    availableStaff.sort((a, b) {
      final aSameArea = _sameArea(address, a) ? 0 : 1;
      final bSameArea = _sameArea(address, b) ? 0 : 1;
      final areaCompare = aSameArea.compareTo(bSameArea);
      if (areaCompare != 0) return areaCompare;
      return a.doanhThuHienTai.compareTo(b.doanhThuHienTai);
    });

    return availableStaff.first.nhanVienId;
  }

  CustomerAddress? _findAddress(String diaChiId) {
    for (final address in _addresses) {
      if (address.diaChiId == diaChiId) return address;
    }
    return null;
  }

  bool _sameArea(CustomerAddress? address, StaffProfile staff) {
    if (address == null) return false;
    return staff.viTriHienTai.toLowerCase().contains(
      address.quanHuyen.toLowerCase(),
    );
  }
}

class NotificationController extends StateNotifier<List<AppNotification>> {
  NotificationController({
    required FirestoreNotificationService service,
    required String? userId,
    required List<AppNotification> initialNotifications,
  }) : _service = service,
       _userId = userId,
       super([...initialNotifications]);

  final FirestoreNotificationService _service;
  final String? _userId;

  Future<void> initialize() async {
    final userId = _userId;

    if (userId == null) {
      state = const <AppNotification>[];
      return;
    }

    try {
      await _service.seedNotificationsIfEmpty(
        userId: userId,
        initialNotifications: state,
      );

      final remoteNotifications = await _service.getNotifications(userId);

      state = remoteNotifications;
    } catch (error) {
      debugPrint('Không thể tải thông báo từ Firestore: $error');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final index = state.indexWhere(
      (notification) => notification.thongBaoId == notificationId,
    );

    if (index < 0) {
      return;
    }

    if (state[index].trangThaiDoc == 'DA_DOC') {
      return;
    }

    await _service.markAsRead(notificationId);

    state = [
      for (final notification in state)
        if (notification.thongBaoId == notificationId)
          _copyWithReadStatus(notification, 'DA_DOC')
        else
          notification,
    ];
  }

  Future<void> markAllAsRead() async {
    final userId = _userId;

    if (userId == null) {
      return;
    }

    await _service.markAllAsRead(userId);

    state = [
      for (final notification in state)
        if (notification.trangThaiDoc == 'CHUA_DOC')
          _copyWithReadStatus(notification, 'DA_DOC')
        else
          notification,
    ];
  }

  AppNotification _copyWithReadStatus(
    AppNotification notification,
    String readStatus,
  ) {
    return AppNotification(
      thongBaoId: notification.thongBaoId,
      nguoiNhanId: notification.nguoiNhanId,
      maDon: notification.maDon,
      tieuDe: notification.tieuDe,
      noiDung: notification.noiDung,
      trangThaiDoc: readStatus,
      thoiGian: notification.thoiGian,
    );
  }
}

class PackageSubscriptionController
    extends StateNotifier<List<PackageSubscription>> {
  PackageSubscriptionController({
    required List<PackageSubscription> initialSubscriptions,
    required FirestorePackageService service,
  }) : _service = service,
       super([...initialSubscriptions]);

  final FirestorePackageService _service;

  Future<void> loadCustomerSubscription(String customerId) async {
    try {
      final remoteSubscription = await _service.getSubscription(customerId);

      if (remoteSubscription == null) {
        return;
      }

      _replaceCustomerSubscription(remoteSubscription);
    } catch (error) {
      debugPrint('Không thể tải gói tháng từ Firestore: $error');
    }
  }

  Future<void> subscribeOrRenew({
    required String khachHangId,
    required PickupPackage package,
  }) async {
    final now = DateTime.now();

    final month = now.month.toString().padLeft(2, '0');

    final monthYear = '${now.year}-$month';

    final existingIndex = state.indexWhere(
      (item) => item.khachHangId == khachHangId,
    );

    final subscription = PackageSubscription(
      dangKyGoiId: existingIndex >= 0
          ? state[existingIndex].dangKyGoiId
          : 'DKG_$khachHangId',
      khachHangId: khachHangId,
      goiId: package.goiId,
      thangNam: monthYear,
      soKgDaDung: 0,
      soKgConLai: package.hanMucKgThang.toDouble(),
      trangThai: 'CON_HL',
    );

    // Chỉ cập nhật giao diện sau khi ghi Firestore thành công.
    await _service.saveSubscription(subscription);

    _replaceCustomerSubscription(subscription);
  }

  void _replaceCustomerSubscription(PackageSubscription subscription) {
    final index = state.indexWhere(
      (item) => item.khachHangId == subscription.khachHangId,
    );

    if (index < 0) {
      state = [...state, subscription];
      return;
    }

    final updatedSubscriptions = [...state];

    updatedSubscriptions[index] = subscription;

    state = updatedSubscriptions;
  }
}

class CustomerBillingState {
  const CustomerBillingState({
    this.payments = const <PaymentRecord>[],
    this.invoices = const <Invoice>[],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<PaymentRecord> payments;
  final List<Invoice> invoices;
  final bool isLoading;
  final String? errorMessage;
}

class CatalogState {
  const CatalogState({
    this.wasteTypes = const <WasteType>[],
    this.prices = const <PriceItem>[],
    this.packages = const <PickupPackage>[],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<WasteType> wasteTypes;
  final List<PriceItem> prices;
  final List<PickupPackage> packages;
  final bool isLoading;
  final String? errorMessage;
}

class CustomerBillingController extends StateNotifier<CustomerBillingState> {
  CustomerBillingController({
    required FirestoreBillingService service,
    required String? customerId,
    required List<PaymentRecord> initialPayments,
    required List<Invoice> initialInvoices,
  }) : _service = service,
       _customerId = customerId,
       _initialPayments = initialPayments,
       _initialInvoices = initialInvoices,
       super(
         CustomerBillingState(
           payments: initialPayments,
           invoices: initialInvoices,
         ),
       );

  final FirestoreBillingService _service;
  final String? _customerId;
  final List<PaymentRecord> _initialPayments;
  final List<Invoice> _initialInvoices;

  Future<void> initialize() async {
    final customerId = _customerId;

    if (customerId == null) {
      state = const CustomerBillingState();
      return;
    }

    state = CustomerBillingState(
      payments: state.payments,
      invoices: state.invoices,
      isLoading: true,
    );

    try {
      await _service.seedDataIfEmpty(
        customerId: customerId,
        initialPayments: _initialPayments,
        initialInvoices: _initialInvoices,
      );

      final payments = await _service.getPayments(customerId);

      final paymentIds = payments
          .map((payment) => payment.thanhToanId)
          .toList();

      final invoices = await _service.getInvoicesForPayments(paymentIds);

      state = CustomerBillingState(payments: payments, invoices: invoices);
    } catch (error) {
      debugPrint('Không thể tải thanh toán từ Firestore: $error');

      state = CustomerBillingState(
        payments: state.payments,
        invoices: state.invoices,
        errorMessage: 'Không thể tải lịch sử thanh toán',
      );
    }
  }

  Future<void> reload() async {
    await initialize();
  }
}

class CatalogController extends StateNotifier<CatalogState> {
  CatalogController({
    required FirestoreCatalogService service,
    required List<WasteType> initialWasteTypes,
    required List<PriceItem> initialPrices,
    required List<PickupPackage> initialPackages,
  }) : _service = service,
       _initialWasteTypes = initialWasteTypes,
       _initialPrices = initialPrices,
       _initialPackages = initialPackages,
       super(
         CatalogState(
           wasteTypes: initialWasteTypes,
           prices: initialPrices,
           packages: initialPackages,
         ),
       );

  final FirestoreCatalogService _service;
  final List<WasteType> _initialWasteTypes;
  final List<PriceItem> _initialPrices;
  final List<PickupPackage> _initialPackages;

  Future<void> initialize() async {
    state = CatalogState(
      wasteTypes: state.wasteTypes,
      prices: state.prices,
      packages: state.packages,
      isLoading: true,
    );

    try {
      await _service.seedCatalogIfEmpty(
        initialWasteTypes: _initialWasteTypes,
        initialPrices: _initialPrices,
        initialPackages: _initialPackages,
      );

      final wasteTypes = await _service.getWasteTypes();
      final prices = await _service.getPrices();
      final packages = await _service.getPackages();

      state = CatalogState(
        wasteTypes: wasteTypes,
        prices: prices,
        packages: packages,
      );
    } catch (error) {
      debugPrint('Không thể tải danh mục từ Firestore: $error');

      state = CatalogState(
        wasteTypes: state.wasteTypes,
        prices: state.prices,
        packages: state.packages,
        errorMessage: 'Không thể tải loại rác và bảng giá từ Firestore',
      );
    }
  }

  Future<void> reload() async {
    await initialize();
  }
}
