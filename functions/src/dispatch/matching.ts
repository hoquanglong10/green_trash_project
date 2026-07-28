import {Timestamp} from "firebase-admin/firestore";

export interface Coordinates {
  latitude: number;
  longitude: number;
}

export interface MatchableOrder {
  maDon: string;
  ngayThuGom: Timestamp;
  khungGio: string;
  diaChiId: string;
}

export interface MatchableStaff {
  nhanVienId: string;
  gioBatDau: string;
  gioKetThuc: string;
  doanhThuHienTai?: number;
  viTriHienTai?: string;
  toaDoLat?: number;
  toaDoLng?: number;
  phanCongDangChoId?: string;
}

export interface MatchableAddress {
  quanHuyen?: string;
  toaDoLat?: number;
  toaDoLng?: number;
}

export interface ActiveOrder {
  maDon: string;
  nhanVienHienTaiId?: string;
  ngayThuGom: Timestamp;
  khungGio: string;
}

export function rankStaff(
  order: MatchableOrder,
  address: MatchableAddress,
  staff: MatchableStaff[],
  activeOrders: ActiveOrder[],
  excludedStaffIds: Set<string>,
): MatchableStaff[] {
  const pickupRange = parseTimeSlot(order.khungGio);
  if (!pickupRange) return [];

  return staff
    .filter((candidate) => {
      if (
        excludedStaffIds.has(candidate.nhanVienId) ||
        candidate.phanCongDangChoId
      ) {
        return false;
      }
      if (!isInsideWorkingHours(candidate, pickupRange)) return false;
      return !hasScheduleConflict(candidate, order, activeOrders, pickupRange);
    })
    .sort((first, second) => {
      const firstDistance = distanceToAddress(address, first);
      const secondDistance = distanceToAddress(address, second);
      if (firstDistance !== secondDistance) {
        return firstDistance - secondDistance;
      }

      const firstSameArea = isSameArea(address, first) ? 0 : 1;
      const secondSameArea = isSameArea(address, second) ? 0 : 1;
      if (firstSameArea !== secondSameArea) {
        return firstSameArea - secondSameArea;
      }

      return (
        (first.doanhThuHienTai ?? 0) - (second.doanhThuHienTai ?? 0)
      );
    });
}

export function haversineDistanceKm(
  first: Coordinates,
  second: Coordinates,
): number {
  const earthRadiusKm = 6371;
  const latitudeDelta = degreesToRadians(
    second.latitude - first.latitude,
  );
  const longitudeDelta = degreesToRadians(
    second.longitude - first.longitude,
  );
  const firstLatitude = degreesToRadians(first.latitude);
  const secondLatitude = degreesToRadians(second.latitude);
  const a =
    Math.sin(latitudeDelta / 2) ** 2 +
    Math.cos(firstLatitude) *
      Math.cos(secondLatitude) *
      Math.sin(longitudeDelta / 2) ** 2;
  return earthRadiusKm * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

export function parseTimeSlot(
  value: string,
): {start: number; end: number} | null {
  const parts = value.split("-");
  if (parts.length !== 2) return null;
  const start = parseMinutes(parts[0]);
  const end = parseMinutes(parts[1]);
  if (start === null || end === null || start >= end) return null;
  return {start, end};
}

function parseMinutes(value: string): number | null {
  const parts = value.trim().split(":");
  if (parts.length === 1) {
    const hour = Number(parts[0]);
    return Number.isInteger(hour) && hour >= 0 && hour <= 23 ?
      hour * 60 :
      null;
  }
  if (parts.length !== 2) return null;
  const hour = Number(parts[0]);
  const minute = Number(parts[1]);
  if (
    !Number.isInteger(hour) ||
    !Number.isInteger(minute) ||
    hour < 0 ||
    hour > 23 ||
    minute < 0 ||
    minute > 59
  ) {
    return null;
  }
  return hour * 60 + minute;
}

function isInsideWorkingHours(
  staff: MatchableStaff,
  pickupRange: {start: number; end: number},
): boolean {
  const start = parseMinutes(staff.gioBatDau);
  const end = parseMinutes(staff.gioKetThuc);
  return (
    start !== null &&
    end !== null &&
    pickupRange.start >= start &&
    pickupRange.end <= end
  );
}

function hasScheduleConflict(
  staff: MatchableStaff,
  order: MatchableOrder,
  activeOrders: ActiveOrder[],
  pickupRange: {start: number; end: number},
): boolean {
  return activeOrders.some((activeOrder) => {
    if (
      activeOrder.maDon === order.maDon ||
      activeOrder.nhanVienHienTaiId !== staff.nhanVienId ||
      !isSameDay(activeOrder.ngayThuGom, order.ngayThuGom)
    ) {
      return false;
    }
    const activeRange = parseTimeSlot(activeOrder.khungGio);
    return (
      activeRange !== null &&
      pickupRange.start < activeRange.end &&
      activeRange.start < pickupRange.end
    );
  });
}

function isSameDay(first: Timestamp, second: Timestamp): boolean {
  const firstDate = first.toDate();
  const secondDate = second.toDate();
  return (
    firstDate.getFullYear() === secondDate.getFullYear() &&
    firstDate.getMonth() === secondDate.getMonth() &&
    firstDate.getDate() === secondDate.getDate()
  );
}

function distanceToAddress(
  address: MatchableAddress,
  staff: MatchableStaff,
): number {
  const addressCoordinates = coordinatesOf(
    address.toaDoLat,
    address.toaDoLng,
  );
  const staffCoordinates = coordinatesOf(staff.toaDoLat, staff.toaDoLng);
  if (!addressCoordinates || !staffCoordinates) {
    return Number.POSITIVE_INFINITY;
  }
  return haversineDistanceKm(addressCoordinates, staffCoordinates);
}

function coordinatesOf(
  latitude: number | undefined,
  longitude: number | undefined,
): Coordinates | null {
  if (
    typeof latitude !== "number" ||
    typeof longitude !== "number" ||
    latitude < -90 ||
    latitude > 90 ||
    longitude < -180 ||
    longitude > 180
  ) {
    return null;
  }
  return {latitude, longitude};
}

function isSameArea(
  address: MatchableAddress,
  staff: MatchableStaff,
): boolean {
  const district = address.quanHuyen?.trim().toLocaleLowerCase("vi");
  const location = staff.viTriHienTai?.trim().toLocaleLowerCase("vi");
  return Boolean(district && location?.includes(district));
}

function degreesToRadians(value: number): number {
  return value * (Math.PI / 180);
}
