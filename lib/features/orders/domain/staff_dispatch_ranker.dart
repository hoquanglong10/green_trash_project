import 'dart:math' as math;

import '../../../models/app_models.dart';

const _earthRadiusMeters = 6371000.0;

double? pickupDistanceMeters({
  required CustomerAddress? address,
  required StaffProfile staff,
}) {
  if (address == null ||
      !_isUsableCoordinate(address.toaDoLat, address.toaDoLng) ||
      !staff.hasLiveLocation ||
      !_isUsableCoordinate(staff.toaDoLat!, staff.toaDoLng!)) {
    return null;
  }
  return geoDistanceMeters(
    firstLatitude: address.toaDoLat,
    firstLongitude: address.toaDoLng,
    secondLatitude: staff.toaDoLat!,
    secondLongitude: staff.toaDoLng!,
  );
}

double geoDistanceMeters({
  required double firstLatitude,
  required double firstLongitude,
  required double secondLatitude,
  required double secondLongitude,
}) {
  final lat1 = _radians(firstLatitude);
  final lat2 = _radians(secondLatitude);
  final deltaLat = _radians(secondLatitude - firstLatitude);
  final deltaLng = _radians(secondLongitude - firstLongitude);
  final value =
      math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
      math.cos(lat1) *
          math.cos(lat2) *
          math.sin(deltaLng / 2) *
          math.sin(deltaLng / 2);
  final arc = 2 * math.atan2(math.sqrt(value), math.sqrt(1 - value));
  return _earthRadiusMeters * arc;
}

int compareStaffForPickup(
  StaffProfile first,
  StaffProfile second,
  CustomerAddress? address,
) {
  final firstDistance = pickupDistanceMeters(address: address, staff: first);
  final secondDistance = pickupDistanceMeters(address: address, staff: second);

  if (firstDistance != null && secondDistance != null) {
    final distanceCompare = firstDistance.compareTo(secondDistance);
    if (distanceCompare != 0) return distanceCompare;
  } else if (firstDistance != null) {
    return -1;
  } else if (secondDistance != null) {
    return 1;
  }

  final firstSameArea = _sameArea(address, first) ? 0 : 1;
  final secondSameArea = _sameArea(address, second) ? 0 : 1;
  final areaCompare = firstSameArea.compareTo(secondSameArea);
  if (areaCompare != 0) return areaCompare;

  final revenueCompare = first.doanhThuHienTai.compareTo(
    second.doanhThuHienTai,
  );
  if (revenueCompare != 0) return revenueCompare;
  return first.nhanVienId.compareTo(second.nhanVienId);
}

bool _sameArea(CustomerAddress? address, StaffProfile staff) {
  if (address == null) return false;
  return staff.viTriHienTai.toLowerCase().contains(
    address.quanHuyen.toLowerCase(),
  );
}

bool _isUsableCoordinate(double latitude, double longitude) {
  return latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180 &&
      (latitude != 0 || longitude != 0);
}

double _radians(double value) => value * math.pi / 180;
