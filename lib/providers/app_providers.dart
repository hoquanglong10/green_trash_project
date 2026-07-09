import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_models.dart';
import '../repositories/green_trash_repository.dart';

final greenTrashRepositoryProvider = Provider<GreenTrashRepository>((ref) {
  return MockGreenTrashRepository();
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

final wasteTypesProvider = Provider<List<WasteType>>((ref) {
  return ref.watch(greenTrashRepositoryProvider).wasteTypes;
});

final pricesProvider = Provider<List<PriceItem>>((ref) {
  return ref.watch(greenTrashRepositoryProvider).prices;
});

final packagesProvider = Provider<List<PickupPackage>>((ref) {
  return ref.watch(greenTrashRepositoryProvider).packages;
});

final subscriptionsProvider = Provider<List<PackageSubscription>>((ref) {
  return ref.watch(greenTrashRepositoryProvider).subscriptions;
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

final notificationsProvider = Provider<List<AppNotification>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const [];
  return ref
      .watch(greenTrashRepositoryProvider)
      .notifications
      .where((notification) => notification.nguoiNhanId == user.userId)
      .toList();
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
