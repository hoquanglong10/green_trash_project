import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../models/app_models.dart';

class FirestoreCustomerService {
  FirestoreCustomerService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersCollection {
    return _firestore.collection('NGUOI_DUNG');
  }

  Future<void> saveProfile(AppUser user) async {
    await _usersCollection.doc(user.userId).set({
      'userId': user.userId,
      'hoTen': user.hoTen,
      'email': user.email,
      'soDienThoai': user.soDienThoai,
      'vaiTro': user.role.name,
      'capNhatLuc': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<AppUser?> getProfile({required AppUser fallbackUser}) async {
    final snapshot = await _usersCollection.doc(fallbackUser.userId).get();

    final data = snapshot.data();

    if (!snapshot.exists || data == null) {
      return null;
    }

    return AppUser(
      userId: data['userId'] as String? ?? fallbackUser.userId,
      hoTen: data['hoTen'] as String? ?? fallbackUser.hoTen,
      email: data['email'] as String? ?? fallbackUser.email,
      soDienThoai: data['soDienThoai'] as String? ?? fallbackUser.soDienThoai,
      role: fallbackUser.role,
    );
  }
}
