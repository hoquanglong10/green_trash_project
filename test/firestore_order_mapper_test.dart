import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:green_trash_project/features/orders/data/firestore_order_mapper.dart';
import 'package:green_trash_project/features/orders/domain/order_workflow_models.dart';

void main() {
  group('FirestoreOrderMapper', () {
    test('maps backend order fields and denormalized matching state', () {
      final createdAt = DateTime(2026, 7, 27, 9);
      final pickupAt = DateTime(2026, 7, 30, 8);
      final offerExpiresAt = DateTime(2026, 7, 27, 9, 2);

      final order = FirestoreOrderMapper.fromMap(
        documentId: 'DON_TEST',
        data: <String, dynamic>{
          'maDon': 'DON_TEST',
          'khachHangId': 'CUSTOMER_UID',
          'diaChiId': 'DC_TEST',
          'loaiRacId': 'LR_TEST',
          'phanCongHienTaiId': 'PC_TEST',
          'nhanVienDeXuatId': 'STAFF_NEXT',
          'offerExpiresAt': Timestamp.fromDate(offerExpiresAt),
          'nhanVienTuChoiIds': ['STAFF_OLD'],
          'soLanDeXuat': 2,
          'dangChoHoTro': true,
          'khoiLuongDuKien': 5,
          'ngayThuGom': Timestamp.fromDate(pickupAt),
          'khungGio': '08:00-10:00',
          'hinhThucTinhPhi': 'THEO_KG',
          'trangThai': 'CHO_XU_LY',
          'ngayTao': Timestamp.fromDate(createdAt),
          'ngayCapNhat': Timestamp.fromDate(createdAt),
        },
      );

      expect(order.maDon, 'DON_TEST');
      expect(order.phanCongHienTaiId, 'PC_TEST');
      expect(order.offerAttempt, 2);
      expect(order.waitingForSupport, isTrue);
      expect(order.nhanVienDeXuatId, 'STAFF_NEXT');
      expect(order.offerExpiresAt, offerExpiresAt);
      expect(order.nhanVienTuChoiIds, ['STAFF_OLD']);
    });

    test('create data enters support queue when no staff is available', () {
      final now = DateTime(2026, 7, 27, 9);
      final data = FirestoreOrderMapper.createData(
        maDon: 'DON_TEST',
        command: CreatePickupOrderCommand(
          khachHangId: 'CUSTOMER_UID',
          diaChiId: 'DC_TEST',
          loaiRacId: 'LR_TEST',
          khoiLuongDuKien: 5,
          ngayThuGom: DateTime(2026, 7, 30),
          khungGio: '08:00-10:00',
          hinhThucTinhPhi: 'THEO_KG',
        ),
        now: now,
      );

      expect(data['trangThai'], 'CHO_XU_LY');
      expect(data['soLanDeXuat'], 0);
      expect(data['dangChoHoTro'], isTrue);
      expect(data, isNot(contains('nhanVienDeXuatId')));
      expect(data['nhanVienTuChoiIds'], isEmpty);
      expect(data, isNot(contains('offerExpiresAt')));
    });

    test('create data stores one targeted staff offer', () {
      final now = DateTime(2026, 7, 27, 9);
      final expiresAt = now.add(const Duration(minutes: 2));
      final data = FirestoreOrderMapper.createData(
        maDon: 'DON_TARGETED',
        command: CreatePickupOrderCommand(
          khachHangId: 'CUSTOMER_UID',
          diaChiId: 'DC_TEST',
          loaiRacId: 'LR_TEST',
          khoiLuongDuKien: 5,
          ngayThuGom: DateTime(2026, 7, 30),
          khungGio: '08:00-10:00',
          hinhThucTinhPhi: 'THEO_KG',
        ),
        now: now,
        suggestedStaffId: 'STAFF_NEAREST',
        offerExpiresAt: expiresAt,
      );

      expect(data['nhanVienDeXuatId'], 'STAFF_NEAREST');
      expect(data['soLanDeXuat'], 1);
      expect(data['dangChoHoTro'], isFalse);
      expect((data['offerExpiresAt'] as Timestamp).toDate(), expiresAt);
    });
  });

  group('FirestoreAssignmentMapper', () {
    test('reads legacy CHO_NHAN as a waiting offer', () {
      final assignedAt = DateTime(2026, 7, 27, 9);
      final assignment = FirestoreAssignmentMapper.fromMap(
        documentId: 'PC_TEST',
        data: <String, dynamic>{
          'phanCongId': 'PC_TEST',
          'maDon': 'DON_TEST',
          'nhanVienId': 'STAFF_UID',
          'adminId': 'ADMIN_UID',
          'trangThaiPhanCong': 'CHO_NHAN',
          'thoiGianPhanCong': Timestamp.fromDate(assignedAt),
        },
      );

      expect(assignment.trangThai, AssignmentStatus.waiting);
      expect(assignment.nguonPhanCong, AssignmentSource.admin);
      expect(assignment.thuTuDeXuat, 1);
    });
  });

  group('FirestoreCollectionRecordMapper', () {
    test('reads collection evidence bytes from a Firestore Blob', () {
      final evidence = Uint8List.fromList([255, 216, 255, 224]);
      final record = FirestoreCollectionRecordMapper.fromMap(
        documentId: 'BB_TEST',
        data: <String, dynamic>{
          'bienBanId': 'BB_TEST',
          'maDon': 'DON_TEST',
          'nhanVienId': 'STAFF_UID',
          'loaiRacThucTeId': 'LR_TEST',
          'khoiLuongThucTe': 4.5,
          'anhXacNhanBytes': Blob(evidence),
          'phiPhaiTra': 0,
          'trangThaiThanhToan': 'DA_THANH_TOAN',
          'thoiGianLap': Timestamp.fromDate(DateTime(2026, 7, 28)),
        },
      );

      expect(record.anhXacNhanBytes, evidence);
    });
  });
}
