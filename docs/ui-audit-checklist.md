# UI Audit Checklist

Before finishing any UI task, verify:

## Design source check
- [ ] Read `AGENTS.md`
- [ ] Read `docs/ui-style-guide.md`
- [ ] Read `docs/design-tokens.md`
- [ ] Read `docs/ui-guardrails.md`
- [ ] Read the relevant screen spec
- [ ] Checked `docs/references/auth-home-reference.png`

## Token usage
- [ ] Colors use `AppColors`
- [ ] Spacing uses `AppSpacing` or repeated approved values
- [ ] Radius uses `AppRadius`
- [ ] Sizes use `AppSizes`
- [ ] Typography is compact and theme-driven
- [ ] No old `#22AA86`, `#9CC026`, `#44514E`, or `#F2F4F4` brand colors remain

## Component reuse
- [ ] `AppPage` reused for app screens
- [ ] Shared input/button/card/list widgets reused where applicable
- [ ] No duplicate one-off component styles
- [ ] New shared component added only when reusable

## Visual consistency
- [ ] Main screen green header matches Customer Home reference style
- [ ] Auth screens use the no-AppBar centered-logo variant
- [ ] Buttons match reference style
- [ ] Inputs match reference style
- [ ] Cards match reference style
- [ ] Typography remains compact
- [ ] Page background uses light gray and cards/forms use white
- [ ] No unrelated visual language introduced

## Scope control
- [ ] No unrelated files changed
- [ ] No business logic changed
- [ ] No Riverpod provider changes unless requested
- [ ] No Firestore schema changes unless requested

## Final summary
Include:

- files changed
- components reused
- tokens used
- assumptions made
- checks run
