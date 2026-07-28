// The existing default Firestore database is in nam5. Firebase recommends
// us-central1 as the nearest Functions region for that multi-region.
export const REGION = "us-central1";
export const OFFER_TIMEOUT_MINUTES = 2;

export const collections = {
  orders: "DON_THU_GOM",
  assignments: "PHAN_CONG_THU_GOM",
  addresses: "DIA_CHI",
  staff: "NHAN_VIEN_THU_GOM",
  notifications: "THONG_BAO",
  activityLogs: "LICH_SU_HOAT_DONG",
} as const;

export const activeOrderStatuses = [
  "DA_NHAN",
  "DANG_DEN",
  "DA_DEN",
  "DANG_CAN_RAC",
] as const;

export const terminalAssignmentStatuses = new Set([
  "DA_NHAN",
  "TU_CHOI",
  "HET_HAN",
  "HUY",
]);
