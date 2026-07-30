# Login Screen

## Reference
Use `docs/references/auth-home-reference.png`.

## Target
V3 uses no AppBar. Keep the approved centered composition on every viewport:
a large, sharp GreenTrash mark, brand name and slogan sit above the direct
form. The form stays centered and is capped at 460px on wide screens rather
than becoming a split marketing layout. Use 12px-radius inputs, a solid primary
CTA, compact helper controls, official Google/Facebook provider colors and a
clear sign-up link.

## Must use
- `AppColors`, `AppSpacing`, `AppRadius`, `AppSizes`
- Shared input/button style
- Compact typography
- Official palette from `docs/design-tokens.md`
- `BrandLogo` / `LogoMark`

## Must not use
- full-screen hero illustration
- split brand/form marketing panel
- decorative color band above the logo
- oversized pill inputs/buttons
- unrelated colors
