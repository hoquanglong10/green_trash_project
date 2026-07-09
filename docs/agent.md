# Codex Operating Guide for GreenTrash UI

Use this file as the user-facing runbook for future Codex tasks.

## Default prompt for UI work

```md
Read `AGENTS.md`, `docs/ui-style-guide.md`, `docs/design-tokens.md`, `docs/ui-guardrails.md`, `docs/ui-audit-checklist.md`, and the relevant file in `docs/screens/` before coding.

Task: <describe the screen or UI change>.

Rules:
- Flutter + Riverpod project. Do not change providers, repositories, models, order lifecycle, or navigation unless explicitly requested.
- Use `lib/core/theme/app_theme.dart` for tokens.
- Reuse widgets in `lib/shared/widgets/app_widgets.dart`.
- Do not invent new visual style.
- Creative layout is allowed, but creative visual language is not allowed.
- Match `docs/references/auth-home-reference.png`.

Before coding, summarize the implementation plan. After coding, run checks if available and review against `docs/ui-audit-checklist.md`.
```

## Prompt for new screens with no exact design

```md
Design and implement <screen name>.

There is no exact reference screen, so create the layout creatively while strictly following the existing GreenTrash UI style.

Allowed:
- new layout using existing components
- new combination of cards, forms, metrics, and actions

Not allowed:
- new colors
- new typography scale
- new button/input/header/card visual language
- heavy shadows or unrelated UI trends

Use `AppPage`, `AppTextInput`, `PrimaryActionButton`, `MetricCard`, `OrderCard`, `StatusChip`, `OrderTimeline`, and other shared widgets when applicable.
```

## Prompt for fixing style drift

```md
The implementation has style drift. Re-read `AGENTS.md`, `docs/ui-style-guide.md`, `docs/design-tokens.md`, `docs/ui-guardrails.md`, and `docs/references/auth-home-reference.png`.

Fix:
1. hardcoded colors outside tokens
2. hardcoded spacing/radius outside tokens
3. duplicate one-off inputs/buttons/cards
4. headers that do not use the green app style
5. oversized typography or pill-shaped controls
6. unrelated visual effects

Do not change functionality.
```
