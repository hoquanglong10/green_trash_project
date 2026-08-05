import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_models.dart';

class FirestoreCatalogService {
  FirestoreCatalogService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _wasteTypesCollection {
    return _firestore.collection('LOAI_RAC');
  }

  CollectionReference<Map<String, dynamic>> get _pricesCollection {
    return _firestore.collection('DICH_VU_GIA_BIEU');
  }

  CollectionReference<Map<String, dynamic>> get _packagesCollection {
    return _firestore.collection('GOI_THU_GOM');
  }

  Future<void> seedCatalogIfEmpty({
    required List<WasteType> initialWasteTypes,
    required List<PriceItem> initialPrices,
    required List<PickupPackage> initialPackages,
  }) async {
    await _seedWasteTypesIfEmpty(initialWasteTypes);
    await _seedPricesIfEmpty(initialPrices);
    await _seedPackagesIfEmpty(initialPackages);
  }

  Future<void> _seedWasteTypesIfEmpty(List<WasteType> wasteTypes) async {
    final existingSnapshot = await _wasteTypesCollection.limit(1).get();

    if (existingSnapshot.docs.isNotEmpty || wasteTypes.isEmpty) {
      return;
    }

    final batch = _firestore.batch();

    for (final wasteType in wasteTypes) {
      batch.set(_wasteTypesCollection.doc(wasteType.loaiRacId), {
        'loaiRacId': wasteType.loaiRacId,
        'tenLoaiRac': wasteType.tenLoaiRac,
        'nhomRac': wasteType.nhomRac,
        'moTa': wasteType.moTa,
        'capNhatLuc': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  Future<void> _seedPricesIfEmpty(List<PriceItem> prices) async {
    final existingSnapshot = await _pricesCollection.limit(1).get();

    if (existingSnapshot.docs.isNotEmpty || prices.isEmpty) {
      return;
    }

    final batch = _firestore.batch();

    for (final price in prices) {
      batch.set(_pricesCollection.doc(price.bangGiaId), {
        'bangGiaId': price.bangGiaId,
        'loaiRacId': price.loaiRacId,
        'tenDichVu': price.tenDichVu,
        'donGiaKg': price.donGiaKg,
        'khuVuc': price.khuVuc,
        'capNhatLuc': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  Future<void> _seedPackagesIfEmpty(List<PickupPackage> packages) async {
    final existingSnapshot = await _packagesCollection.limit(1).get();

    if (existingSnapshot.docs.isNotEmpty || packages.isEmpty) {
      return;
    }

    final batch = _firestore.batch();

    for (final package in packages) {
      batch.set(_packagesCollection.doc(package.goiId), {
        'goiId': package.goiId,
        'tenGoi': package.tenGoi,
        'hanMucKgThang': package.hanMucKgThang,
        'giaGoi': package.giaGoi,
        'phiVuotGoi': package.phiVuotGoi,
        'moTa': package.moTa,
        'capNhatLuc': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  Future<List<WasteType>> getWasteTypes() async {
    final snapshot = await _wasteTypesCollection.get();

    final wasteTypes = snapshot.docs.map((document) {
      final data = document.data();

      return WasteType(
        loaiRacId: data['loaiRacId'] as String? ?? document.id,
        tenLoaiRac: data['tenLoaiRac'] as String? ?? 'Loại rác',
        nhomRac: data['nhomRac'] as String? ?? 'Khác',
        moTa: data['moTa'] as String? ?? '',
      );
    }).toList();

    wasteTypes.sort((a, b) => a.tenLoaiRac.compareTo(b.tenLoaiRac));

    return wasteTypes;
  }

  Future<List<PriceItem>> getPrices() async {
    final snapshot = await _pricesCollection.get();

    final prices = snapshot.docs.map((document) {
      final data = document.data();

      return PriceItem(
        bangGiaId: data['bangGiaId'] as String? ?? document.id,
        loaiRacId: data['loaiRacId'] as String? ?? '',
        tenDichVu: data['tenDichVu'] as String? ?? 'Dịch vụ thu gom',
        donGiaKg: (data['donGiaKg'] as num?)?.toInt() ?? 0,
        khuVuc: data['khuVuc'] as String? ?? 'ALL',
      );
    }).toList();

    prices.sort((a, b) => a.tenDichVu.compareTo(b.tenDichVu));

    return prices;
  }

  Future<List<PickupPackage>> getPackages() async {
    final snapshot = await _packagesCollection.get();

    final packages = snapshot.docs.map((document) {
      final data = document.data();

      return PickupPackage(
        goiId: data['goiId'] as String? ?? document.id,
        tenGoi: data['tenGoi'] as String? ?? 'Gói thu gom',
        hanMucKgThang: (data['hanMucKgThang'] as num?)?.toInt() ?? 0,
        giaGoi: (data['giaGoi'] as num?)?.toInt() ?? 0,
        phiVuotGoi: (data['phiVuotGoi'] as num?)?.toInt() ?? 0,
        moTa: data['moTa'] as String? ?? '',
      );
    }).toList();

    packages.sort((a, b) => a.hanMucKgThang.compareTo(b.hanMucKgThang));

    return packages;
  }
}
