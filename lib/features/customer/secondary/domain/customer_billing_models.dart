class CustomerPayment {
  const CustomerPayment({
    required this.thanhToanId,
    required this.maDon,
    required this.khachHangId,
    required this.soTien,
    required this.phuongThuc,
    required this.trangThai,
    required this.thoiGian,
    this.maGiaoDichNgoai,
  });

  final String thanhToanId;
  final String maDon;
  final String khachHangId;
  final int soTien;
  final String phuongThuc;
  final String? maGiaoDichNgoai;
  final String trangThai;
  final DateTime thoiGian;
}

class CustomerInvoice {
  const CustomerInvoice({
    required this.hoaDonId,
    required this.maDon,
    required this.soKgThucTe,
    required this.donGia,
    required this.tongTien,
    required this.thoiGianTao,
    this.thanhToanId,
    this.filePdfUrl,
  });

  final String hoaDonId;
  final String maDon;
  final String? thanhToanId;
  final double soKgThucTe;
  final int donGia;
  final int tongTien;
  final String? filePdfUrl;
  final DateTime thoiGianTao;
}
