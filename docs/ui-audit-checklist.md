# GreenTrash V3 UI Audit Checklist

## Sources

- [ ] Read `AGENTS.md` and V3 design documents
- [ ] Read the relevant screen and workflow specification
- [ ] Inspect shared theme and widgets before adding UI

## UX

- [ ] Screen state is clear in the first viewport
- [ ] The next primary action is obvious
- [ ] Secondary data does not compete with the primary task
- [ ] Loading, empty, error, disabled and success states are explicit
- [ ] Destructive actions require appropriate confirmation

## Visual system

- [ ] White app header and neutral canvas are used consistently
- [ ] Green hero is limited to brand or operational state
- [ ] Surfaces use quiet borders and no default elevation
- [ ] Semantic colors include an icon and text label
- [ ] No nested cards, decorative icon-tile repetition or large accent fills
- [ ] Typography, spacing, radius and motion use V3 tokens

## Responsive and accessibility

- [ ] No overflow at 360px
- [ ] Lists fill the responsive 760/900px shell
- [ ] Web-only scrollbar behavior is preserved
- [ ] Touch targets are at least 44px
- [ ] Reduced motion is honored

## Verification

- [ ] Riverpod/Firebase/business behavior is unchanged for UI work
- [ ] `flutter analyze` passes
- [ ] Relevant widget and responsive tests pass
- [ ] Customer, staff, admin and auth previews were reviewed
