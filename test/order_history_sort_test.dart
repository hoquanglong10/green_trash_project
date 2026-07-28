import 'package:flutter_test/flutter_test.dart';
import 'package:green_trash_project/features/orders/domain/order_history_sort.dart';
import 'package:green_trash_project/models/app_models.dart';

void main() {
  test('staff history sorts by latest completion or cancellation update', () {
    final orders = sortHistoryOrdersNewestFirst([
      _order('DON_OLD', createdAt: DateTime(2026, 7, 1)),
      _order(
        'DON_NEW',
        createdAt: DateTime(2026, 7, 1),
        updatedAt: DateTime(2026, 7, 29, 10),
      ),
      _order(
        'DON_MID',
        createdAt: DateTime(2026, 7, 7),
        updatedAt: DateTime(2026, 7, 29, 8),
      ),
    ]);

    expect(orders.map((order) => order.maDon), [
      'DON_NEW',
      'DON_MID',
      'DON_OLD',
    ]);
  });
}

PickupOrder _order(
  String maDon, {
  required DateTime createdAt,
  DateTime? updatedAt,
}) {
  return PickupOrder(
    maDon: maDon,
    khachHangId: 'CUSTOMER_UID',
    diaChiId: 'DC_01',
    loaiRacId: 'LR_01',
    khoiLuongDuKien: 5,
    ngayThuGom: DateTime(2026, 7, 29),
    khungGio: '08:00-10:00',
    hinhThucTinhPhi: 'THEO_KG',
    trangThai: 'HOAN_THANH',
    ngayTao: createdAt,
    ngayCapNhat: updatedAt,
  );
}
