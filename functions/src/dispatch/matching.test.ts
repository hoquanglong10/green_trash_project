import assert from "node:assert/strict";
import test from "node:test";
import {Timestamp} from "firebase-admin/firestore";
import {
  haversineDistanceKm,
  parseTimeSlot,
  rankStaff,
} from "./matching";

test("haversine distance is zero for the same point", () => {
  const distance = haversineDistanceKm(
    {latitude: 10.8, longitude: 106.7},
    {latitude: 10.8, longitude: 106.7},
  );
  assert.equal(distance, 0);
});

test("time slots support canonical and audited short formats", () => {
  assert.deepEqual(parseTimeSlot("08:00-10:00"), {start: 480, end: 600});
  assert.deepEqual(parseTimeSlot("08-10"), {start: 480, end: 600});
  assert.equal(parseTimeSlot("10:00-08:00"), null);
});

test("ranking prefers the nearest eligible staff member", () => {
  const date = Timestamp.fromDate(new Date(2026, 6, 30, 8));
  const ranked = rankStaff(
    {
      maDon: "DON_TEST",
      diaChiId: "DC_TEST",
      ngayThuGom: date,
      khungGio: "08:00-10:00",
    },
    {toaDoLat: 10.8, toaDoLng: 106.7, quanHuyen: "Quận 3"},
    [
      {
        nhanVienId: "STAFF_FAR",
        gioBatDau: "06:00",
        gioKetThuc: "17:00",
        toaDoLat: 10.9,
        toaDoLng: 106.8,
      },
      {
        nhanVienId: "STAFF_NEAR",
        gioBatDau: "06:00",
        gioKetThuc: "17:00",
        toaDoLat: 10.801,
        toaDoLng: 106.701,
      },
    ],
    [],
    new Set(),
  );

  assert.equal(ranked[0]?.nhanVienId, "STAFF_NEAR");
});

test("ranking excludes a staff member with an overlapping order", () => {
  const date = Timestamp.fromDate(new Date(2026, 6, 30, 8));
  const ranked = rankStaff(
    {
      maDon: "DON_NEW",
      diaChiId: "DC_TEST",
      ngayThuGom: date,
      khungGio: "08:00-10:00",
    },
    {toaDoLat: 10.8, toaDoLng: 106.7},
    [
      {
        nhanVienId: "STAFF_1",
        gioBatDau: "06:00",
        gioKetThuc: "17:00",
        toaDoLat: 10.8,
        toaDoLng: 106.7,
      },
    ],
    [
      {
        maDon: "DON_ACTIVE",
        nhanVienHienTaiId: "STAFF_1",
        ngayThuGom: date,
        khungGio: "09:00-11:00",
      },
    ],
    new Set(),
  );

  assert.equal(ranked.length, 0);
});
