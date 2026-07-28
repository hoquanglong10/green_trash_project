import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../models/app_models.dart';
import '../../../schema_contract.dart';

class FirebaseAuthenticationService {
  FirebaseAuthenticationService(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<AppSession?> restoreSession() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _loadSession(user);
  }

  Future<AppSession> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthenticationException(
          'sign-in-failed',
          'Khong the xac nhan tai khoan dang nhap.',
        );
      }
      try {
        return await _loadSession(user);
      } on AuthenticationException {
        await _auth.signOut();
        rethrow;
      }
    } on FirebaseAuthException catch (error) {
      throw AuthenticationException(error.code, _authMessage(error.code));
    }
  }

  Future<AppSession> registerCustomer({
    required String fullName,
    required String phone,
    required String email,
    required String password,
  }) async {
    final normalizedName = fullName.trim();
    final normalizedEmail = email.trim();
    if (normalizedName.isEmpty ||
        normalizedEmail.isEmpty ||
        password.length < 6) {
      throw const AuthenticationException(
        'invalid-registration',
        'Vui long nhap ho ten, email va mat khau tu 6 ky tu.',
      );
    }

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthenticationException(
          'registration-failed',
          'Khong the tao tai khoan moi.',
        );
      }

      final now = Timestamp.now();
      await _firestore.collection(nguoiDungCollection).doc(user.uid).set({
        'userId': user.uid,
        'uidFirebase': user.uid,
        'hoTen': normalizedName,
        'soDienThoai': phone.trim(),
        'email': normalizedEmail,
        'roleId': UserRole.customer.id,
        'trangThai': 'ACTIVE',
        'ngayTao': now,
        'ngayCapNhat': now,
      });
      await _firestore.collection(khachHangCollection).doc(user.uid).set({
        'khachHangId': user.uid,
        'goiHienTaiId': null,
        'diemUyTin': 0,
        'ghiChuCSKH': '',
      });
      return _loadSession(user);
    } on FirebaseAuthException catch (error) {
      throw AuthenticationException(error.code, _authMessage(error.code));
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error) {
      throw AuthenticationException(error.code, _authMessage(error.code));
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<AppSession> _loadSession(User firebaseUser) async {
    final snapshot = await _readUserProfile(firebaseUser);
    final data = snapshot.data();
    if (!snapshot.exists || data == null) {
      throw const AuthenticationException(
        'profile-missing',
        'Tai khoan da dang nhap nhung chua co ho so NGUOI_DUNG trung UID Firebase.',
      );
    }
    if (data['trangThai'] != 'ACTIVE') {
      throw const AuthenticationException(
        'account-inactive',
        'Tai khoan hien khong o trang thai hoat dong.',
      );
    }

    final role = _roleFromValue(data['roleId']);
    if (role == null) {
      throw const AuthenticationException(
        'invalid-role',
        'Ho so tai khoan co vai tro khong hop le.',
      );
    }

    return AppSession(
      role: role,
      user: AppUser(
        userId: firebaseUser.uid,
        hoTen: _string(
          data['hoTen'],
          fallback: firebaseUser.displayName ?? 'Nguoi dung',
        ),
        email: _string(data['email'], fallback: firebaseUser.email ?? ''),
        soDienThoai: _string(data['soDienThoai']),
        role: role,
      ),
    );
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _readUserProfile(
    User firebaseUser,
  ) async {
    try {
      return await _firestore
          .collection(nguoiDungCollection)
          .doc(firebaseUser.uid)
          .get();
    } on FirebaseException catch (error) {
      throw AuthenticationException(
        'profile-${error.code}',
        _profileReadMessage(error.code),
      );
    }
  }

  String _profileReadMessage(String code) {
    return switch (code) {
      'permission-denied' =>
        'Firestore Rules khong cho doc ho so NGUOI_DUNG cua tai khoan nay. Kiem tra document ID co trung Firebase Auth UID va roleId/trangThai.',
      'unavailable' =>
        'Khong the ket noi Firestore de tai ho so tai khoan. Vui long thu lai.',
      _ => 'Khong the doc ho so Firestore cua tai khoan ($code).',
    };
  }

  UserRole? _roleFromValue(Object? value) {
    for (final role in UserRole.values) {
      if (role.id == value) return role;
    }
    return null;
  }

  String _string(Object? value, {String fallback = ''}) {
    return value is String && value.trim().isNotEmpty ? value.trim() : fallback;
  }

  String _authMessage(String code) {
    return switch (code) {
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' => 'Email hoac mat khau khong dung.',
      'invalid-email' => 'Email khong hop le.',
      'email-already-in-use' => 'Email nay da duoc su dung.',
      'weak-password' => 'Mat khau can it nhat 6 ky tu.',
      'too-many-requests' => 'Da thu qua nhieu lan. Vui long thu lai sau.',
      _ => 'Khong the xu ly yeu cau tai khoan luc nay.',
    };
  }
}

class AuthenticationException implements Exception {
  const AuthenticationException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'AuthenticationException($code): $message';
}
