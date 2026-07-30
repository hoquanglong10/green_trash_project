# GreenTrash: AI Collaborator Brief

This is the self-contained project brief for any contributor using ChatGPT, Gemini, Claude, Copilot, or another AI assistant. Give this file to the AI before asking it to change code. The task owner assigns feature ownership separately; this file deliberately does not allocate work to individual people.

## 1. Product

GreenTrash is a Vietnamese waste-pickup application with three roles:

- **Customer**: manages addresses, chooses a waste type and time slot, books pickup, tracks the order, pays, manages a monthly package, views history, and submits complaints/reviews.
- **Collection staff**: receives one targeted nearby order at a time, accepts or rejects it, travels to the pickup point, records actual waste weight and evidence, then completes the order.
- **Admin/CSKH**: monitors operations, manages catalogue/price/package/account/complaint data, and intervenes only for exceptions or overrides.

The application is mobile-first. Admin screens are currently mobile-responsive Flutter screens; a separate desktop web experience is a later scope, not a reason to introduce a different visual language.

## 2. Current Reality: Mock UI With a Backend Foundation

The visible app is a functional UI prototype with in-memory Riverpod state.

- `MockGreenTrashRepository` supplies seed users, addresses, waste types, prices, packages, orders, logs, and notifications.
- `OrderController` mutates a local `List<PickupOrder>`.
- Login is a demo role/session switch, not Firebase Authentication.
- Creating, accepting, rejecting, cancelling, and updating an order affects the current app session only.
- A hot restart resets all data to seed values.
- `main.dart` initializes Firebase, and the customer/staff order flow uses the
  Firestore workflow adapter when Firebase Auth is active. Mock providers remain
  the widget-test/offline fallback.

Never claim that a screen is persisted or realtime until that screen has been
switched to the production providers and verified with Firebase Auth.

## 3. Agreed Core Order Flow

The course-project flow uses sequential targeted dispatch, similar to a
delivery app. It does not require admin assignment or Cloud Functions.

```text
Customer submits a pickup order
  -> order is CHO_XU_LY
  -> rank ready staff by GPS distance
  -> only nhanVienDeXuatId can see and respond to the offer
  -> accept: DA_NHAN; that staff becomes nhanVienHienTaiId and busy
  -> reject: record the reason and target the next nearest staff member
  -> no candidate: keep CHO_XU_LY with dangChoHoTro = true
```

The current mock and Firestore adapter both use this targeted flow. Candidate
ranking falls back to district, current revenue, then staff ID when GPS is
missing. Firestore transactions recheck the offer owner and staff availability.

Admin manual assignment is an exception/override. It may create a `CHO_NHAN` waiting state for the selected staff member, but it is not the normal path.

### Supported order statuses

```text
CHO_XU_LY -> CHO_NHAN (manual exception only) -> DA_NHAN
DA_NHAN -> DANG_DEN -> DA_DEN -> DANG_CAN_RAC -> HOAN_THANH
Any eligible pre-completion state -> HUY
```

Every real backend transition must eventually create an activity log and an appropriate notification. Cancellation, rejection, and complaint actions require a reason in the real implementation.

## 4. Authoritative Sources and Reading Order

Read these before changing a feature. Do not rely only on a screenshot or an old prompt.

1. `AGENTS.md`: mandatory UI rules for this repository.
2. `docs/Documentation/GreenTrash_Project_Context.md`: business requirements and current decisions.
3. `docs/Documentation/Firestore_Data_Audit.md`: observed facts from the real Firestore database.
4. `lib/schema_contract.dart`: code-level collection, field, type, and enum contract.
5. `docs/firestore_schema.json`: portable JSON representation of the audited schema; useful when handing context to another AI.
6. `docs/backend-order-workflow.md`: order persistence, open-queue logic,
   security, activation, and deployment boundaries.
7. `docs/screens/<relevant-screen>.md`: screen-specific requirements.
8. UI work additionally requires `docs/ui-style-guide.md`, `docs/design-tokens.md`, `docs/ui-guardrails.md`, `docs/ui-audit-checklist.md`, and `docs/references/auth-home-reference.png`.
9. Inspect the existing feature and shared widgets before writing a new widget.

If sources disagree, use this priority:

1. Firestore audit and `schema_contract.dart` for actual collection/field names.
2. `docs/screens/order-flow.md` for the agreed current order flow.
3. UI design documents and `AGENTS.md` for visual behaviour.
4. Original docx/PDF requirements for remaining business rules.

## 5. Repository Structure

```text
lib/
  main.dart                         application entry point and MaterialApp
  firebase_options.dart             active Firebase project options
  schema_contract.dart              audited Firestore collections, fields, and enums
  core/
    theme/app_theme.dart            AppColors, AppSpacing, AppRadius, AppSizes, theme
    constants/app_assets.dart       logo asset paths
    utils/formatters.dart           display formatting helpers
    utils/status_mapper.dart        status label/color/icon mapping
  models/app_models.dart            current UI/domain models
  repositories/green_trash_repository.dart
                                   repository interface and mock seed data
  providers/app_providers.dart      Riverpod providers and temporary OrderController
  shared/widgets/app_widgets.dart   shared design-system widgets
  features/
    auth/auth_gate.dart             demo login, register, forgot password, OTP screens
    customer/
      customer_home_screen.dart
      booking/                      booking screen, calculator, and booking widgets
      order_detail/                 order detail screen and detail widgets
    staff/                          staff home and order-handling screens
    admin/                          dashboard and manual exception assignment screens
    orders/
      domain/                       commands, assignments, repository contract
      data/                         Firestore mappers and atomic repository
      application/                  production Riverpod providers
functions/                          optional advanced matching; not required
docs/
  screens/                          individual screen specifications
  Documentation/                    project context and Firestore audit
  references/                       visual reference image
  logo/                             approved logo assets
test/                               widget and customer screen smoke tests
firestore.rules                     uppercase classroom security rules
firestore.indexes.json              Firestore query indexes
```

Do not collapse a feature back into one giant file. Keep reusable presentation widgets in a local `widgets/` folder; move a component to `lib/shared/widgets/` only when it is reused by multiple features.

## 6. State and Architecture Rules

The app uses Flutter Material and Riverpod.

- Use providers for app-wide/readable state. Keep UI rendering in feature screens and reusable widgets.
- `greenTrashRepositoryProvider` currently returns `MockGreenTrashRepository`.
- `currentSessionProvider` stores the demo session.
- `orderControllerProvider` owns mock order mutation and exposes selectors such
  as customer orders, staff open orders, staff accepted orders, and admin
  orders.
- Do not change models, provider ownership, repository semantics, order lifecycle, or navigation merely to make a UI task easier.
- Do not duplicate business logic in a screen. The order repository owns
  Firestore persistence and atomic claim transactions.

Core order-flow files are sensitive. Do not alter `lib/models/app_models.dart`, `lib/providers/app_providers.dart`, `lib/repositories/green_trash_repository.dart`, `lib/schema_contract.dart`, `firestore.rules`, or customer/staff order-flow screens unless the task explicitly asks for core-flow or backend work.

## 7. Firebase and Firestore Contract

### Actual database naming

The real `greentrashdb` database uses uppercase Vietnamese collection names.
Collection names are case-sensitive. `firestore.rules` is now aligned to this
contract; never reintroduce the old lower_snake_case names.

| Collection | Purpose | Important fields |
|---|---|---|
| `VAI_TRO` | roles | `roleId`, `tenVaiTro`, `trangThai` |
| `NGUOI_DUNG` | shared user profile | `userId`, `uidFirebase`, `roleId`, `trangThai` |
| `KHACH_HANG` | customer-only profile | `khachHangId`, `goiHienTaiId`, `diemUyTin` |
| `NHAN_VIEN_THU_GOM` | staff profile | `nhanVienId`, `maNhanVien`, `trangThaiLamViec`, working hours, location |
| `ADMIN` | administrator profile | `adminId`, `quyenQuanTri` |
| `DIA_CHI` | customer address | `diaChiId`, `khachHangId`, address parts, latitude/longitude |
| `LOAI_RAC` | waste catalogue | `loaiRacId`, `tenLoaiRac`, `nhomRac`, `trangThai` |
| `DICH_VU_GIA_BIEU` | price catalogue | `bangGiaId`, `loaiRacId`, `donGiaKg`, effective dates |
| `GOI_THU_GOM` | monthly package catalogue | `goiId`, `hanMucKgThang`, `giaGoi`, `phiVuotGoi` |
| `DANG_KY_GOI` | customer package subscription | `dangKyGoiId`, `khachHangId`, used/remaining kg, status |
| `DON_THU_GOM` | pickup order | `maDon`, customer/address/waste IDs, `nhanVienHienTaiId`, schedule, fee type, status |
| `PHAN_CONG_THU_GOM` | assignment/audit | `phanCongId`, `maDon`, `nhanVienId`, `adminId`, assignment status/reason |
| `BIEN_BAN_THU_GOM` | verified pickup result | actual waste, actual weight, evidence URL, fee/payment status |
| `THANH_TOAN` | payment | order/customer IDs, amount, method, status |
| `HOA_DON` | invoice | order/payment IDs, actual kg, price, total, PDF URL |
| `DOANH_THU_NHAN_VIEN` | staff revenue | staff/order IDs, amount, reconciliation state |
| `KHIEU_NAI` | complaint | sender, order, content, evidence, status, response |
| `DANH_GIA` | review | customer/staff/order IDs, rating/content |
| `THONG_BAO` | user notification | recipient, order, type, title, body, read state |
| `LICH_SU_HOAT_DONG` | immutable activity log | user, order, action, time, note |
| `THONG_KE_TONG_HOP` | aggregate reporting | date, area, waste type, order/kg/revenue totals |
| `THAM_SO_HE_THONG` | settings/enums | parameter key, value, effective date, state |

### Important identifiers and enums

- User roles: `ADMIN`, `CUSTOMER`, `STAFF`.
- Use `NGUOI_DUNG.roleId`, not a guessed `role` field.
- Pickup orders use `nhanVienHienTaiId`, not a generic `nhanVienId`.
- Core actual statuses: `CHO_XU_LY`, `CHO_NHAN`, `DA_NHAN`, `DANG_DEN`, `DA_DEN`, `DANG_CAN_RAC`, `HOAN_THANH`, `HUY`.
- Standard time slots: `06:00-08:00`, `08:00-10:00`, `10:00-12:00`, `13:00-15:00`, `15:00-17:00`.
- Fee types: `GOI_THANG`, `THEO_KG`.
- Staff availability includes `SAN_SANG`, `DANG_RANH`, `DANG_THU_GOM`, `TAM_NGHI`, `NGHI_VIEC`.

### Known data inconsistencies to handle explicitly

- One audited order uses `08-10` while system parameters use `08:00-10:00`.
- A package may use `CON_HL` rather than `CON_HIEU_LUC`.
- A payment may use `DA_TT` rather than `DA_THANH_TOAN`.
- One payment stores `GOI_THANG` in `phuongThuc`, although it is a fee type rather than a payment method.
- Some audited Vietnamese text may be encoding-damaged. Treat it as display data; do not invent enum values from it.

### Targeted-offer persistence

Offers are read from `DON_THU_GOM` with
`nhanVienDeXuatId == signed-in staff UID`; Rules prevent reading another
staff member's offer. `nhanVienTuChoiIds` stores rejected staff and
`offerExpiresAt` stores the current offer deadline. An acceptance creates
`PHAN_CONG_THU_GOM.DA_NHAN` and sets `nhanVienHienTaiId` plus
`phanCongHienTaiId` in one transaction. The same transaction changes
`NHAN_VIEN_THU_GOM.trangThaiLamViec` to `DANG_THU_GOM`, preventing a second
unfinished order from being claimed by that staff member. A dismissal creates
`PHAN_CONG_THU_GOM.TU_CHOI` and moves `nhanVienDeXuatId` to the next candidate.

The selected classroom backend uses Spark-compatible client transactions.
Blaze and Cloud Functions are not required.

Existing assignment data must be migrated before live activation. Read
`docs/backend-order-workflow.md` before deployment.

## 8. UI Design System

Every UI task must first read `AGENTS.md` and the design documents listed in section 4.

### V3 Calm Utility palette

Use the complete token table in `docs/design-tokens.md`. Core roles are
green600 `#285F46` for primary actions, green900 `#102F25` for operational
heroes, `#F4F6F4` for the page background, white for surfaces, `#D9DFDA` for
borders, and `#16221C` / `#536159` / `#7A867F` for the three text levels.

Semantic states are pending yellow, processing blue, success green and danger
red. Google/Facebook colors are allowed only inside provider marks.

### Layout and component rules

- Mobile-first, neutral-canvas/white-surface system with quiet borders.
- App screens use the compact white product header from Customer Home.
- Auth screens use no AppBar, the approved centered logo-and-form composition,
  a direct form surface and 12px-radius fields.
- Use the V3 typography scale from `docs/design-tokens.md`.
- Use `AppSpacing`, `AppRadius`, and `AppSizes` from `lib/core/theme/app_theme.dart`; do not hardcode a new spacing/radius/size system.
- Inputs/buttons are 50px, social buttons 48px, cards 16px radius and modal
  surfaces 22px.
- Gradients are reserved for heroes. AppBars and primary CTAs are solid.
- Sunflower yellow is limited to small attention elements and must not fill cards,
  AppBars, page backgrounds or primary buttons.
- Do not introduce colors or visual styles outside the V3 design system.

### Shared-widget priority

Reuse or extend these before creating a one-off component:

- `AppPage`, `BrandLogo`, `BrandWordmark`, `HomeBrandHeader`
- `AppTextInput`, `PrimaryActionButton`, `SocialAuthButton`, `AppSearchBar`
- `SectionHeader`, `MetricCard`, `OrderCard`, `StatusChip`, `OrderTimeline`, `EmptyState`
- `AppLoadingView`, `AppErrorState`, `AnimatedEntrance`, `DashboardHero`,
  `DashboardMetricCard`, `AnimatedProgressBar`, `OrderJourneyBar`

The customer home screen is the visual baseline for customer, staff, and admin screens. Do not make admin screens look like a separate desktop dashboard product.

## 9. Implementation Workflow for Any Task

1. Read the relevant docs and inspect the existing feature plus shared widgets.
2. State the files to change, reusable components, tokens, and assumptions before coding.
3. Keep the change scoped to the requested feature. Preserve uncommitted work from other people.
4. Use models/providers/repositories as they already exist; do not make a UI task change business rules.
5. Extract a local reusable widget when a screen begins to repeat meaningful presentation code.
6. For a shared pattern used across features, extend `lib/shared/widgets/app_widgets.dart` and the theme tokens first.
7. Run `flutter analyze` and relevant `flutter test` tests after Dart/Flutter changes.
8. For UI work, review `docs/ui-audit-checklist.md` and fix drift before finishing.
9. Report changed files, reused components, tokens, assumptions, and checks run.

## 10. Current Screen Coverage

Implemented at UI/mock-flow level:

- Login, sign-up, forgot-password, verify-OTP screens.
- Customer home, booking, order detail/tracking, cancellation action, package summary, order list, and notification cards.
- Staff home with targeted offers, accept/reject, busy-state offer hiding,
  accepted jobs, and order status handling.
- Admin dashboard and manual exception assignment.

Implemented as backend code but not yet connected to the visible screens:

- Firestore reads/writes, realtime listeners, atomic workflow transactions,
  uppercase security rules, indexes, and targeted-offer persistence.

Not yet completed as live end-to-end features:

- Firebase Auth session/profile handling and switching screens to production
  providers.
- FCM device-token registration and push delivery.
- Cloud Storage evidence upload.
- Payment gateway, invoice PDF, staff revenue reconciliation, full package purchase/renewal, complaint/review management, profile/address CRUD, and reporting data.

## 11. Safe Prompt Template for Another AI

```md
You are contributing to the GreenTrash Flutter + Riverpod project.

First read:
- docs/AI_COLLABORATOR_BRIEF.md
- AGENTS.md
- the relevant docs/screens/<screen>.md file
- for UI: docs/ui-style-guide.md, docs/design-tokens.md,
  docs/ui-guardrails.md, docs/ui-audit-checklist.md, and
  docs/references/auth-home-reference.png

Task: <describe one scoped task>.

Before coding, state the files you will change, shared widgets/theme tokens you
will reuse, and any assumptions. Preserve existing provider/repository/model
logic unless this task explicitly requires a data-flow change. Do not claim the
mock app writes to Firebase. After code changes run flutter analyze and relevant
flutter test, then report the result and any remaining backend dependency.
```

## 12. Final Guardrails

- Do not overwrite or revert somebody else's uncommitted work.
- Do not use guessed Firestore names, fields, roles, or statuses.
- Do not deploy Firestore or Functions before migration, dry-run, and owner
  review.
- Do not turn a UI request into a schema/business-flow refactor.
- Do not turn a mock interaction into a fake claim of backend completion.
- Ask the task owner when a requirement needs new Firestore fields, a new order status, a schema migration, or a cross-feature shared abstraction.
