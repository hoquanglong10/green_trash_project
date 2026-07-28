import 'package:flutter_test/flutter_test.dart';
import 'package:green_trash_project/models/app_models.dart';
import 'package:green_trash_project/providers/mock_event_controllers.dart';

void main() {
  test('monthly package usage is updated and never becomes negative', () {
    final controller = PackageSubscriptionController(const [
      PackageSubscription(
        dangKyGoiId: 'DKG_001',
        khachHangId: 'USER_KH_001',
        goiId: 'GOI_126',
        thangNam: '2026-07',
        soKgDaDung: 120,
        soKgConLai: 6,
        trangThai: 'CON_HL',
      ),
    ]);

    controller.consume(customerId: 'USER_KH_001', kg: 8.5);

    expect(controller.state.single.soKgDaDung, 128.5);
    expect(controller.state.single.soKgConLai, 0);
  });

  test('pending payment can be confirmed by the customer', () {
    final controller = PaymentRecordController();
    controller.save(
      PaymentRecord(
        thanhToanId: 'TT_DON_001',
        maDon: 'DON_001',
        khachHangId: 'USER_KH_001',
        soTien: 25000,
        phuongThuc: 'CHUYEN_KHOAN',
        trangThai: 'CHO_THANH_TOAN',
        thoiGianTao: DateTime(2026, 7, 27, 10),
      ),
    );

    controller.markPaid('DON_001', paidAt: DateTime(2026, 7, 27, 10, 5));

    expect(controller.state['DON_001']?.trangThai, 'DA_THANH_TOAN');
    expect(
      controller.state['DON_001']?.thoiGianThanhToan,
      DateTime(2026, 7, 27, 10, 5),
    );
  });
}
