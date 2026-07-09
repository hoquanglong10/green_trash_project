enum SchemaFieldType {
  string,
  number,
  boolean,
  timestamp,
  geoPoint,
  stringArray,
}

class SchemaField {
  const SchemaField({
    required this.name,
    required this.type,
    required this.required,
    this.allowedValues = const <String>{},
  });

  final String name;
  final SchemaFieldType type;
  final bool required;
  final Set<String> allowedValues;
}

class CollectionSchema {
  const CollectionSchema({
    required this.name,
    required this.documentIdField,
    required this.fields,
  });

  final String name;
  final String documentIdField;
  final List<SchemaField> fields;

  Set<String> get fieldNames => fields.map((field) => field.name).toSet();
}

// Contract aligned to the real Firestore data read from greentrashdb on
// 2026-07-08. Firestore collection names are case-sensitive.
const vaiTroCollection = 'VAI_TRO';
const nguoiDungCollection = 'NGUOI_DUNG';
const khachHangCollection = 'KHACH_HANG';
const nhanVienThuGomCollection = 'NHAN_VIEN_THU_GOM';
const adminCollection = 'ADMIN';
const diaChiCollection = 'DIA_CHI';
const loaiRacCollection = 'LOAI_RAC';
const dichVuGiaBieuCollection = 'DICH_VU_GIA_BIEU';
const goiThuGomCollection = 'GOI_THU_GOM';
const dangKyGoiCollection = 'DANG_KY_GOI';
const donThuGomCollection = 'DON_THU_GOM';
const phanCongThuGomCollection = 'PHAN_CONG_THU_GOM';
const bienBanThuGomCollection = 'BIEN_BAN_THU_GOM';
const thanhToanCollection = 'THANH_TOAN';
const hoaDonCollection = 'HOA_DON';
const doanhThuNhanVienCollection = 'DOANH_THU_NHAN_VIEN';
const khieuNaiCollection = 'KHIEU_NAI';
const danhGiaCollection = 'DANH_GIA';
const thongBaoCollection = 'THONG_BAO';
const lichSuHoatDongCollection = 'LICH_SU_HOAT_DONG';
const thongKeTongHopCollection = 'THONG_KE_TONG_HOP';
const thamSoHeThongCollection = 'THAM_SO_HE_THONG';

const userRoles = {'ADMIN', 'CUSTOMER', 'STAFF'};
const activeStates = {'ACTIVE', 'LOCKED', 'DELETED', 'INACTIVE'};
const staffWorkStates = {
  'SAN_SANG',
  'DANG_RANH',
  'DANG_THU_GOM',
  'TAM_NGHI',
  'NGHI_VIEC',
};
const wasteGroups = {
  'HUU_CO',
  'VO_CO',
  'TAI_CHE',
  'Hữu cơ',
  'Vô cơ',
  'Tái chế',
};
const orderStatuses = {
  'CHO_XU_LY',
  'CHO_NHAN',
  'DA_NHAN',
  'DANG_DEN',
  'DA_DEN',
  'DANG_CAN_RAC',
  'HOAN_THANH',
  'HUY',
};
const timeSlots = {
  '06:00-08:00',
  '08:00-10:00',
  '10:00-12:00',
  '13:00-15:00',
  '15:00-17:00',
  // Existing sample data currently uses this short form.
  '08-10',
};
const feeTypes = {'GOI_THANG', 'THEO_KG'};
const assignmentStatuses = {'CHO_NHAN', 'DA_NHAN', 'TU_CHOI', 'HUY'};
const packageStatuses = {
  'CHO_THANH_TOAN',
  'CON_HIEU_LUC',
  'HET_HAN',
  'HUY',
  // Existing sample data currently uses this short form.
  'CON_HL',
};
const paymentMethods = {
  'TIEN_MAT',
  'BANKING',
  'CHUYEN_KHOAN',
  'VI_DIEN_TU',
  // Existing sample data currently stores the fee type in this field.
  'GOI_THANG',
};
const paymentStatuses = {
  'CHO_THANH_TOAN',
  'DA_THANH_TOAN',
  'THAT_BAI',
  'HOAN_TIEN',
  // Existing sample data currently uses this short form.
  'DA_TT',
};
const reconciliationStatuses = {'CHO_DS', 'DA_DS', 'HUY'};
const complaintStatuses = {
  'MOI',
  'CHO_XU_LY',
  'DANG_XU_LY',
  'DA_PHAN_HOI',
  'DONG',
};
const readStatuses = {'CHUA_DOC', 'DA_DOC'};

const greenTrashSchemas = <CollectionSchema>[
  CollectionSchema(
    name: vaiTroCollection,
    documentIdField: 'roleId',
    fields: [
      SchemaField(name: 'roleId', type: SchemaFieldType.string, required: true),
      SchemaField(
        name: 'tenVaiTro',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(name: 'moTa', type: SchemaFieldType.string, required: false),
      SchemaField(
        name: 'trangThai',
        type: SchemaFieldType.string,
        required: true,
        allowedValues: activeStates,
      ),
    ],
  ),
  CollectionSchema(
    name: nguoiDungCollection,
    documentIdField: 'userId',
    fields: [
      SchemaField(name: 'userId', type: SchemaFieldType.string, required: true),
      SchemaField(
        name: 'uidFirebase',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(name: 'hoTen', type: SchemaFieldType.string, required: true),
      SchemaField(
        name: 'soDienThoai',
        type: SchemaFieldType.string,
        required: false,
      ),
      SchemaField(name: 'email', type: SchemaFieldType.string, required: true),
      SchemaField(
        name: 'roleId',
        type: SchemaFieldType.string,
        required: true,
        allowedValues: userRoles,
      ),
      SchemaField(
        name: 'trangThai',
        type: SchemaFieldType.string,
        required: true,
        allowedValues: activeStates,
      ),
      SchemaField(
        name: 'ngayTao',
        type: SchemaFieldType.timestamp,
        required: true,
      ),
      SchemaField(
        name: 'ngayCapNhat',
        type: SchemaFieldType.timestamp,
        required: false,
      ),
    ],
  ),
  CollectionSchema(
    name: khachHangCollection,
    documentIdField: 'khachHangId',
    fields: [
      SchemaField(
        name: 'khachHangId',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(
        name: 'goiHienTaiId',
        type: SchemaFieldType.string,
        required: false,
      ),
      SchemaField(
        name: 'diemUyTin',
        type: SchemaFieldType.number,
        required: false,
      ),
      SchemaField(
        name: 'ghiChuCSKH',
        type: SchemaFieldType.string,
        required: false,
      ),
    ],
  ),
  CollectionSchema(
    name: nhanVienThuGomCollection,
    documentIdField: 'nhanVienId',
    fields: [
      SchemaField(
        name: 'nhanVienId',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(
        name: 'maNhanVien',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(
        name: 'trangThaiLamViec',
        type: SchemaFieldType.string,
        required: true,
        allowedValues: staffWorkStates,
      ),
      SchemaField(
        name: 'gioBatDau',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(
        name: 'gioKetThuc',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(
        name: 'doanhThuHienTai',
        type: SchemaFieldType.number,
        required: false,
      ),
      SchemaField(
        name: 'viTriHienTai',
        type: SchemaFieldType.string,
        required: false,
      ),
    ],
  ),
  CollectionSchema(
    name: adminCollection,
    documentIdField: 'adminId',
    fields: [
      SchemaField(
        name: 'adminId',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(
        name: 'quyenQuanTri',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(
        name: 'capDoQuanTri',
        type: SchemaFieldType.number,
        required: false,
      ),
    ],
  ),
  CollectionSchema(
    name: diaChiCollection,
    documentIdField: 'diaChiId',
    fields: [
      SchemaField(
        name: 'diaChiId',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(
        name: 'khachHangId',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(
        name: 'diaChiChiTiet',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(
        name: 'phuongXa',
        type: SchemaFieldType.string,
        required: false,
      ),
      SchemaField(
        name: 'quanHuyen',
        type: SchemaFieldType.string,
        required: false,
      ),
      SchemaField(
        name: 'tinhThanh',
        type: SchemaFieldType.string,
        required: false,
      ),
      SchemaField(
        name: 'toaDoLat',
        type: SchemaFieldType.number,
        required: false,
      ),
      SchemaField(
        name: 'toaDoLng',
        type: SchemaFieldType.number,
        required: false,
      ),
      SchemaField(
        name: 'macDinh',
        type: SchemaFieldType.boolean,
        required: true,
      ),
      SchemaField(
        name: 'trangThai',
        type: SchemaFieldType.string,
        required: true,
        allowedValues: activeStates,
      ),
    ],
  ),
  CollectionSchema(
    name: loaiRacCollection,
    documentIdField: 'loaiRacId',
    fields: [
      SchemaField(
        name: 'loaiRacId',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(
        name: 'tenLoaiRac',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(
        name: 'nhomRac',
        type: SchemaFieldType.string,
        required: true,
        allowedValues: wasteGroups,
      ),
      SchemaField(name: 'moTa', type: SchemaFieldType.string, required: false),
      SchemaField(
        name: 'trangThai',
        type: SchemaFieldType.string,
        required: true,
        allowedValues: activeStates,
      ),
    ],
  ),
  CollectionSchema(
    name: dichVuGiaBieuCollection,
    documentIdField: 'bangGiaId',
    fields: [
      SchemaField(
        name: 'bangGiaId',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(
        name: 'loaiRacId',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(
        name: 'tenDichVu',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(
        name: 'donGiaKg',
        type: SchemaFieldType.number,
        required: true,
      ),
      SchemaField(
        name: 'khuVuc',
        type: SchemaFieldType.string,
        required: false,
      ),
      SchemaField(
        name: 'ngayHieuLuc',
        type: SchemaFieldType.timestamp,
        required: true,
      ),
      SchemaField(
        name: 'ngayHetHieuLuc',
        type: SchemaFieldType.timestamp,
        required: false,
      ),
      SchemaField(
        name: 'trangThai',
        type: SchemaFieldType.string,
        required: true,
        allowedValues: activeStates,
      ),
    ],
  ),
  CollectionSchema(
    name: goiThuGomCollection,
    documentIdField: 'goiId',
    fields: [
      SchemaField(name: 'goiId', type: SchemaFieldType.string, required: true),
      SchemaField(name: 'tenGoi', type: SchemaFieldType.string, required: true),
      SchemaField(
        name: 'hanMucKgThang',
        type: SchemaFieldType.number,
        required: true,
      ),
      SchemaField(name: 'giaGoi', type: SchemaFieldType.number, required: true),
      SchemaField(
        name: 'phiVuotGoi',
        type: SchemaFieldType.number,
        required: true,
      ),
      SchemaField(name: 'moTa', type: SchemaFieldType.string, required: false),
      SchemaField(
        name: 'trangThai',
        type: SchemaFieldType.string,
        required: true,
        allowedValues: activeStates,
      ),
    ],
  ),
  CollectionSchema(
    name: dangKyGoiCollection,
    documentIdField: 'dangKyGoiId',
    fields: [
      SchemaField(
        name: 'dangKyGoiId',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(
        name: 'khachHangId',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(name: 'goiId', type: SchemaFieldType.string, required: true),
      SchemaField(
        name: 'thangNam',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(
        name: 'soKgDaDung',
        type: SchemaFieldType.number,
        required: true,
      ),
      SchemaField(
        name: 'soKgConLai',
        type: SchemaFieldType.number,
        required: true,
      ),
      SchemaField(
        name: 'trangThai',
        type: SchemaFieldType.string,
        required: true,
        allowedValues: packageStatuses,
      ),
      SchemaField(
        name: 'ngayDangKy',
        type: SchemaFieldType.timestamp,
        required: true,
      ),
      SchemaField(
        name: 'ngayHetHan',
        type: SchemaFieldType.timestamp,
        required: false,
      ),
    ],
  ),
  CollectionSchema(
    name: donThuGomCollection,
    documentIdField: 'maDon',
    fields: [
      SchemaField(name: 'maDon', type: SchemaFieldType.string, required: true),
      SchemaField(
        name: 'khachHangId',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(
        name: 'diaChiId',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(
        name: 'loaiRacId',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(
        name: 'nhanVienHienTaiId',
        type: SchemaFieldType.string,
        required: false,
      ),
      SchemaField(
        name: 'khoiLuongDuKien',
        type: SchemaFieldType.number,
        required: true,
      ),
      SchemaField(
        name: 'ngayThuGom',
        type: SchemaFieldType.timestamp,
        required: true,
      ),
      SchemaField(
        name: 'khungGio',
        type: SchemaFieldType.string,
        required: true,
        allowedValues: timeSlots,
      ),
      SchemaField(
        name: 'gioChot',
        type: SchemaFieldType.timestamp,
        required: false,
      ),
      SchemaField(
        name: 'hinhThucTinhPhi',
        type: SchemaFieldType.string,
        required: true,
        allowedValues: feeTypes,
      ),
      SchemaField(
        name: 'trangThai',
        type: SchemaFieldType.string,
        required: true,
        allowedValues: orderStatuses,
      ),
      SchemaField(
        name: 'ghiChu',
        type: SchemaFieldType.string,
        required: false,
      ),
      SchemaField(
        name: 'ngayTao',
        type: SchemaFieldType.timestamp,
        required: true,
      ),
    ],
  ),
  CollectionSchema(
    name: phanCongThuGomCollection,
    documentIdField: 'phanCongId',
    fields: [
      SchemaField(
        name: 'phanCongId',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(name: 'maDon', type: SchemaFieldType.string, required: true),
      SchemaField(
        name: 'nhanVienId',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(
        name: 'adminId',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(
        name: 'trangThaiPhanCong',
        type: SchemaFieldType.string,
        required: true,
        allowedValues: assignmentStatuses,
      ),
      SchemaField(
        name: 'thoiGianPhanCong',
        type: SchemaFieldType.timestamp,
        required: true,
      ),
      SchemaField(
        name: 'lyDoTuChoi',
        type: SchemaFieldType.string,
        required: false,
      ),
    ],
  ),
  CollectionSchema(
    name: bienBanThuGomCollection,
    documentIdField: 'bienBanId',
    fields: [
      SchemaField(
        name: 'bienBanId',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(name: 'maDon', type: SchemaFieldType.string, required: true),
      SchemaField(
        name: 'nhanVienId',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(
        name: 'loaiRacThucTeId',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(
        name: 'khoiLuongThucTe',
        type: SchemaFieldType.number,
        required: true,
      ),
      SchemaField(
        name: 'anhXacNhanUrl',
        type: SchemaFieldType.string,
        required: false,
      ),
      SchemaField(
        name: 'phiPhaiTra',
        type: SchemaFieldType.number,
        required: true,
      ),
      SchemaField(
        name: 'trangThaiThanhToan',
        type: SchemaFieldType.string,
        required: true,
        allowedValues: paymentStatuses,
      ),
      SchemaField(
        name: 'thoiGianLap',
        type: SchemaFieldType.timestamp,
        required: true,
      ),
    ],
  ),
  CollectionSchema(
    name: thanhToanCollection,
    documentIdField: 'thanhToanId',
    fields: [
      SchemaField(
        name: 'thanhToanId',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(name: 'maDon', type: SchemaFieldType.string, required: true),
      SchemaField(
        name: 'khachHangId',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(name: 'soTien', type: SchemaFieldType.number, required: true),
      SchemaField(
        name: 'phuongThuc',
        type: SchemaFieldType.string,
        required: true,
        allowedValues: paymentMethods,
      ),
      SchemaField(
        name: 'maGiaoDichNgoai',
        type: SchemaFieldType.string,
        required: false,
      ),
      SchemaField(
        name: 'trangThai',
        type: SchemaFieldType.string,
        required: true,
        allowedValues: paymentStatuses,
      ),
      SchemaField(
        name: 'thoiGian',
        type: SchemaFieldType.timestamp,
        required: true,
      ),
    ],
  ),
  CollectionSchema(
    name: hoaDonCollection,
    documentIdField: 'hoaDonId',
    fields: [
      SchemaField(
        name: 'hoaDonId',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(name: 'maDon', type: SchemaFieldType.string, required: true),
      SchemaField(
        name: 'thanhToanId',
        type: SchemaFieldType.string,
        required: false,
      ),
      SchemaField(
        name: 'soKgThucTe',
        type: SchemaFieldType.number,
        required: true,
      ),
      SchemaField(name: 'donGia', type: SchemaFieldType.number, required: true),
      SchemaField(
        name: 'tongTien',
        type: SchemaFieldType.number,
        required: true,
      ),
      SchemaField(
        name: 'filePdfUrl',
        type: SchemaFieldType.string,
        required: false,
      ),
      SchemaField(
        name: 'thoiGianTao',
        type: SchemaFieldType.timestamp,
        required: true,
      ),
    ],
  ),
  CollectionSchema(
    name: doanhThuNhanVienCollection,
    documentIdField: 'doanhThuId',
    fields: [
      SchemaField(
        name: 'doanhThuId',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(
        name: 'nhanVienId',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(name: 'maDon', type: SchemaFieldType.string, required: true),
      SchemaField(name: 'soTien', type: SchemaFieldType.number, required: true),
      SchemaField(
        name: 'thoiGian',
        type: SchemaFieldType.timestamp,
        required: true,
      ),
      SchemaField(
        name: 'trangThaiDoiSoat',
        type: SchemaFieldType.string,
        required: true,
        allowedValues: reconciliationStatuses,
      ),
    ],
  ),
  CollectionSchema(
    name: khieuNaiCollection,
    documentIdField: 'khieuNaiId',
    fields: [
      SchemaField(
        name: 'khieuNaiId',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(name: 'maDon', type: SchemaFieldType.string, required: true),
      SchemaField(
        name: 'nguoiGuiId',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(
        name: 'noiDung',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(
        name: 'hinhAnhUrl',
        type: SchemaFieldType.string,
        required: false,
      ),
      SchemaField(
        name: 'trangThai',
        type: SchemaFieldType.string,
        required: true,
        allowedValues: complaintStatuses,
      ),
      SchemaField(
        name: 'phanHoi',
        type: SchemaFieldType.string,
        required: false,
      ),
      SchemaField(
        name: 'nguoiXuLyId',
        type: SchemaFieldType.string,
        required: false,
      ),
      SchemaField(
        name: 'thoiGianTao',
        type: SchemaFieldType.timestamp,
        required: true,
      ),
      SchemaField(
        name: 'thoiGianXuLy',
        type: SchemaFieldType.timestamp,
        required: false,
      ),
    ],
  ),
  CollectionSchema(
    name: danhGiaCollection,
    documentIdField: 'danhGiaId',
    fields: [
      SchemaField(
        name: 'danhGiaId',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(name: 'maDon', type: SchemaFieldType.string, required: true),
      SchemaField(
        name: 'khachHangId',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(
        name: 'nhanVienId',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(
        name: 'diemDichVu',
        type: SchemaFieldType.number,
        required: true,
      ),
      SchemaField(
        name: 'diemNhanVien',
        type: SchemaFieldType.number,
        required: true,
      ),
      SchemaField(
        name: 'noiDung',
        type: SchemaFieldType.string,
        required: false,
      ),
      SchemaField(
        name: 'thoiGian',
        type: SchemaFieldType.timestamp,
        required: true,
      ),
    ],
  ),
  CollectionSchema(
    name: thongBaoCollection,
    documentIdField: 'thongBaoId',
    fields: [
      SchemaField(
        name: 'thongBaoId',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(
        name: 'nguoiNhanId',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(name: 'maDon', type: SchemaFieldType.string, required: false),
      SchemaField(
        name: 'loaiThongBao',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(name: 'tieuDe', type: SchemaFieldType.string, required: true),
      SchemaField(
        name: 'noiDung',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(
        name: 'trangThaiDoc',
        type: SchemaFieldType.string,
        required: true,
        allowedValues: readStatuses,
      ),
      SchemaField(
        name: 'thoiGian',
        type: SchemaFieldType.timestamp,
        required: true,
      ),
    ],
  ),
  CollectionSchema(
    name: lichSuHoatDongCollection,
    documentIdField: 'logId',
    fields: [
      SchemaField(name: 'logId', type: SchemaFieldType.string, required: true),
      SchemaField(name: 'maDon', type: SchemaFieldType.string, required: false),
      SchemaField(name: 'userId', type: SchemaFieldType.string, required: true),
      SchemaField(
        name: 'hanhDong',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(
        name: 'thoiGian',
        type: SchemaFieldType.timestamp,
        required: true,
      ),
      SchemaField(
        name: 'ghiChu',
        type: SchemaFieldType.string,
        required: false,
      ),
    ],
  ),
  CollectionSchema(
    name: thongKeTongHopCollection,
    documentIdField: 'thongKeId',
    fields: [
      SchemaField(
        name: 'thongKeId',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(
        name: 'ngayThongKe',
        type: SchemaFieldType.timestamp,
        required: true,
      ),
      SchemaField(
        name: 'khuVuc',
        type: SchemaFieldType.string,
        required: false,
      ),
      SchemaField(
        name: 'loaiRacId',
        type: SchemaFieldType.string,
        required: false,
      ),
      SchemaField(
        name: 'tongSoDon',
        type: SchemaFieldType.number,
        required: true,
      ),
      SchemaField(name: 'tongKg', type: SchemaFieldType.number, required: true),
      SchemaField(
        name: 'tongDoanhThu',
        type: SchemaFieldType.number,
        required: true,
      ),
      SchemaField(
        name: 'soKhieuNai',
        type: SchemaFieldType.number,
        required: true,
      ),
    ],
  ),
  CollectionSchema(
    name: thamSoHeThongCollection,
    documentIdField: 'thamSoId',
    fields: [
      SchemaField(
        name: 'thamSoId',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(
        name: 'maThamSo',
        type: SchemaFieldType.string,
        required: true,
      ),
      SchemaField(name: 'giaTri', type: SchemaFieldType.string, required: true),
      SchemaField(name: 'moTa', type: SchemaFieldType.string, required: false),
      SchemaField(
        name: 'ngayHieuLuc',
        type: SchemaFieldType.timestamp,
        required: true,
      ),
      SchemaField(
        name: 'trangThai',
        type: SchemaFieldType.string,
        required: true,
        allowedValues: activeStates,
      ),
    ],
  ),
];

final greenTrashSchemaByName = <String, CollectionSchema>{
  for (final schema in greenTrashSchemas) schema.name: schema,
};
