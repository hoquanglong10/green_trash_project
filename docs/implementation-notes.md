# Implementation Notes

## Current implementation

The application is a Flutter + Riverpod prototype with a coherent customer, staff, and admin UI. It currently uses `MockGreenTrashRepository` and an in-memory `OrderController`; it is not yet connected to Firebase at runtime.

Implemented mock behaviour:

- Demo login switches among customer, staff, and admin sessions.
- A customer can create and cancel a pickup order, then view it in home and detail/tracking screens.
- The mock dispatcher chooses an available staff member from the same area first, then uses lower current revenue as a tie-breaker.
- The selected staff member can accept or reject the offer. A rejection advances the offer to another eligible staff member.
- Staff can update the order through the supported collection statuses.
- Admin has a manual assignment screen for exception handling, not as the normal dispatch path.

## Important backend boundary

Firebase dependencies, `firebase_options.dart`, and a Firestore schema contract are present, but the app does not call `Firebase.initializeApp`, Firebase Auth, or Cloud Firestore in its active flow. A hot restart resets all changes to mock seed data.

The target direct-offer flow needs a deliberate Firestore migration before real persistence is added. The audited `DON_THU_GOM` contract has no proposal fields, while the mock `PickupOrder` contains `nhanVienDeXuatId` and `nhanVienTuChoiIds`. See `docs/Documentation/Firestore_Data_Audit.md` and `docs/screens/order-flow.md` before changing backend code.

## Architecture already in place

- `lib/core/theme/app_theme.dart`: palette, spacing, radii, sizes, and Material theme.
- `lib/shared/widgets/app_widgets.dart`: reusable logo, page shell, inputs, actions, cards, chips, timelines, and empty states.
- `lib/features/customer/booking/`: booking screen split into small reusable widgets and calculator.
- `lib/features/customer/order_detail/`: order detail screen split into lookup and presentation widgets.
- `lib/providers/app_providers.dart`: Riverpod selectors plus the temporary in-memory order controller.

## Required validation

Run these after any Dart/Flutter change:

```sh
flutter analyze
flutter test
```

For UI work, also follow `docs/ui-audit-checklist.md`. For data/backend work, verify collection names and fields against `lib/schema_contract.dart` and `docs/Documentation/Firestore_Data_Audit.md` before writing or deploying anything.
