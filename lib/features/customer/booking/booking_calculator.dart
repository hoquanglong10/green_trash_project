import '../../../core/utils/formatters.dart';
import '../../../models/app_models.dart';

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

StaffProfile? suggestedStaffForAddress({
  required List<StaffProfile> staff,
  required CustomerAddress? address,
}) {
  final available = staff
      .where((profile) => profile.trangThaiLamViec == 'SAN_SANG')
      .toList();
  if (available.isEmpty) return null;

  available.sort((a, b) {
    final aSameArea = _sameArea(address, a) ? 0 : 1;
    final bSameArea = _sameArea(address, b) ? 0 : 1;
    final areaCompare = aSameArea.compareTo(bSameArea);
    if (areaCompare != 0) return areaCompare;
    return a.doanhThuHienTai.compareTo(b.doanhThuHienTai);
  });

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

bool _sameArea(CustomerAddress? address, StaffProfile staff) {
  if (address == null) return false;
  return staff.viTriHienTai.toLowerCase().contains(
    address.quanHuyen.toLowerCase(),
  );
}
