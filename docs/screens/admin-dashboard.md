# Admin Dashboard Screen

## Target
Admin dashboard must use the same mobile card system:

1. Shared responsive dashboard shell
2. Neutral gray page background
3. White overview card
4. Metric cards using the official palette only
5. Exception order cards: orders with no available/accepting staff or orders requiring manual intervention
6. Staff availability cards

Mobile uses bottom navigation; wide screens use the same navigation rail as
customer and staff dashboards. `Ngoại lệ` opens manual assignment while
`Tổng quan` remains the monitoring workspace.

## Rules
Do not introduce desktop admin panel styling. Keep mobile-first and consistent
with customer/staff screens. The normal dispatch path is customer -> system
suggestion -> staff accept/reject; admin assignment is a fallback or override,
not the primary workflow. Use botanical mid for operational metrics, sunflower yellow for
small pending/attention details, deep for positive metrics, and dark for
text/icons. Keep state labels and icons explicit because the palette is
intentionally restrained.
