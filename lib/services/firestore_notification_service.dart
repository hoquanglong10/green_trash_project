import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_models.dart';

class FirestoreNotificationService {
  FirestoreNotificationService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _notificationCollection {
    return _firestore.collection('THONG_BAO');
  }

  /// Lấy thông báo của một khách hàng từ Firestore.
  Future<List<AppNotification>> getNotifications(String userId) async {
    final snapshot = await _notificationCollection
        .where('nguoiNhanId', isEqualTo: userId)
        .get();

    final notifications = snapshot.docs
        .map((document) => _fromFirestore(document.id, document.data()))
        .toList();

    notifications.sort((a, b) => b.thoiGian.compareTo(a.thoiGian));

    return notifications;
  }

  /// Tạo dữ liệu ban đầu từ repository mock nếu Firestore chưa có thông báo.
  Future<void> seedNotificationsIfEmpty({
    required String userId,
    required List<AppNotification> initialNotifications,
  }) async {
    final existingSnapshot = await _notificationCollection
        .where('nguoiNhanId', isEqualTo: userId)
        .limit(1)
        .get();

    if (existingSnapshot.docs.isNotEmpty) {
      return;
    }

    final userNotifications = initialNotifications
        .where((notification) => notification.nguoiNhanId == userId)
        .toList();

    if (userNotifications.isEmpty) {
      return;
    }

    final batch = _firestore.batch();

    for (final notification in userNotifications) {
      final documentReference = _notificationCollection.doc(
        notification.thongBaoId,
      );

      batch.set(
        documentReference,
        _toFirestore(notification),
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }

  /// Đánh dấu một thông báo là đã đọc.
  Future<void> markAsRead(String notificationId) async {
    await _notificationCollection.doc(notificationId).update({
      'trangThaiDoc': 'DA_DOC',
      'capNhatLuc': FieldValue.serverTimestamp(),
    });
  }

  /// Đánh dấu tất cả thông báo của người dùng là đã đọc.
  Future<void> markAllAsRead(String userId) async {
    final snapshot = await _notificationCollection
        .where('nguoiNhanId', isEqualTo: userId)
        .get();

    final unreadDocuments = snapshot.docs.where(
      (document) => document.data()['trangThaiDoc'] == 'CHUA_DOC',
    );

    final batch = _firestore.batch();
    var hasChanges = false;

    for (final document in unreadDocuments) {
      hasChanges = true;

      batch.update(document.reference, {
        'trangThaiDoc': 'DA_DOC',
        'capNhatLuc': FieldValue.serverTimestamp(),
      });
    }

    if (hasChanges) {
      await batch.commit();
    }
  }

  Map<String, dynamic> _toFirestore(AppNotification notification) {
    return {
      'thongBaoId': notification.thongBaoId,
      'nguoiNhanId': notification.nguoiNhanId,
      'maDon': notification.maDon,
      'tieuDe': notification.tieuDe,
      'noiDung': notification.noiDung,
      'trangThaiDoc': notification.trangThaiDoc,
      'thoiGian': Timestamp.fromDate(notification.thoiGian),
      'capNhatLuc': FieldValue.serverTimestamp(),
    };
  }

  AppNotification _fromFirestore(String documentId, Map<String, dynamic> data) {
    return AppNotification(
      thongBaoId: data['thongBaoId'] as String? ?? documentId,
      nguoiNhanId: data['nguoiNhanId'] as String? ?? '',
      maDon: data['maDon'] as String?,
      tieuDe: data['tieuDe'] as String? ?? 'Thông báo GreenTrash',
      noiDung: data['noiDung'] as String? ?? '',
      trangThaiDoc: data['trangThaiDoc'] as String? ?? 'CHUA_DOC',
      thoiGian: _readDateTime(data['thoiGian']),
    );
  }

  DateTime _readDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.now();
  }
}
