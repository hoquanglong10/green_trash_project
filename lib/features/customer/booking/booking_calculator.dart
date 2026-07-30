import '../../../core/utils/formatters.dart';
import '../../../models/app_models.dart';
import '../../orders/domain/staff_dispatch_ranker.dart';

class BookingEstimate {
  const BookingEstimate({
    required this.label,
    required this.canSubmit,
    required this.suggestedStaff,
  });

  final String label;
  final bool canSubmit;
  final StaffProfile? suggestedStaff;
}

class BookingValidation {
  const BookingValidation._(this.message);

  const BookingValidation.valid() : this._(null);

  const BookingValidation.invalid(String message) : this._(message);

  final String? message;

  bool get canSubmit => message == null;
}

DateTime defaultBookingDate(DateTime now, List<String> timeSlots) {
  final today = DateTime(now.year, now.month, now.day);
  if (availableTimeSlots(
    date: today,
    timeSlots: timeSlots,
    now: now,
  ).isNotEmpty) {
    return today;
  }
  return today.add(const Duration(days: 1));
}

List<String> availableTimeSlots({
  required DateTime date,
  required List<String> timeSlots,
  required DateTime now,
  Duration leadTime = const Duration(minutes: 30),
}) {
  final today = DateTime(now.year, now.month, now.day);
  final selectedDay = DateTime(date.year, date.month, date.day);
  if (selectedDay.isBefore(today)) return const [];
  if (selectedDay.isAfter(today)) return List.unmodifiable(timeSlots);

  final earliest = now.add(leadTime);
  return [
    for (final slot in timeSlots)
      if (_slotStart(date, slot) case final start?)
        if (!start.isBefore(earliest)) slot,
  ];
}

BookingValidation validateBooking({
  required CustomerAddress? address,
  required WasteType? waste,
  required double? kg,
  required DateTime pickupDate,
  required String? timeSlot,
  required List<String> availableSlots,
  required String paymentMethod,
  required PackageSubscription? subscription,
  required PickupPackage? package,
  required List<PickupOrder> customerOrders,
  required DateTime now,
}) {
  if (address == null) {
    return const BookingValidation.invalid('Vui lòng chọn địa chỉ lấy rác.');
  }
  if (!address.hasPickupCoordinate) {
    return const BookingValidation.invalid(
      'Địa chỉ chưa có điểm bản đồ. Vui lòng cập nhật trong sổ địa chỉ.',
    );
  }
  if (waste == null) {
    return const BookingValidation.invalid('Vui lòng chọn loại rác.');
  }
  if (kg == null || kg <= 0) {
    return const BookingValidation.invalid(
      'Khối lượng dự kiến phải lớn hơn 0 kg.',
    );
  }
  if (kg > 500) {
    return const BookingValidation.invalid(
      'Đơn trên 500 kg cần liên hệ bộ phận hỗ trợ.',
    );
  }
  final today = DateTime(now.year, now.month, now.day);
  final selectedDay = DateTime(
    pickupDate.year,
    pickupDate.month,
    pickupDate.day,
  );
  if (selectedDay.isBefore(today)) {
    return const BookingValidation.invalid(
      'Ngày thu gom không thể nằm trong quá khứ.',
    );
  }
  if (timeSlot == null || !availableSlots.contains(timeSlot)) {
    return const BookingValidation.invalid(
      'Vui lòng chọn một khung giờ còn nhận đơn.',
    );
  }
  if (paymentMethod == 'GOI_THANG' &&
      (subscription == null ||
          subscription.trangThai != 'CON_HL' ||
          package == null)) {
    return const BookingValidation.invalid(
      'Gói tháng hiện không còn hiệu lực. Vui lòng chọn tính phí theo kg.',
    );
  }

  for (final order in customerOrders) {
    if (order.trangThai == 'HOAN_THANH' ||
        order.trangThai == 'HUY' ||
        !_sameDay(order.ngayThuGom, pickupDate)) {
      continue;
    }
    if (_slotsOverlap(order.khungGio, timeSlot)) {
      return BookingValidation.invalid(
        'Bạn đã có ${order.maDon} trùng khung giờ này.',
      );
    }
  }
  return const BookingValidation.valid();
}

String estimatePaymentLabel({
  required String paymentMethod,
  required PriceItem? price,
  required double? kg,
  required PackageSubscription? subscription,
  required PickupPackage? package,
}) {
  if (kg == null) return 'Nhập khối lượng';

  if (paymentMethod == 'GOI_THANG') {
    final remaining = subscription?.soKgConLai ?? package?.hanMucKgThang;
    if (remaining == null) return 'Dùng gói tháng';
    if (kg <= remaining) return 'Trừ ${formatKg(kg)} trong gói';

    final overKg = kg - remaining;
    final overPrice = package?.phiVuotGoi ?? price?.donGiaKg ?? 0;
    return 'Vượt ${formatKg(overKg)} • ${formatMoney(overKg * overPrice)}';
  }

  if (price == null) return 'Chưa có giá';
  return formatMoney(price.donGiaKg * kg);
}

num calculatePaymentAmount({
  required String paymentMethod,
  required PriceItem? price,
  required double kg,
  required PackageSubscription? subscription,
  required PickupPackage? package,
}) {
  if (paymentMethod != 'GOI_THANG') {
    return (price?.donGiaKg ?? 0) * kg;
  }

  final remaining = subscription?.soKgConLai ?? package?.hanMucKgThang ?? 0;
  final overKg = kg > remaining ? kg - remaining : 0;
  final overPrice = package?.phiVuotGoi ?? price?.donGiaKg ?? 0;
  return overKg * overPrice;
}

StaffProfile? suggestedStaffForAddress({
  required List<StaffProfile> staff,
  required CustomerAddress? address,
}) {
  final available = staff
      .where((profile) => profile.trangThaiLamViec == 'SAN_SANG')
      .toList();
  if (available.isEmpty) return null;

  available.sort((a, b) => compareStaffForPickup(a, b, address));

  return available.first;
}

CustomerAddress? findAddress(List<CustomerAddress> addresses, String? id) {
  for (final address in addresses) {
    if (address.diaChiId == id) return address;
  }
  return null;
}

WasteType? findWaste(List<WasteType> wastes, String? id) {
  for (final waste in wastes) {
    if (waste.loaiRacId == id) return waste;
  }
  return null;
}

PriceItem? findPrice(List<PriceItem> prices, String? loaiRacId) {
  for (final price in prices) {
    if (price.loaiRacId == loaiRacId) return price;
  }
  return null;
}

DateTime? _slotStart(DateTime date, String slot) {
  final range = _slotMinutes(slot);
  if (range == null) return null;
  return DateTime(
    date.year,
    date.month,
    date.day,
    range.$1 ~/ 60,
    range.$1 % 60,
  );
}

bool _slotsOverlap(String first, String second) {
  final firstRange = _slotMinutes(first);
  final secondRange = _slotMinutes(second);
  if (firstRange == null || secondRange == null) return true;
  return firstRange.$1 < secondRange.$2 && secondRange.$1 < firstRange.$2;
}

(int, int)? _slotMinutes(String slot) {
  final limits = slot.split('-');
  if (limits.length != 2) return null;
  final start = _minutes(limits.first);
  final end = _minutes(limits.last);
  if (start == null || end == null || start >= end) return null;
  return (start, end);
}

int? _minutes(String value) {
  final parts = value.trim().split(':');
  if (parts.length != 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  return hour * 60 + minute;
}

bool _sameDay(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}
