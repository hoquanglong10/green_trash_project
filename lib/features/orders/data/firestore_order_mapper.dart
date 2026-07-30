import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/app_models.dart';
import '../domain/order_workflow_models.dart';

class FirestoreOrderMapper {
  const FirestoreOrderMapper._();

  static PickupOrder fromMap({
    required String documentId,
    required Map<String, dynamic> data,
  }) {
    return PickupOrder(
      maDon: _requiredString(data, 'maDon', fallback: documentId),
      khachHangId: _requiredString(data, 'khachHangId'),
      diaChiId: _requiredString(data, 'diaChiId'),
      loaiRacId: _requiredString(data, 'loaiRacId'),
      nhanVienHienTaiId: _optionalString(data, 'nhanVienHienTaiId'),
      phanCongHienTaiId: _optionalString(data, 'phanCongHienTaiId'),
      nhanVienDeXuatId: _optionalString(data, 'nhanVienDeXuatId'),
      nhanVienTuChoiIds: _optionalStringList(data, 'nhanVienTuChoiIds'),
      offerExpiresAt: _optionalDate(data, 'offerExpiresAt'),
      offerAttempt: _optionalInt(data, 'soLanDeXuat') ?? 0,
      waitingForSupport: data['dangChoHoTro'] == true,
      khoiLuongDuKien: _requiredNumber(data, 'khoiLuongDuKien').toDouble(),
      ngayThuGom: _requiredDate(data, 'ngayThuGom'),
      khungGio: _requiredString(data, 'khungGio'),
      gioChot: _optionalDate(data, 'gioChot'),
      hinhThucTinhPhi: _requiredString(data, 'hinhThucTinhPhi'),
      trangThai: _requiredString(data, 'trangThai'),
      ghiChu: _optionalString(data, 'ghiChu') ?? '',
      ngayTao: _requiredDate(data, 'ngayTao'),
      ngayCapNhat: _optionalDate(data, 'ngayCapNhat'),
      lyDoHuy: _optionalString(data, 'lyDoHuy'),
      bienBanId: _optionalString(data, 'bienBanId'),
      thanhToanId: _optionalString(data, 'thanhToanId'),
    );
  }

  static Map<String, dynamic> createData({
    required String maDon,
    required CreatePickupOrderCommand command,
    required DateTime now,
    String? suggestedStaffId,
    DateTime? offerExpiresAt,
  }) {
    return <String, dynamic>{
      'maDon': maDon,
      'khachHangId': command.khachHangId,
      'diaChiId': command.diaChiId,
      'loaiRacId': command.loaiRacId,
      'khoiLuongDuKien': command.khoiLuongDuKien,
      'ngayThuGom': Timestamp.fromDate(command.ngayThuGom),
      'khungGio': command.khungGio,
      'hinhThucTinhPhi': command.hinhThucTinhPhi,
      'trangThai': 'CHO_XU_LY',
      'ghiChu': command.ghiChu.trim(),
      'nhanVienTuChoiIds': <String>[],
      'nhanVienDeXuatId': ?suggestedStaffId,
      if (offerExpiresAt != null)
        'offerExpiresAt': Timestamp.fromDate(offerExpiresAt),
      'soLanDeXuat': suggestedStaffId == null ? 0 : 1,
      'dangChoHoTro': suggestedStaffId == null,
      'ngayTao': Timestamp.fromDate(now),
      'ngayCapNhat': Timestamp.fromDate(now),
    };
  }
}

class FirestoreAssignmentMapper {
  const FirestoreAssignmentMapper._();

  static PickupAssignment fromMap({
    required String documentId,
    required Map<String, dynamic> data,
  }) {
    return PickupAssignment(
      phanCongId: _requiredString(data, 'phanCongId', fallback: documentId),
      maDon: _requiredString(data, 'maDon'),
      nhanVienId: _requiredString(data, 'nhanVienId'),
      adminId: _optionalString(data, 'adminId'),
      nguonPhanCong: AssignmentSource.fromValue(
        _optionalString(data, 'nguonPhanCong') ?? 'ADMIN',
      ),
      trangThai: AssignmentStatus.fromValue(
        _requiredString(data, 'trangThaiPhanCong'),
      ),
      thoiGianPhanCong: _requiredDate(data, 'thoiGianPhanCong'),
      thoiGianHetHan:
          _optionalDate(data, 'thoiGianHetHan') ??
          _requiredDate(data, 'thoiGianPhanCong'),
      thuTuDeXuat: _optionalInt(data, 'thuTuDeXuat') ?? 1,
      thoiGianPhanHoi: _optionalDate(data, 'thoiGianPhanHoi'),
      lyDoTuChoi: _optionalString(data, 'lyDoTuChoi'),
      ngayCapNhat: _optionalDate(data, 'ngayCapNhat'),
    );
  }
}

class FirestoreCollectionRecordMapper {
  const FirestoreCollectionRecordMapper._();

  static CollectionRecord fromMap({
    required String documentId,
    required Map<String, dynamic> data,
  }) {
    return CollectionRecord(
      bienBanId: _requiredString(data, 'bienBanId', fallback: documentId),
      maDon: _requiredString(data, 'maDon'),
      nhanVienId: _requiredString(data, 'nhanVienId'),
      loaiRacThucTeId: _requiredString(data, 'loaiRacThucTeId'),
      khoiLuongThucTe: _requiredNumber(data, 'khoiLuongThucTe').toDouble(),
      anhXacNhanUrl: _optionalString(data, 'anhXacNhanUrl'),
      anhXacNhanBytes: _optionalBytes(data, 'anhXacNhanBytes'),
      phiPhaiTra: _requiredNumber(data, 'phiPhaiTra'),
      trangThaiThanhToan: _requiredString(data, 'trangThaiThanhToan'),
      thoiGianLap: _requiredDate(data, 'thoiGianLap'),
    );
  }
}

class FirestorePaymentMapper {
  const FirestorePaymentMapper._();

  static PaymentRecord fromMap({
    required String documentId,
    required Map<String, dynamic> data,
  }) {
    final time = _requiredDate(data, 'thoiGian');
    return PaymentRecord(
      thanhToanId: _requiredString(data, 'thanhToanId', fallback: documentId),
      maDon: _requiredString(data, 'maDon'),
      khachHangId: _requiredString(data, 'khachHangId'),
      soTien: _requiredNumber(data, 'soTien'),
      phuongThuc: _requiredString(data, 'phuongThuc'),
      trangThai: _requiredString(data, 'trangThai'),
      thoiGianTao: time,
      thoiGianThanhToan: data['trangThai'] == 'DA_THANH_TOAN' ? time : null,
    );
  }
}

class FirestoreActivityLogMapper {
  const FirestoreActivityLogMapper._();

  static ActivityLog fromMap({
    required String documentId,
    required Map<String, dynamic> data,
  }) {
    return ActivityLog(
      logId: _requiredString(data, 'logId', fallback: documentId),
      maDon: _requiredString(data, 'maDon'),
      userId: _requiredString(data, 'userId'),
      hanhDong: _requiredString(data, 'hanhDong'),
      thoiGian: _requiredDate(data, 'thoiGian'),
      ghiChu: _optionalString(data, 'ghiChu') ?? '',
    );
  }
}

String _requiredString(
  Map<String, dynamic> data,
  String field, {
  String? fallback,
}) {
  final value = data[field];
  if (value is String && value.trim().isNotEmpty) return value;
  if (fallback != null && fallback.isNotEmpty) return fallback;
  throw FormatException('Missing or invalid string field: $field');
}

String? _optionalString(Map<String, dynamic> data, String field) {
  final value = data[field];
  if (value == null) return null;
  if (value is String) {
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }
  throw FormatException('Invalid string field: $field');
}

Uint8List? _optionalBytes(Map<String, dynamic> data, String field) {
  final value = data[field];
  if (value == null) return null;
  if (value is Blob) return value.bytes;
  if (value is Uint8List) return value;
  throw FormatException('Invalid bytes field: $field');
}

num _requiredNumber(Map<String, dynamic> data, String field) {
  final value = data[field];
  if (value is num) return value;
  throw FormatException('Missing or invalid number field: $field');
}

int? _optionalInt(Map<String, dynamic> data, String field) {
  final value = data[field];
  if (value == null) return null;
  if (value is num) return value.toInt();
  throw FormatException('Invalid integer field: $field');
}

List<String> _optionalStringList(Map<String, dynamic> data, String field) {
  final value = data[field];
  if (value == null) return const [];
  if (value is! List) {
    throw FormatException('Invalid string list field: $field');
  }
  return value
      .map((item) {
        if (item is String && item.trim().isNotEmpty) return item;
        throw FormatException('Invalid string list item in field: $field');
      })
      .toList(growable: false);
}

DateTime _requiredDate(Map<String, dynamic> data, String field) {
  final value = _optionalDate(data, field);
  if (value != null) return value;
  throw FormatException('Missing timestamp field: $field');
}

DateTime? _optionalDate(Map<String, dynamic> data, String field) {
  final value = data[field];
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  throw FormatException('Invalid timestamp field: $field');
}
