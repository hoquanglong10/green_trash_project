import 'dart:typed_data';

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
    this.toaDoLat,
    this.toaDoLng,
    this.capNhatViTriLuc,
  });

  final String nhanVienId;
  final String maNhanVien;
  final String trangThaiLamViec;
  final String gioBatDau;
  final String gioKetThuc;
  final num doanhThuHienTai;
  final String viTriHienTai;
  final double? toaDoLat;
  final double? toaDoLng;
  final DateTime? capNhatViTriLuc;

  bool get hasLiveLocation =>
      toaDoLat != null &&
      toaDoLng != null &&
      toaDoLat! >= -90 &&
      toaDoLat! <= 90 &&
      toaDoLng! >= -180 &&
      toaDoLng! <= 180;

  StaffProfile copyWith({
    String? trangThaiLamViec,
    String? gioBatDau,
    String? gioKetThuc,
    num? doanhThuHienTai,
    String? viTriHienTai,
    double? toaDoLat,
    double? toaDoLng,
    DateTime? capNhatViTriLuc,
  }) {
    return StaffProfile(
      nhanVienId: nhanVienId,
      maNhanVien: maNhanVien,
      trangThaiLamViec: trangThaiLamViec ?? this.trangThaiLamViec,
      gioBatDau: gioBatDau ?? this.gioBatDau,
      gioKetThuc: gioKetThuc ?? this.gioKetThuc,
      doanhThuHienTai: doanhThuHienTai ?? this.doanhThuHienTai,
      viTriHienTai: viTriHienTai ?? this.viTriHienTai,
      toaDoLat: toaDoLat ?? this.toaDoLat,
      toaDoLng: toaDoLng ?? this.toaDoLng,
      capNhatViTriLuc: capNhatViTriLuc ?? this.capNhatViTriLuc,
    );
  }
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

  PackageSubscription copyWith({
    double? soKgDaDung,
    double? soKgConLai,
    String? trangThai,
  }) {
    return PackageSubscription(
      dangKyGoiId: dangKyGoiId,
      khachHangId: khachHangId,
      goiId: goiId,
      thangNam: thangNam,
      soKgDaDung: soKgDaDung ?? this.soKgDaDung,
      soKgConLai: soKgConLai ?? this.soKgConLai,
      trangThai: trangThai ?? this.trangThai,
    );
  }
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
    this.phanCongHienTaiId,
    this.nhanVienDeXuatId,
    this.nhanVienTuChoiIds = const [],
    this.offerExpiresAt,
    this.offerAttempt = 0,
    this.waitingForSupport = false,
    this.gioChot,
    this.ghiChu = '',
    this.ngayCapNhat,
    this.lyDoHuy,
    this.bienBanId,
    this.thanhToanId,
  });

  final String maDon;
  final String khachHangId;
  final String diaChiId;
  final String loaiRacId;
  final String? nhanVienHienTaiId;
  final String? phanCongHienTaiId;
  final String? nhanVienDeXuatId;
  final List<String> nhanVienTuChoiIds;
  final DateTime? offerExpiresAt;
  final int offerAttempt;
  final bool waitingForSupport;
  final double khoiLuongDuKien;
  final DateTime ngayThuGom;
  final String khungGio;
  final DateTime? gioChot;
  final String hinhThucTinhPhi;
  final String trangThai;
  final String ghiChu;
  final DateTime ngayTao;
  final DateTime? ngayCapNhat;
  final String? lyDoHuy;
  final String? bienBanId;
  final String? thanhToanId;

  PickupOrder copyWith({
    String? nhanVienHienTaiId,
    String? phanCongHienTaiId,
    String? nhanVienDeXuatId,
    bool clearNhanVienHienTaiId = false,
    bool clearPhanCongHienTaiId = false,
    bool clearNhanVienDeXuatId = false,
    List<String>? nhanVienTuChoiIds,
    DateTime? offerExpiresAt,
    bool clearOfferExpiresAt = false,
    int? offerAttempt,
    bool? waitingForSupport,
    double? khoiLuongDuKien,
    DateTime? ngayThuGom,
    String? khungGio,
    DateTime? gioChot,
    String? hinhThucTinhPhi,
    String? trangThai,
    String? ghiChu,
    DateTime? ngayCapNhat,
    String? lyDoHuy,
    bool clearLyDoHuy = false,
    String? bienBanId,
    String? thanhToanId,
  }) {
    return PickupOrder(
      maDon: maDon,
      khachHangId: khachHangId,
      diaChiId: diaChiId,
      loaiRacId: loaiRacId,
      nhanVienHienTaiId: clearNhanVienHienTaiId
          ? null
          : nhanVienHienTaiId ?? this.nhanVienHienTaiId,
      phanCongHienTaiId: clearPhanCongHienTaiId
          ? null
          : phanCongHienTaiId ?? this.phanCongHienTaiId,
      nhanVienDeXuatId: clearNhanVienDeXuatId
          ? null
          : nhanVienDeXuatId ?? this.nhanVienDeXuatId,
      nhanVienTuChoiIds: nhanVienTuChoiIds ?? this.nhanVienTuChoiIds,
      offerExpiresAt: clearOfferExpiresAt
          ? null
          : offerExpiresAt ?? this.offerExpiresAt,
      offerAttempt: offerAttempt ?? this.offerAttempt,
      waitingForSupport: waitingForSupport ?? this.waitingForSupport,
      khoiLuongDuKien: khoiLuongDuKien ?? this.khoiLuongDuKien,
      ngayThuGom: ngayThuGom ?? this.ngayThuGom,
      khungGio: khungGio ?? this.khungGio,
      gioChot: gioChot ?? this.gioChot,
      hinhThucTinhPhi: hinhThucTinhPhi ?? this.hinhThucTinhPhi,
      trangThai: trangThai ?? this.trangThai,
      ghiChu: ghiChu ?? this.ghiChu,
      ngayTao: ngayTao,
      ngayCapNhat: ngayCapNhat ?? this.ngayCapNhat,
      lyDoHuy: clearLyDoHuy ? null : lyDoHuy ?? this.lyDoHuy,
      bienBanId: bienBanId ?? this.bienBanId,
      thanhToanId: thanhToanId ?? this.thanhToanId,
    );
  }
}

class CollectionRecord {
  const CollectionRecord({
    required this.bienBanId,
    required this.maDon,
    required this.nhanVienId,
    required this.loaiRacThucTeId,
    required this.khoiLuongThucTe,
    required this.phiPhaiTra,
    required this.trangThaiThanhToan,
    required this.thoiGianLap,
    this.anhXacNhanUrl,
    this.anhXacNhanBytes,
  });

  final String bienBanId;
  final String maDon;
  final String nhanVienId;
  final String loaiRacThucTeId;
  final double khoiLuongThucTe;
  final String? anhXacNhanUrl;
  final Uint8List? anhXacNhanBytes;
  final num phiPhaiTra;
  final String trangThaiThanhToan;
  final DateTime thoiGianLap;

  CollectionRecord copyWith({
    String? trangThaiThanhToan,
    String? anhXacNhanUrl,
    Uint8List? anhXacNhanBytes,
  }) {
    return CollectionRecord(
      bienBanId: bienBanId,
      maDon: maDon,
      nhanVienId: nhanVienId,
      loaiRacThucTeId: loaiRacThucTeId,
      khoiLuongThucTe: khoiLuongThucTe,
      anhXacNhanUrl: anhXacNhanUrl ?? this.anhXacNhanUrl,
      anhXacNhanBytes: anhXacNhanBytes ?? this.anhXacNhanBytes,
      phiPhaiTra: phiPhaiTra,
      trangThaiThanhToan: trangThaiThanhToan ?? this.trangThaiThanhToan,
      thoiGianLap: thoiGianLap,
    );
  }
}

class PaymentRecord {
  const PaymentRecord({
    required this.thanhToanId,
    required this.maDon,
    required this.khachHangId,
    required this.soTien,
    required this.phuongThuc,
    required this.trangThai,
    required this.thoiGianTao,
    this.thoiGianThanhToan,
  });

  final String thanhToanId;
  final String maDon;
  final String khachHangId;
  final num soTien;
  final String phuongThuc;
  final String trangThai;
  final DateTime thoiGianTao;
  final DateTime? thoiGianThanhToan;

  PaymentRecord copyWith({
    String? phuongThuc,
    String? trangThai,
    DateTime? thoiGianThanhToan,
  }) {
    return PaymentRecord(
      thanhToanId: thanhToanId,
      maDon: maDon,
      khachHangId: khachHangId,
      soTien: soTien,
      phuongThuc: phuongThuc ?? this.phuongThuc,
      trangThai: trangThai ?? this.trangThai,
      thoiGianTao: thoiGianTao,
      thoiGianThanhToan: thoiGianThanhToan ?? this.thoiGianThanhToan,
    );
  }
}

class CollectionCompletion {
  const CollectionCompletion({required this.record, required this.payment});

  final CollectionRecord record;
  final PaymentRecord payment;
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
