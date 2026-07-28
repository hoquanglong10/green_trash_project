import {initializeApp} from "firebase-admin/app";
import {FieldValue, getFirestore, Timestamp} from "firebase-admin/firestore";
import {setGlobalOptions} from "firebase-functions/v2";
import {
  onDocumentCreated,
  onDocumentUpdated,
} from "firebase-functions/v2/firestore";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {collections, REGION} from "./config";
import {dispatchNextOffer} from "./dispatch/dispatch-service";

initializeApp();
const db = getFirestore();

setGlobalOptions({
  region: REGION,
  maxInstances: 10,
  memory: "256MiB",
});

export const onPickupOrderCreated = onDocumentCreated(
  `${collections.orders}/{maDon}`,
  async (event) => {
    const maDon = event.params.maDon as string;
    const order = event.data?.data();
    if (order?.trangThai !== "CHO_XU_LY") return;
    await dispatchNextOffer(db, maDon);
  },
);

export const onPickupOrderUpdated = onDocumentUpdated(
  `${collections.orders}/{maDon}`,
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after || before.trangThai === after.trangThai) return;
    if (!["HUY", "HOAN_THANH"].includes(String(after.trangThai))) return;

    const staffId = after.nhanVienHienTaiId as string | undefined;
    if (!staffId) return;
    const otherActiveOrder = await db
      .collection(collections.orders)
      .where("nhanVienHienTaiId", "==", staffId)
      .where("trangThai", "in", [
        "DA_NHAN",
        "DANG_DEN",
        "DA_DEN",
        "DANG_CAN_RAC",
      ])
      .limit(1)
      .get();
    if (otherActiveOrder.empty) {
      await db.collection(collections.staff).doc(staffId).update({
        trangThaiLamViec: "SAN_SANG",
      });
    }
  },
);

export const onPickupAssignmentUpdated = onDocumentUpdated(
  `${collections.assignments}/{phanCongId}`,
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) return;

    const wasWaiting =
      before.trangThaiPhanCong === "CHO_PHAN_HOI" ||
      before.trangThaiPhanCong === "CHO_NHAN";
    const isTerminal = [
      "DA_NHAN",
      "TU_CHOI",
      "HET_HAN",
      "HUY",
    ].includes(String(after.trangThaiPhanCong));
    if (!wasWaiting || !isTerminal) return;

    const assignmentId = event.params.phanCongId as string;
    const staffId = String(after.nhanVienId);
    const staffRef = db.collection(collections.staff).doc(staffId);
    await db.runTransaction(async (transaction) => {
      const snapshot = await transaction.get(staffRef);
      if (
        snapshot.exists &&
        snapshot.data()?.phanCongDangChoId === assignmentId
      ) {
        transaction.update(staffRef, {
          phanCongDangChoId: FieldValue.delete(),
        });
      }
    });

    if (
      after.trangThaiPhanCong === "TU_CHOI" ||
      after.trangThaiPhanCong === "HET_HAN"
    ) {
      await dispatchNextOffer(db, String(after.maDon));
    }
    await retryWaitingOrders();
  },
);

export const expirePickupOffers = onSchedule(
  {
    schedule: "every 1 minutes",
    timeZone: "Asia/Ho_Chi_Minh",
  },
  async () => {
    const now = Timestamp.now();
    const snapshot = await db
      .collection(collections.assignments)
      .where("trangThaiPhanCong", "==", "CHO_PHAN_HOI")
      .where("thoiGianHetHan", "<=", now)
      .limit(100)
      .get();
    if (snapshot.empty) return;

    const batch = db.batch();
    for (const document of snapshot.docs) {
      batch.update(document.ref, {
        trangThaiPhanCong: "HET_HAN",
        thoiGianPhanHoi: now,
        ngayCapNhat: now,
      });
    }
    await batch.commit();
  },
);

export const onStaffAvailabilityUpdated = onDocumentUpdated(
  `${collections.staff}/{nhanVienId}`,
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after || after.trangThaiLamViec !== "SAN_SANG") return;

    const becameAvailable = before.trangThaiLamViec !== "SAN_SANG";
    const locationChanged =
      before.toaDoLat !== after.toaDoLat ||
      before.toaDoLng !== after.toaDoLng;
    if (!becameAvailable && !locationChanged) return;

    await retryWaitingOrders();
  },
);

async function retryWaitingOrders(): Promise<void> {
  const waitingOrders = await db
    .collection(collections.orders)
    .where("trangThai", "==", "CHO_XU_LY")
    .where("dangChoHoTro", "==", true)
    .orderBy("ngayTao")
    .limit(10)
    .get();
  for (const order of waitingOrders.docs) {
    await dispatchNextOffer(db, order.id);
  }
}
