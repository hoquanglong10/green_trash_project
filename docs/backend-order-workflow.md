# Backend Order Workflow

## Chosen scope for the course project

GreenTrash uses a Spark-compatible open-order queue for the main customer and
staff flow. Cloud Functions, scheduled jobs, nearest-distance matching, and
FCM push delivery are optional extensions, not requirements for the submitted
project.

```text
Customer creates order
  -> CHO_XU_LY
  -> all available staff can see the order
  -> the first successful atomic claim wins
  -> DA_NHAN -> DANG_DEN -> DA_DEN -> DANG_CAN_RAC -> HOAN_THANH
```

This design keeps the food-delivery-style workflow without requiring the Blaze
billing plan. Admin assignment remains an exception tool.

## Runtime status

The running Flutter app now uses Firebase Authentication and Firestore for the
customer/staff order flow whenever Firebase is initialized. Riverpod mock state
is retained only as the offline/widget-test fallback. The Firestore layer now
handles:

- Customer and staff order streams.
- Open-order stream for staff.
- Atomic create, claim, dismiss, ETA, status, completion, cancellation, and
  payment operations.
- Firestore Rules for the uppercase audited collections.
- Composite indexes for customer, staff, and open-order queries.
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
- `nhanVienHienTaiId` and `phanCongHienTaiId` are absent until acceptance.
- `nhanVienTuChoiIds` stores staff who dismissed the order so it can be hidden
  from their own open-order list.
- `soLanDeXuat` counts claim/dismiss responses for simple audit display.

`PHAN_CONG_THU_GOM` records the staff response:

```text
CHO_XU_LY + staff claim   -> PHAN_CONG_THU_GOM.DA_NHAN
CHO_XU_LY + staff dismiss -> PHAN_CONG_THU_GOM.TU_CHOI
```

Claiming uses one Firestore transaction to create the assignment and update
the order. If two staff members claim simultaneously, only the transaction
that still reads `CHO_XU_LY` can succeed.

## Staff visibility

The classroom workflow intentionally does not calculate geographic distance.
An active staff account can query all `CHO_XU_LY` orders and the app filters
orders the staff member already dismissed. The staff profile must use
`SAN_SANG` or the audited legacy value `DANG_RANH` before claiming.

Work-hour and schedule-conflict checks remain in the mock UI. They can be kept
as client validation for the course demo; the atomic order status is the
server-side guard against duplicate acceptance.

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
3. Add `nhanVienTuChoiIds: []` to new or pending order data when needed.
4. Verify Rules and indexes without deploying:

```sh
npx firebase-tools@latest deploy --only firestore --dry-run
```

5. Deploy Firestore Rules and indexes after review.
6. Run the Flutter app and sign in with an existing customer or staff account.
7. Test create, dismiss, simultaneous claim, status updates, completion, and
   cancellation using two accounts.

No Cloud Functions deployment or Blaze upgrade is required for this workflow.
The existing `functions/` directory is retained only as an optional advanced
version and must not be deployed for the classroom mode.

## Deployment command

This command changes the live Firebase project and must only run after review:

```sh
npx firebase-tools@latest deploy --only firestore
```

No live Rules, indexes, or Functions are deployed automatically by Codex.
