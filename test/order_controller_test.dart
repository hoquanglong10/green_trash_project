import 'package:flutter_test/flutter_test.dart';
import 'package:green_trash_project/models/app_models.dart';
import 'package:green_trash_project/providers/order_controller.dart';
import 'package:green_trash_project/repositories/green_trash_repository.dart';

void main() {
  test('staff order follows the documented flow and saves BM02 data', () {
    final repository = MockGreenTrashRepository();
    final logs = <ActivityLog>[];
    final notifications = <AppNotification>[];
    final records = <CollectionRecord>[];
    final payments = <PaymentRecord>[];
    final packageUsage = <double>[];
    final controller = OrderController(
      initialOrders: repository.initialOrders,
      staff: repository.staff,
      addresses: repository.addresses,
      addActivityLog: logs.add,
      addNotification: notifications.add,
      saveCollectionRecord: records.add,
      savePaymentRecord: payments.add,
      consumeSubscription: ({required String customerId, required double kg}) {
        expect(customerId, 'USER_KH_001');
        packageUsage.add(kg);
      },
    );

    expect(
      controller.updateStatus(
        maDon: 'DON_002',
        nhanVienId: 'USER_NV_001',
        status: 'DA_DEN',
      ),
      isFalse,
      reason: 'A pending offer cannot skip directly to arrived.',
    );

    final arrival = DateTime(2026, 7, 9, 10, 30);
    expect(
      controller.acceptOffer(
        maDon: 'DON_002',
        nhanVienId: 'USER_NV_001',
        gioChot: arrival,
      ),
      isTrue,
    );
    expect(_order(controller, 'DON_002').trangThai, 'DA_NHAN');
    expect(_order(controller, 'DON_002').gioChot, arrival);

    for (final status in ['DANG_DEN', 'DA_DEN', 'DANG_CAN_RAC']) {
      expect(
        controller.updateStatus(
          maDon: 'DON_002',
          nhanVienId: 'USER_NV_001',
          status: status,
        ),
        isTrue,
      );
    }

    final record = CollectionRecord(
      bienBanId: 'BB_DON_002',
      maDon: 'DON_002',
      nhanVienId: 'USER_NV_001',
      loaiRacThucTeId: 'LR_HUU_CO',
      khoiLuongThucTe: 5.2,
      anhXacNhanUrl: 'mock://evidence/DON_002.jpg',
      phiPhaiTra: 15600,
      trangThaiThanhToan: 'CHO_THANH_TOAN',
      thoiGianLap: DateTime(2026, 7, 9, 10, 50),
    );
    final payment = PaymentRecord(
      thanhToanId: 'TT_DON_002',
      maDon: 'DON_002',
      khachHangId: 'USER_KH_001',
      soTien: 15600,
      phuongThuc: 'TIEN_MAT',
      trangThai: 'CHO_THANH_TOAN',
      thoiGianTao: DateTime(2026, 7, 9, 10, 50),
    );
    expect(
      controller.completeOrder(
        maDon: 'DON_002',
        nhanVienId: 'USER_NV_001',
        record: record,
        payment: payment,
      ),
      isTrue,
    );
    expect(_order(controller, 'DON_002').trangThai, 'HOAN_THANH');
    expect(records.single, same(record));
    expect(payments.single, same(payment));
    expect(packageUsage, isEmpty);
    expect(logs.map((log) => log.hanhDong), contains('Hoàn thành thu gom'));
    expect(
      notifications.map((notification) => notification.tieuDe),
      contains('Đơn đã hoàn thành'),
    );
  });

  test('rejecting an offer requires a reason', () {
    final repository = MockGreenTrashRepository();
    final controller = OrderController(
      initialOrders: repository.initialOrders,
      staff: repository.staff,
      addresses: repository.addresses,
      addActivityLog: (_) {},
      addNotification: (_) {},
      saveCollectionRecord: (_) {},
    );

    expect(
      controller.rejectOffer(
        maDon: 'DON_002',
        nhanVienId: 'USER_NV_001',
        reason: '   ',
      ),
      isFalse,
    );
    expect(_order(controller, 'DON_002').nhanVienDeXuatId, 'USER_NV_001');
  });

  test('open queue hides dismissed orders and lets another staff claim', () {
    final repository = MockGreenTrashRepository();
    final controller = OrderController(
      initialOrders: repository.initialOrders,
      staff: repository.staff,
      addresses: repository.addresses,
      dispatchMode: OrderDispatchMode.openQueue,
      addActivityLog: (_) {},
      addNotification: (_) {},
      saveCollectionRecord: (_) {},
    );

    expect(_order(controller, 'DON_002').nhanVienDeXuatId, isNull);
    expect(
      controller.rejectOffer(
        maDon: 'DON_002',
        nhanVienId: 'USER_NV_001',
        reason: 'Ngoài khu vực phụ trách',
      ),
      isTrue,
    );
    expect(
      _order(controller, 'DON_002').nhanVienTuChoiIds,
      contains('USER_NV_001'),
    );
    expect(
      controller.acceptOffer(
        maDon: 'DON_002',
        nhanVienId: 'USER_NV_001',
        gioChot: DateTime(2026, 7, 9, 10, 30),
      ),
      isFalse,
    );
    expect(
      controller.acceptOffer(
        maDon: 'DON_002',
        nhanVienId: 'USER_NV_002',
        gioChot: DateTime(2026, 7, 9, 10, 30),
      ),
      isTrue,
    );
    expect(_order(controller, 'DON_002').nhanVienHienTaiId, 'USER_NV_002');
  });

  test('expired offers move to the next staff then to support queue', () {
    final repository = MockGreenTrashRepository();
    final notifications = <AppNotification>[];
    final controller = OrderController(
      initialOrders: repository.initialOrders,
      staff: repository.staff,
      addresses: repository.addresses,
      addActivityLog: (_) {},
      addNotification: notifications.add,
      saveCollectionRecord: (_) {},
    );

    final firstOffer = _order(controller, 'DON_002');
    expect(
      controller.expireOffer(
        maDon: firstOffer.maDon,
        nhanVienId: 'USER_NV_001',
        now: firstOffer.offerExpiresAt!.add(const Duration(seconds: 1)),
      ),
      isTrue,
    );
    final secondOffer = _order(controller, 'DON_002');
    expect(secondOffer.nhanVienDeXuatId, 'USER_NV_002');
    expect(secondOffer.offerAttempt, 2);
    expect(secondOffer.nhanVienTuChoiIds, contains('USER_NV_001'));

    expect(
      controller.expireOffer(
        maDon: secondOffer.maDon,
        nhanVienId: 'USER_NV_002',
        now: secondOffer.offerExpiresAt!.add(const Duration(seconds: 1)),
      ),
      isTrue,
    );
    final supportOrder = _order(controller, 'DON_002');
    expect(supportOrder.nhanVienDeXuatId, isNull);
    expect(supportOrder.waitingForSupport, isTrue);
    expect(
      notifications.map((item) => item.tieuDe),
      contains('Đơn đang chờ hỗ trợ'),
    );
  });

  test('dispatcher skips staff whose accepted order overlaps the slot', () {
    final repository = MockGreenTrashRepository();
    final controller = OrderController(
      initialOrders: repository.initialOrders,
      staff: repository.staff,
      addresses: repository.addresses,
      addActivityLog: (_) {},
      addNotification: (_) {},
      saveCollectionRecord: (_) {},
    );

    final order = controller.createOrder(
      khachHangId: 'USER_KH_001',
      diaChiId: 'DC_001',
      loaiRacId: 'LR_HUU_CO',
      khoiLuongDuKien: 4,
      ngayThuGom: DateTime(2026, 7, 8),
      khungGio: '08:00-10:00',
      hinhThucTinhPhi: 'THEO_KG',
      ghiChu: '',
    );

    expect(order.nhanVienDeXuatId, 'USER_NV_002');
  });

  test('customer can cancel after acceptance while staff is travelling', () {
    final repository = MockGreenTrashRepository();
    final controller = OrderController(
      initialOrders: repository.initialOrders,
      staff: repository.staff,
      addresses: repository.addresses,
      addActivityLog: (_) {},
      addNotification: (_) {},
      saveCollectionRecord: (_) {},
    );

    expect(
      controller.acceptOffer(
        maDon: 'DON_002',
        nhanVienId: 'USER_NV_001',
        gioChot: DateTime(2026, 7, 9, 10, 30),
      ),
      isTrue,
    );
    expect(
      controller.updateStatus(
        maDon: 'DON_002',
        nhanVienId: 'USER_NV_001',
        status: 'DANG_DEN',
      ),
      isTrue,
    );
    expect(
      controller.cancelOrder(
        maDon: 'DON_002',
        actorId: 'USER_KH_001',
        reason: 'Muốn đổi lịch thu gom',
      ),
      isTrue,
    );
    expect(_order(controller, 'DON_002').trangThai, 'HUY');
  });
}

PickupOrder _order(OrderController controller, String id) {
  return controller.state.firstWhere((order) => order.maDon == id);
}
