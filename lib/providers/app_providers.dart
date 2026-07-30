import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/data/firebase_authentication_service.dart';
import '../features/orders/domain/order_history_sort.dart';
import '../features/orders/application/order_workflow_providers.dart';
import '../features/reference_data/application/reference_data_providers.dart';
import '../models/app_models.dart';
import '../repositories/green_trash_repository.dart';
import 'mock_event_controllers.dart';
import 'order_controller.dart';

final greenTrashRepositoryProvider = Provider<GreenTrashRepository>((ref) {
  return MockGreenTrashRepository();
});

final firebaseEnabledProvider = Provider<bool>((ref) {
  try {
    return Firebase.apps.isNotEmpty;
  } catch (_) {
    return false;
  }
});

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firebaseAuthenticationServiceProvider =
    Provider<FirebaseAuthenticationService>((ref) {
      return FirebaseAuthenticationService(
        ref.watch(firebaseAuthProvider),
        ref.watch(firebaseFirestoreProvider),
      );
    });

final currentSessionProvider = StateProvider<AppSession?>((ref) => null);

final usersProvider = Provider<List<AppUser>>((ref) {
  if (ref.watch(firebaseEnabledProvider)) {
    final user = ref.watch(currentUserProvider);
    return user == null ? const [] : [user];
  }
  return ref.watch(greenTrashRepositoryProvider).users;
});

final currentUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(currentSessionProvider)?.user;
});

final staffProfileControllerProvider =
    StateNotifierProvider<StaffProfileController, List<StaffProfile>>((ref) {
      return StaffProfileController(
        ref.watch(greenTrashRepositoryProvider).staff,
      );
    });

final staffProfilesProvider = Provider<List<StaffProfile>>((ref) {
  if (ref.watch(firebaseEnabledProvider)) {
    return ref.watch(firestoreStaffProfilesProvider).valueOrNull ?? const [];
  }
  return ref.watch(staffProfileControllerProvider);
});

final customerAddressControllerProvider =
    StateNotifierProvider<CustomerAddressController, List<CustomerAddress>>((
      ref,
    ) {
      return CustomerAddressController(
        ref.watch(greenTrashRepositoryProvider).addresses,
      );
    });

final customerAddressesProvider = Provider<List<CustomerAddress>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const [];
  if (ref.watch(firebaseEnabledProvider)) {
    return ref
            .watch(firestoreCustomerAddressesProvider(user.userId))
            .valueOrNull ??
        const [];
  }
  final addresses = ref.watch(customerAddressControllerProvider);
  final customerAddresses = addresses
      .where((address) => address.khachHangId == user.userId)
      .toList();
  customerAddresses.sort((first, second) {
    if (first.macDinh != second.macDinh) return first.macDinh ? -1 : 1;
    return first.diaChiChiTiet.compareTo(second.diaChiChiTiet);
  });
  return customerAddresses;
});

final allAddressesProvider = Provider<List<CustomerAddress>>((ref) {
  if (ref.watch(firebaseEnabledProvider)) {
    final user = ref.watch(currentUserProvider);
    if (user?.role == UserRole.customer) {
      return ref.watch(customerAddressesProvider);
    }
    return ref.watch(firestoreAllAddressesProvider).valueOrNull ?? const [];
  }
  return ref.watch(customerAddressControllerProvider);
});

final wasteTypesProvider = Provider<List<WasteType>>((ref) {
  if (ref.watch(firebaseEnabledProvider)) {
    return ref.watch(firestoreWasteTypesProvider).valueOrNull ?? const [];
  }
  return ref.watch(greenTrashRepositoryProvider).wasteTypes;
});

final pricesProvider = Provider<List<PriceItem>>((ref) {
  if (ref.watch(firebaseEnabledProvider)) {
    return ref.watch(firestorePriceItemsProvider).valueOrNull ?? const [];
  }
  return ref.watch(greenTrashRepositoryProvider).prices;
});

final packagesProvider = Provider<List<PickupPackage>>((ref) {
  if (ref.watch(firebaseEnabledProvider)) {
    return ref.watch(firestorePackagesProvider).valueOrNull ?? const [];
  }
  return ref.watch(greenTrashRepositoryProvider).packages;
});

final subscriptionControllerProvider =
    StateNotifierProvider<
      PackageSubscriptionController,
      List<PackageSubscription>
    >((ref) {
      return PackageSubscriptionController(
        ref.watch(greenTrashRepositoryProvider).subscriptions,
      );
    });

final subscriptionsProvider = Provider<List<PackageSubscription>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (ref.watch(firebaseEnabledProvider)) {
    if (user?.role != UserRole.customer) return const [];
    return ref
            .watch(firestoreCustomerSubscriptionsProvider(user!.userId))
            .valueOrNull ??
        const [];
  }
  return ref.watch(subscriptionControllerProvider);
});

final currentSubscriptionProvider = Provider<PackageSubscription?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  for (final subscription in ref.watch(subscriptionsProvider)) {
    if (subscription.khachHangId == user.userId &&
        {'CON_HL', 'CON_HIEU_LUC'}.contains(subscription.trangThai)) {
      return subscription;
    }
  }
  return null;
});

final activityLogControllerProvider =
    StateNotifierProvider<ActivityLogController, List<ActivityLog>>((ref) {
      final repository = ref.watch(greenTrashRepositoryProvider);
      return ActivityLogController(repository.activityLogs);
    });

final activityLogsProvider = Provider<List<ActivityLog>>((ref) {
  return ref.watch(activityLogControllerProvider);
});

final notificationControllerProvider =
    StateNotifierProvider<NotificationController, List<AppNotification>>((ref) {
      final repository = ref.watch(greenTrashRepositoryProvider);
      return NotificationController(repository.notifications);
    });

final notificationsProvider = Provider<List<AppNotification>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const [];
  if (ref.watch(firebaseEnabledProvider)) {
    return ref.watch(firestoreNotificationsProvider(user.userId)).valueOrNull ??
        const [];
  }
  final notifications = ref
      .watch(notificationControllerProvider)
      .where((notification) => notification.nguoiNhanId == user.userId)
      .toList();
  notifications.sort((a, b) => b.thoiGian.compareTo(a.thoiGian));
  return notifications;
});

final collectionRecordControllerProvider =
    StateNotifierProvider<
      CollectionRecordController,
      Map<String, CollectionRecord>
    >((ref) {
      return CollectionRecordController();
    });

final collectionRecordProvider = Provider.family<CollectionRecord?, String>((
  ref,
  maDon,
) {
  if (ref.watch(firebaseEnabledProvider)) {
    return ref.watch(firestoreCollectionRecordProvider(maDon)).valueOrNull;
  }
  return ref.watch(collectionRecordControllerProvider)[maDon];
});

final paymentRecordControllerProvider =
    StateNotifierProvider<PaymentRecordController, Map<String, PaymentRecord>>((
      ref,
    ) {
      return PaymentRecordController();
    });

final paymentRecordProvider = Provider.family<PaymentRecord?, String>((
  ref,
  maDon,
) {
  if (ref.watch(firebaseEnabledProvider)) {
    return ref.watch(firestorePaymentRecordProvider(maDon)).valueOrNull;
  }
  return ref.watch(paymentRecordControllerProvider)[maDon];
});

final orderActivityLogsProvider = Provider.family<List<ActivityLog>, String>((
  ref,
  maDon,
) {
  if (ref.watch(firebaseEnabledProvider)) {
    return ref.watch(firestoreOrderActivityLogsProvider(maDon)).valueOrNull ??
        const [];
  }
  return ref
      .watch(activityLogsProvider)
      .where((log) => log.maDon == maDon)
      .toList(growable: false);
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
        dispatchMode: OrderDispatchMode.targetedOffer,
        addActivityLog: ref.read(activityLogControllerProvider.notifier).add,
        addNotification: ref.read(notificationControllerProvider.notifier).add,
        saveCollectionRecord: ref
            .read(collectionRecordControllerProvider.notifier)
            .save,
        savePaymentRecord: ref
            .read(paymentRecordControllerProvider.notifier)
            .save,
        consumeSubscription:
            ({required String customerId, required double kg}) {
              ref
                  .read(subscriptionControllerProvider.notifier)
                  .consume(customerId: customerId, kg: kg);
            },
        readStaffProfiles: () => ref.read(staffProfileControllerProvider),
        readAddresses: () => ref.read(customerAddressControllerProvider),
        updateStaffStatus: (staffId, status) {
          ref
              .read(staffProfileControllerProvider.notifier)
              .setWorkStatus(staffId, status);
        },
      );
    });

final customerOrdersProvider = Provider<List<PickupOrder>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const [];
  if (ref.watch(firebaseEnabledProvider)) {
    return ref
            .watch(firestoreCustomerOrdersProvider(user.userId))
            .valueOrNull ??
        const [];
  }
  final orders = ref.watch(orderControllerProvider);
  return orders.where((order) => order.khachHangId == user.userId).toList()
    ..sort((a, b) => b.ngayTao.compareTo(a.ngayTao));
});

final staffOrdersProvider = Provider<List<PickupOrder>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const [];
  if (ref.watch(firebaseEnabledProvider)) {
    return ref
            .watch(firestoreStaffOrdersProvider(user.userId))
            .valueOrNull
            ?.where(
              (order) =>
                  order.trangThai != 'HOAN_THANH' && order.trangThai != 'HUY',
            )
            .toList(growable: false) ??
        const [];
  }
  final orders = ref.watch(orderControllerProvider);
  return orders
      .where(
        (order) =>
            order.nhanVienHienTaiId == user.userId &&
            order.trangThai != 'HOAN_THANH' &&
            order.trangThai != 'HUY',
      )
      .toList()
    ..sort((a, b) => a.ngayThuGom.compareTo(b.ngayThuGom));
});

final staffOrderHistoryProvider = Provider<List<PickupOrder>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const [];
  if (ref.watch(firebaseEnabledProvider)) {
    final orders = ref
        .watch(firestoreStaffOrdersProvider(user.userId))
        .valueOrNull;
    if (orders == null) return const [];
    return sortHistoryOrdersNewestFirst(
      orders.where(
        (order) => order.trangThai == 'HOAN_THANH' || order.trangThai == 'HUY',
      ),
    );
  }
  final orders = ref.watch(orderControllerProvider);
  return sortHistoryOrdersNewestFirst(
    orders.where(
      (order) =>
          order.nhanVienHienTaiId == user.userId &&
          (order.trangThai == 'HOAN_THANH' || order.trangThai == 'HUY'),
    ),
  );
});

final staffOfferOrdersProvider = Provider<List<PickupOrder>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const [];
  final activeOrders = ref.watch(staffOrdersProvider);
  StaffProfile? profile;
  for (final item in ref.watch(staffProfilesProvider)) {
    if (item.nhanVienId == user.userId) {
      profile = item;
      break;
    }
  }
  if (activeOrders.isNotEmpty ||
      profile == null ||
      !{'SAN_SANG', 'DANG_RANH'}.contains(profile.trangThaiLamViec)) {
    return const [];
  }
  if (ref.watch(firebaseEnabledProvider)) {
    return ref.watch(firestoreOpenOrdersProvider(user.userId)).valueOrNull ??
        const [];
  }
  final orders = ref.watch(orderControllerProvider);
  return orders
      .where(
        (order) =>
            order.trangThai == 'CHO_XU_LY' &&
            order.nhanVienDeXuatId == user.userId &&
            !order.nhanVienTuChoiIds.contains(user.userId),
      )
      .toList()
    ..sort((a, b) => a.ngayThuGom.compareTo(b.ngayThuGom));
});

final adminOrdersProvider = Provider<List<PickupOrder>>((ref) {
  return [...ref.watch(orderControllerProvider)]
    ..sort((a, b) => b.ngayTao.compareTo(a.ngayTao));
});
