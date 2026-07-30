import 'package:flutter_test/flutter_test.dart';
import 'package:green_trash_project/features/orders/domain/staff_dispatch_ranker.dart';
import 'package:green_trash_project/models/app_models.dart';

void main() {
  test('GPS distance wins when both staff locations are available', () {
    const address = CustomerAddress(
      diaChiId: 'DC_001',
      khachHangId: 'KH_001',
      diaChiChiTiet: '12 Nguyễn Văn Bảo',
      phuongXa: 'Phường 4',
      quanHuyen: 'Gò Vấp',
      tinhThanh: 'TP.HCM',
      toaDoLat: 10.8226,
      toaDoLng: 106.6872,
      macDinh: true,
    );
    const near = StaffProfile(
      nhanVienId: 'NV_NEAR',
      maNhanVien: 'NV_NEAR',
      trangThaiLamViec: 'SAN_SANG',
      gioBatDau: '06:00',
      gioKetThuc: '17:00',
      doanhThuHienTai: 100000,
      viTriHienTai: 'Quận khác',
      toaDoLat: 10.8230,
      toaDoLng: 106.6874,
    );
    const far = StaffProfile(
      nhanVienId: 'NV_FAR',
      maNhanVien: 'NV_FAR',
      trangThaiLamViec: 'SAN_SANG',
      gioBatDau: '06:00',
      gioKetThuc: '17:00',
      doanhThuHienTai: 0,
      viTriHienTai: 'Gò Vấp',
      toaDoLat: 10.7800,
      toaDoLng: 106.6800,
    );

    final staff = [far, near]
      ..sort((a, b) => compareStaffForPickup(a, b, address));

    expect(staff.first.nhanVienId, 'NV_NEAR');
    expect(
      pickupDistanceMeters(address: address, staff: near),
      lessThan(pickupDistanceMeters(address: address, staff: far)!),
    );
  });

  test('zero address coordinates use the deterministic fallback', () {
    const address = CustomerAddress(
      diaChiId: 'DC_NO_GPS',
      khachHangId: 'KH_001',
      diaChiChiTiet: '12 Nguyen Van Bao',
      phuongXa: 'Phuong 4',
      quanHuyen: 'Go Vap',
      tinhThanh: 'TP.HCM',
      toaDoLat: 0,
      toaDoLng: 0,
      macDinh: true,
    );
    const sameArea = StaffProfile(
      nhanVienId: 'NV_SAME_AREA',
      maNhanVien: 'NV_SAME_AREA',
      trangThaiLamViec: 'SAN_SANG',
      gioBatDau: '06:00',
      gioKetThuc: '17:00',
      doanhThuHienTai: 100000,
      viTriHienTai: 'Go Vap',
      toaDoLat: 10.8226,
      toaDoLng: 106.6872,
    );
    const lowerRevenueElsewhere = StaffProfile(
      nhanVienId: 'NV_ELSEWHERE',
      maNhanVien: 'NV_ELSEWHERE',
      trangThaiLamViec: 'SAN_SANG',
      gioBatDau: '06:00',
      gioKetThuc: '17:00',
      doanhThuHienTai: 0,
      viTriHienTai: 'Quan 1',
      toaDoLat: 10.7800,
      toaDoLng: 106.6800,
    );

    final staff = [lowerRevenueElsewhere, sameArea]
      ..sort((a, b) => compareStaffForPickup(a, b, address));

    expect(pickupDistanceMeters(address: address, staff: sameArea), isNull);
    expect(staff.first.nhanVienId, 'NV_SAME_AREA');
  });
}
