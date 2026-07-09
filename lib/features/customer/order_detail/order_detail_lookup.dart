import '../../../models/app_models.dart';

PickupOrder? findOrder(List<PickupOrder> orders, String id) {
  for (final order in orders) {
    if (order.maDon == id) return order;
  }
  return null;
}

CustomerAddress? findAddress(List<CustomerAddress> addresses, String id) {
  for (final address in addresses) {
    if (address.diaChiId == id) return address;
  }
  return null;
}

WasteType? findWaste(List<WasteType> wastes, String id) {
  for (final waste in wastes) {
    if (waste.loaiRacId == id) return waste;
  }
  return null;
}

StaffProfile? findStaff(List<StaffProfile> staff, String? id) {
  if (id == null) return null;
  for (final profile in staff) {
    if (profile.nhanVienId == id) return profile;
  }
  return null;
}
