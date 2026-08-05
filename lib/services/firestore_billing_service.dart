import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_models.dart';

class FirestoreBillingService {
  FirestoreBillingService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _paymentsCollection {
    return _firestore.collection('THANH_TOAN');
  }

  CollectionReference<Map<String, dynamic>> get _invoicesCollection {
    return _firestore.collection('HOA_DON');
  }

  Future<void> seedDataIfEmpty({
    required String customerId,
    required List<PaymentRecord> initialPayments,
    required List<Invoice> initialInvoices,
  }) async {
    final existingPayments = await _paymentsCollection
        .where('khachHangId', isEqualTo: customerId)
        .limit(1)
        .get();

    if (existingPayments.docs.isNotEmpty) {
      return;
    }

    final customerPayments = initialPayments
        .where((payment) => payment.khachHangId == customerId)
        .toList();

    if (customerPayments.isEmpty) {
      return;
    }

    final paymentIds = customerPayments
        .map((payment) => payment.thanhToanId)
        .toSet();

    final customerInvoices = initialInvoices
        .where(
          (invoice) =>
              invoice.thanhToanId != null &&
              paymentIds.contains(invoice.thanhToanId),
        )
        .toList();

    final batch = _firestore.batch();

    for (final payment in customerPayments) {
      batch.set(
        _paymentsCollection.doc(payment.thanhToanId),
        _paymentToFirestore(payment),
        SetOptions(merge: true),
      );
    }

    for (final invoice in customerInvoices) {
      batch.set(
        _invoicesCollection.doc(invoice.hoaDonId),
        _invoiceToFirestore(invoice),
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }

  Future<List<PaymentRecord>> getPayments(String customerId) async {
    final snapshot = await _paymentsCollection
        .where('khachHangId', isEqualTo: customerId)
        .get();

    final payments = snapshot.docs
        .map((document) => _paymentFromFirestore(document.id, document.data()))
        .toList();

    payments.sort((a, b) => b.thoiGian.compareTo(a.thoiGian));

    return payments;
  }

  Future<List<Invoice>> getInvoicesForPayments(List<String> paymentIds) async {
    if (paymentIds.isEmpty) {
      return const <Invoice>[];
    }

    final snapshot = await _invoicesCollection.get();

    final invoices = snapshot.docs
        .map((document) => _invoiceFromFirestore(document.id, document.data()))
        .where(
          (invoice) =>
              invoice.thanhToanId != null &&
              paymentIds.contains(invoice.thanhToanId),
        )
        .toList();

    invoices.sort((a, b) => b.thoiGianTao.compareTo(a.thoiGianTao));

    return invoices;
  }

  Map<String, dynamic> _paymentToFirestore(PaymentRecord payment) {
    return {
      'thanhToanId': payment.thanhToanId,
      'maDon': payment.maDon,
      'khachHangId': payment.khachHangId,
      'soTien': payment.soTien,
      'phuongThuc': payment.phuongThuc,
      'maGiaoDichNgoai': payment.maGiaoDichNgoai,
      'trangThai': payment.trangThai,
      'thoiGian': Timestamp.fromDate(payment.thoiGian),
      'capNhatLuc': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> _invoiceToFirestore(Invoice invoice) {
    return {
      'hoaDonId': invoice.hoaDonId,
      'maDon': invoice.maDon,
      'thanhToanId': invoice.thanhToanId,
      'soKgThucTe': invoice.soKgThucTe,
      'donGia': invoice.donGia,
      'tongTien': invoice.tongTien,
      'filePdfUrl': invoice.filePdfUrl,
      'thoiGianTao': Timestamp.fromDate(invoice.thoiGianTao),
      'capNhatLuc': FieldValue.serverTimestamp(),
    };
  }

  PaymentRecord _paymentFromFirestore(
    String documentId,
    Map<String, dynamic> data,
  ) {
    return PaymentRecord(
      thanhToanId: data['thanhToanId'] as String? ?? documentId,
      maDon: data['maDon'] as String? ?? '',
      khachHangId: data['khachHangId'] as String? ?? '',
      soTien: (data['soTien'] as num?)?.toInt() ?? 0,
      phuongThuc: data['phuongThuc'] as String? ?? 'TIEN_MAT',
      maGiaoDichNgoai: data['maGiaoDichNgoai'] as String?,
      trangThai: data['trangThai'] as String? ?? 'CHO_THANH_TOAN',
      thoiGian: _readDateTime(data['thoiGian']),
    );
  }

  Invoice _invoiceFromFirestore(String documentId, Map<String, dynamic> data) {
    return Invoice(
      hoaDonId: data['hoaDonId'] as String? ?? documentId,
      maDon: data['maDon'] as String? ?? '',
      thanhToanId: data['thanhToanId'] as String?,
      soKgThucTe: (data['soKgThucTe'] as num?)?.toDouble() ?? 0,
      donGia: (data['donGia'] as num?)?.toInt() ?? 0,
      tongTien: (data['tongTien'] as num?)?.toInt() ?? 0,
      filePdfUrl: data['filePdfUrl'] as String?,
      thoiGianTao: _readDateTime(data['thoiGianTao']),
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
