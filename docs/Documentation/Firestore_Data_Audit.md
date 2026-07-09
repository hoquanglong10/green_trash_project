# GreenTrash Firestore Data Audit

Ngay quet: 2026-07-08

Project Firebase: `greentrashdb`

Ket qua: quet duoc 38 documents trong 22 collections bang Firestore REST API. Database that su dung collection uppercase, khong phai lower_snake_case.

## Collections Dang Co Du Lieu

| Collection | Docs | Document ID field | Ghi chu UI |
|---|---:|---|---|
| `VAI_TRO` | 3 | `roleId` | Vai tro: `ADMIN`, `CUSTOMER`, `STAFF` |
| `NGUOI_DUNG` | 3 | `userId` | Ho so Auth chung, doc id trung UID |
| `KHACH_HANG` | 1 | `khachHangId` | Thong tin rieng khach hang |
| `NHAN_VIEN_THU_GOM` | 1 | `nhanVienId` | Thong tin rieng nhan vien |
| `ADMIN` | 1 | `adminId` | Thong tin quyen admin |
| `DIA_CHI` | 1 | `diaChiId` | Dia chi khach hang, co lat/lng |
| `LOAI_RAC` | 3 | `loaiRacId` | Danh muc rac |
| `DICH_VU_GIA_BIEU` | 3 | `bangGiaId` | Bang gia theo loai rac |
| `GOI_THU_GOM` | 1 | `goiId` | Goi 126kg/thang |
| `DANG_KY_GOI` | 1 | `dangKyGoiId` | Goi hien tai cua khach |
| `DON_THU_GOM` | 1 | `maDon` | Don thu gom |
| `PHAN_CONG_THU_GOM` | 1 | `phanCongId` | Phan cong nhan vien |
| `BIEN_BAN_THU_GOM` | 1 | `bienBanId` | Ket qua can rac/xac nhan |
| `THANH_TOAN` | 1 | `thanhToanId` | Giao dich thanh toan |
| `HOA_DON` | 1 | `hoaDonId` | Hoa don sau thu gom |
| `DOANH_THU_NHAN_VIEN` | 1 | `doanhThuId` | Doanh thu nhan vien |
| `KHIEU_NAI` | 1 | `khieuNaiId` | Khieu nai |
| `DANH_GIA` | 1 | `danhGiaId` | Danh gia dich vu/nhan vien |
| `THONG_BAO` | 1 | `thongBaoId` | Thong bao nguoi dung |
| `LICH_SU_HOAT_DONG` | 2 | `logId` | Audit trail |
| `THONG_KE_TONG_HOP` | 1 | `thongKeId` | So lieu dashboard |
| `THAM_SO_HE_THONG` | 8 | `thamSoId` | Enum/cau hinh he thong |

## Tham So He Thong

- `COMPLAINT_STATUS_LIST`: `MOI`, `DANG_XU_LY`, `DA_PHAN_HOI`, `DONG`
- `DEFAULT_MONTHLY_LIMIT_KG`: `126`
- `NOTIFICATION_STATUS_LIST`: `CHUA_DOC`, `DA_DOC`
- `ORDER_STATUS_LIST`: `CHO_XU_LY`, `CHO_NHAN`, `DA_NHAN`, `DANG_DEN`, `DA_DEN`, `DANG_CAN_RAC`, `HOAN_THANH`, `HUY`
- `PAYMENT_METHOD_LIST`: `TIEN_MAT`, `BANKING`, `VI_DIEN_TU`
- `TIME_SLOT_LIST`: `06:00-08:00`, `08:00-10:00`, `10:00-12:00`, `13:00-15:00`, `15:00-17:00`
- `WORK_START_TIME`: `06:00`
- `WORK_END_TIME`: `17:00`

## Field Chinh Cho UI

- Auth/profile: doc `NGUOI_DUNG/{uid}` dung `roleId`, khong dung `role`.
- Role hien co: `ADMIN`, `CUSTOMER`, `STAFF`.
- Customer data tach rieng o `KHACH_HANG/{uid}`.
- Staff data tach rieng o `NHAN_VIEN_THU_GOM/{uid}`.
- Admin data tach rieng o `ADMIN/{uid}`.
- Don thu gom dung `nhanVienHienTaiId`, khong dung `nhanVienId`.
- Gia bieu dung `DICH_VU_GIA_BIEU` voi `loaiRacId`, `donGiaKg`, `khuVuc`, `ngayHieuLuc`.
- Thanh toan/hien thi tien can doc them `THANH_TOAN`, `HOA_DON`, `DOANH_THU_NHAN_VIEN`.

## Diem Can Luu Y Khi Lam UI

- `LOAI_RAC.nhomRac` dang luu gia tri tieng Viet: `Hữu cơ`, `Tái chế`, `Vô cơ`, khong phai enum uppercase.
- Sample `DON_THU_GOM.khungGio` dang la `08-10`, trong khi `THAM_SO_HE_THONG.TIME_SLOT_LIST` la `08:00-10:00`.
- Sample `DANG_KY_GOI.trangThai` dang la `CON_HL`, nen UI nen map label "Con hieu luc" cho ca `CON_HL` va `CON_HIEU_LUC`.
- Sample `THANH_TOAN.trangThai` dang la `DA_TT`, nen UI nen map label "Da thanh toan" cho ca `DA_TT` va `DA_THANH_TOAN`.
- Sample `THANH_TOAN.phuongThuc` dang la `GOI_THANG`, trong khi tham so payment method la `TIEN_MAT`, `BANKING`, `VI_DIEN_TU`.
- File `firestore.rules` hien tai trong workspace van la ban cu lower_snake_case. Khong nen deploy lai rules do truoc khi doi sang schema uppercase nay.
