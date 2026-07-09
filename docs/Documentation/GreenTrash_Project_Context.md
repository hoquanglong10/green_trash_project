# GreenTrash Project Context

Nguon doc: `GreenTrash mainn.docx` va `GreenTrashDoc.pdf`.

Muc dich file nay: ghi nho yeu cau chinh cua do an GreenTrash de bam khi thiet ke/cai dat Flutter app.

## 1. Tong Quan

GreenTrash la he thong/app thu gom rac tai che, ho tro khach hang dat lich thu gom, nhan vien thu gom xu ly don, va admin/CSKH quan ly van hanh.

Cong nghe dinh huong trong tai lieu:

- Flutter cho app mobile khach hang va nhan vien.
- Flutter Web/Admin app cho admin, CSKH, van hanh, tai chinh.
- Firebase Authentication cho dang ky, dang nhap, quen mat khau, UID va role.
- Cloud Firestore cho du lieu nghiep vu.
- Cloud Storage cho anh bang chung thu gom va hoa don PDF.
- Cloud Functions cho phan cong, kiem tra gio lam viec, tinh phi, cap nhat han muc/doanh thu/thong ke.
- Firebase Cloud Messaging cho thong bao realtime.

## 2. Vai Tro

Khach hang:

- Dang ky/dang nhap, cap nhat thong tin ca nhan.
- Xem dich vu, bang gia, goi thang.
- Quan ly so dia chi.
- Dat lich thu gom rac.
- Theo doi tien trinh don.
- Huy/sua don khi con hop le.
- Xac nhan ket qua, thanh toan, xem hoa don.
- Xem lich su.
- Gui khieu nai, danh gia nhan vien/dich vu.

Nhan vien thu gom:

- Dang nhap, xem don duoc phan cong.
- Nhan/tu choi don.
- Chot gio den du kien.
- Cap nhat trang thai di chuyen/tien trinh.
- Kiem tra phan loai rac, can kg thuc te.
- Chup/upload anh bang chung.
- Ghi nhan thu tien tai cho.
- Xac nhan hoan thanh hoac huy/tu choi co ly do.
- Xem doanh thu va lich su don.

Admin/CSKH:

- Quan ly tai khoan khach hang/nhan vien, khoa/mo tai khoan.
- Quan ly lich dat va phan cong nhan vien.
- Quan ly phan loai rac, dich vu, bang gia, goi thang, tham so he thong.
- Quan ly khieu nai, phan hoi va dong khieu nai.
- Xem dashboard thong ke: don, kg rac, doanh thu, khieu nai, khu vuc, loai rac.

## 3. To Chuc Nghiep Vu

Tai lieu chia he thong thanh 10 phan he:

- P01 - Quan ly tai khoan nguoi dung.
- P02 - Quan ly don dat thu gom.
- P03 - Quan ly danh gia va khieu nai.
- P04 - Quan ly thong bao.
- P05 - Quan ly don nhan thu gom.
- P06 - Quan ly goi thang.
- P07 - Quan ly doanh thu va thu tien nhan vien.
- P08 - Quan ly so dia chi.
- P09 - Quan tri tai khoan he thong.
- P10 - Thong ke va ghi nhan rac.

Tai lieu liet ke 45 use case, trong do cac use case cot loi cho MVP:

- UC01 Dang ky.
- UC02 Dang nhap.
- UC03 Lay lai mat khau.
- UC05 Cap nhat thong tin ca nhan.
- UC07 Phan loai rac huu co/vo co/tai che.
- UC08 Dat lich thu gom rac.
- UC09 Theo doi trang thai don.
- UC10 Huy don.
- UC11 Xac nhan don thanh cong va thanh toan.
- UC15 Xem lich su dat don.
- UC17 Nhan don thu gom rac.
- UC18 Tu choi don thu gom.
- UC19 Nhan thong bao co don thu gom.
- UC20 Chot gio va cap nhat trang thai di chuyen.
- UC21 Kiem tra va xac nhan rac.
- UC22 Chup hinh anh bang chung thu gom.
- UC23 Xac nhan hoan thanh don.
- UC24 Huy don hang va ly do huy.
- UC25 Quan ly doanh thu cua nhan vien thu gom.
- UC26 Ghi nhan thu tien tai cho.
- UC27 Xem danh sach dich vu va gia bieu.
- UC28 Dang ky goi thu gom thang 126 kg.
- UC29 Quan ly han muc goi thang.
- UC30 Thanh toan theo kg thuc te.
- UC33 Quan ly phan loai - gia bieu.
- UC34 Quan ly lich dat va phan cong.
- UC35 Quan ly khach hang.
- UC36 Quan ly khieu nai.
- UC37 Nhan thong bao don hang.
- UC40 Quan ly tham so gia/goi.
- UC41 Quan ly danh muc dich vu/goi thang.
- UC42 Quan ly trang thai tai khoan.
- UC43 Quan ly so dia chi.
- UC44 Thong ke phan loai rac, doanh thu va khieu nai.
- UC45 Ghi nhan khoi luong rac thuc te.

## 4. Quy Dinh Chinh

QD01:

- Nguoi dung phai dang ky tai khoan bang so dien thoai/email hop le va dang nhap thanh cong truoc khi dat lich, nhan don, thanh toan hoac quan tri.

QD02:

- He thong tiep nhan 3 nhom rac chinh: Huu co, Vo co, Tai che.
- Co the chon chi tiet: thuc pham, nhua, giay, kim loai, dien tu.
- Neu rac thuc te khong dung thong tin dang ky hoac khong thuoc danh muc ho tro, nhan vien co quyen tu choi thu gom hoac yeu cau cap nhat don.

QD03:

- Khach hang duoc tao don/dat lich 24/7.
- Nhan vien chi nhan va xu ly don trong gio lam viec 06:00-17:00.
- Khung gio hop le: 06:00-08:00, 08:00-10:00, 10:00-12:00, 13:00-15:00, 15:00-17:00.
- Don ngoai gio hoac het ca phu hop duoc luu o trang thai Cho xu ly va phan cong vao ca ke tiep.

QD04:

- Sau khi nhan vien xac nhan hoan thanh, he thong ghi nhan loai rac thuc te, so kg thuc te, anh bang chung.
- He thong tu dong tinh phi theo goi thang 126 kg/thang hoac theo don gia/kg.
- He thong cap nhat han muc goi, trang thai thanh toan va doanh thu nhan vien.

QD05:

- Moi thao tac tao don, phan cong, nhan/tu choi, chot gio, cap nhat trang thai, xac nhan thu gom, thu tien, thanh toan, huy don, khieu nai deu phai luu lich su.
- Du lieu giao dich khong xoa vat ly; chuyen trang thai de doi soat, thong ke va xu ly tranh chap.

## 5. Bieu Mau

BM01 - Phieu dat lich thu gom rac:

- Ma don: tu dong.
- Ho ten khach hang.
- So dien thoai khach hang.
- Dia chi thu gom.
- Loai rac: Huu co/Vo co/Tai che va loai chi tiet neu co.
- Khoi luong du kien.
- Ngay thu gom.
- Khung gio.
- Ghi chu: goi su dung, phuong thuc thanh toan, ghi chu vi tri de rac.

BM02 - Bien ban xac nhan thu gom rac:

- Ma don.
- Ma nhan vien.
- Loai rac thuc te.
- Khoi luong thuc te.
- Hinh anh xac nhan.
- Phi/diem/goi con lai.
- Trang thai: Hoan thanh/Cho thanh toan/Da thanh toan.

BM03 - Phieu doi diem/nhan qua trong tai lieu, nhung noi dung thuc te gan voi goi/thanh toan:

- Ma khach hang.
- Goi dich vu hien co.
- Dich vu/goi dang ky.
- Han muc/don gia.
- Ngay dang ky/thanh toan.
- Trang thai: Cho thanh toan/Da thanh toan/Con hieu luc/Het han.

## 6. Luong Chinh

Dat lich thu gom:

1. Khach hang chon dich vu/bang gia, dia chi, loai rac, khoi luong du kien, ngay, khung gio, goi thang hoac tra theo kg.
2. He thong kiem tra dang nhap, thong tin bat buoc, loai rac, goi/thanh toan, gio lam viec va ca phu hop.
3. He thong tao don, sinh ma don, luu lich su.
4. Neu du dieu kien: don sang Cho phan cong/Cho nhan va gui thong bao.
5. Neu ngoai gio/het ca: don sang Cho xu ly va thong bao cho khach hang.

Nhan don thu gom:

1. Nhan vien mo don duoc phan cong.
2. He thong kiem tra dung nhan vien, dung gio 06:00-17:00, don con Cho nhan, chua bi huy.
3. Nhan vien bam Nhan don hoac Tu choi.
4. Neu nhan: nhan vien chot gio den du kien trong khung gio khach chon.
5. He thong cap nhat Da nhan/Da chot gio, luu lich su, thong bao khach hang.
6. Neu tu choi: bat buoc nhap ly do, don chuyen Tu choi/Cho phan cong lai.

Cap nhat tien trinh:

- Nhan vien cap nhat theo danh sach trang thai co dinh.
- He thong luu trang thai, thoi gian, vi tri gan nhat neu co.
- Khach hang nhin thay trang thai tuong ung theo thoi gian thuc.

Kiem tra va xac nhan rac:

1. Nhan vien doi chieu loai rac thuc te voi BM01.
2. Neu hop le: can kg thuc te, nhap so kg, chup/upload anh bang chung.
3. Neu khong hop le: tu choi/huy va nhap ly do.
4. He thong luu ket qua kiem tra va chuyen sang hoan thanh hoac huy.

Xac nhan hoan thanh:

1. Nhan vien nhap loai rac thuc te, khoi luong thuc te, anh xac nhan, ghi nhan thu tien tai cho neu co.
2. He thong kiem tra BM02.
3. He thong upload anh len Cloud Storage.
4. He thong cap nhat trang thai Da lay rac thanh cong/Hoan thanh hoac Cho thanh toan.
5. He thong tinh phi theo goi thang hoac kg thuc te.
6. He thong cap nhat thanh toan, hoa don, doanh thu nhan vien, han muc goi, lich su.
7. He thong gui thong bao ket qua cho khach hang.

Huy don/khieu nai:

- Huy, tu choi, khieu nai deu bat buoc co ly do.
- Co the dinh kem anh neu can.
- He thong luu lich su va thong bao khach hang/CSKH.

## 7. Trang Thai

Trang thai DonThuGom theo text va statechart:

- Moi tao.
- Cho xu ly.
- Cho phan cong.
- Cho nhan.
- Da nhan.
- Da chot gio.
- Sap di thu.
- Dang den.
- Da den noi.
- Dang kiem tra/can rac.
- Da lay rac thanh cong.
- Cho thanh toan.
- Hoan thanh.
- Huy/Tu choi.

Trang thai goi:

- Cho thanh toan.
- Con hieu luc.
- Vuot han muc.
- Het han.
- Huy goi.

Trang thai thanh toan:

- Khoi tao.
- Cho thanh toan.
- Dang xu ly.
- Da thanh toan.
- That bai.
- Hoan tien/thanh toan lai neu can.

Trang thai khieu nai:

- Moi gui.
- Da tiep nhan.
- Dang xu ly.
- Da phan hoi.
- Tu choi neu khong hop le.
- Dong khieu nai.

Trang thai tai khoan:

- Moi dang ky.
- Hoat dong.
- Khoa/an.
- Deleted/locked theo bang chi tiet.

## 8. Du Lieu/Collections De Xuat

Tai lieu thiet ke du lieu theo huong 3NF. Khi dua sang Firestore co the map thanh collections:

- roles tu VAI_TRO.
- users tu NGUOI_DUNG.
- customers tu KHACH_HANG.
- collectionStaff tu NHAN_VIEN_THU_GOM.
- admins tu ADMIN.
- addresses tu DIA_CHI.
- wasteTypes tu LOAI_RAC.
- priceTables/services tu DICH_VU_GIA_BIEU.
- monthlyPackages tu GOI_THU_GOM.
- packageSubscriptions tu DANG_KY_GOI.
- pickupOrders tu DON_THU_GOM.
- staffAssignments tu PHAN_CONG_THU_GOM.
- collectionConfirmations tu BIEN_BAN_THU_GOM.
- payments tu THANH_TOAN.
- invoices tu HOA_DON.
- employeeRevenues tu DOANH_THU_NHAN_VIEN.
- complaints tu KHIEU_NAI.
- reviews tu DANH_GIA.
- notifications tu THONG_BAO.
- activityLogs tu LICH_SU_HOAT_DONG.
- aggregateStats tu THONG_KE_TONG_HOP.
- systemParameters tu THAM_SO_HE_THONG.

Field cot loi:

- User: userId, uidFirebase, roleId, hoTen, soDienThoai, email, trangThai, ngayTao, ngayCapNhat.
- Staff: nhanVienId, maNhanVien, trangThaiLamViec, gioBatDau, gioKetThuc, doanhThuHienTai, viTriHienTai.
- Address: diaChiId, khachHangId, diaChiChiTiet, phuongXa, quanHuyen, tinhThanh, toaDoLat, toaDoLng, macDinh, trangThai.
- WasteType: loaiRacId, nhomRac, tenLoaiRac, moTa, trangThai.
- PriceTable: bangGiaId, loaiRacId, tenDichVu, donGiaKg, khuVuc, ngayHieuLuc, ngayHetHieuLuc, trangThai.
- MonthlyPackage: goiId, tenGoi, hanMucKgThang, giaGoi, phiVuotGoi, moTa, trangThai.
- PackageSubscription: dangKyGoiId, khachHangId, goiId, thangNam, soKgDaDung, soKgConLai, ngayDangKy, ngayHetHan, trangThai.
- PickupOrder: maDon, khachHangId, diaChiId, nhanVienHienTaiId, loaiRacId, khoiLuongDuKien, ngayThuGom, khungGio, gioChot, hinhThucTinhPhi, trangThai, ghiChu, ngayTao.
- Assignment: phanCongId, maDon, nhanVienId, adminId, thoiGianPhanCong, trangThaiPhanCong, lyDoTuChoi.
- Confirmation: bienBanId, maDon, nhanVienId, loaiRacThucTeId, khoiLuongThucTe, anhXacNhanUrl, phiPhaiTra, trangThaiThanhToan, thoiGianLap.
- Payment: thanhToanId, maDon, khachHangId, soTien, phuongThuc, maGiaoDichNgoai, trangThai, thoiGian.
- Invoice: hoaDonId, maDon, thanhToanId, soKgThucTe, donGia, tongTien, filePdfUrl, thoiGianTao.
- Complaint: khieuNaiId, maDon, nguoiGuiId, noiDung, hinhAnhUrl, trangThai, phanHoi, nguoiXuLyId, thoiGianTao, thoiGianXuLy.
- Notification: thongBaoId, nguoiNhanId, maDon, loaiThongBao, tieuDe, noiDung, trangThaiDoc, thoiGian.
- ActivityLog: logId, maDon, userId, hanhDong, thoiGian, ghiChu.
- AggregateStat: thongKeId, ngayThongKe, khuVuc, loaiRacId, tongSoDon, tongKg, tongDoanhThu, soKhieuNai.
- SystemParameter: thamSoId, maThamSo, giaTri, moTa, ngayHieuLuc, trangThai.

## 9. Tham So He Thong Mac Dinh

- WORK_START_TIME = 06:00.
- WORK_END_TIME = 17:00.
- TIME_SLOT_LIST = 06:00-08:00; 08:00-10:00; 10:00-12:00; 13:00-15:00; 15:00-17:00.
- DEFAULT_MONTHLY_LIMIT_KG = 126.
- ORDER_STATUS_LIST = CHO_XU_LY; CHO_NHAN; DA_NHAN; DANG_DEN; DA_DEN; DANG_CAN_RAC; HOAN_THANH; HUY.
- PAYMENT_METHOD_LIST = TIEN_MAT; BANKING; VI_DIEN_TU.
- COMPLAINT_STATUS_LIST = MOI; DANG_XU_LY; DA_PHAN_HOI; DONG.
- MAX_CONFIRM_IMAGE_MB = 5.

## 10. Man Hinh

Khach hang:

- Dang nhap/Dang ky.
- Trang chu khach hang.
- Danh sach dich vu va gia bieu.
- Dat lich/Thanh toan.
- Chi tiet don/Theo doi tien trinh.
- Goi thang va thanh toan.
- Lich su don.
- Khieu nai/Danh gia.
- Ho so ca nhan/so dia chi.

Nhan vien:

- Dang nhap.
- Trang chu nhan vien.
- Danh sach don duoc phan cong.
- Chi tiet don nhan.
- Nhan/Tu choi/Chot gio.
- Cap nhat tien trinh.
- Kiem tra - xac nhan rac.
- Thu tien.
- Doanh thu nhan vien/Lich su.

Admin/CSKH:

- Dang nhap web.
- Dashboard thong ke.
- Quan ly lich dat va phan cong.
- Quan ly phan loai - gia bieu.
- Quan ly goi thang/tham so.
- Quan ly tai khoan khach hang/nhan vien.
- Quan ly khieu nai.
- Bao cao.

Tieu chuan UI:

- Mobile 390x844, web toi thieu 1366x768.
- Le 16px mobile, 24px web.
- Form doc, co the cuon, label gan voi input.
- Man hinh xu ly mobile uu tien thao tac mot tay, nut hanh dong o cuoi man hinh.
- Man hinh tra cuu dung danh sach + bo loc: ma don, khach hang, ngay, trang thai.
- Bao cao web theo luoi 12 cot, co bieu do, the so lieu, bang chi tiet, bo loc thoi gian.
- Font Roboto/SF Pro.
- Mau chinh theo Home reference: Green #10B981, Blue #2563EB, Amber #F59E0B, Purple #8B5CF6, Slate #1F2937, Gray #F3F4F6, White #FFFFFF.
- Green dung cho header, nut chinh, icon/trang thai tich cuc, vien card dang chon; Blue dung cho trang thai dang xu ly/dang thu gom; Amber dung cho cho xu ly/canh bao nhe; Purple dung cho ho tro/tien ich phu; Slate la mau chu/icon trung tinh; Gray la nen tong the; White la card/form/content.
- Input cao 44-48px, bo goc 8px.
- Button chinh cao 44-48px, nen xanh, chu trang.
- Badge trang thai co mau rieng cho Cho/Dang xu ly/Hoan thanh/Huy.

## 11. Wireframe Trong Tai Lieu

Khach hang wireframe:

- Login/Dang ky: logo, email/SDT, mat khau, dang nhap, tao tai khoan, quen mat khau/xac thuc danh tinh.
- Trang chu: goi hien tai 126 kg/thang, da dung/con lai, nut dat lich, don dang theo doi, thong bao moi.
- Dat lich: dia chi, loai rac, kg du kien, ngay, khung gio, ghi chu, xac nhan dat lich.
- Chi tiet don: ma don, trang thai hien tai, timeline Da nhan -> Sap di thu -> Dang den -> Da den -> Hoan thanh, thong tin don, huy don, khieu nai, xac nhan/thanh toan.
- Goi thang & thanh toan: goi 126 kg/thang, han hieu luc, da dung, dang ky/gia han, thanh toan theo kg thuc te, lich su gan day.

Nhan vien wireframe:

- Trang chu: ca lam viec 06:00-17:00, don moi duoc phan cong, nut nhan/tu choi, don hom nay.
- Chi tiet don: ma don, thong tin khach, dia chi, loai rac, kg du kien, khung gio, chot gio, cap nhat trang thai, ban do/goi khach, huy don va nhap ly do.
- Cap nhat tien trinh: chon trang thai don, vi tri gan nhat/GPS, luu trang thai va thong bao khach hang.
- Xac nhan thu gom: loai rac thuc te, kg thuc te, khung chup/upload anh, tu dong tinh phi, ghi nhan thu tien tai cho, hoan thanh don.
- Doanh thu: doanh thu hom nay, so don hoan thanh, danh sach thu tien, xem bao cao thang.

Admin wireframe:

- Dashboard: tong don hom nay, kg rac thu gom, doanh thu, bieu do so kg theo ngay, bo loc thoi gian/khu vuc/loai rac/trang thai.
- Quan ly lich dat & phan cong: tim kiem, loc trang thai, bang don, phan cong tu dong, panel thao tac.
- Quan ly phan loai/gia/goi: them loai rac, them goi, bang gia theo loai rac, goi 126 kg/thang, phi vuot goi, ngay hieu luc.
- Tai khoan & khieu nai: danh sach tai khoan, khoa/mo, danh sach khieu nai, phan hoi.

## 12. Bao Mat Va Phan Quyen

- Moi tai khoan gan UID Firebase duy nhat.
- Khach hang chi sua ho so va don cua minh khi con hop le.
- Nhan vien chi xem/nhan/cap nhat don duoc phan cong.
- Admin quan ly bang gia, goi, tham so, tai khoan, thong ke.
- CSKH/Admin xu ly khieu nai.
- Thanh toan khong luu thong tin the/mat khau ngan hang nhay cam.
- Security Rules phai gioi han doc/ghi theo UID, role va nhanVienDuocPhanCong.

## 13. Ghi Chu Trien Khai MVP

Vi repo hien tai la Flutter moi tao, nen nen di theo thu tu:

1. Sua app mac dinh thanh GreenTrash shell va theme.
2. Tao mock data/model/enums theo tai lieu truoc khi ket noi Firebase.
3. Lam navigation 3 role: Khach hang, Nhan vien, Admin.
4. Lam luong khach hang dat lich va theo doi don.
5. Lam luong nhan vien nhan don, cap nhat tien trinh, xac nhan thu gom.
6. Lam admin dashboard, bang phan cong, bang gia/goi, khieu nai.
7. Sau khi UI/logic demo on dinh moi gan Firebase Auth/Firestore/Storage/FCM.

Quy tac uu tien khi co mau thuan:

- Uu tien Lab 3 bang chi tiet hon ER/relational schema trong hinh vi bang chi tiet day du va moi hon.
- Uu tien statechart hinh + bang statechart text khi thiet ke enum trang thai.
- Uu tien wireframe hinh khi thiet ke layout man hinh.
- Uu tien quy dinh QD01-QD05 khi viet validation/business logic.
