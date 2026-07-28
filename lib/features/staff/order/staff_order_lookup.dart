import '../../../models/app_models.dart';

PickupOrder? findStaffOrder(List<PickupOrder> orders, String id) {
  for (final order in orders) {
    if (order.maDon == id) return order;
  }
  return null;
}

CustomerAddress? findOrderAddress(List<CustomerAddress> addresses, String id) {
  for (final address in addresses) {
    if (address.diaChiId == id) return address;
  }
  return null;
}

WasteType? findOrderWaste(List<WasteType> wastes, String? id) {
  if (id == null) return null;
  for (final waste in wastes) {
    if (waste.loaiRacId == id) return waste;
  }
  return null;
}

AppUser? findOrderCustomer(List<AppUser> users, String id) {
  for (final user in users) {
    if (user.userId == id) return user;
  }
  return null;
}

StaffProfile? findOrderStaff(List<StaffProfile> staff, String? id) {
  if (id == null) return null;
  for (final profile in staff) {
    if (profile.nhanVienId == id) return profile;
  }
  return null;
}
