# UI Guardrails

## Absolute restrictions
Do not introduce these unless explicitly approved by the user:

- new brand color palette
- old `#22AA86`, `#9CC026`, `#44514E`, or `#F2F4F4` brand palette values
- blue/purple/orange primary actions
- new typography scale
- large display typography on regular app screens
- pill-shaped auth inputs/buttons
- heavy shadows
- glassmorphism
- neumorphism
- bright gradients
- decorative illustrations
- unrelated ecommerce dashboard style
- unrelated admin panel style

## No style drift
Style drift means the UI starts looking different from the reference app.

Examples of style drift:

- replacing the green header with a white Material default header
- using the old Jungle Green/Bahia/Corduroy/Azure palette instead of the current Home palette
- using large hero cards on login/signup
- using 24px+ titles on compact auth screens
- making buttons pill-shaped when reference buttons are 8-10px radius
- using thick card shadows
- using inconsistent spacing per screen
- creating duplicate one-off card/input/button styles inside screens

Style drift is not allowed.

## Missing design information
If a design detail is missing:

1. Use the closest existing token.
2. Use the closest reference screen.
3. State the assumption in the summary.
4. Do not silently invent a new style.

## Riverpod/state safety
UI work must not alter:

- provider ownership
- repository logic
- mock data semantics
- Firestore schema contracts
- order status lifecycle
- booking/staff/admin business rules

Unless the user explicitly requests that change.
