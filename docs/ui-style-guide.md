# GreenTrash V3 UI Style Guide

## Product direction

GreenTrash V3 is a calm, operational eco-service product. The interface is
designed around tasks, status and readable data rather than decorative cards.
It should feel trustworthy, current and useful during a pickup.

The visual language uses:

- a white product header with dark botanical text and icons
- cool neutral gray page canvas
- white content surfaces with quiet borders
- deep botanical green for brand moments and primary actions
- yellow, blue, green and red only for semantic status
- spacing and typography instead of decorative containers
- short motion that explains entry, progress and state changes

## Information hierarchy

Each screen must answer these questions in order:

1. Where am I?
2. What is the current state?
3. What should I do next?
4. What supporting information do I need?

Do not give every block the same visual weight. Operational state and the next
action come before metadata and history.

## Auth

- Auth uses the approved centered logo-and-form composition.
- The form remains centered with a 460px maximum width on wide screens.
- Forms are not placed in a floating marketing card.
- Inputs and actions use 12px radius and explicit error/loading states.
- Real GreenTrash assets and official provider marks are required.

## Customer

- Home uses `DashboardShell`: white product header, bottom navigation on mobile
  and navigation rail on wide screens.
- The deep-green greeting hero remains, but the active order is the primary
  operational module directly below it.
- An active order replaces new-booking shortcuts with a direct progress action.
- Booking is a four-part workflow: address, waste, schedule, confirmation.
- Tracking leads with current state, then pickup facts, map, timeline and logs.
- Home shows two recent orders; the full list lives on History.
- Notifications use an anchored preview and a responsive full list.

## Staff

- Home uses the same responsive shell and is an operations console: shift
  state, availability, live metrics, active work, offers, then recent history.
- Offers expose only the facts needed to accept or dismiss.
- Active-order screens keep the next valid action in the bottom action surface.
- Location sharing, progress and collection evidence remain explicit.

## Admin

- Admin uses the shared responsive dashboard shell and remains a compact data
  workspace, not a marketing dashboard.
- Overview metrics, exception orders and staff availability are primary.
- Manual assignment is an exception workflow, not the normal dispatch path.

## Responsive behavior

- Mobile content padding is 16px.
- Wide content uses a maximum width of 760px for flows, 900px for lists and
  1120-1180px for responsive dashboards.
- Dashboard columns split only when each column remains readable.
- Cards and rows fill the available content width.
- Native scrollbars are web-only.
- All screens must work at 360px without overflow.

## Motion

Use entrance, progress and state-change animation only. Honor reduced motion.
Never loop decoration or delay an order action.
