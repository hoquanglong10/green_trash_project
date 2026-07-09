# Design Tokens

These tokens define the GreenTrash visual system. All UI must use these values or their code equivalents in `lib/core/theme/app_theme.dart`.

## Colors

### Official Palette
This palette is the single source of truth from `docs/references/auth-home-reference.png` and the current Customer Home screen.

- `green`: `#10B981`
- `blue`: `#2563EB`
- `amber`: `#F59E0B`
- `purple`: `#8B5CF6`
- `slate`: `#1F2937`
- `gray`: `#F3F4F6`
- `white`: `#FFFFFF`

Usage roles:
- `green` / `primary`: app header, main CTA, active package/progress, positive order states, selected borders, brand accents.
- `blue` / `secondary`: in-progress/working states, secondary links, staff movement/status highlights.
- `amber` / `accent`: pending state, small alert dot, warning or attention badges, compact accent markers.
- `purple` / `support`: QR, support, notification utility, and non-critical secondary accents.
- `slate` / `text`: main text, card titles, important body text, neutral icons.
- `gray` / `background`: app background, search/input light areas, badge surfaces, subtle separators.
- `white` / `surface`: cards, forms, modal/bottom-sheet surfaces, content regions.

Only these seven palette colors may be introduced as new brand colors. Muted text, borders, and soft state backgrounds must be alpha/opacity variants of these colors, not separate color families.

### Code Tokens
- `primary`: `green`
- `primaryDark`: `slate`
- `secondary`: `blue`
- `accent`: `amber`
- `support`: `purple`
- `screenBackground`: `gray`
- `surface`: `white`
- `surfaceAlt`: `gray`
- `text`: `slate`
- `success`: `green`
- `warning`: `amber`
- `error`: `amber`

Compatibility aliases such as `jungleGreen`, `bahia`, `corduroy`, `azure`, and `HomeTrialColors` may exist in code temporarily, but they must resolve to the official palette values above.

### Auth Reference Controls
These tokens support the current auth reference variant and should be used only for auth helper controls, role/demo selectors, auth links, and provider logos.

- `authControlText`: `slate` at muted opacity
- `authControlIcon`: `slate` at muted opacity
- `authControlSurface`: `gray`
- `authControlSelectedSurface`: `slate` at light opacity
- `authControlBorder`: `slate` at border opacity
- `authControlSelectedBorder`: `slate` at border opacity
- `authLinkBlue`: `blue`
- `googleBlue`: `#4285F4`
- `googleRed`: `#EA4335`
- `googleYellow`: `#FBBC05`
- `googleGreen`: `#34A853`
- `facebookBlue`: `#1877F2`

Social provider colors are allowed only inside provider logo icons.

### Background
- `screenBackground`: `#F3F4F6`
- `surface`: `#FFFFFF`
- `surfaceAlt`: `#F3F4F6`
- `mint`: `green` at soft opacity

### Text
- `text`: `#1F2937`
- `muted`: `#1F2937` at 80% opacity
- `textMuted`: `#1F2937` at 60% opacity
- `textInverse`: `#FFFFFF`
- `textInverseMuted`: `#FFFFFF` at 80% opacity

### Borders and states
- `border`: `#1F2937` at 12% opacity
- `borderLight`: `#1F2937` at 8% opacity
- `success`: `#10B981`
- `warning`: `#F59E0B`
- `error`: `#F59E0B`

## Typography
Use the project font unless a product font is added later.

- `headerTitle`: 15px, weight 600
- `screenTitle`: 18px, weight 700
- `sectionTitle`: 14px, weight 700
- `label`: 12px, weight 500
- `inputText`: 13px, weight 400
- `buttonText`: 13px, weight 600
- `body`: 12px, weight 400
- `caption`: 11px, weight 400
- `tiny`: 10px, weight 400

## Spacing
Allowed scale:

- `xxs`: 2
- `xs`: 4
- `sm`: 8
- `md`: 12
- `lg`: 16
- `xl`: 20
- `xxl`: 24
- `xxxl`: 32

Screen spacing:

- `screenHorizontal`: 16
- `authScreenHorizontal`: 24
- `homeScreenHorizontal`: 12
- `sectionGap`: 20
- `fieldGap`: 14
- `labelInputGap`: 6
- `buttonTopGap`: 20

## Radius
- `xs`: 4
- `sm`: 6
- `md`: 8
- `lg`: 10
- `xl`: 12
- `xxl`: 16
- `pill`: 999

## Component sizes
- `appHeaderHeight`: 56
- `inputHeight`: 46
- `buttonHeight`: 46
- `socialButtonHeight`: 44
- `cardRadius`: 10
- `promoCardRadius`: 12
- `headerIconSize`: 22

## Shadows
The reference uses no shadow or very subtle shadows.

Allowed:
- no shadow
- very light card shadow only if needed for separation

Not allowed:
- heavy shadow
- colored shadow
- neumorphic shadow
- floating glass cards
