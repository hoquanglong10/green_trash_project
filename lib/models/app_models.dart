enum UserRole {
  customer('CUSTOMER', 'Khách hàng'),
  staff('STAFF', 'Nhân viên'),
  admin('ADMIN', 'Admin');

  const UserRole(this.id, this.label);

  final String id;
  final String label;
}

class AppSession {
  const AppSession({required this.user, required this.role});

  final AppUser user;
  final UserRole role;
}

class AppUser {
  const AppUser({
    required this.userId,
    required this.hoTen,
    required this.email,
    required this.soDienThoai,
    required this.role,
  });

  final String userId;
  final String hoTen;
  final String email;
  final String soDienThoai;
  final UserRole role;
}

class CustomerProfile {
  const CustomerProfile({
    required this.khachHangId,
    required this.goiHienTaiId,
    required this.diemUyTin,
  });

  final String khachHangId;
  final String goiHienTaiId;
  final int diemUyTin;
}

class StaffProfile {
  const StaffProfile({
    required this.nhanVienId,
    required this.maNhanVien,
    required this.trangThaiLamViec,
    required this.gioBatDau,
    required this.gioKetThuc,
    required this.doanhThuHienTai,
    required this.viTriHienTai,
  });

  final String nhanVienId;
  final String maNhanVien;
  final String trangThaiLamViec;
  final String gioBatDau;
  final String gioKetThuc;
  final num doanhThuHienTai;
  final String viTriHienTai;
}

class CustomerAddress {
  const CustomerAddress({
    required this.diaChiId,
    required this.khachHangId,
    required this.diaChiChiTiet,
    required this.phuongXa,
    required this.quanHuyen,
    required this.tinhThanh,
    required this.toaDoLat,
    required this.toaDoLng,
    required this.macDinh,
  });

  final String diaChiId;
  final String khachHangId;
  final String diaChiChiTiet;
  final String phuongXa;
  final String quanHuyen;
  final String tinhThanh;
  final double toaDoLat;
  final double toaDoLng;
  final bool macDinh;

  String get shortAddress => '$diaChiChiTiet, $phuongXa';
}

class WasteType {
  const WasteType({
    required this.loaiRacId,
    required this.tenLoaiRac,
    required this.nhomRac,
    required this.moTa,
  });

  final String loaiRacId;
  final String tenLoaiRac;
  final String nhomRac;
  final String moTa;
}

class PriceItem {
  const PriceItem({
    required this.bangGiaId,
    required this.loaiRacId,
    required this.tenDichVu,
    required this.donGiaKg,
    required this.khuVuc,
  });

  final String bangGiaId;
  final String loaiRacId;
  final String tenDichVu;
  final int donGiaKg;
  final String khuVuc;
}

class PickupPackage {
  const PickupPackage({
    required this.goiId,
    required this.tenGoi,
    required this.hanMucKgThang,
    required this.giaGoi,
    required this.phiVuotGoi,
    required this.moTa,
  });

  final String goiId;
  final String tenGoi;
  final int hanMucKgThang;
  final int giaGoi;
  final int phiVuotGoi;
  final String moTa;
}

class PackageSubscription {
  const PackageSubscription({
    required this.dangKyGoiId,
    required this.khachHangId,
    required this.goiId,
    required this.thangNam,
    required this.soKgDaDung,
    required this.soKgConLai,
    required this.trangThai,
  });

  final String dangKyGoiId;
  final String khachHangId;
  final String goiId;
  final String thangNam;
  final double soKgDaDung;
  final double soKgConLai;
  final String trangThai;
}

class PickupOrder {
  const PickupOrder({
    required this.maDon,
    required this.khachHangId,
    required this.diaChiId,
    required this.loaiRacId,
    required this.khoiLuongDuKien,
    required this.ngayThuGom,
    required this.khungGio,
    required this.hinhThucTinhPhi,
    required this.trangThai,
    required this.ngayTao,
    this.nhanVienHienTaiId,
    this.nhanVienDeXuatId,
    this.nhanVienTuChoiIds = const [],
    this.gioChot,
    this.ghiChu = '',
  });

  final String maDon;
  final String khachHangId;
  final String diaChiId;
  final String loaiRacId;
  final String? nhanVienHienTaiId;
  final String? nhanVienDeXuatId;
  final List<String> nhanVienTuChoiIds;
  final double khoiLuongDuKien;
  final DateTime ngayThuGom;
  final String khungGio;
  final DateTime? gioChot;
  final String hinhThucTinhPhi;
  final String trangThai;
  final String ghiChu;
  final DateTime ngayTao;

  PickupOrder copyWith({
    String? nhanVienHienTaiId,
    String? nhanVienDeXuatId,
    bool clearNhanVienHienTaiId = false,
    bool clearNhanVienDeXuatId = false,
    List<String>? nhanVienTuChoiIds,
    double? khoiLuongDuKien,
    DateTime? ngayThuGom,
    String? khungGio,
    DateTime? gioChot,
    String? hinhThucTinhPhi,
    String? trangThai,
    String? ghiChu,
  }) {
    return PickupOrder(
      maDon: maDon,
      khachHangId: khachHangId,
      diaChiId: diaChiId,
      loaiRacId: loaiRacId,
      nhanVienHienTaiId: clearNhanVienHienTaiId
          ? null
          : nhanVienHienTaiId ?? this.nhanVienHienTaiId,
      nhanVienDeXuatId: clearNhanVienDeXuatId
          ? null
          : nhanVienDeXuatId ?? this.nhanVienDeXuatId,
      nhanVienTuChoiIds: nhanVienTuChoiIds ?? this.nhanVienTuChoiIds,
      khoiLuongDuKien: khoiLuongDuKien ?? this.khoiLuongDuKien,
      ngayThuGom: ngayThuGom ?? this.ngayThuGom,
      khungGio: khungGio ?? this.khungGio,
      gioChot: gioChot ?? this.gioChot,
      hinhThucTinhPhi: hinhThucTinhPhi ?? this.hinhThucTinhPhi,
      trangThai: trangThai ?? this.trangThai,
      ghiChu: ghiChu ?? this.ghiChu,
      ngayTao: ngayTao,
    );
  }
}

class ActivityLog {
  const ActivityLog({
    required this.logId,
    required this.maDon,
    required this.userId,
    required this.hanhDong,
    required this.thoiGian,
    required this.ghiChu,
  });

  final String logId;
  final String maDon;
  final String userId;
  final String hanhDong;
  final DateTime thoiGian;
  final String ghiChu;
}

class AppNotification {
  const AppNotification({
    required this.thongBaoId,
    required this.nguoiNhanId,
    required this.tieuDe,
    required this.noiDung,
    required this.trangThaiDoc,
    required this.thoiGian,
    this.maDon,
  });

  final String thongBaoId;
  final String nguoiNhanId;
  final String? maDon;
  final String tieuDe;
  final String noiDung;
  final String trangThaiDoc;
  final DateTime thoiGian;
}
