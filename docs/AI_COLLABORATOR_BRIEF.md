# GreenTrash: AI Collaborator Brief

This is the self-contained project brief for any contributor using ChatGPT, Gemini, Claude, Copilot, or another AI assistant. Give this file to the AI before asking it to change code. The task owner assigns feature ownership separately; this file deliberately does not allocate work to individual people.

## 1. Product

GreenTrash is a Vietnamese waste-pickup application with three roles:

- **Customer**: manages addresses, chooses a waste type and time slot, books pickup, tracks the order, pays, manages a monthly package, views history, and submits complaints/reviews.
- **Collection staff**: receives a nearby pickup offer, accepts or rejects it, travels to the pickup point, records actual waste weight and evidence, then completes the order.
- **Admin/CSKH**: monitors operations, manages catalogue/price/package/account/complaint data, and intervenes only when the normal dispatcher cannot resolve an order or when an override is needed.

The application is mobile-first. Admin screens are currently mobile-responsive Flutter screens; a separate desktop web experience is a later scope, not a reason to introduce a different visual language.

## 2. Current Reality: Mock Flow, Not a Live Backend

The visible app is a functional UI prototype with in-memory Riverpod state.

- `MockGreenTrashRepository` supplies seed users, addresses, waste types, prices, packages, orders, logs, and notifications.
- `OrderController` mutates a local `List<PickupOrder>`.
- Login is a demo role/session switch, not Firebase Authentication.
- Creating, accepting, rejecting, cancelling, and updating an order affects the current app session only.
- A hot restart resets all data to seed values.
- Firebase packages, Firebase options, and an audited Firestore contract are present, but `main.dart` does not initialize Firebase and the active repository does not call Firestore.

Never claim that a screen is already persisted or realtime unless a Firebase repository has actually been connected and verified.

## 3. Agreed Core Order Flow

The product uses direct staff offers, similar to a delivery app. It must not require an admin to manually assign every ordinary order.

```text
Customer submits a pickup order
  -> order is CHO_XU_LY
  -> dispatcher chooses one eligible nearby/available staff member
  -> staff receives a new-order offer and notification
  -> staff accepts: DA_NHAN; that staff becomes nhanVienHienTaiId
  -> staff rejects: record the rejection; dispatch to the next eligible staff member
  -> no eligible staff remains: keep CHO_XU_LY for admin/CSKH exception handling
```

The current mock chooses staff who are `SAN_SANG`, prefers the same district, then uses lower current revenue as a tie-breaker. This is a prototype heuristic, not a production geospatial matching algorithm.

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
5. `docs/screens/<relevant-screen>.md`: screen-specific requirements.
6. UI work additionally requires `docs/ui-style-guide.md`, `docs/design-tokens.md`, `docs/ui-guardrails.md`, `docs/ui-audit-checklist.md`, and `docs/references/auth-home-reference.png`.
7. Inspect the existing feature and shared widgets before writing a new widget.

If sources disagree, use this priority:

1. Firestore audit and `schema_contract.dart` for actual collection/field names.
2. `docs/screens/order-flow.md` for the agreed current order flow.
3. UI design documents and `AGENTS.md` for visual behaviour.
4. Original docx/PDF requirements for remaining business rules.

## 5. Repository Structure

```text
lib/
  main.dart                         application entry point and MaterialApp
  firebase_options.dart             Firebase project options; not active at runtime yet
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
docs/
  screens/                          individual screen specifications
  Documentation/                    project context and Firestore audit
  references/                       visual reference image
  logo/                             approved logo assets
test/                               widget and customer screen smoke tests
```

Do not collapse a feature back into one giant file. Keep reusable presentation widgets in a local `widgets/` folder; move a component to `lib/shared/widgets/` only when it is reused by multiple features.

## 6. State and Architecture Rules

The app uses Flutter Material and Riverpod.

- Use providers for app-wide/readable state. Keep UI rendering in feature screens and reusable widgets.
- `greenTrashRepositoryProvider` currently returns `MockGreenTrashRepository`.
- `currentSessionProvider` stores the demo session.
- `orderControllerProvider` owns mock order mutation and exposes selectors such as customer orders, staff offers, staff accepted orders, and admin orders.
- Do not change models, provider ownership, repository semantics, order lifecycle, or navigation merely to make a UI task easier.
- Do not duplicate business logic in a screen. A future real repository/service should own persistence, transactions, and mapping.

Core order-flow files are sensitive. Do not alter `lib/models/app_models.dart`, `lib/providers/app_providers.dart`, `lib/repositories/green_trash_repository.dart`, `lib/schema_contract.dart`, `firestore.rules`, or customer/staff order-flow screens unless the task explicitly asks for core-flow or backend work.

## 7. Firebase and Firestore Contract

### Actual database naming

The real `greentrashdb` database uses uppercase Vietnamese collection names. Collection names are case-sensitive. Do not use the old lower_snake_case names from the current `firestore.rules` file.

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

### Direct-offer migration gap

The mock model uses `nhanVienDeXuatId` and `nhanVienTuChoiIds`, but the audited `DON_THU_GOM` contract does not contain them. `PHAN_CONG_THU_GOM.adminId` is currently required, so it cannot yet cleanly represent an offer created by the system.

Before real backend work, the team must approve one schema design: either extend `PHAN_CONG_THU_GOM` for system offers/admin overrides, or add proposal fields to `DON_THU_GOM`. Then update the Firestore schema contract, security rules, indexes, mappers, tests, and documentation together. Do not quietly add fields from a UI screen.

`firestore.rules` is currently an old lower_snake_case ruleset and is incompatible with the audited database. Do not deploy it.

## 8. UI Design System

Every UI task must first read `AGENTS.md` and the design documents listed in section 4.

### Official palette

| Token | Hex | Use |
|---|---|---|
| `green` / primary | `#10B981` | header, primary CTA, active/positive state |
| `blue` / secondary | `#2563EB` | active pickup or secondary operational status |
| `amber` / accent | `#F59E0B` | pending/attention chips and compact accents |
| `purple` / support | `#8B5CF6` | support, QR, notification utility accents |
| `slate` / text | `#1F2937` | primary text and neutral icons |
| `gray` / background | `#F3F4F6` | screen background, subtle surfaces/dividers |
| `white` / surface | `#FFFFFF` | cards, forms, modal surfaces |

Muted text, borders, and soft backgrounds must be opacity variants of the official palette. Google/Facebook logo colors are allowed only inside their provider icons.

### Layout and component rules

- Mobile-first, compact, white/gray card system, light borders, minimal/no shadows.
- App screens use the green header pattern from Customer Home: wordmark centered, menu left, notification right where relevant.
- Auth screens use no AppBar, a centered real logo mark, slogan below, compact 8px-style fields, and a green full-width CTA.
- Use only the existing compact typography scale: screen title 18, section title 14, label 12, input/button 13, body 12, caption 11, tiny 10.
- Use `AppSpacing`, `AppRadius`, and `AppSizes` from `lib/core/theme/app_theme.dart`; do not hardcode a new spacing/radius/size system.
- Inputs and primary buttons are 46px high; social buttons are 44px; cards use roughly 10px radius; promo cards use 12px radius.
- Cards are white on `#F3F4F6`; primary actions are green; pending is amber; active travel is blue; complete is green; utility is purple; cancelled is slate/gray.
- Do not introduce a new palette, typography scale, header style, button/input style, large hero layout, heavy shadows, glassmorphism, neumorphism, decorative illustrations, or bright gradients.

### Shared-widget priority

Reuse or extend these before creating a one-off component:

- `AppPage`, `BrandLogo`, `BrandWordmark`, `HomeBrandHeader`
- `AppTextInput`, `PrimaryActionButton`, `SocialAuthButton`, `AppSearchBar`
- `SectionHeader`, `MetricCard`, `OrderCard`, `StatusChip`, `OrderTimeline`, `EmptyState`

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
- Staff home with new-order offers, accept/reject, accepted jobs, and order status handling.
- Admin dashboard and manual exception assignment.

Not yet completed as real end-to-end backend features:

- Firebase Auth session/profile handling.
- Firestore reads/writes, realtime listeners, transactions, and security rules aligned to uppercase collections.
- Direct-offer persistence and real push notifications.
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
- Do not deploy the current Firestore rules file.
- Do not turn a UI request into a schema/business-flow refactor.
- Do not turn a mock interaction into a fake claim of backend completion.
- Ask the task owner when a requirement needs new Firestore fields, a new order status, a schema migration, or a cross-feature shared abstraction.
