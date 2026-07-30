import 'package:flutter_test/flutter_test.dart';
import 'package:green_trash_project/features/customer/booking/booking_calculator.dart';
import 'package:green_trash_project/models/app_models.dart';
import 'package:green_trash_project/repositories/green_trash_repository.dart';

void main() {
  test('same-day booking only exposes slots with enough preparation time', () {
    final slots = availableTimeSlots(
      date: DateTime(2026, 7, 27),
      timeSlots: const ['10:00-12:00', '13:00-15:00', '15:00-17:00'],
      now: DateTime(2026, 7, 27, 13, 10),
    );

    expect(slots, ['15:00-17:00']);
  });

  test('default booking date moves to tomorrow after the last slot', () {
    final date = defaultBookingDate(DateTime(2026, 7, 27, 16, 45), const [
      '06:00-08:00',
      '15:00-17:00',
    ]);

    expect(date, DateTime(2026, 7, 28));
  });

  test('booking validation blocks an overlapping active customer order', () {
    final repository = MockGreenTrashRepository();
    final validation = validateBooking(
      address: repository.addresses.first,
      waste: repository.wasteTypes.first,
      kg: 5,
      pickupDate: DateTime(2026, 7, 8),
      timeSlot: '08:00-10:00',
      availableSlots: const ['08:00-10:00'],
      paymentMethod: 'THEO_KG',
      subscription: repository.subscriptions.first,
      package: repository.packages.first,
      customerOrders: repository.initialOrders,
      now: DateTime(2026, 7, 8, 6),
    );

    expect(validation.canSubmit, isFalse);
    expect(validation.message, contains('DON_001'));
  });

  test('booking validation rejects an inactive monthly package', () {
    final repository = MockGreenTrashRepository();
    final validation = validateBooking(
      address: repository.addresses.first,
      waste: repository.wasteTypes.first,
      kg: 5,
      pickupDate: DateTime(2026, 7, 10),
      timeSlot: '10:00-12:00',
      availableSlots: const ['10:00-12:00'],
      paymentMethod: 'GOI_THANG',
      subscription: null,
      package: repository.packages.first,
      customerOrders: const [],
      now: DateTime(2026, 7, 8, 6),
    );

    expect(validation.canSubmit, isFalse);
    expect(validation.message, contains('không còn hiệu lực'));
  });

  test('booking validation requires a confirmed pickup map point', () {
    final repository = MockGreenTrashRepository();
    const addressWithoutMapPoint = CustomerAddress(
      diaChiId: 'DIA_CHI_LEGACY',
      khachHangId: 'USER_KH_001',
      diaChiChiTiet: '99 Quang Trung',
      phuongXa: 'Phường 10',
      quanHuyen: 'Gò Vấp',
      tinhThanh: 'TP. Hồ Chí Minh',
      toaDoLat: 0,
      toaDoLng: 0,
      macDinh: true,
    );

    final validation = validateBooking(
      address: addressWithoutMapPoint,
      waste: repository.wasteTypes.first,
      kg: 5,
      pickupDate: DateTime(2026, 7, 30),
      timeSlot: '10:00-12:00',
      availableSlots: const ['10:00-12:00'],
      paymentMethod: 'THEO_KG',
      subscription: repository.subscriptions.first,
      package: repository.packages.first,
      customerOrders: const [],
      now: DateTime(2026, 7, 30, 6),
    );

    expect(validation.canSubmit, isFalse);
    expect(validation.message, contains('điểm bản đồ'));
  });
}
