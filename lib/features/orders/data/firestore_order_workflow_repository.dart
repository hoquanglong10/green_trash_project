import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/app_models.dart';
import '../../../schema_contract.dart';
import '../domain/order_workflow_models.dart';
import '../domain/order_workflow_repository.dart';
import 'firestore_order_mapper.dart';

class FirestoreOrderWorkflowRepository implements OrderWorkflowRepository {
  FirestoreOrderWorkflowRepository(
    this._firestore, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  static const _activeStaffStatuses = <String>{
    'DA_NHAN',
    'DANG_DEN',
    'DA_DEN',
    'DANG_CAN_RAC',
  };
  static const _customerCancelableStatuses = <String>{
    'CHO_XU_LY',
    'CHO_NHAN',
    'DA_NHAN',
    'DANG_DEN',
  };
  static const _nearPickupDistanceMeters = 200.0;
  static const _arrivedPickupDistanceMeters = 30.0;
  static const _allowedTransitions = <String, String>{
    'DA_NHAN': 'DANG_DEN',
    'DANG_DEN': 'DA_DEN',
    'DA_DEN': 'DANG_CAN_RAC',
  };

  final FirebaseFirestore _firestore;
  final DateTime Function() _clock;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _firestore.collection(donThuGomCollection);

  CollectionReference<Map<String, dynamic>> get _assignments =>
      _firestore.collection(phanCongThuGomCollection);

  CollectionReference<Map<String, dynamic>> get _collectionRecords =>
      _firestore.collection(bienBanThuGomCollection);

  CollectionReference<Map<String, dynamic>> get _payments =>
      _firestore.collection(thanhToanCollection);

  CollectionReference<Map<String, dynamic>> get _activityLogs =>
      _firestore.collection(lichSuHoatDongCollection);

  @override
  Stream<List<PickupOrder>> watchCustomerOrders(String customerId) {
    return _orders.where('khachHangId', isEqualTo: customerId).snapshots().map((
      snapshot,
    ) {
      final orders = snapshot.docs
          .map(
            (doc) => FirestoreOrderMapper.fromMap(
              documentId: doc.id,
              data: doc.data(),
            ),
          )
          .toList(growable: false);
      orders.sort((first, second) => second.ngayTao.compareTo(first.ngayTao));
      return orders;
    });
  }

  @override
  Stream<List<PickupOrder>> watchStaffOrders(String staffId) {
    return _orders
        .where('nhanVienHienTaiId', isEqualTo: staffId)
        .snapshots()
        .map((snapshot) {
          final orders = snapshot.docs
              .map(
                (doc) => FirestoreOrderMapper.fromMap(
                  documentId: doc.id,
                  data: doc.data(),
                ),
              )
              .toList(growable: false);
          orders.sort(
            (first, second) => first.ngayThuGom.compareTo(second.ngayThuGom),
          );
          return orders;
        });
  }

  @override
  Stream<List<PickupOrder>> watchOpenOrders(String staffId) {
    return _orders.where('trangThai', isEqualTo: 'CHO_XU_LY').snapshots().map((
      snapshot,
    ) {
      final orders = snapshot.docs
          .map(
            (doc) => FirestoreOrderMapper.fromMap(
              documentId: doc.id,
              data: doc.data(),
            ),
          )
          .where((order) => !order.nhanVienTuChoiIds.contains(staffId))
          .toList(growable: false);
      orders.sort(
        (first, second) => first.ngayThuGom.compareTo(second.ngayThuGom),
      );
      return orders;
    });
  }

  @override
  Stream<List<PickupAssignment>> watchPendingOffers(String staffId) {
    return _assignments
        .where('nhanVienId', isEqualTo: staffId)
        .where('trangThaiPhanCong', isEqualTo: AssignmentStatus.waiting.value)
        .orderBy('thoiGianHetHan')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => FirestoreAssignmentMapper.fromMap(
                  documentId: doc.id,
                  data: doc.data(),
                ),
              )
              .toList(growable: false),
        );
  }

  @override
  Stream<PickupOrder?> watchOrder(String maDon) {
    return _orders.doc(maDon).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) return null;
      return FirestoreOrderMapper.fromMap(documentId: snapshot.id, data: data);
    });
  }

  @override
  Stream<List<ActivityLog>> watchActivityLogs(String maDon) {
    return _activityLogs.where('maDon', isEqualTo: maDon).snapshots().map((
      snapshot,
    ) {
      final logs = _mapValidDocuments(
        snapshot.docs,
        (doc) => FirestoreActivityLogMapper.fromMap(
          documentId: doc.id,
          data: doc.data(),
        ),
      );
      logs.sort((first, second) => second.thoiGian.compareTo(first.thoiGian));
      return logs;
    });
  }

  @override
  Stream<CollectionRecord?> watchCollectionRecord(String maDon) {
    return _collectionRecords
        .where('maDon', isEqualTo: maDon)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          final document = snapshot.docs.first;
          final records = _mapValidDocuments(
            [document],
            (doc) => FirestoreCollectionRecordMapper.fromMap(
              documentId: doc.id,
              data: doc.data(),
            ),
          );
          return records.isEmpty ? null : records.first;
        });
  }

  @override
  Stream<PaymentRecord?> watchPaymentRecord(String maDon) {
    return _payments.where('maDon', isEqualTo: maDon).limit(1).snapshots().map((
      snapshot,
    ) {
      if (snapshot.docs.isEmpty) return null;
      final document = snapshot.docs.first;
      final payments = _mapValidDocuments(
        [document],
        (doc) => FirestorePaymentMapper.fromMap(
          documentId: doc.id,
          data: doc.data(),
        ),
      );
      return payments.isEmpty ? null : payments.first;
    });
  }

  List<T> _mapValidDocuments<T>(
    Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> documents,
    T Function(QueryDocumentSnapshot<Map<String, dynamic>> document) mapper,
  ) {
    final values = <T>[];
    for (final document in documents) {
      try {
        values.add(mapper(document));
      } on FormatException {
        // Legacy documents may predate the current Firestore contract.
      }
    }
    return values;
  }

  @override
  Future<PickupOrder> createOrder(CreatePickupOrderCommand command) async {
    _validateCreateCommand(command);

    final now = _clock();
    final maDon = _prefixedId(_orders, 'DON');
    final orderRef = _orders.doc(maDon);
    final addressRef = _firestore
        .collection(diaChiCollection)
        .doc(command.diaChiId);
    final wasteTypeRef = _firestore
        .collection(loaiRacCollection)
        .doc(command.loaiRacId);
    final logRef = _newDocument(lichSuHoatDongCollection, 'LOG');
    final orderData = FirestoreOrderMapper.createData(
      maDon: maDon,
      command: command,
      now: now,
    );

    await _firestore.runTransaction((transaction) async {
      final addressSnapshot = await transaction.get(addressRef);
      final wasteTypeSnapshot = await transaction.get(wasteTypeRef);
      if (!addressSnapshot.exists) {
        throw const OrderWorkflowException(
          'address-not-found',
          'Địa chỉ thu gom không tồn tại.',
        );
      }
      if (addressSnapshot.data()?['khachHangId'] != command.khachHangId) {
        throw const OrderWorkflowException(
          'address-owner-mismatch',
          'Địa chỉ không thuộc khách hàng đang đặt đơn.',
        );
      }
      if (!wasteTypeSnapshot.exists) {
        throw const OrderWorkflowException(
          'waste-type-not-found',
          'Loại rác không tồn tại.',
        );
      }

      transaction.set(orderRef, orderData);
      transaction.set(
        logRef,
        _activityData(
          ref: logRef,
          maDon: maDon,
          userId: command.khachHangId,
          action: 'Tạo đơn thu gom',
          note: 'Khách hàng đã gửi yêu cầu thu gom.',
          time: now,
        ),
      );
    });

    return FirestoreOrderMapper.fromMap(documentId: maDon, data: orderData);
  }

  @override
  Future<void> acceptOffer(AcceptPickupOfferCommand command) async {
    final assignmentRef = _assignments.doc(command.phanCongId);
    final staffRef = _firestore
        .collection(nhanVienThuGomCollection)
        .doc(command.nhanVienId);
    final now = _clock();
    final logRef = _newDocument(lichSuHoatDongCollection, 'LOG');
    final notificationRef = _newDocument(thongBaoCollection, 'TB');

    await _firestore.runTransaction((transaction) async {
      final assignmentSnapshot = await transaction.get(assignmentRef);
      final assignmentData = assignmentSnapshot.data();
      if (!assignmentSnapshot.exists || assignmentData == null) {
        throw const OrderWorkflowException(
          'offer-not-found',
          'Đề xuất đơn không còn tồn tại.',
        );
      }
      final assignment = FirestoreAssignmentMapper.fromMap(
        documentId: assignmentSnapshot.id,
        data: assignmentData,
      );
      final orderRef = _orders.doc(assignment.maDon);
      final orderSnapshot = await transaction.get(orderRef);
      final staffSnapshot = await transaction.get(staffRef);
      final orderData = orderSnapshot.data();
      final staffData = staffSnapshot.data();
      if (!orderSnapshot.exists || orderData == null) {
        throw const OrderWorkflowException(
          'order-not-found',
          'Đơn thu gom không còn tồn tại.',
        );
      }
      if (!staffSnapshot.exists || staffData == null) {
        throw const OrderWorkflowException(
          'staff-not-found',
          'Hồ sơ nhân viên không tồn tại.',
        );
      }
      final order = FirestoreOrderMapper.fromMap(
        documentId: orderSnapshot.id,
        data: orderData,
      );

      if (assignment.nhanVienId != command.nhanVienId ||
          assignment.trangThai != AssignmentStatus.waiting ||
          assignment.isExpiredAt(now) ||
          order.trangThai != 'CHO_XU_LY' ||
          order.phanCongHienTaiId != assignment.phanCongId) {
        throw const OrderWorkflowException(
          'offer-unavailable',
          'Đề xuất đã hết hạn hoặc đã được xử lý.',
        );
      }
      if (!{'SAN_SANG', 'DANG_RANH'}.contains(staffData['trangThaiLamViec'])) {
        throw const OrderWorkflowException(
          'staff-unavailable',
          'Nhân viên hiện không ở trạng thái sẵn sàng.',
        );
      }
      if (!_isInsidePickupSlot(order, command.gioChot)) {
        throw const OrderWorkflowException(
          'invalid-arrival-time',
          'Giờ đến dự kiến phải nằm trong khung giờ thu gom.',
        );
      }

      transaction.update(assignmentRef, <String, dynamic>{
        'trangThaiPhanCong': AssignmentStatus.accepted.value,
        'thoiGianPhanHoi': Timestamp.fromDate(now),
        'ngayCapNhat': Timestamp.fromDate(now),
      });
      transaction.update(orderRef, <String, dynamic>{
        'nhanVienHienTaiId': command.nhanVienId,
        'gioChot': Timestamp.fromDate(command.gioChot),
        'trangThai': 'DA_NHAN',
        'dangChoHoTro': false,
        'ngayCapNhat': Timestamp.fromDate(now),
      });
      transaction.update(staffRef, <String, dynamic>{
        'phanCongDangChoId': FieldValue.delete(),
      });
      transaction.set(
        logRef,
        _activityData(
          ref: logRef,
          maDon: order.maDon,
          userId: command.nhanVienId,
          action: 'Nhận đơn',
          note: 'Nhân viên đã nhận đề xuất thu gom.',
          time: now,
        ),
      );
      transaction.set(
        notificationRef,
        _notificationData(
          ref: notificationRef,
          recipientId: order.khachHangId,
          maDon: order.maDon,
          type: 'DON_DA_NHAN',
          title: 'Nhân viên đã nhận đơn',
          content: '${order.maDon} đã có nhân viên thu gom.',
          time: now,
        ),
      );
    });
  }

  @override
  Future<void> claimOpenOrder(ClaimOpenPickupOrderCommand command) async {
    final orderRef = _orders.doc(command.maDon);
    final staffRef = _firestore
        .collection(nhanVienThuGomCollection)
        .doc(command.nhanVienId);
    final assignmentRef = _newDocument(phanCongThuGomCollection, 'PC');
    final logRef = _newDocument(lichSuHoatDongCollection, 'LOG');
    final notificationRef = _newDocument(thongBaoCollection, 'TB');
    final now = _clock();

    await _firestore.runTransaction((transaction) async {
      final orderSnapshot = await transaction.get(orderRef);
      final staffSnapshot = await transaction.get(staffRef);
      final orderData = orderSnapshot.data();
      final staffData = staffSnapshot.data();
      if (!orderSnapshot.exists || orderData == null) {
        throw const OrderWorkflowException(
          'order-not-found',
          'Đơn thu gom không còn tồn tại.',
        );
      }
      if (!staffSnapshot.exists || staffData == null) {
        throw const OrderWorkflowException(
          'staff-not-found',
          'Hồ sơ nhân viên không tồn tại.',
        );
      }

      final order = FirestoreOrderMapper.fromMap(
        documentId: orderSnapshot.id,
        data: orderData,
      );
      if (order.trangThai != 'CHO_XU_LY' ||
          order.nhanVienHienTaiId != null ||
          order.nhanVienTuChoiIds.contains(command.nhanVienId)) {
        throw const OrderWorkflowException(
          'order-unavailable',
          'Đơn đã được nhân viên khác nhận hoặc không còn khả dụng.',
        );
      }
      if (staffData['trangThaiLamViec'] != 'SAN_SANG') {
        throw const OrderWorkflowException(
          'staff-unavailable',
          'Nhân viên hiện không ở trạng thái sẵn sàng.',
        );
      }
      if (!_isInsidePickupSlot(order, command.gioChot)) {
        throw const OrderWorkflowException(
          'invalid-arrival-time',
          'Giờ đến dự kiến phải nằm trong khung giờ thu gom.',
        );
      }

      final attempt = (orderData['soLanDeXuat'] as num?)?.toInt() ?? 0;
      transaction.set(assignmentRef, <String, dynamic>{
        'phanCongId': assignmentRef.id,
        'maDon': order.maDon,
        'nhanVienId': command.nhanVienId,
        'nguonPhanCong': AssignmentSource.system.value,
        'trangThaiPhanCong': AssignmentStatus.accepted.value,
        'thoiGianPhanCong': Timestamp.fromDate(now),
        'thoiGianHetHan': Timestamp.fromDate(now),
        'thuTuDeXuat': attempt + 1,
        'thoiGianPhanHoi': Timestamp.fromDate(now),
        'ngayCapNhat': Timestamp.fromDate(now),
      });
      transaction.update(orderRef, <String, dynamic>{
        'nhanVienHienTaiId': command.nhanVienId,
        'phanCongHienTaiId': assignmentRef.id,
        'gioChot': Timestamp.fromDate(command.gioChot),
        'trangThai': 'DA_NHAN',
        'soLanDeXuat': attempt + 1,
        'dangChoHoTro': false,
        'ngayCapNhat': Timestamp.fromDate(now),
      });
      transaction.set(
        logRef,
        _activityData(
          ref: logRef,
          maDon: order.maDon,
          userId: command.nhanVienId,
          action: 'Nhận đơn',
          note: 'Nhân viên đã nhận đơn từ danh sách đang chờ.',
          time: now,
        ),
      );
      transaction.set(
        notificationRef,
        _notificationData(
          ref: notificationRef,
          recipientId: order.khachHangId,
          maDon: order.maDon,
          type: 'DON_DA_NHAN',
          title: 'Nhân viên đã nhận đơn',
          content: '${order.maDon} đã có nhân viên phụ trách.',
          time: now,
        ),
      );
    });
  }

  @override
  Future<void> dismissOpenOrder(DismissOpenPickupOrderCommand command) async {
    final reason = command.lyDo.trim();
    if (reason.isEmpty) {
      throw const OrderWorkflowException(
        'reason-required',
        'Cần nhập lý do bỏ qua đơn.',
      );
    }

    final orderRef = _orders.doc(command.maDon);
    final assignmentRef = _newDocument(phanCongThuGomCollection, 'PC');
    final logRef = _newDocument(lichSuHoatDongCollection, 'LOG');
    final now = _clock();

    await _firestore.runTransaction((transaction) async {
      final orderSnapshot = await transaction.get(orderRef);
      final orderData = orderSnapshot.data();
      if (!orderSnapshot.exists || orderData == null) {
        throw const OrderWorkflowException(
          'order-not-found',
          'Đơn thu gom không còn tồn tại.',
        );
      }
      final order = FirestoreOrderMapper.fromMap(
        documentId: orderSnapshot.id,
        data: orderData,
      );
      if (order.trangThai != 'CHO_XU_LY' ||
          order.nhanVienHienTaiId != null ||
          order.nhanVienTuChoiIds.contains(command.nhanVienId)) {
        throw const OrderWorkflowException(
          'order-unavailable',
          'Đơn đã thay đổi hoặc đã được bỏ qua trước đó.',
        );
      }

      final rejectedStaff = [...order.nhanVienTuChoiIds, command.nhanVienId];
      final attempt = (orderData['soLanDeXuat'] as num?)?.toInt() ?? 0;
      transaction.set(assignmentRef, <String, dynamic>{
        'phanCongId': assignmentRef.id,
        'maDon': order.maDon,
        'nhanVienId': command.nhanVienId,
        'nguonPhanCong': AssignmentSource.system.value,
        'trangThaiPhanCong': AssignmentStatus.rejected.value,
        'thoiGianPhanCong': Timestamp.fromDate(now),
        'thoiGianHetHan': Timestamp.fromDate(now),
        'thuTuDeXuat': attempt + 1,
        'thoiGianPhanHoi': Timestamp.fromDate(now),
        'lyDoTuChoi': reason,
        'ngayCapNhat': Timestamp.fromDate(now),
      });
      transaction.update(orderRef, <String, dynamic>{
        'nhanVienTuChoiIds': rejectedStaff,
        'soLanDeXuat': attempt + 1,
        'ngayCapNhat': Timestamp.fromDate(now),
      });
      transaction.set(
        logRef,
        _activityData(
          ref: logRef,
          maDon: order.maDon,
          userId: command.nhanVienId,
          action: 'Bỏ qua đơn',
          note: reason,
          time: now,
        ),
      );
    });
  }

  @override
  Future<void> rejectOffer(RejectPickupOfferCommand command) async {
    final reason = command.lyDo.trim();
    if (reason.isEmpty) {
      throw const OrderWorkflowException(
        'reason-required',
        'Cần nhập lý do từ chối đơn.',
      );
    }

    final assignmentRef = _assignments.doc(command.phanCongId);
    final now = _clock();
    final logRef = _newDocument(lichSuHoatDongCollection, 'LOG');

    await _firestore.runTransaction((transaction) async {
      final assignmentSnapshot = await transaction.get(assignmentRef);
      final data = assignmentSnapshot.data();
      if (!assignmentSnapshot.exists || data == null) {
        throw const OrderWorkflowException(
          'offer-not-found',
          'Đề xuất đơn không còn tồn tại.',
        );
      }
      final assignment = FirestoreAssignmentMapper.fromMap(
        documentId: assignmentSnapshot.id,
        data: data,
      );
      final orderRef = _orders.doc(assignment.maDon);
      final staffRef = _firestore
          .collection(nhanVienThuGomCollection)
          .doc(command.nhanVienId);
      final orderSnapshot = await transaction.get(orderRef);
      final staffSnapshot = await transaction.get(staffRef);
      final orderData = orderSnapshot.data();
      if (!orderSnapshot.exists || orderData == null) {
        throw const OrderWorkflowException(
          'order-not-found',
          'Đơn thu gom không còn tồn tại.',
        );
      }
      if (!staffSnapshot.exists) {
        throw const OrderWorkflowException(
          'staff-not-found',
          'Hồ sơ nhân viên không tồn tại.',
        );
      }
      final order = FirestoreOrderMapper.fromMap(
        documentId: orderSnapshot.id,
        data: orderData,
      );

      if (assignment.nhanVienId != command.nhanVienId ||
          assignment.trangThai != AssignmentStatus.waiting ||
          order.trangThai != 'CHO_XU_LY' ||
          order.phanCongHienTaiId != assignment.phanCongId) {
        throw const OrderWorkflowException(
          'offer-unavailable',
          'Đề xuất đã được xử lý.',
        );
      }

      transaction.update(assignmentRef, <String, dynamic>{
        'trangThaiPhanCong': AssignmentStatus.rejected.value,
        'thoiGianPhanHoi': Timestamp.fromDate(now),
        'lyDoTuChoi': reason,
        'ngayCapNhat': Timestamp.fromDate(now),
      });
      if (staffSnapshot.data()?['phanCongDangChoId'] == assignment.phanCongId) {
        transaction.update(staffRef, <String, dynamic>{
          'phanCongDangChoId': FieldValue.delete(),
        });
      }
      transaction.set(
        logRef,
        _activityData(
          ref: logRef,
          maDon: order.maDon,
          userId: command.nhanVienId,
          action: 'Từ chối đơn',
          note: reason,
          time: now,
        ),
      );
    });
  }

  @override
  Future<void> updateArrivalTime(UpdateArrivalTimeCommand command) async {
    final orderRef = _orders.doc(command.maDon);
    final now = _clock();
    final logRef = _newDocument(lichSuHoatDongCollection, 'LOG');
    final notificationRef = _newDocument(thongBaoCollection, 'TB');

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(orderRef);
      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        throw const OrderWorkflowException(
          'order-not-found',
          'Đơn thu gom không tồn tại.',
        );
      }
      final order = FirestoreOrderMapper.fromMap(
        documentId: snapshot.id,
        data: data,
      );
      if (order.nhanVienHienTaiId != command.nhanVienId ||
          !{'DA_NHAN', 'DANG_DEN'}.contains(order.trangThai)) {
        throw const OrderWorkflowException(
          'arrival-update-denied',
          'Không thể cập nhật giờ đến cho đơn này.',
        );
      }
      if (!_isInsidePickupSlot(order, command.gioChot)) {
        throw const OrderWorkflowException(
          'invalid-arrival-time',
          'Giờ đến dự kiến phải nằm trong khung giờ thu gom.',
        );
      }

      transaction.update(orderRef, <String, dynamic>{
        'gioChot': Timestamp.fromDate(command.gioChot),
        'ngayCapNhat': Timestamp.fromDate(now),
      });
      transaction.set(
        logRef,
        _activityData(
          ref: logRef,
          maDon: order.maDon,
          userId: command.nhanVienId,
          action: 'Cập nhật giờ đến',
          note: 'Nhân viên đã cập nhật thời gian đến dự kiến.',
          time: now,
        ),
      );
      transaction.set(
        notificationRef,
        _notificationData(
          ref: notificationRef,
          recipientId: order.khachHangId,
          maDon: order.maDon,
          type: 'CAP_NHAT_GIO_DEN',
          title: 'Giờ đến đã thay đổi',
          content: 'Nhân viên vừa cập nhật thời gian đến của ${order.maDon}.',
          time: now,
        ),
      );
    });
  }

  @override
  Future<void> transitionOrder(TransitionPickupOrderCommand command) async {
    final orderRef = _orders.doc(command.maDon);
    final staffRef = _firestore
        .collection(nhanVienThuGomCollection)
        .doc(command.nhanVienId);
    final now = _clock();
    final logRef = _newDocument(lichSuHoatDongCollection, 'LOG');
    final notificationRef = _newDocument(thongBaoCollection, 'TB');

    await _firestore.runTransaction((transaction) async {
      final orderSnapshot = await transaction.get(orderRef);
      final staffSnapshot = await transaction.get(staffRef);
      final data = orderSnapshot.data();
      if (!orderSnapshot.exists || data == null) {
        throw const OrderWorkflowException(
          'order-not-found',
          'Đơn thu gom không tồn tại.',
        );
      }
      if (!staffSnapshot.exists) {
        throw const OrderWorkflowException(
          'staff-not-found',
          'Hồ sơ nhân viên không tồn tại.',
        );
      }
      final order = FirestoreOrderMapper.fromMap(
        documentId: orderSnapshot.id,
        data: data,
      );
      if (order.nhanVienHienTaiId != command.nhanVienId ||
          _allowedTransitions[order.trangThai] != command.trangThaiMoi) {
        throw const OrderWorkflowException(
          'invalid-transition',
          'Trạng thái đơn không thể chuyển theo thao tác này.',
        );
      }

      final copy = _statusCopy(command.trangThaiMoi);
      transaction.update(orderRef, <String, dynamic>{
        'trangThai': command.trangThaiMoi,
        'ngayCapNhat': Timestamp.fromDate(now),
      });
      if (command.trangThaiMoi == 'DANG_DEN') {
        transaction.update(staffRef, <String, dynamic>{
          'trangThaiLamViec': 'DANG_THU_GOM',
        });
      }
      transaction.set(
        logRef,
        _activityData(
          ref: logRef,
          maDon: order.maDon,
          userId: command.nhanVienId,
          action: copy.action,
          note: copy.note,
          time: now,
        ),
      );
      transaction.set(
        notificationRef,
        _notificationData(
          ref: notificationRef,
          recipientId: order.khachHangId,
          maDon: order.maDon,
          type: command.trangThaiMoi,
          title: copy.action,
          content: copy.customerMessage,
          time: now,
        ),
      );
    });
  }

  @override
  Future<void> completeOrder(CompletePickupOrderCommand command) async {
    final orderRef = _orders.doc(command.maDon);
    final staffRef = _firestore
        .collection(nhanVienThuGomCollection)
        .doc(command.nhanVienId);
    final recordRef = _firestore
        .collection(bienBanThuGomCollection)
        .doc(command.record.bienBanId);
    final paymentRef = _firestore
        .collection(thanhToanCollection)
        .doc(command.payment.thanhToanId);
    DocumentReference<Map<String, dynamic>>? subscriptionRef =
        command.dangKyGoiId == null
        ? null
        : _firestore.collection(dangKyGoiCollection).doc(command.dangKyGoiId);
    final customerSubscriptionsQuery = _firestore
        .collection(dangKyGoiCollection)
        .where('khachHangId', isEqualTo: command.payment.khachHangId);
    if (subscriptionRef == null) {
      final subscriptions = await customerSubscriptionsQuery.get();
      for (final document in subscriptions.docs) {
        final candidate = document.data();
        if (candidate['trangThai'] == 'CON_HL' ||
            candidate['trangThai'] == 'CON_HIEU_LUC') {
          subscriptionRef = document.reference;
          break;
        }
      }
    }
    final resolvedSubscriptionRef = subscriptionRef;
    final logRef = _newDocument(lichSuHoatDongCollection, 'LOG');
    final notificationRef = _newDocument(thongBaoCollection, 'TB');
    final now = _clock();

    _validateCompletion(command);

    await _firestore.runTransaction((transaction) async {
      final orderSnapshot = await transaction.get(orderRef);
      final staffSnapshot = await transaction.get(staffRef);
      final subscriptionSnapshot = resolvedSubscriptionRef == null
          ? null
          : await transaction.get(resolvedSubscriptionRef);
      final data = orderSnapshot.data();
      if (!orderSnapshot.exists || data == null) {
        throw const OrderWorkflowException(
          'order-not-found',
          'Đơn thu gom không tồn tại.',
        );
      }
      if (!staffSnapshot.exists) {
        throw const OrderWorkflowException(
          'staff-not-found',
          'Hồ sơ nhân viên không tồn tại.',
        );
      }
      final order = FirestoreOrderMapper.fromMap(
        documentId: orderSnapshot.id,
        data: data,
      );
      if (order.trangThai != 'DANG_CAN_RAC' ||
          order.nhanVienHienTaiId != command.nhanVienId ||
          command.record.maDon != order.maDon ||
          command.record.nhanVienId != command.nhanVienId ||
          command.payment.maDon != order.maDon ||
          command.payment.khachHangId != order.khachHangId) {
        throw const OrderWorkflowException(
          'completion-denied',
          'Biên bản hoặc thanh toán không khớp với đơn.',
        );
      }

      if (order.hinhThucTinhPhi == 'GOI_THANG') {
        final subscriptionData = subscriptionSnapshot?.data();
        if (resolvedSubscriptionRef == null ||
            subscriptionSnapshot == null ||
            !subscriptionSnapshot.exists ||
            subscriptionData == null ||
            subscriptionData['khachHangId'] != order.khachHangId) {
          throw const OrderWorkflowException(
            'subscription-not-found',
            'Không tìm thấy gói tháng đang áp dụng.',
          );
        }
        final used = (subscriptionData['soKgDaDung'] as num?)?.toDouble() ?? 0;
        final remaining =
            (subscriptionData['soKgConLai'] as num?)?.toDouble() ?? 0;
        transaction.update(resolvedSubscriptionRef, <String, dynamic>{
          'soKgDaDung': used + command.record.khoiLuongThucTe,
          'soKgConLai': (remaining - command.record.khoiLuongThucTe).clamp(
            0,
            double.infinity,
          ),
          'maDonCapNhatCuoi': order.maDon,
        });
      }

      transaction.set(recordRef, _collectionRecordData(command.record));
      transaction.set(paymentRef, _paymentData(command.payment));
      transaction.update(orderRef, <String, dynamic>{
        'trangThai': 'HOAN_THANH',
        'bienBanId': command.record.bienBanId,
        'thanhToanId': command.payment.thanhToanId,
        'ngayCapNhat': Timestamp.fromDate(now),
      });
      transaction.update(staffRef, <String, dynamic>{
        'trangThaiLamViec': 'SAN_SANG',
      });
      transaction.set(
        logRef,
        _activityData(
          ref: logRef,
          maDon: order.maDon,
          userId: command.nhanVienId,
          action: 'Hoàn thành thu gom',
          note: 'Đã lưu biên bản và kết quả cân rác.',
          time: now,
        ),
      );
      transaction.set(
        notificationRef,
        _notificationData(
          ref: notificationRef,
          recipientId: order.khachHangId,
          maDon: order.maDon,
          type: 'HOAN_THANH',
          title: 'Đơn đã hoàn thành',
          content:
              '${order.maDon} đã thu gom ${command.record.khoiLuongThucTe} kg rác.',
          time: now,
        ),
      );
    });
  }

  @override
  Future<void> cancelOrder(CancelPickupOrderCommand command) async {
    final reason = command.lyDo.trim();
    if (reason.isEmpty) {
      throw const OrderWorkflowException(
        'reason-required',
        'Cần nhập lý do hủy đơn.',
      );
    }
    final orderRef = _orders.doc(command.maDon);
    final now = _clock();
    final logRef = _newDocument(lichSuHoatDongCollection, 'LOG');
    final notificationRef = _newDocument(thongBaoCollection, 'TB');

    await _firestore.runTransaction((transaction) async {
      final orderSnapshot = await transaction.get(orderRef);
      final data = orderSnapshot.data();
      if (!orderSnapshot.exists || data == null) {
        throw const OrderWorkflowException(
          'order-not-found',
          'Đơn thu gom không tồn tại.',
        );
      }
      final customerId = data['khachHangId'];
      final status = data['trangThai'];
      if (customerId is! String || customerId.isEmpty || status is! String) {
        throw const OrderWorkflowException(
          'invalid-order-data',
          'Don thu gom thieu thong tin can thiet de huy.',
        );
      }
      final orderId =
          data['maDon'] is String && (data['maDon'] as String).isNotEmpty
          ? data['maDon'] as String
          : orderSnapshot.id;
      final staffId = data['nhanVienHienTaiId'] is String
          ? data['nhanVienHienTaiId'] as String
          : null;
      final assignmentId = data['phanCongHienTaiId'] is String
          ? data['phanCongHienTaiId'] as String
          : null;
      final isCustomer = command.actorId == customerId;
      final isStaff = command.actorId == staffId;
      if (status == 'HOAN_THANH' ||
          status == 'HUY' ||
          (!isCustomer && !isStaff) ||
          (isCustomer && !_customerCancelableStatuses.contains(status))) {
        throw const OrderWorkflowException(
          'cancel-denied',
          'Tài khoản hoặc trạng thái hiện tại không được phép hủy đơn.',
        );
      }

      DocumentReference<Map<String, dynamic>>? assignmentRef;
      DocumentSnapshot<Map<String, dynamic>>? assignmentSnapshot;
      if (assignmentId != null && assignmentId.isNotEmpty) {
        assignmentRef = _assignments.doc(assignmentId);
        assignmentSnapshot = await transaction.get(assignmentRef);
      }
      final assignmentData = assignmentSnapshot?.data();
      DocumentReference<Map<String, dynamic>>? staffRef;
      DocumentSnapshot<Map<String, dynamic>>? staffSnapshot;
      if (isStaff && staffId != null && staffId.isNotEmpty) {
        staffRef = _firestore.collection(nhanVienThuGomCollection).doc(staffId);
        staffSnapshot = await transaction.get(staffRef);
      }

      transaction.update(orderRef, <String, dynamic>{
        'trangThai': 'HUY',
        'lyDoHuy': reason,
        'dangChoHoTro': false,
        'ngayCapNhat': Timestamp.fromDate(now),
      });
      if (assignmentRef != null &&
          assignmentSnapshot != null &&
          assignmentSnapshot.exists &&
          assignmentData != null &&
          {
            'CHO_PHAN_HOI',
            'CHO_NHAN',
          }.contains(assignmentData['trangThaiPhanCong'])) {
        transaction.update(assignmentRef, <String, dynamic>{
          'trangThaiPhanCong': AssignmentStatus.canceled.value,
          'thoiGianPhanHoi': Timestamp.fromDate(now),
          'ngayCapNhat': Timestamp.fromDate(now),
        });
      }
      if (staffRef != null && staffSnapshot?.exists == true) {
        final staffUpdates = <String, dynamic>{};
        if (_activeStaffStatuses.contains(status)) {
          staffUpdates['trangThaiLamViec'] = 'SAN_SANG';
        }
        if (staffUpdates.isNotEmpty) {
          transaction.update(staffRef, staffUpdates);
        }
      }
      transaction.set(
        logRef,
        _activityData(
          ref: logRef,
          maDon: orderId,
          userId: command.actorId,
          action: 'Hủy đơn',
          note: reason,
          time: now,
        ),
      );

      final recipientId = isCustomer ? staffId : customerId;
      if (recipientId != null) {
        transaction.set(
          notificationRef,
          _notificationData(
            ref: notificationRef,
            recipientId: recipientId,
            maDon: orderId,
            type: 'HUY',
            title: 'Đơn đã hủy',
            content: '$orderId: $reason',
            time: now,
          ),
        );
      }
    });
  }

  @override
  Future<void> confirmPayment(ConfirmPaymentCommand command) async {
    final orderRef = _orders.doc(command.maDon);
    final paymentRef = _firestore
        .collection(thanhToanCollection)
        .doc(command.thanhToanId);
    final now = _clock();
    final logRef = _newDocument(lichSuHoatDongCollection, 'LOG');

    await _firestore.runTransaction((transaction) async {
      final orderSnapshot = await transaction.get(orderRef);
      final paymentSnapshot = await transaction.get(paymentRef);
      final orderData = orderSnapshot.data();
      final paymentData = paymentSnapshot.data();
      if (!orderSnapshot.exists ||
          orderData == null ||
          !paymentSnapshot.exists ||
          paymentData == null) {
        throw const OrderWorkflowException(
          'payment-not-found',
          'Không tìm thấy đơn hoặc giao dịch thanh toán.',
        );
      }
      final order = FirestoreOrderMapper.fromMap(
        documentId: orderSnapshot.id,
        data: orderData,
      );
      if (order.khachHangId != command.khachHangId ||
          order.trangThai != 'HOAN_THANH' ||
          paymentData['maDon'] != order.maDon ||
          paymentData['khachHangId'] != command.khachHangId) {
        throw const OrderWorkflowException(
          'payment-denied',
          'Không thể xác nhận thanh toán cho giao dịch này.',
        );
      }

      transaction.update(paymentRef, <String, dynamic>{
        'phuongThuc': command.phuongThuc,
        'trangThai': 'DA_THANH_TOAN',
        'thoiGian': Timestamp.fromDate(now),
      });
      transaction.set(
        logRef,
        _activityData(
          ref: logRef,
          maDon: order.maDon,
          userId: command.khachHangId,
          action: 'Xác nhận thanh toán',
          note: 'Khách hàng đã xác nhận hoàn tất thanh toán.',
          time: now,
        ),
      );
    });
  }

  @override
  Future<void> updateStaffLocation(StaffLocationCommand command) async {
    if (command.latitude < -90 ||
        command.latitude > 90 ||
        command.longitude < -180 ||
        command.longitude > 180) {
      throw const OrderWorkflowException(
        'invalid-location',
        'Tọa độ nhân viên không hợp lệ.',
      );
    }
    final data = <String, dynamic>{
      'toaDoLat': command.latitude,
      'toaDoLng': command.longitude,
      'capNhatViTriLuc': Timestamp.fromDate(_clock()),
    };
    final label = command.label?.trim();
    if (label != null && label.isNotEmpty) {
      data['viTriHienTai'] = label;
    }
    final orderId = command.maDon;
    final destinationLatitude = command.diaChiLat;
    final destinationLongitude = command.diaChiLng;
    if (!command.canCheckPickupProximity ||
        orderId == null ||
        destinationLatitude == null ||
        destinationLongitude == null) {
      await _firestore
          .collection(nhanVienThuGomCollection)
          .doc(command.nhanVienId)
          .update(data);
      return;
    }

    final orderRef = _orders.doc(orderId);
    final staffRef = _firestore
        .collection(nhanVienThuGomCollection)
        .doc(command.nhanVienId);
    final now = _clock();

    await _firestore.runTransaction((transaction) async {
      final orderSnapshot = await transaction.get(orderRef);
      final order = orderSnapshot.data();
      transaction.update(staffRef, data);

      if (!orderSnapshot.exists ||
          order == null ||
          order['nhanVienHienTaiId'] != command.nhanVienId ||
          order['trangThai'] != 'DANG_DEN' ||
          order['khachHangId'] is! String) {
        return;
      }

      final distance = _distanceMeters(
        command.latitude,
        command.longitude,
        destinationLatitude,
        destinationLongitude,
      );
      final nearNotified = order['daThongBaoNhanVienSapDen'] == true;
      final arrivedNotified = order['daThongBaoNhanVienDaDen'] == true;

      if (distance <= _arrivedPickupDistanceMeters && !arrivedNotified) {
        final notificationRef = _newDocument(thongBaoCollection, 'TB');
        transaction.update(orderRef, <String, dynamic>{
          'daThongBaoNhanVienSapDen': true,
          'daThongBaoNhanVienDaDen': true,
          'ngayCapNhat': Timestamp.fromDate(now),
        });
        transaction.set(
          notificationRef,
          _notificationData(
            ref: notificationRef,
            recipientId: order['khachHangId'] as String,
            maDon: orderId,
            type: 'NHAN_VIEN_DA_DEN',
            title: 'Nhân viên đã đến',
            content:
                'Nhân viên đã đến gần điểm thu gom. Vui lòng chuẩn bị bàn giao rác.',
            time: now,
          ),
        );
        return;
      }

      if (distance <= _nearPickupDistanceMeters && !nearNotified) {
        final notificationRef = _newDocument(thongBaoCollection, 'TB');
        transaction.update(orderRef, <String, dynamic>{
          'daThongBaoNhanVienSapDen': true,
          'ngayCapNhat': Timestamp.fromDate(now),
        });
        transaction.set(
          notificationRef,
          _notificationData(
            ref: notificationRef,
            recipientId: order['khachHangId'] as String,
            maDon: orderId,
            type: 'NHAN_VIEN_SAP_DEN',
            title: 'Nhân viên sắp đến',
            content:
                'Nhân viên đang ở gần điểm thu gom, dự kiến sẽ đến trong ít phút.',
            time: now,
          ),
        );
      }
    });
  }

  double _distanceMeters(
    double firstLatitude,
    double firstLongitude,
    double secondLatitude,
    double secondLongitude,
  ) {
    const earthRadiusMeters = 6371000.0;
    final latitudeDelta = _toRadians(secondLatitude - firstLatitude);
    final longitudeDelta = _toRadians(secondLongitude - firstLongitude);
    final firstLatitudeRadians = _toRadians(firstLatitude);
    final secondLatitudeRadians = _toRadians(secondLatitude);
    final halfChord =
        math.sin(latitudeDelta / 2) * math.sin(latitudeDelta / 2) +
        math.cos(firstLatitudeRadians) *
            math.cos(secondLatitudeRadians) *
            math.sin(longitudeDelta / 2) *
            math.sin(longitudeDelta / 2);
    return earthRadiusMeters *
        2 *
        math.atan2(math.sqrt(halfChord), math.sqrt(1 - halfChord));
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;

  void _validateCreateCommand(CreatePickupOrderCommand command) {
    if (command.khachHangId.trim().isEmpty ||
        command.diaChiId.trim().isEmpty ||
        command.loaiRacId.trim().isEmpty) {
      throw const OrderWorkflowException(
        'missing-order-data',
        'Thiếu thông tin bắt buộc của đơn thu gom.',
      );
    }
    if (command.khoiLuongDuKien <= 0) {
      throw const OrderWorkflowException(
        'invalid-weight',
        'Khối lượng dự kiến phải lớn hơn 0.',
      );
    }
    if (!timeSlots.contains(command.khungGio) ||
        !feeTypes.contains(command.hinhThucTinhPhi)) {
      throw const OrderWorkflowException(
        'invalid-order-option',
        'Khung giờ hoặc hình thức tính phí không hợp lệ.',
      );
    }
  }

  void _validateCompletion(CompletePickupOrderCommand command) {
    if (command.record.khoiLuongThucTe <= 0 ||
        command.record.phiPhaiTra < 0 ||
        command.payment.soTien < 0) {
      throw const OrderWorkflowException(
        'invalid-completion-data',
        'Khối lượng hoặc số tiền hoàn tất không hợp lệ.',
      );
    }
  }

  DocumentReference<Map<String, dynamic>> _newDocument(
    String collection,
    String prefix,
  ) {
    final target = _firestore.collection(collection);
    return target.doc(_prefixedId(target, prefix));
  }

  String _prefixedId(
    CollectionReference<Map<String, dynamic>> collection,
    String prefix,
  ) {
    return '${prefix}_${collection.doc().id.toUpperCase()}';
  }

  Map<String, dynamic> _activityData({
    required DocumentReference<Map<String, dynamic>> ref,
    required String maDon,
    required String userId,
    required String action,
    required String note,
    required DateTime time,
  }) {
    return <String, dynamic>{
      'logId': ref.id,
      'maDon': maDon,
      'userId': userId,
      'hanhDong': action,
      'thoiGian': Timestamp.fromDate(time),
      'ghiChu': note,
    };
  }

  Map<String, dynamic> _notificationData({
    required DocumentReference<Map<String, dynamic>> ref,
    required String recipientId,
    required String maDon,
    required String type,
    required String title,
    required String content,
    required DateTime time,
  }) {
    return <String, dynamic>{
      'thongBaoId': ref.id,
      'nguoiNhanId': recipientId,
      'maDon': maDon,
      'loaiThongBao': type,
      'tieuDe': title,
      'noiDung': content,
      'trangThaiDoc': 'CHUA_DOC',
      'thoiGian': Timestamp.fromDate(time),
    };
  }

  Map<String, dynamic> _collectionRecordData(CollectionRecord record) {
    return <String, dynamic>{
      'bienBanId': record.bienBanId,
      'maDon': record.maDon,
      'nhanVienId': record.nhanVienId,
      'loaiRacThucTeId': record.loaiRacThucTeId,
      'khoiLuongThucTe': record.khoiLuongThucTe,
      if (record.anhXacNhanUrl != null) 'anhXacNhanUrl': record.anhXacNhanUrl,
      if (record.anhXacNhanBytes != null)
        'anhXacNhanBytes': Blob(record.anhXacNhanBytes!),
      'phiPhaiTra': record.phiPhaiTra,
      'trangThaiThanhToan': record.trangThaiThanhToan,
      'thoiGianLap': Timestamp.fromDate(record.thoiGianLap),
    };
  }

  Map<String, dynamic> _paymentData(PaymentRecord payment) {
    return <String, dynamic>{
      'thanhToanId': payment.thanhToanId,
      'maDon': payment.maDon,
      'khachHangId': payment.khachHangId,
      'soTien': payment.soTien,
      'phuongThuc': payment.phuongThuc,
      'trangThai': payment.trangThai,
      'thoiGian': Timestamp.fromDate(
        payment.thoiGianThanhToan ?? payment.thoiGianTao,
      ),
    };
  }

  bool _isInsidePickupSlot(PickupOrder order, DateTime arrival) {
    if (arrival.year != order.ngayThuGom.year ||
        arrival.month != order.ngayThuGom.month ||
        arrival.day != order.ngayThuGom.day) {
      return false;
    }
    final parts = order.khungGio.split('-');
    if (parts.length != 2) return false;
    final start = _minutes(parts.first);
    final end = _minutes(parts.last);
    if (start == null || end == null) return false;
    final arrivalMinutes = arrival.hour * 60 + arrival.minute;
    return arrivalMinutes >= start && arrivalMinutes < end;
  }

  int? _minutes(String value) {
    final parts = value.trim().split(':');
    if (parts.length == 1) {
      final hour = int.tryParse(parts.first);
      return hour == null ? null : hour * 60;
    }
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts.first);
    final minute = int.tryParse(parts.last);
    if (hour == null || minute == null) return null;
    return hour * 60 + minute;
  }

  _StatusCopy _statusCopy(String status) {
    return switch (status) {
      'DANG_DEN' => const _StatusCopy(
        action: 'Bắt đầu di chuyển',
        note: 'Nhân viên đang trên đường đến điểm thu gom.',
        customerMessage: 'Nhân viên đang di chuyển đến địa chỉ của bạn.',
      ),
      'DA_DEN' => const _StatusCopy(
        action: 'Đã đến điểm lấy',
        note: 'Nhân viên đã có mặt tại địa chỉ thu gom.',
        customerMessage: 'Nhân viên đã đến. Vui lòng chuẩn bị bàn giao rác.',
      ),
      'DANG_CAN_RAC' => const _StatusCopy(
        action: 'Bắt đầu cân rác',
        note: 'Nhân viên đang kiểm tra loại rác và khối lượng thực tế.',
        customerMessage: 'Rác đang được kiểm tra và cân thực tế.',
      ),
      _ => throw const OrderWorkflowException(
        'invalid-transition',
        'Trạng thái đích không hợp lệ.',
      ),
    };
  }
}

class _StatusCopy {
  const _StatusCopy({
    required this.action,
    required this.note,
    required this.customerMessage,
  });

  final String action;
  final String note;
  final String customerMessage;
}
