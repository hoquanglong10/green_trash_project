# GreenTrash V3 Design Tokens

`lib/core/theme/app_theme.dart` is the executable source of truth.

## Brand

- `green50`: `#F0F5F2`
- `green100`: `#DCE9E1`
- `green200`: `#B9D2C2`
- `green300`: `#8DB49C`
- `green400`: `#5F9275`
- `green500`: `#3E765A`
- `green600`: `#285F46` - primary action
- `green700`: `#1F4D3A`
- `green800`: `#173D2F`
- `green900`: `#102F25` - brand hero
- `green950`: `#091E18`

## Neutral

- screen background: `#F4F6F4`
- surface: `#FFFFFF`
- alternate surface: `#EAEEEB`
- border: `#D9DFDA`
- divider: `#C6CEC8`
- primary text: `#16221C`
- secondary text: `#536159`
- tertiary text: `#7A867F`

## Semantic

- pending/attention: yellow `#F4C430`, deep label `#8A5A00`
- processing: blue `#245EA8` on `#E8F1FF`
- success: green `#26733A` on `#E3F5E8`
- danger: red `#B7382E` on `#FDE9E7`

Semantic colors must be paired with an icon and label. Yellow never fills a
large surface.

## Composition

- app header: white with a bottom border
- operational hero: subtle `green900 -> green700` gradient
- primary action: solid `green600`
- screen canvas: cool neutral gray
- content rows/cards: white with a 1px border and no default elevation

## Type

- headline small: 22/28, weight 700
- title large: 18/24, weight 600
- title medium: 16/22, weight 600
- title small: 14/20, weight 600
- body: 14/20, weight 400
- body small: 12/18, weight 400
- labels: 12-14, weight 600-700

Use hierarchy and weight before adding another size.

## Shape and spacing

- controls: 12px radius
- cards and operational panels: 12-16px radius
- modal surfaces: 22px radius
- standard spacing scale: 4, 8, 12, 16, 20, 24, 32
- touch targets: at least 44px

## Motion

- fast: 180ms
- standard: 280ms
- slow: 420ms
- easing: `Curves.easeOutCubic`

Motion explains navigation, loading, selection and progress. It is not ambient
decoration.
