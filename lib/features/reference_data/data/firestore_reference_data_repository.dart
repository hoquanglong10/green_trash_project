import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/app_models.dart';
import '../../../schema_contract.dart';

class FirestoreReferenceDataRepository {
  FirestoreReferenceDataRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<CustomerAddress>> watchCustomerAddresses(String customerId) {
    return _firestore
        .collection(diaChiCollection)
        .where('khachHangId', isEqualTo: customerId)
        .snapshots()
        .map((snapshot) {
          final addresses = snapshot.docs
              .map((doc) => _addressFromMap(doc.id, doc.data()))
              .whereType<CustomerAddress>()
              .toList();
          addresses.sort((first, second) {
            if (first.macDinh != second.macDinh) {
              return first.macDinh ? -1 : 1;
            }
            return first.diaChiChiTiet.compareTo(second.diaChiChiTiet);
          });
          return addresses;
        });
  }

  Future<String> saveCustomerAddress({
    String? addressId,
    required String customerId,
    required String detail,
    required String ward,
    required String district,
    required String city,
    required double latitude,
    required double longitude,
    required bool isDefault,
  }) async {
    final collection = _firestore.collection(diaChiCollection);
    final snapshot = await collection
        .where('khachHangId', isEqualTo: customerId)
        .get();
    final reference = addressId == null
        ? collection.doc()
        : collection.doc(addressId);
    QueryDocumentSnapshot<Map<String, dynamic>>? existing;
    for (final document in snapshot.docs) {
      if (document.id == reference.id) {
        existing = document;
        break;
      }
    }
    if (addressId != null && existing == null) {
      throw StateError('Địa chỉ không còn tồn tại.');
    }
    final shouldBeDefault =
        isDefault ||
        snapshot.docs.isEmpty ||
        existing?.data()['macDinh'] == true;
    final batch = _firestore.batch();
    if (shouldBeDefault) {
      for (final document in snapshot.docs) {
        if (document.id != reference.id && document.data()['macDinh'] == true) {
          batch.update(document.reference, {'macDinh': false});
        }
      }
    }
    batch.set(reference, {
      'diaChiId': reference.id,
      'khachHangId': customerId,
      'diaChiChiTiet': detail,
      'phuongXa': ward,
      'quanHuyen': district,
      'tinhThanh': city,
      'toaDoLat': latitude,
      'toaDoLng': longitude,
      'macDinh': shouldBeDefault,
      'trangThai': 'ACTIVE',
    });
    await batch.commit();
    return reference.id;
  }

  Future<void> setDefaultCustomerAddress({
    required String customerId,
    required String addressId,
  }) async {
    final snapshot = await _firestore
        .collection(diaChiCollection)
        .where('khachHangId', isEqualTo: customerId)
        .get();
    if (!snapshot.docs.any((document) => document.id == addressId)) {
      throw StateError('Địa chỉ không còn tồn tại.');
    }
    final batch = _firestore.batch();
    for (final document in snapshot.docs) {
      batch.update(document.reference, {'macDinh': document.id == addressId});
    }
    await batch.commit();
  }

  Future<void> deleteCustomerAddress({
    required String customerId,
    required String addressId,
  }) async {
    final snapshot = await _firestore
        .collection(diaChiCollection)
        .where('khachHangId', isEqualTo: customerId)
        .get();
    QueryDocumentSnapshot<Map<String, dynamic>>? removed;
    for (final document in snapshot.docs) {
      if (document.id == addressId) {
        removed = document;
        break;
      }
    }
    if (removed == null) throw StateError('Địa chỉ không còn tồn tại.');

    final batch = _firestore.batch()..delete(removed.reference);
    if (removed.data()['macDinh'] == true) {
      for (final document in snapshot.docs) {
        if (document.id != addressId) {
          batch.update(document.reference, {'macDinh': true});
          break;
        }
      }
    }
    await batch.commit();
  }

  Stream<List<CustomerAddress>> watchAllAddresses() {
    return _firestore
        .collection(diaChiCollection)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _addressFromMap(doc.id, doc.data()))
              .whereType<CustomerAddress>()
              .toList(growable: false),
        );
  }

  Stream<List<WasteType>> watchWasteTypes() {
    return _firestore
        .collection(loaiRacCollection)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .where((doc) => _isActive(doc.data()))
              .map((doc) => _wasteFromMap(doc.id, doc.data()))
              .whereType<WasteType>()
              .toList(growable: false),
        );
  }

  Stream<List<PriceItem>> watchPriceItems() {
    return _firestore
        .collection(dichVuGiaBieuCollection)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .where((doc) => _isActive(doc.data()))
              .map((doc) => _priceFromMap(doc.id, doc.data()))
              .whereType<PriceItem>()
              .toList(growable: false),
        );
  }

  Stream<List<PickupPackage>> watchPackages() {
    return _firestore
        .collection(goiThuGomCollection)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .where((doc) => _isActive(doc.data()))
              .map((doc) => _packageFromMap(doc.id, doc.data()))
              .whereType<PickupPackage>()
              .toList(growable: false),
        );
  }

  Stream<List<PackageSubscription>> watchCustomerSubscriptions(
    String customerId,
  ) {
    return _firestore
        .collection(dangKyGoiCollection)
        .where('khachHangId', isEqualTo: customerId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _subscriptionFromMap(doc.id, doc.data()))
              .whereType<PackageSubscription>()
              .toList(growable: false),
        );
  }

  Stream<List<StaffProfile>> watchStaffProfiles() {
    return _firestore
        .collection(nhanVienThuGomCollection)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _staffFromMap(doc.id, doc.data()))
              .whereType<StaffProfile>()
              .toList(growable: false),
        );
  }

  Stream<List<AppNotification>> watchNotifications(String recipientId) {
    return _firestore
        .collection(thongBaoCollection)
        .where('nguoiNhanId', isEqualTo: recipientId)
        .snapshots()
        .map((snapshot) {
          final notifications = snapshot.docs
              .map((doc) => _notificationFromMap(doc.id, doc.data()))
              .whereType<AppNotification>()
              .toList(growable: false);
          notifications.sort(
            (first, second) => second.thoiGian.compareTo(first.thoiGian),
          );
          return notifications;
        });
  }

  Future<void> updateStaffAvailability({
    required String staffId,
    required String status,
  }) {
    return _firestore.collection(nhanVienThuGomCollection).doc(staffId).update({
      'trangThaiLamViec': status,
    });
  }

  CustomerAddress? _addressFromMap(
    String documentId,
    Map<String, dynamic> data,
  ) {
    final customerId = _string(data['khachHangId']);
    final detail = _string(data['diaChiChiTiet']);
    if (customerId.isEmpty || detail.isEmpty) return null;
    return CustomerAddress(
      diaChiId: _string(data['diaChiId'], fallback: documentId),
      khachHangId: customerId,
      diaChiChiTiet: detail,
      phuongXa: _string(data['phuongXa']),
      quanHuyen: _string(data['quanHuyen']),
      tinhThanh: _string(data['tinhThanh']),
      toaDoLat: _double(data['toaDoLat']),
      toaDoLng: _double(data['toaDoLng']),
      macDinh: data['macDinh'] == true,
    );
  }

  WasteType? _wasteFromMap(String documentId, Map<String, dynamic> data) {
    final name = _string(data['tenLoaiRac']);
    if (name.isEmpty) return null;
    return WasteType(
      loaiRacId: _string(data['loaiRacId'], fallback: documentId),
      tenLoaiRac: name,
      nhomRac: _string(data['nhomRac']),
      moTa: _string(data['moTa']),
    );
  }

  PriceItem? _priceFromMap(String documentId, Map<String, dynamic> data) {
    final wasteId = _string(data['loaiRacId']);
    final price = data['donGiaKg'];
    if (wasteId.isEmpty || price is! num) return null;
    return PriceItem(
      bangGiaId: _string(data['bangGiaId'], fallback: documentId),
      loaiRacId: wasteId,
      tenDichVu: _string(data['tenDichVu']),
      donGiaKg: price.toInt(),
      khuVuc: _string(data['khuVuc']),
    );
  }

  PickupPackage? _packageFromMap(String documentId, Map<String, dynamic> data) {
    final name = _string(data['tenGoi']);
    final limit = data['hanMucKgThang'];
    final price = data['giaGoi'];
    final excess = data['phiVuotGoi'];
    if (name.isEmpty || limit is! num || price is! num || excess is! num) {
      return null;
    }
    return PickupPackage(
      goiId: _string(data['goiId'], fallback: documentId),
      tenGoi: name,
      hanMucKgThang: limit.toInt(),
      giaGoi: price.toInt(),
      phiVuotGoi: excess.toInt(),
      moTa: _string(data['moTa']),
    );
  }

  PackageSubscription? _subscriptionFromMap(
    String documentId,
    Map<String, dynamic> data,
  ) {
    final customerId = _string(data['khachHangId']);
    final packageId = _string(data['goiId']);
    if (customerId.isEmpty || packageId.isEmpty) return null;
    return PackageSubscription(
      dangKyGoiId: _string(data['dangKyGoiId'], fallback: documentId),
      khachHangId: customerId,
      goiId: packageId,
      thangNam: _string(data['thangNam']),
      soKgDaDung: _double(data['soKgDaDung']),
      soKgConLai: _double(data['soKgConLai']),
      trangThai: _string(data['trangThai']),
    );
  }

  StaffProfile? _staffFromMap(String documentId, Map<String, dynamic> data) {
    final code = _string(data['maNhanVien']);
    if (code.isEmpty) return null;
    return StaffProfile(
      nhanVienId: _string(data['nhanVienId'], fallback: documentId),
      maNhanVien: code,
      trangThaiLamViec: _string(data['trangThaiLamViec'], fallback: 'TAM_NGHI'),
      gioBatDau: _string(data['gioBatDau'], fallback: '06:00'),
      gioKetThuc: _string(data['gioKetThuc'], fallback: '17:00'),
      doanhThuHienTai: data['doanhThuHienTai'] is num
          ? data['doanhThuHienTai'] as num
          : 0,
      viTriHienTai: _string(data['viTriHienTai']),
      toaDoLat: _optionalDouble(data['toaDoLat']),
      toaDoLng: _optionalDouble(data['toaDoLng']),
      capNhatViTriLuc: _optionalDate(data['capNhatViTriLuc']),
    );
  }

  AppNotification? _notificationFromMap(
    String documentId,
    Map<String, dynamic> data,
  ) {
    final recipientId = _string(data['nguoiNhanId']);
    final title = _string(data['tieuDe']);
    final content = _string(data['noiDung']);
    final time = _optionalDate(data['thoiGian']);
    if (recipientId.isEmpty ||
        title.isEmpty ||
        content.isEmpty ||
        time == null) {
      return null;
    }
    return AppNotification(
      thongBaoId: _string(data['thongBaoId'], fallback: documentId),
      nguoiNhanId: recipientId,
      maDon: _string(data['maDon']).isEmpty ? null : _string(data['maDon']),
      tieuDe: title,
      noiDung: content,
      trangThaiDoc: _string(data['trangThaiDoc'], fallback: 'CHUA_DOC'),
      thoiGian: time,
    );
  }

  bool _isActive(Map<String, dynamic> data) {
    final status = data['trangThai'];
    return status == null || status == 'ACTIVE';
  }

  String _string(Object? value, {String fallback = ''}) {
    return value is String && value.trim().isNotEmpty ? value.trim() : fallback;
  }

  double _double(Object? value) => value is num ? value.toDouble() : 0;

  double? _optionalDouble(Object? value) =>
      value is num ? value.toDouble() : null;

  DateTime? _optionalDate(Object? value) {
    if (value is Timestamp) return value.toDate();
    return value is DateTime ? value : null;
  }
}
