import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/customer_billing_models.dart';

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

  Future<List<CustomerPayment>> getPayments(String customerId) async {
    final snapshot = await _paymentsCollection
        .where('khachHangId', isEqualTo: customerId)
        .get();

    final payments = snapshot.docs
        .map((document) => _paymentFromFirestore(document.id, document.data()))
        .toList();

    payments.sort((a, b) => b.thoiGian.compareTo(a.thoiGian));

    return payments;
  }

  Future<List<CustomerInvoice>> getInvoicesForPayments(
    List<String> paymentIds,
  ) async {
    if (paymentIds.isEmpty) {
      return const <CustomerInvoice>[];
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

  CustomerPayment _paymentFromFirestore(
    String documentId,
    Map<String, dynamic> data,
  ) {
    return CustomerPayment(
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

  CustomerInvoice _invoiceFromFirestore(
    String documentId,
    Map<String, dynamic> data,
  ) {
    return CustomerInvoice(
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
