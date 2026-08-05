import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../models/app_models.dart';

class FirestorePackageService {
  FirestorePackageService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _subscriptionsCollection {
    return _firestore.collection('DANG_KY_GOI');
  }

  Future<void> saveSubscription(PackageSubscription subscription) async {
    await _subscriptionsCollection.doc(subscription.khachHangId).set({
      'dangKyGoiId': subscription.dangKyGoiId,
      'khachHangId': subscription.khachHangId,
      'goiId': subscription.goiId,
      'thangNam': subscription.thangNam,
      'soKgDaDung': subscription.soKgDaDung,
      'soKgConLai': subscription.soKgConLai,
      'trangThai': subscription.trangThai,
      'capNhatLuc': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<PackageSubscription?> getSubscription(String customerId) async {
    final snapshot = await _subscriptionsCollection.doc(customerId).get();

    final data = snapshot.data();

    if (!snapshot.exists || data == null) {
      return null;
    }

    return PackageSubscription(
      dangKyGoiId: data['dangKyGoiId'] as String? ?? 'DKG_$customerId',
      khachHangId: data['khachHangId'] as String? ?? customerId,
      goiId: data['goiId'] as String? ?? '',
      thangNam: data['thangNam'] as String? ?? '',
      soKgDaDung: (data['soKgDaDung'] as num?)?.toDouble() ?? 0,
      soKgConLai: (data['soKgConLai'] as num?)?.toDouble() ?? 0,
      trangThai: data['trangThai'] as String? ?? 'CON_HL',
    );
  }
}
