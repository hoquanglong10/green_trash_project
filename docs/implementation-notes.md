# Implementation Notes

## Current implementation

The application is a Flutter + Riverpod course project with coherent customer,
staff, and admin UI. When Firebase initializes and the user signs in through
Firebase Auth, customer/staff order data is read and written through the
Firestore order workflow repository. Riverpod mock state remains only for
offline work and widget tests.

Implemented customer/staff flow:

- Customers can create, edit, delete and choose a default pickup address.
  Firestore writes use `DIA_CHI`; the mock address controller preserves the
  same default-address invariant for tests and offline UI work.
- A customer creates and cancels a pickup order, then sees order details,
  status timeline, logs, and payment data.
- New orders are offered to one available staff member at a time. Candidates
  are ranked by GPS distance, then district/revenue/ID when GPS is missing.
- A rejection moves the offer to the next candidate. A busy staff member sees
  no new offers until the active order finishes or is cancelled.
- Staff can set/update ETA, move through collection statuses, create BM02 and
  payment data, and complete the order.
- Customer/staff cancellation, activity history, and notifications follow the
  status restrictions in `docs/screens/order-flow.md`.
- Admin manual assignment is an exception tool, not the normal dispatch path.
- While an assigned staff member is actively handling an order, foreground GPS
  is requested after `DANG_DEN`. Position changes of at least 20 m update the
  existing `NHAN_VIEN_THU_GOM` coordinate fields. The customer sees the live
  marker and pickup point through OpenStreetMap without a paid map API.

## Important backend boundary

Firebase data is live only when the Auth UID exactly matches the document ID of
`NGUOI_DUNG/{uid}` and its corresponding customer/staff/admin profile. Otherwise
the app cannot pass the audited Firestore Rules. A hot restart resets only the
mock fallback, never the Firestore path.

Foreground GPS is intentionally limited to the active staff order screen. It
does not track in the background or provide turn-by-turn routing. Dispatch uses
the latest saved coordinate and falls back deterministically when GPS is
missing. See `docs/backend-order-workflow.md`.

## Architecture already in place

- `lib/core/theme/app_theme.dart`: palette, spacing, radii, sizes, and Material theme.
- `lib/shared/widgets/app_widgets.dart`: reusable logo, page shell, inputs, actions, cards, chips, timelines, and empty states.
- `lib/features/customer/booking/`: booking screen split into small reusable widgets and calculator.
- `lib/features/customer/address_book/`: customer address list, responsive
  form, optional foreground GPS capture and Firestore/mock actions.
- `lib/features/customer/order_detail/`: order detail screen split into lookup and presentation widgets.
- `lib/features/staff/order/`: staff claim, ETA, status transition, collection record, and completion UI.
- `lib/providers/app_providers.dart`: Riverpod selectors plus temporary in-memory order, staff, payment, package, history, and notification state.
- `lib/providers/order_controller.dart`: the mock workflow authority for targeted dispatch and order transitions.
- `lib/features/orders/domain/staff_dispatch_ranker.dart`: shared GPS/fallback
  candidate ordering used by mock and Firestore flows.
- `lib/providers/mock_event_controllers.dart`: small in-memory stores for profiles, package usage, records, payments, logs, and notifications.
- `lib/features/orders/domain/`: production order commands, assignment model,
  repository contract, and workflow errors.
- `lib/features/orders/data/`: Firestore mappers and atomic order repository.
- `lib/features/orders/application/`: Riverpod providers for production order
  streams and repository access.
- `lib/features/location/`: foreground GPS service/controller and reusable map
  and location-sharing widgets.
- `functions/`: optional advanced matching implementation retained for future
  work; it is not part of the classroom runtime.
- `firestore.rules` and `firestore.indexes.json`: uppercase Spark-compatible
  access contract and required queries.

The chosen classroom runtime uses client Firestore transactions and does not
require Cloud Functions, Cloud Scheduler, or the Blaze plan.

## Required validation

Run these after any Dart/Flutter change:

```sh
flutter analyze
flutter test
```

The optional Functions code can still be unit-tested without deployment:

```sh
cd functions
npm test
```

For UI work, also follow `docs/ui-audit-checklist.md`. For data/backend work,
verify collection names and fields against `lib/schema_contract.dart` and
`docs/Documentation/Firestore_Data_Audit.md` before writing or deploying
anything.
