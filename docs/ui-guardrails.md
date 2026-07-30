# GreenTrash V3 UI Guardrails

## Required

- Use `AppColors`, `AppSpacing`, `AppRadius`, `AppSizes` and `AppMotion`.
- Reuse shared widgets before creating a screen-specific duplicate.
- Keep current state and next action above secondary information.
- Use white rows/cards on the neutral canvas with quiet borders.
- Use the green operational hero only where a strong brand/state anchor helps.
- Keep status understandable through text, icon and color together.
- Preserve 44px touch targets, Vietnamese labels and 360px layouts.
- Honor reduced motion and keep loading, empty and error states explicit.

## Avoid

- colored app bars on every screen
- card-inside-card layouts
- identical visual weight for every section
- decorative icon tiles on every row
- gradients outside operational heroes
- large yellow surfaces, neon colors, glow, glass or heavy shadow
- one-off hard-coded colors and component styles
- looping decorative animation
- changes to Riverpod, repositories, Firestore contracts or lifecycle during
  UI-only work

## Missing design information

Choose the layout that makes the current task and next action easiest to
understand, then express it with existing V3 tokens and components.
