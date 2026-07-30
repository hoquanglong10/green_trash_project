# Staff Home Screen

## Target
Operational version of the Customer Home style for staff:

1. Responsive `DashboardShell` with white AppBar, mobile bottom navigation and
   wide navigation rail
2. Neutral gray page background
3. White work-shift status card
4. Metric cards using dark, deep, mid and sage botanical accents only
5. One targeted pending order, followed by the signed-in staff member's accepted orders
6. Compact order cards and status chips

## V3 composition

- The start-aligned full-color brand and compact app bar match Customer Home.
- Shift state is the first visual priority. Botanical deep communicates
  availability, mid communicates an active trip, and dark communicates
  pause/offline.
- New offers use sage attention accents; accepted work uses botanical mid
  operational accents.
- Metric values transition without resizing their cards.
- Metric and order-information icons are compact filled Material icons with
  semantic colors and no repeated decorative tile treatment.
- Open offers expose a compact journey bar before the decision actions.
- Logout lives in the drawer so the app header matches Customer Home.
- Dashboard sections use brief staggered entrances and honor reduced-motion
  settings.
- On wide layouts, active missions and offers occupy the primary column while
  recent history forms a secondary column.

## Rules
Keep it fast to scan, compact, and action-oriented. A targeted offer exposes
only the necessary pickup information and explicit `Nhan don` / `Tu choi`
actions. Only the staff ID stored in `nhanVienDeXuatId` may see it; rejection
moves it to the next nearest available candidate. Do not
use admin-dashboard-heavy visuals. Staff screens must feel like the same app
as Customer Home, with botanical mid reserved for active pickup progress and
sunflower yellow reserved for small pending/attention details. State labels and icons
remain explicit.

When the staff member has an active order, the new-offer section is hidden, the
availability switch is disabled, and an explicit lock reason is shown below it.

## Recent History

- Home shows at most two completed or cancelled staff orders.
- `Xem lịch sử` opens the full staff work-history list instead of expanding the
  operational Home screen.
- Staff history is sorted by `ngayCapNhat` descending (the completion/cancel
  time), with `ngayTao` as the legacy-data fallback.
