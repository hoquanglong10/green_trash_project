# Customer Home Screen

## Target
This screen is now the canonical visual baseline for GreenTrash:

1. Responsive `DashboardShell` with a compact white AppBar
2. Full-color `BrandLogo` aligned to the start of the product header
3. Neutral gray page background
4. White cards with `#DFE6DF` borders and minimal depth
5. Preserve the forest-to-leaf greeting gradient and its pickup workflow
   hierarchy
6. Compact search/status area
7. Promo/status card for current subscription
8. Primary CTA to book pickup
9. Active order cards
10. Notification bell opens a compact preview popup; notification cards do not
   occupy Home content space.

## V3 composition

- The app bar is 64px high. Mobile uses a bottom navigation bar and a drawer;
  wide screens use a navigation rail.
- `Dia chi` opens the customer address book from bottom navigation, navigation
  rail or the mobile drawer.
- The greeting hero uses the restrained green900-green700 gradient. It must not contain a
  separate olive color block.
- The active order includes an animated journey bar so status changes are
  understandable before opening order details.
- Subscription usage animates once when data appears or changes.
- Package, recent-order and information rows use filled Material icons without
  repeated decorative tiles. Yellow is limited to pending and premium details.
- Dashboard sections use a brief staggered entrance and honor reduced-motion
  settings.
- On wide screens, action/tracking content and recent activity form balanced
  columns. Mobile retains a single clear vertical flow.
- The first viewport follows the task hierarchy: personal greeting, active
  order, then shortcuts and package information.

## Rules
Use compact cards, solid green600 primary actions, blue for in-progress states,
sunflower yellow for pending details, semantic red for cancellation, and the
three text roles from `AppColors`. Keep status icons and labels visible.

Order cards display a shortened `Đơn #XXXXXXXX` label while preserving the
full Firestore ID for navigation and detail behavior.

The Home screen must pass without overflow at 320, 375, 390 and 430px.

When an active order exists, Home changes its hero action to `Xem tiến trình`
and hides new-booking shortcuts. This prevents the customer from entering a
flow that overlap validation will reject.

## Notifications

- The top-right bell opens a lightweight popover anchored below the bell.
- The preview initially shows the newest notification. `Xem thêm` reveals up to
  three notifications in total; longer history belongs in the full list.
- `Xem tất cả` opens the dedicated notification list screen.
- Live Firebase data is read from `THONG_BAO` for the signed-in user; the mock
  notification controller remains the widget-test fallback.

## Recent Orders

- Home shows exactly the two newest customer orders.
- `Xem lịch sử` opens the full customer order list; older orders do not expand
  the Home screen.
