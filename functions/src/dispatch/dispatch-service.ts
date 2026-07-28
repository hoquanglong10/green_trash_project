import {
  DocumentData,
  DocumentReference,
  Firestore,
  Timestamp,
} from "firebase-admin/firestore";
import {
  activeOrderStatuses,
  collections,
  OFFER_TIMEOUT_MINUTES,
  terminalAssignmentStatuses,
} from "../config";
import {
  ActiveOrder,
  MatchableAddress,
  MatchableOrder,
  MatchableStaff,
  rankStaff,
} from "./matching";

type OfferCreationResult = "created" | "candidate-unavailable" | "done";

export async function dispatchNextOffer(
  db: Firestore,
  maDon: string,
): Promise<void> {
  const orderRef = db.collection(collections.orders).doc(maDon);
  const orderSnapshot = await orderRef.get();
  const orderData = orderSnapshot.data();
  if (!orderSnapshot.exists || !orderData || orderData.trangThai !== "CHO_XU_LY") {
    return;
  }

  const order = toOrder(maDon, orderData);
  const [
    addressSnapshot,
    staffSnapshot,
    historySnapshot,
    activeOrdersSnapshot,
  ] = await Promise.all([
    db.collection(collections.addresses).doc(order.diaChiId).get(),
    db
      .collection(collections.staff)
      .where("trangThaiLamViec", "==", "SAN_SANG")
      .get(),
    db
      .collection(collections.assignments)
      .where("maDon", "==", maDon)
      .get(),
    db
      .collection(collections.orders)
      .where("trangThai", "in", [...activeOrderStatuses])
      .get(),
  ]);

  const address = (addressSnapshot.data() ?? {}) as MatchableAddress;
  const excludedStaffIds = new Set(
    historySnapshot.docs
      .filter((doc) => terminalAssignmentStatuses.has(
        String(doc.data().trangThaiPhanCong),
      ))
      .map((doc) => String(doc.data().nhanVienId)),
  );
  const staff = staffSnapshot.docs.map((doc) => ({
    ...doc.data(),
    nhanVienId: doc.id,
  })) as MatchableStaff[];
  const activeOrders = activeOrdersSnapshot.docs.map((doc) => ({
    ...doc.data(),
    maDon: doc.id,
  })) as ActiveOrder[];

  const candidates = rankStaff(
    order,
    address,
    staff,
    activeOrders,
    excludedStaffIds,
  );
  for (const candidate of candidates) {
    const result = await tryCreateOffer(db, orderRef, candidate);
    if (result === "created" || result === "done") return;
  }

  await markWaitingForSupport(db, orderRef);
}

async function tryCreateOffer(
  db: Firestore,
  orderRef: DocumentReference,
  candidate: MatchableStaff,
): Promise<OfferCreationResult> {
  const assignmentRef = prefixedDocument(
    db,
    collections.assignments,
    "PC",
  );
  const notificationRef = prefixedDocument(
    db,
    collections.notifications,
    "TB",
  );
  const logRef = prefixedDocument(db, collections.activityLogs, "LOG");
  const staffRef = db.collection(collections.staff).doc(candidate.nhanVienId);
  const now = Timestamp.now();
  const expiresAt = Timestamp.fromMillis(
    now.toMillis() + OFFER_TIMEOUT_MINUTES * 60 * 1000,
  );

  return db.runTransaction(async (transaction) => {
    const freshOrderSnapshot = await transaction.get(orderRef);
    const freshOrder = freshOrderSnapshot.data();
    if (
      !freshOrderSnapshot.exists ||
      !freshOrder ||
      freshOrder.trangThai !== "CHO_XU_LY"
    ) {
      return "done";
    }

    const currentAssignmentId = freshOrder.phanCongHienTaiId as
      | string
      | undefined;
    let currentAssignmentStatus: string | undefined;
    if (currentAssignmentId) {
      const currentAssignmentSnapshot = await transaction.get(
        db.collection(collections.assignments).doc(currentAssignmentId),
      );
      currentAssignmentStatus = currentAssignmentSnapshot.data()
        ?.trangThaiPhanCong as string | undefined;
    }
    const staffSnapshot = await transaction.get(staffRef);
    const staffData = staffSnapshot.data();

    if (
      currentAssignmentStatus === "CHO_PHAN_HOI" ||
      currentAssignmentStatus === "CHO_NHAN"
    ) {
      return "done";
    }
    if (
      !staffSnapshot.exists ||
      !staffData ||
      staffData.trangThaiLamViec !== "SAN_SANG" ||
      staffData.phanCongDangChoId
    ) {
      return "candidate-unavailable";
    }

    const nextAttempt = Number(freshOrder.soLanDeXuat ?? 0) + 1;
    transaction.set(assignmentRef, {
      phanCongId: assignmentRef.id,
      maDon: orderRef.id,
      nhanVienId: candidate.nhanVienId,
      nguonPhanCong: "HE_THONG",
      trangThaiPhanCong: "CHO_PHAN_HOI",
      thoiGianPhanCong: now,
      thoiGianHetHan: expiresAt,
      thuTuDeXuat: nextAttempt,
      ngayCapNhat: now,
    });
    transaction.update(orderRef, {
      phanCongHienTaiId: assignmentRef.id,
      soLanDeXuat: nextAttempt,
      dangChoHoTro: false,
      ngayCapNhat: now,
    });
    transaction.update(staffRef, {
      phanCongDangChoId: assignmentRef.id,
    });
    transaction.set(notificationRef, {
      thongBaoId: notificationRef.id,
      nguoiNhanId: candidate.nhanVienId,
      maDon: orderRef.id,
      loaiThongBao: "DON_MOI",
      tieuDe: "Có đơn thu gom mới",
      noiDung: `${orderRef.id} đang chờ bạn phản hồi.`,
      trangThaiDoc: "CHUA_DOC",
      thoiGian: now,
    });
    transaction.set(logRef, {
      logId: logRef.id,
      maDon: orderRef.id,
      userId: "HE_THONG",
      hanhDong: "Đề xuất đơn cho nhân viên",
      thoiGian: now,
      ghiChu: `Lượt ${nextAttempt}: ${candidate.nhanVienId}.`,
    });
    return "created";
  });
}

async function markWaitingForSupport(
  db: Firestore,
  orderRef: DocumentReference,
): Promise<void> {
  const notificationRef = prefixedDocument(
    db,
    collections.notifications,
    "TB",
  );
  const now = Timestamp.now();

  await db.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(orderRef);
    const order = snapshot.data();
    if (
      !snapshot.exists ||
      !order ||
      order.trangThai !== "CHO_XU_LY" ||
      order.dangChoHoTro === true
    ) {
      return;
    }
    transaction.update(orderRef, {
      dangChoHoTro: true,
      ngayCapNhat: now,
    });
    transaction.set(notificationRef, {
      thongBaoId: notificationRef.id,
      nguoiNhanId: order.khachHangId,
      maDon: orderRef.id,
      loaiThongBao: "CHO_HO_TRO",
      tieuDe: "Đơn đang chờ hỗ trợ",
      noiDung:
        "Hiện chưa có nhân viên phù hợp. GreenTrash vẫn tiếp tục tìm người nhận.",
      trangThaiDoc: "CHUA_DOC",
      thoiGian: now,
    });
  });
}

function toOrder(
  maDon: string,
  data: DocumentData,
): MatchableOrder {
  if (
    !(data.ngayThuGom instanceof Timestamp) ||
    typeof data.khungGio !== "string" ||
    typeof data.diaChiId !== "string"
  ) {
    throw new Error(`Order ${maDon} has invalid scheduling data.`);
  }
  return {
    maDon,
    ngayThuGom: data.ngayThuGom,
    khungGio: data.khungGio,
    diaChiId: data.diaChiId,
  };
}

function prefixedDocument(
  db: Firestore,
  collection: string,
  prefix: string,
): DocumentReference {
  const target = db.collection(collection);
  return target.doc(`${prefix}_${target.doc().id.toUpperCase()}`);
}
