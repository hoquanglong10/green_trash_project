# GreenTrash

GreenTrash is a Flutter + Riverpod waste-pickup application with three roles: customer, collection staff, and administrator/CSKH.

## Current state

- The app currently runs a complete **mocked** customer-to-staff order flow in memory.
- Firebase packages and project configuration exist, but the runtime has not yet initialized Firebase or written app data to Firestore.
- The real Firestore database was audited on 2026-07-08. Its collection names are uppercase Vietnamese identifiers such as `NGUOI_DUNG`, `DON_THU_GOM`, and `THONG_BAO`.
- The local `firestore.rules` file still targets an old lower_snake_case schema. Do not deploy it until it is migrated to the audited uppercase contract.

## Documentation map

- `docs/AI_COLLABORATOR_BRIEF.md`: self-contained context and implementation rules for any AI-assisted contributor.
- `docs/Documentation/GreenTrash_Project_Context.md`: product requirements, business rules, and the agreed target order flow.
- `docs/Documentation/Firestore_Data_Audit.md`: facts observed in the real Firestore database and migration gaps.
- `lib/schema_contract.dart`: code-level representation of the audited Firestore contract.
- `docs/firestore_schema.json`: portable JSON representation of the same audited schema for quick inspection or AI context.
- `docs/design-tokens.md`, `docs/ui-style-guide.md`, `docs/ui-guardrails.md`, and `docs/ui-audit-checklist.md`: the UI source of truth.
- `docs/screens/`: screen-level UI and flow specifications.

## Source layout

```text
lib/
  core/           theme, tokens, assets, formatting and status mapping
  models/         domain models used by the current UI and mock flow
  repositories/   repository interface and mock implementation
  providers/      Riverpod state and the order-flow controller
  shared/widgets/ reusable UI components
  features/       auth, customer, staff, and admin screens
  schema_contract.dart  audited Firestore collection and field contract
docs/             product, data, UI, and contributor documentation
test/             widget and customer-flow smoke tests
```

## Run locally

```sh
flutter pub get
flutter analyze
flutter test
flutter run
```
