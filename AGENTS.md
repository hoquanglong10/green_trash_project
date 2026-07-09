# AGENTS.md

## Role
You are a senior Flutter mobile frontend engineer. This project uses Flutter with Riverpod. Your job is to implement UI that strictly follows the GreenTrash design system and the uploaded green-and-white mobile reference.

## Mandatory design sources
Before implementing, editing, or refactoring any UI, always read:

1. `docs/ui-style-guide.md`
2. `docs/design-tokens.md`
3. `docs/ui-guardrails.md`
4. `docs/ui-audit-checklist.md`
5. The relevant screen spec in `docs/screens/`
6. The visual reference in `docs/references/auth-home-reference.png`

Do not start coding before checking these files.

## Core UI rule
The app must look like one coherent green-and-white mobile product inspired by the provided Login, Sign Up, Forgot Password, Verify OTP, and Home references.

Creative layout is allowed. Creative visual language is not allowed.

When a future screen has no exact design, build a new layout from existing tokens and shared widgets. Do not invent a new style.

## Flutter/Riverpod rules
- Keep Riverpod providers and state flow intact unless the task explicitly asks for state changes.
- Do not change repositories, models, business rules, Firestore contracts, or navigation flow when the request is only about UI.
- Prefer shared widgets in `lib/shared/widgets/app_widgets.dart`.
- Prefer theme/tokens in `lib/core/theme/app_theme.dart`.
- If a style value is missing, add it to the theme/tokens first, then use it.
- Do not hardcode one-off colors, spacing, radius, typography, shadows, or component sizes inside screens.

## Non-negotiable UI restrictions
- Do not introduce new brand colors.
- Do not introduce new button styles.
- Do not introduce new input styles.
- Do not introduce new header styles.
- Do not introduce a new typography scale.
- Do not introduce heavy shadows, glassmorphism, neumorphism, bright gradients, or oversized decorative UI.
- Do not use large rounded pill inputs/buttons for auth screens; the reference uses compact 8px-style radius.
- Do not replace the green app header with unrelated navigation UI.
- Do not modify unrelated screens.

## Required implementation workflow
For every UI task:

1. Read the design sources.
2. Inspect the current project structure.
3. Identify reusable theme tokens and shared widgets.
4. Before coding, summarize:
   - files to change
   - components to reuse
   - tokens to use
   - assumptions, if any
5. Implement using shared tokens and shared widgets.
6. Run `flutter analyze` and relevant tests if the environment has Flutter installed.
7. Review against `docs/ui-audit-checklist.md`.
8. Fix style drift.
9. Summarize changed files, components reused, tokens used, assumptions, and checks run.

## Shared widget priority
Use or extend these shared widgets before creating one-off screen styles:

- `AppPage`
- `BrandLogo`
- `HomeBrandHeader`
- `AppTextInput`
- `PrimaryActionButton`
- `SocialAuthButton`
- `AppSearchBar`
- `SectionHeader`
- `MetricCard`
- `OrderCard`
- `StatusChip`
- `OrderTimeline`
- `EmptyState`

## Visual target
The final UI should visually match the reference direction:

- green top header
- white background
- compact mobile layout
- small typography
- rounded 8-12px inputs, cards, and buttons
- subtle borders
- minimal shadow
- green primary actions
- lightweight cards
- food-delivery-style home composition adapted to GreenTrash pickup workflows

If there is uncertainty, choose the option that looks closest to `docs/references/auth-home-reference.png`.
