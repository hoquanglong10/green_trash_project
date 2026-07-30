# Customer Address Book

## Scope

- List the signed-in customer's saved pickup addresses.
- Add and edit address detail, ward, district and city.
- Optionally capture the current GPS coordinate and resolve it to an editable
  address suggestion.
- Keep exactly one default address whenever at least one address exists.
- Delete an address and promote another address when the default is removed.

## V3 composition

- Use a white `AppPage` header and neutral gray canvas.
- The list uses the responsive 900px shell; the form uses the 760px flow shell.
- Address rows are white bordered surfaces with no elevation.
- The default address uses a compact success chip and a quiet green border.
- Add/save is the primary green600 action. Delete requires confirmation.
- Web uses a native scrollbar; mobile does not show one.

## Data

The live implementation reads and writes `DIA_CHI`. The document ID equals
`diaChiId`, and `khachHangId` must equal the signed-in Firebase Auth UID.
The first address is automatically saved as `macDinh = true`.

## Map picker

- The address form embeds an interactive OpenStreetMap picker with pan, pinch
  zoom, mouse-wheel zoom, explicit zoom controls and current-location action.
- Tapping the map, selecting a search result, entering `lat, lng`, or using the
  current location updates the same marker and reverse-geocodes that point.
- Manual text uses a debounced Photon search dropdown. Results are limited to
  Vietnam, biased around the current map center and capped at five.
- Nominatim remains reverse-only; never use its public endpoint for
  autocomplete.
- Native builds use HTTPS. Web uses Nominatim's documented JSONP callback
  because the public endpoint does not expose a browser CORS response header.
- Available road, ward, district and city values are filled into the form.
  Missing road, ward and city values preserve the user's existing input.
  An unresolved district is cleared to avoid retaining a wrong map suggestion.
- Address detail prefers `house number + street`; when Nominatim omits those
  separate fields, use the first human-readable segment of its address label.
- District is optional because current two-tier local administration can place
  a ward directly under a province-level city. Never infer district from a
  `city` value; leave it empty when Nominatim does not return a reliable
  `Quận`, `Huyện` or `Thị xã`.
- The suggestion is never saved automatically; the customer must review and
  submit the editable form.
- Saving requires a confirmed non-zero map coordinate. Editing the search text
  invalidates the current confirmation until the customer selects a suggestion
  or taps the map again.
- If reverse lookup fails, coordinates remain available and the address can be
  entered manually.
- The form displays OpenStreetMap attribution. Photon public-demo traffic must
  remain low-volume and may be replaced with a private/API-key provider later.
