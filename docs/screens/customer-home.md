# Customer Home Screen

## Target
This screen is now the canonical visual baseline for GreenTrash:

1. Green `#10B981` AppBar
2. Full white `BrandWordmark` centered in the header, using `docs/logo/logo_mark.png` plus vector text for smooth rendering
3. Light gray `#F3F4F6` page background
4. White cards with subtle slate-opacity borders
5. Green-led greeting/status promo composition adapted to pickup workflows; blue is a small operational accent only, not a new visual language or a new gradient treatment
6. Compact search/status area
7. Promo/status card for current subscription
8. Primary CTA to book pickup
9. Active order cards
10. Notification bell opens a compact preview popup; notification cards do not
   occupy Home content space.

## Rules
Use compact cards, green primary actions, blue for in-progress states, amber for pending states, purple for utility/support accents, slate text, and small section titles.

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
