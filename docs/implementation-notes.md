# Implementation Notes

## What was added

- Root `AGENTS.md` for Codex behavior and UI constraints.
- `docs/agent.md` with reusable prompts for future Codex work.
- Design docs: `ui-style-guide.md`, `design-tokens.md`, `ui-guardrails.md`, `ui-audit-checklist.md`.
- Screen specs for auth, customer home, staff home, admin dashboard, and order flow.
- Reference image copied to `docs/references/auth-home-reference.png`.

## What was updated in code

- `lib/core/theme/app_theme.dart`
  - Added `AppSpacing`, `AppRadius`, and `AppSizes` token classes.
  - Changed app theme to compact green-and-white mobile style.
  - Standardized AppBar, cards, buttons, inputs, chips, and typography.

- `lib/shared/widgets/app_widgets.dart`
  - Added reusable `AppTextInput`, `PrimaryActionButton`, `SocialAuthButton`, `DividerLabel`, and `AppSearchBar`.
  - Reworked `AppPage`, `HomeBrandHeader`, `MetricCard`, `OrderCard`, `StatusChip`, `OrderTimeline`, and `EmptyState` to use the design system.

- `lib/features/auth/auth_gate.dart`
  - Reworked Login, Sign Up, Forgot Password, and Verify OTP toward the provided reference style.
  - Removed the previous large hero/gradient auth layout.
  - Kept demo role selection and Riverpod session logic intact.

- `lib/features/customer/customer_home_screen.dart`
  - Reworked customer home to follow the reference Home structure: search, green promo card, package card, primary CTA, order list, notifications.

- `lib/features/customer/booking_screen.dart`
  - Kept the booking flow intact.
  - Fixed the default time-slot fallback to avoid an index error if the list has fewer than two items.

## Checks

Flutter/Dart tooling was not available in this environment, so `flutter analyze` and `flutter test` could not be executed here. Run locally:

```sh
flutter pub get
flutter analyze
flutter test
flutter run
```

## Design rule for future screens

Creative layout is allowed, but creative visual language is not allowed. New screens should reuse the tokens and shared widgets created here.
