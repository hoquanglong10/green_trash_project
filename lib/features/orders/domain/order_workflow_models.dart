import '../../../models/app_models.dart';

enum AssignmentSource {
  system('HE_THONG'),
  admin('ADMIN');

  const AssignmentSource(this.value);

  final String value;

  static AssignmentSource fromValue(String value) {
    return value == admin.value ? admin : system;
  }
}

enum AssignmentStatus {
  waiting('CHO_PHAN_HOI'),
  accepted('DA_NHAN'),
  rejected('TU_CHOI'),
  expired('HET_HAN'),
  canceled('HUY');

  const AssignmentStatus(this.value);

  final String value;

  static AssignmentStatus fromValue(String value) {
    if (value == 'CHO_NHAN') return waiting;
    return AssignmentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () =>
          throw FormatException('Unsupported assignment status: $value'),
    );
  }
}

class PickupAssignment {
  const PickupAssignment({
    required this.phanCongId,
    required this.maDon,
    required this.nhanVienId,
    required this.nguonPhanCong,
    required this.trangThai,
    required this.thoiGianPhanCong,
    required this.thoiGianHetHan,
    required this.thuTuDeXuat,
    this.adminId,
    this.thoiGianPhanHoi,
    this.lyDoTuChoi,
    this.ngayCapNhat,
  });

  final String phanCongId;
  final String maDon;
  final String nhanVienId;
  final String? adminId;
  final AssignmentSource nguonPhanCong;
  final AssignmentStatus trangThai;
  final DateTime thoiGianPhanCong;
  final DateTime thoiGianHetHan;
  final int thuTuDeXuat;
  final DateTime? thoiGianPhanHoi;
  final String? lyDoTuChoi;
  final DateTime? ngayCapNhat;

  bool isExpiredAt(DateTime now) =>
      trangThai == AssignmentStatus.waiting && !now.isBefore(thoiGianHetHan);
}

class CreatePickupOrderCommand {
  const CreatePickupOrderCommand({
    required this.khachHangId,
    required this.diaChiId,
    required this.loaiRacId,
    required this.khoiLuongDuKien,
    required this.ngayThuGom,
    required this.khungGio,
    required this.hinhThucTinhPhi,
    this.ghiChu = '',
  });

  final String khachHangId;
  final String diaChiId;
  final String loaiRacId;
  final double khoiLuongDuKien;
  final DateTime ngayThuGom;
  final String khungGio;
  final String hinhThucTinhPhi;
  final String ghiChu;
}

class AcceptPickupOfferCommand {
  const AcceptPickupOfferCommand({
    required this.phanCongId,
    required this.nhanVienId,
    required this.gioChot,
  });

  final String phanCongId;
  final String nhanVienId;
  final DateTime gioChot;
}

class ClaimOpenPickupOrderCommand {
  const ClaimOpenPickupOrderCommand({
    required this.maDon,
    required this.nhanVienId,
    required this.gioChot,
  });

  final String maDon;
  final String nhanVienId;
  final DateTime gioChot;
}

class DismissOpenPickupOrderCommand {
  const DismissOpenPickupOrderCommand({
    required this.maDon,
    required this.nhanVienId,
    required this.lyDo,
  });

  final String maDon;
  final String nhanVienId;
  final String lyDo;
}

class RejectPickupOfferCommand {
  const RejectPickupOfferCommand({
    required this.phanCongId,
    required this.nhanVienId,
    required this.lyDo,
  });

  final String phanCongId;
  final String nhanVienId;
  final String lyDo;
}

class UpdateArrivalTimeCommand {
  const UpdateArrivalTimeCommand({
    required this.maDon,
    required this.nhanVienId,
    required this.gioChot,
  });

  final String maDon;
  final String nhanVienId;
  final DateTime gioChot;
}

class TransitionPickupOrderCommand {
  const TransitionPickupOrderCommand({
    required this.maDon,
    required this.nhanVienId,
    required this.trangThaiMoi,
  });

  final String maDon;
  final String nhanVienId;
  final String trangThaiMoi;
}

class CompletePickupOrderCommand {
  const CompletePickupOrderCommand({
    required this.maDon,
    required this.nhanVienId,
    required this.record,
    required this.payment,
    this.dangKyGoiId,
  });

  final String maDon;
  final String nhanVienId;
  final CollectionRecord record;
  final PaymentRecord payment;
  final String? dangKyGoiId;
}

class CancelPickupOrderCommand {
  const CancelPickupOrderCommand({
    required this.maDon,
    required this.actorId,
    required this.lyDo,
  });

  final String maDon;
  final String actorId;
  final String lyDo;
}

class ConfirmPaymentCommand {
  const ConfirmPaymentCommand({
    required this.maDon,
    required this.thanhToanId,
    required this.khachHangId,
    required this.phuongThuc,
  });

  final String maDon;
  final String thanhToanId;
  final String khachHangId;
  final String phuongThuc;
}

class StaffLocationCommand {
  const StaffLocationCommand({
    required this.nhanVienId,
    required this.latitude,
    required this.longitude,
    this.maDon,
    this.diaChiLat,
    this.diaChiLng,
    this.label,
  });

  final String nhanVienId;
  final double latitude;
  final double longitude;
  final String? maDon;
  final double? diaChiLat;
  final double? diaChiLng;
  final String? label;

  bool get canCheckPickupProximity =>
      maDon != null &&
      diaChiLat != null &&
      diaChiLng != null &&
      diaChiLat! >= -90 &&
      diaChiLat! <= 90 &&
      diaChiLng! >= -180 &&
      diaChiLng! <= 180;
}

class OrderWorkflowException implements Exception {
  const OrderWorkflowException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'OrderWorkflowException($code): $message';
}
