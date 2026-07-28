# Staff Home Screen

## Target
Operational version of the Customer Home style for staff:

1. Green `#10B981` AppBar
2. Light gray page background
3. White work-shift status card
4. Metric cards using green, blue, amber, and purple accents only
5. Open pending orders, followed by the signed-in staff member's accepted orders
6. Compact order cards and status chips

## Rules
Keep it fast to scan, compact, and action-oriented. Open orders expose only
the necessary pickup information and explicit `Nhận đơn` / `Bỏ qua` actions.
All available staff may see a pending order; the first successful transaction
claims it, while `Bỏ qua` hides it only for the current staff member. Do not
use admin-dashboard-heavy visuals. Staff screens must feel like the same app
as Customer Home, with blue reserved for active pickup progress and amber for
pending/attention states.

## Recent History

- Home shows at most two completed or cancelled staff orders.
- `Xem lịch sử` opens the full staff work-history list instead of expanding the
  operational Home screen.
- Staff history is sorted by `ngayCapNhat` descending (the completion/cancel
  time), with `ngayTao` as the legacy-data fallback.
