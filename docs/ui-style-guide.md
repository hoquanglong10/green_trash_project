# GreenTrash UI Style Guide

## Product style
GreenTrash is a clean, compact, green-and-white mobile app for waste pickup booking, order assignment, and collection operations.

The reference UI includes Login, Sign Up, Forgot Password, Verify OTP, and Home screens. GreenTrash adapts that visual language to waste pickup workflows.

## Visual identity
The UI must feel:

- simple
- clean
- compact
- mobile-first
- white-background based
- green brand-led
- lightly bordered
- rounded but not pill-heavy
- easy to scan during pickup/order operations

## Auth screens
Auth screens follow this pattern:

1. No AppBar in the current reference variant
2. Centered real GreenTrash logo mark from `docs/logo/logo_mark.png`
3. Slogan directly below the logo
4. Compact labels and rounded 8px inputs
5. Full-width green primary button
6. Gray helper controls for remember/forgot/demo roles
7. Provider buttons with official Google/Facebook logo colors
8. Footer navigation link, with sign-up link in blue

Avoid large hero illustrations, oversized titles, large gradients, or decorative shapes on auth screens.

## Main screens
Customer Home is the visual baseline for customer, staff, and admin screens:

1. Green AppBar
2. Full white GreenTrash wordmark centered in the header
3. Menu icon on the left and notification icon on the right for Home-style screens
4. Light gray page background
5. White cards with subtle borders and minimal shadow
6. Compact promotional/status header card
7. Section headers
8. Lightweight cards/lists
9. Bottom action bars for important flows
10. Bottom navigation on customer-style mobile screens when needed

## Order flows
Customer booking and staff collection flows must stay operationally clear:

- selected states use mint/green
- status chips use compact rounded chips
- primary action buttons stay green
- destructive actions use outlined or error styling
- progress/timeline components must remain compact

## Creative rule
When creating a new screen without an exact reference:

Allowed:
- new arrangement of existing components
- new combinations of order cards, metric cards, forms, and action bars
- new content hierarchy

Not allowed:
- new color palette
- new typography scale
- new header style
- new button/input/card visual language
- heavy decoration or unrelated modern UI trends

The screen can be creatively composed, but it must still look like the same app as the reference.

## Palette rule
Use only the official GreenTrash palette from `docs/design-tokens.md`:

- Green `#10B981`
- Blue `#2563EB`
- Amber `#F59E0B`
- Purple `#8B5CF6`
- Slate `#1F2937`
- Gray `#F3F4F6`
- White `#FFFFFF`

Borders, muted text, and soft backgrounds must be opacity variants of these colors.
