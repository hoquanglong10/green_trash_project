# Order Flow Screens

## Covered screens

- Customer booking
- Customer order detail and tracking
- Staff open-order inbox and order handling
- Admin exception assignment

## Product decision: shared open-order queue

The course-project flow is intentionally simple and does not depend on admin
assignment or Cloud Functions.

```text
Customer creates order
  -> CHO_XU_LY
  -> all available staff can see the order
  -> claim: the first successful transaction sets DA_NHAN
  -> dismiss: hide the order only for that staff member
  -> no claim yet: keep CHO_XU_LY
```

Admin manual assignment remains available only for an exception or operational
override. `CHO_NHAN` is retained for that manual path.

## Test fallback behaviour

The Riverpod controller remains available for widget tests and offline UI work:

- Booking dates and slots are validated against the current time.
- Customer orders that overlap another active order are rejected by client
  validation.
- Every ready staff member sees open `CHO_XU_LY` orders except orders they
  dismissed.
- Staff can claim with an ETA, update the ETA, move through every valid
  collection status, record actual waste/weight, capture collection evidence,
  and complete payment.
- Completion stores an in-memory collection record and payment record.
- Monthly-package usage is updated in memory.
- Customer and staff cancellation require reasons.

The mock `PickupOrder.nhanVienDeXuatId` and `offerExpiresAt` fields remain only
for compatibility with old sample data. Open-queue mode clears them.

## Firestore persistence

- `DON_THU_GOM` stores `nhanVienHienTaiId` and `phanCongHienTaiId` only after
  acceptance.
- `DON_THU_GOM.nhanVienTuChoiIds` lets the client hide dismissed orders for
  each staff member.
- `PHAN_CONG_THU_GOM` records `DA_NHAN` or `TU_CHOI` responses.
- A staff claim creates the assignment and updates the order in one Firestore
  transaction.
- Two simultaneous claims cannot both succeed because the transaction requires
  the order to still be `CHO_XU_LY`.
- Completion requires the assigned staff member to capture one camera photo.
  The camera constrains the JPEG to 720 px at 68% quality. The app stores the
  resulting bytes, capped at 650 KB, in
  `BIEN_BAN_THU_GOM.anhXacNhanBytes`; this keeps the record below Firestore's
  1 MiB document limit without requiring Firebase Storage or a Billing Account.
  The assigned staff member, customer, and admin can view the saved evidence
  from the completed collection record.

The Flutter adapter lives in `lib/features/orders/`. The running app reads the
Firestore streams after Firebase initialization; mock state is used only when
Firebase is unavailable in automated widget tests.

## Status lifecycle

```text
CHO_XU_LY -> CHO_NHAN (manual exception only) -> DA_NHAN
DA_NHAN -> DANG_DEN -> DA_DEN -> DANG_CAN_RAC -> HOAN_THANH
Any eligible pre-completion state -> HUY
```

The customer sees a compact timeline. Staff sees only actions valid for the
current status.

## UI rules

- Primary action: green filled button.
- Secondary action: outlined button with slate/green text.
- Selected card: soft green surface and green border/icon.
- Waiting state: amber chip.
- Active pickup progress: blue chip.
- Completed state: green chip.
- Utility/support state: purple chip.
- Neutral/cancelled state: slate on gray.
- Important actions use a bottom action bar on mobile.

## Foreground GPS tracking

- When the assigned staff member moves the order to `DANG_DEN`, the staff order
  screen requests foreground GPS permission and begins sharing location.
- The client writes `NHAN_VIEN_THU_GOM.toaDoLat`, `toaDoLng`, and
  `capNhatViTriLuc` after the device moves at least 10 m. Positions with an
  accuracy worse than 50 m are ignored.
- The Firestore transaction compares the staff coordinate with the selected
  `DIA_CHI` coordinate. At 200 m it creates one `NHAN_VIEN_SAP_DEN`
  notification; at 30 m it creates one `NHAN_VIEN_DA_DEN` notification.
  `DON_THU_GOM.daThongBaoNhanVienSapDen` and
  `daThongBaoNhanVienDaDen` prevent duplicate notifications.
- GPS notifications never change the order status. The staff member still
  confirms `DA_DEN` manually after reaching the pickup point.
- The customer order detail listens to the staff profile stream. During
  `DANG_DEN`, `DA_DEN`, and `DANG_CAN_RAC`, it shows an OpenStreetMap card with
  a blue staff marker and a green pickup-address marker. A compact waiting card
  is shown until the first position arrives.
- Tracking is foreground-only and is active only during `DANG_DEN`; it stops
  when the status changes or the staff leaves the active order detail screen.
  Background tracking, route navigation, and distance-based automatic dispatch
  are intentionally out of scope.
