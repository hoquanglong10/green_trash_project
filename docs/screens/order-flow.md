# Order Flow Screens

## Covered screens

- Customer booking
- Customer order detail and tracking
- Staff targeted-offer inbox and order handling
- Admin exception assignment

## Product decision: targeted nearest-staff dispatch

The course-project flow is intentionally simple and does not depend on admin
assignment or Cloud Functions.

```text
Customer creates order
  -> CHO_XU_LY
  -> choose the nearest available staff by GPS
  -> only that staff member sees the offer
  -> accept: set DA_NHAN and hide all other offers while staff is busy
  -> reject: audit the rejection and offer to the next nearest staff
  -> no candidate: keep CHO_XU_LY with dangChoHoTro = true
```

Admin manual assignment remains available only for an exception or operational
override. `CHO_NHAN` is retained for that manual path.

## Test fallback behaviour

The Riverpod controller remains available for widget tests and offline UI work:

- Booking dates and slots are validated against the current time.
- Customer orders that overlap another active order are rejected by client
  validation.
- A ready staff member sees only a `CHO_XU_LY` order targeted to their ID.
- A staff member with an active order sees no new-offer section.
- Rejection moves the offer to the next ranked staff member.
- Staff can claim with an ETA, update the ETA, move through every valid
  collection status, record actual waste/weight, capture collection evidence,
  and complete payment.
- Completion stores an in-memory collection record and payment record.
- Monthly-package usage is updated in memory.
- Customer and staff cancellation require reasons.

The mock and Firestore adapters both use `nhanVienDeXuatId` and
`offerExpiresAt`, so widget-test behaviour matches the live workflow.

## Firestore persistence

- `DON_THU_GOM` stores `nhanVienHienTaiId` and `phanCongHienTaiId` only after
  acceptance.
- `DON_THU_GOM.nhanVienDeXuatId` is the only staff member currently allowed to
  view and respond to the offer.
- `DON_THU_GOM.nhanVienTuChoiIds` excludes rejected staff from later ranking.
- `PHAN_CONG_THU_GOM` records `DA_NHAN` or `TU_CHOI` responses.
- A staff claim creates the assignment and updates the order in one Firestore
  transaction. The same transaction changes the staff work status to
  `DANG_THU_GOM`, so that staff member cannot claim another unfinished order.
- Accept/reject cannot act on a stale offer because the transaction requires
  `nhanVienDeXuatId` to still match the signed-in staff member.
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

- Customer booking is a four-step wizard with a fixed progress header and
  bottom next/back action surface.
- Customer tracking starts with a dedicated live status board containing the
  current state, assigned staff/ETA and live activity indicator.
- Staff handling keeps the current mission header and only the next valid
  status action visible in the bottom action surface.
- Primary action: botanical deep filled button.
- Secondary action: outlined button with botanical dark/deep text.
- Selected card: soft botanical surface and deep border/icon.
- Waiting state: soft sunflower-yellow chip with clock icon.
- Active pickup progress: botanical mid chip with movement icon.
- Completed state: botanical deep chip with completion icon.
- Utility/support state: botanical mid chip with explicit utility icon.
- Neutral/cancelled state: botanical dark on canvas.
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
- The green destination marker uses the selected
  `DIA_CHI.toaDoLat/toaDoLng`. New orders are rejected when this coordinate is
  missing or equals `0,0`, so tracking uses the point confirmed by the customer
  in the address map picker.
- Tracking is foreground-only and is active only during `DANG_DEN`; it stops
  when the status changes or the staff leaves the active order detail screen.
  Background tracking and route navigation are intentionally out of scope.
  Dispatch ranking uses the latest saved staff GPS point and does not run
  continuous route-distance calculation.
