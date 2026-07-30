# Backend Order Workflow

## Chosen scope for the course project

GreenTrash uses Spark-compatible targeted dispatch for the main customer and
staff flow. The Flutter client ranks available staff and writes the selected
staff ID in a Firestore transaction. Cloud Functions, scheduled jobs, and FCM
push delivery are not required for the submitted project.

```text
Customer creates order
  -> CHO_XU_LY
  -> rank available staff by GPS distance
  -> only the selected staff can see the offer
  -> reject: send to the next nearest available staff
  -> accept: lock that staff until the order finishes
  -> DA_NHAN -> DANG_DEN -> DA_DEN -> DANG_CAN_RAC -> HOAN_THANH
```

If GPS is missing, ranking falls back to district, current revenue, then staff
ID for deterministic ordering. If no candidate is available, the order remains
`CHO_XU_LY` with `dangChoHoTro = true`. Admin assignment remains an exception
tool. This design does not require the Blaze billing plan.

## Runtime status

The running Flutter app now uses Firebase Authentication and Firestore for the
customer/staff order flow whenever Firebase is initialized. Riverpod mock state
is retained only as the offline/widget-test fallback. The Firestore layer now
handles:

- Customer and staff order streams.
- Targeted-offer stream for staff.
- Atomic create, claim, dismiss, ETA, status, completion, cancellation, and
  payment operations.
- Firestore Rules for the uppercase audited collections.
- Composite indexes for customer and staff history queries; the targeted offer
  lookup uses the single `nhanVienDeXuatId` field index.
- BM02, payment, package usage, activity-log, and notification writes.

Still required for a full live verification:

- Confirm customer and staff Firebase Auth UIDs match their profile document
  IDs.
- Test with two separate accounts against the live project.
- Deploy the reviewed Firestore Rules/index changes after explicit approval.

FCM push delivery and a real payment gateway are outside the required scope.
`THONG_BAO` documents are enough for the in-app notification list.

## Foreground GPS tracking

The classroom version uses real device GPS only while the staff member is
actively handling an order in the app. It does not run a background service.

```text
Staff presses "Bắt đầu di chuyển"
  -> order is DANG_DEN
  -> app requests foreground location permission
  -> GPS updates after the device moves at least 20 m
  -> NHAN_VIEN_THU_GOM/{staffId} stores toaDoLat, toaDoLng, capNhatViTriLuc
  -> customer order detail receives the profile stream and redraws the marker
```

The map uses OpenStreetMap through `flutter_map`, so it requires no Google Maps
API key, billing account, or Blaze plan. GPS sharing stops when the order is
completed/cancelled or the staff member leaves the active order detail screen.
`viTriHienTai` remains a human-readable fallback; the map reads the audited
coordinate fields already present in `NHAN_VIEN_THU_GOM`.

## Persistence model

`DON_THU_GOM` is the order aggregate.

- A new order has `trangThai = CHO_XU_LY`.
- `nhanVienDeXuatId` identifies the only staff member allowed to see and
  respond to the current offer.
- `offerExpiresAt` records the offer deadline for UI/audit display. The
  classroom client does not automatically move an expired offer while every
  app is closed.
- `nhanVienHienTaiId` and `phanCongHienTaiId` are absent until acceptance.
- `nhanVienTuChoiIds` stores staff who rejected the order and prevents them
  from being selected again.
- `soLanDeXuat` counts how many staff members received the offer.
- `dangChoHoTro = true` means no eligible next candidate was found.

`PHAN_CONG_THU_GOM` records the staff response:

```text
CHO_XU_LY + staff claim   -> PHAN_CONG_THU_GOM.DA_NHAN
CHO_XU_LY + staff dismiss -> PHAN_CONG_THU_GOM.TU_CHOI
```

Accepting uses one Firestore transaction to create the assignment, update the
order, and change the staff status to `DANG_THU_GOM`. Rejecting also uses a
transaction to audit the rejection and replace `nhanVienDeXuatId` with the
next ranked candidate.

## Staff visibility

An active staff account queries only orders whose
`nhanVienDeXuatId == request.auth.uid`. Firestore Rules also prevent staff from
reading or responding to another staff member's offer. The staff profile must
use `SAN_SANG` or the audited legacy value `DANG_RANH`.

Availability is locked only while the staff member has a real active order. A
stale `DANG_THU_GOM` value with no active order can be toggled back to
`SAN_SANG`. The UI reports an unavailable-staff or Firestore permission error
directly instead of replacing it with a generic order-changed message.

An accepted but unfinished order, including `DA_NHAN`, locks availability.
The accept transaction changes `NHAN_VIEN_THU_GOM.trangThaiLamViec` to
`DANG_THU_GOM`, preventing the same staff member from accepting another order.
Completion or cancellation changes it back to `SAN_SANG`.

The staff home also hides the entire new-offer section while an active order
exists. Work-hour checks are applied during candidate ranking. The transaction
rechecks staff availability before create, accept, or handoff.

## Security identity

The Firebase Auth UID must equal the document ID for:

```text
NGUOI_DUNG/{uid}
KHACH_HANG/{uid}
NHAN_VIEN_THU_GOM/{uid}
ADMIN/{uid}
```

`NGUOI_DUNG.roleId` uses `CUSTOMER`, `STAFF`, or `ADMIN`, and `trangThai` must
be `ACTIVE`.

## Activation order

1. Back up Firestore.
2. Confirm Auth UIDs match the uppercase profile document IDs.
3. Pending legacy orders without `nhanVienDeXuatId` remain in support waiting.
   Assign them manually or recreate them before the demo.
4. Verify Rules and indexes without deploying:

```sh
npx firebase-tools@latest deploy --only firestore --dry-run
```

5. Deploy Firestore Rules and indexes after review.
6. Run the Flutter app and sign in with an existing customer or staff account.
7. Test create, reject-to-next-staff, accept, busy-staff hiding, status
   updates, completion, and cancellation using at least two staff accounts.

No Cloud Functions deployment or Blaze upgrade is required for this workflow.
The existing `functions/` directory is retained only as an optional advanced
version and must not be deployed for the classroom mode.

## Deployment command

This command changes the live Firebase project and must only run after review:

```sh
npx firebase-tools@latest deploy --only firestore
```

No live Rules, indexes, or Functions are deployed automatically by Codex.
