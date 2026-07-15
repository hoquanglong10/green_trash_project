# Order Flow Screens

## Covered screens

- Customer booking
- Customer order detail and tracking
- Staff new-offer inbox and order handling
- Admin exception assignment

## Product decision: direct staff offer is the primary flow

The normal operational flow is similar to a delivery application. It must not depend on an admin manually assigning every order.

```text
Customer creates order
  -> CHO_XU_LY
  -> dispatcher suggests one eligible nearby staff member
  -> staff receives a new-order notification and offer
  -> accept: DA_NHAN and staff becomes nhanVienHienTaiId
  -> reject: record rejection and offer the order to the next eligible staff member
  -> no eligible staff remains: keep CHO_XU_LY for admin/CSKH exception handling
```

Admin manual assignment remains available only for an exception, reassignment, or operational override. In that path the order may use `CHO_NHAN` until the selected staff member accepts.

## Current mock behaviour

The current Riverpod controller already demonstrates this flow in memory using `nhanVienDeXuatId` and `nhanVienTuChoiIds` on `PickupOrder`. It chooses available staff in the same area first, then lower revenue as a simple tie-breaker. It does not persist after a restart and does not send real push notifications.

## Required real-backend decision before implementation

The audited Firestore `DON_THU_GOM` schema does not currently contain proposal fields, and `PHAN_CONG_THU_GOM.adminId` is required. Do not make the mock fields appear in production ad hoc.

Before connecting the flow to Firestore, choose and document one persistence design:

1. Extend `PHAN_CONG_THU_GOM` to represent both system offers and admin overrides. Recommended fields include `nguonPhanCong` (`HE_THONG` or `ADMIN`), nullable `adminId` for system offers, attempt/order sequence, and rejection metadata.
2. Or add proposal fields to `DON_THU_GOM` and retain `PHAN_CONG_THU_GOM` only for the final accepted assignment/audit record.

Whichever option is approved must update `lib/schema_contract.dart`, Firestore rules, repository mappers, indexes, and this document together.

## Status lifecycle

Supported order statuses are:

```text
CHO_XU_LY -> CHO_NHAN (manual exception only) -> DA_NHAN
DA_NHAN -> DANG_DEN -> DA_DEN -> DANG_CAN_RAC -> HOAN_THANH
Any eligible pre-completion state -> HUY
```

The customer sees a compact timeline. The staff sees only actions valid for the current state. Any transition must later create `LICH_SU_HOAT_DONG` data and a relevant `THONG_BAO` document.

## UI rules

- Primary action: green filled button.
- Secondary action: outlined button with slate/green text depending on context.
- Selected card: soft green surface and green border/icon.
- Waiting/pending state: amber chip.
- Active pickup progress: blue chip.
- Completed/positive state: green chip.
- Utility/support state: purple chip.
- Neutral/cancelled state: slate chip or slate text on gray surface.
- Timeline: compact vertical timeline.
- Important actions use a bottom action bar on mobile.
