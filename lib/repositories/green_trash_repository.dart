import '../models/app_models.dart';

abstract class GreenTrashRepository {
  List<AppUser> get users;
  List<CustomerProfile> get customers;
  List<StaffProfile> get staff;
  List<CustomerAddress> get addresses;
  List<WasteType> get wasteTypes;
  List<PriceItem> get prices;
  List<PickupPackage> get packages;
  List<PackageSubscription> get subscriptions;
  List<PickupOrder> get initialOrders;
  List<ActivityLog> get activityLogs;
  List<AppNotification> get notifications;
  List<String> get timeSlots;
}

class MockGreenTrashRepository implements GreenTrashRepository {
  final _now = DateTime(2026, 7, 8, 9, 15);

  @override
  List<AppUser> get users => const [
    AppUser(
      userId: 'USER_KH_001',
      hoTen: 'Minh Anh',
      email: 'customer@greentrash.vn',
      soDienThoai: '0900000001',
      role: UserRole.customer,
    ),
    AppUser(
      userId: 'USER_NV_001',
      hoTen: 'Trần Duy',
      email: 'staff@greentrash.vn',
      soDienThoai: '0900000002',
      role: UserRole.staff,
    ),
    AppUser(
      userId: 'USER_NV_002',
      hoTen: 'Lê Thanh',
      email: 'staff2@greentrash.vn',
      soDienThoai: '0900000004',
      role: UserRole.staff,
    ),
    AppUser(
      userId: 'USER_ADMIN_001',
      hoTen: 'GreenTrash Admin',
      email: 'admin@greentrash.vn',
      soDienThoai: '0900000003',
      role: UserRole.admin,
    ),
  ];

  @override
  List<CustomerProfile> get customers => const [
    CustomerProfile(
      khachHangId: 'USER_KH_001',
      goiHienTaiId: 'DKG_001',
      diemUyTin: 100,
    ),
  ];

  @override
  List<StaffProfile> get staff => const [
    StaffProfile(
      nhanVienId: 'USER_NV_001',
      maNhanVien: 'NV001',
      trangThaiLamViec: 'SAN_SANG',
      gioBatDau: '06:00',
      gioKetThuc: '17:00',
      doanhThuHienTai: 0,
      viTriHienTai: 'Quận 3',
    ),
    StaffProfile(
      nhanVienId: 'USER_NV_002',
      maNhanVien: 'NV002',
      trangThaiLamViec: 'SAN_SANG',
      gioBatDau: '06:00',
      gioKetThuc: '17:00',
      doanhThuHienTai: 185000,
      viTriHienTai: 'Quận 1',
    ),
  ];

  @override
  List<CustomerAddress> get addresses => const [
    CustomerAddress(
      diaChiId: 'DC_001',
      khachHangId: 'USER_KH_001',
      diaChiChiTiet: '24 Nguyễn Thiện Thuật',
      phuongXa: 'Phường 4',
      quanHuyen: 'Quận 3',
      tinhThanh: 'TP.HCM',
      toaDoLat: 10.8231,
      toaDoLng: 106.6297,
      macDinh: true,
    ),
    CustomerAddress(
      diaChiId: 'DC_002',
      khachHangId: 'USER_KH_001',
      diaChiChiTiet: '12 Lê Văn Sỹ',
      phuongXa: 'Phường 11',
      quanHuyen: 'Quận Phú Nhuận',
      tinhThanh: 'TP.HCM',
      toaDoLat: 10.7922,
      toaDoLng: 106.6754,
      macDinh: false,
    ),
  ];

  @override
  List<WasteType> get wasteTypes => const [
    WasteType(
      loaiRacId: 'LR_HUU_CO',
      tenLoaiRac: 'Rác thực phẩm',
      nhomRac: 'Hữu cơ',
      moTa: 'Rau củ, thức ăn thừa, lá cây',
    ),
    WasteType(
      loaiRacId: 'LR_TAI_CHE',
      tenLoaiRac: 'Nhựa/giấy/kim loại',
      nhomRac: 'Tái chế',
      moTa: 'Chai nhựa, giấy, bìa carton, lon kim loại',
    ),
    WasteType(
      loaiRacId: 'LR_VO_CO',
      tenLoaiRac: 'Rác vô cơ thông thường',
      nhomRac: 'Vô cơ',
      moTa: 'Bao bì khó tái chế, vật liệu khó phân hủy',
    ),
  ];

  @override
  List<PriceItem> get prices => const [
    PriceItem(
      bangGiaId: 'BG_HUU_CO_ALL',
      loaiRacId: 'LR_HUU_CO',
      tenDichVu: 'Thu gom rác hữu cơ',
      donGiaKg: 3000,
      khuVuc: 'ALL',
    ),
    PriceItem(
      bangGiaId: 'BG_TAI_CHE_ALL',
      loaiRacId: 'LR_TAI_CHE',
      tenDichVu: 'Thu gom rác tái chế',
      donGiaKg: 5000,
      khuVuc: 'ALL',
    ),
    PriceItem(
      bangGiaId: 'BG_VO_CO_ALL',
      loaiRacId: 'LR_VO_CO',
      tenDichVu: 'Thu gom rác vô cơ',
      donGiaKg: 4500,
      khuVuc: 'ALL',
    ),
  ];

  @override
  List<PickupPackage> get packages => const [
    PickupPackage(
      goiId: 'GOI_126',
      tenGoi: 'Gói tháng 126kg',
      hanMucKgThang: 126,
      giaGoi: 300000,
      phiVuotGoi: 4000,
      moTa: 'Gói thu gom theo tháng với hạn mức 126kg',
    ),
  ];

  @override
  List<PackageSubscription> get subscriptions => const [
    PackageSubscription(
      dangKyGoiId: 'DKG_001',
      khachHangId: 'USER_KH_001',
      goiId: 'GOI_126',
      thangNam: '2026-07',
      soKgDaDung: 9.2,
      soKgConLai: 116.8,
      trangThai: 'CON_HL',
    ),
  ];

  @override
  List<PickupOrder> get initialOrders => [
    PickupOrder(
      maDon: 'DON_001',
      khachHangId: 'USER_KH_001',
      diaChiId: 'DC_001',
      loaiRacId: 'LR_TAI_CHE',
      nhanVienHienTaiId: 'USER_NV_001',
      khoiLuongDuKien: 8.5,
      ngayThuGom: DateTime(2026, 7, 8),
      khungGio: '08:00-10:00',
      gioChot: DateTime(2026, 7, 8, 8, 45),
      hinhThucTinhPhi: 'GOI_THANG',
      trangThai: 'DA_NHAN',
      ghiChu: 'Rác để trước cổng, có thùng màu xanh.',
      ngayTao: DateTime(2026, 7, 7, 20, 30),
    ),
    PickupOrder(
      maDon: 'DON_002',
      khachHangId: 'USER_KH_001',
      diaChiId: 'DC_002',
      loaiRacId: 'LR_HUU_CO',
      nhanVienDeXuatId: 'USER_NV_001',
      khoiLuongDuKien: 5,
      ngayThuGom: DateTime(2026, 7, 9),
      khungGio: '10:00-12:00',
      hinhThucTinhPhi: 'THEO_KG',
      trangThai: 'CHO_XU_LY',
      ghiChu: 'Có túi hữu cơ riêng trong bếp.',
      ngayTao: _now,
    ),
  ];

  @override
  List<ActivityLog> get activityLogs => [
    ActivityLog(
      logId: 'LOG_001',
      maDon: 'DON_001',
      userId: 'USER_KH_001',
      hanhDong: 'Tạo đơn thu gom',
      thoiGian: DateTime(2026, 7, 7, 20, 30),
      ghiChu: 'Khách hàng đặt lịch thu gom.',
    ),
    ActivityLog(
      logId: 'LOG_002',
      maDon: 'DON_001',
      userId: 'USER_NV_001',
      hanhDong: 'Nhận đơn',
      thoiGian: DateTime(2026, 7, 8, 8, 30),
      ghiChu: 'Nhân viên đã nhận đơn.',
    ),
  ];

  @override
  List<AppNotification> get notifications => [
    AppNotification(
      thongBaoId: 'TB_001',
      nguoiNhanId: 'USER_KH_001',
      maDon: 'DON_001',
      tieuDe: 'Nhân viên đã nhận đơn',
      noiDung: 'Đơn DON_001 đang được xử lý trong khung 08:00-10:00.',
      trangThaiDoc: 'CHUA_DOC',
      thoiGian: DateTime(2026, 7, 8, 8, 32),
    ),
  ];

  @override
  List<String> get timeSlots => const [
    '06:00-08:00',
    '08:00-10:00',
    '10:00-12:00',
    '13:00-15:00',
    '15:00-17:00',
  ];
}
