# Sprint 006 reference screenshots (Product Owner, 2026-11-23)

- `add_event_target.png`: target layout for the Add/Edit event dialog (PBI-033).
- `sources_feeds_target.png`: how the Sources and Feeds sections look, for the module screens that come after Settings (PBI-024 and the Sources/Feeds/Rules features). Section headers (Sources, Feeds) do not collapse: that requirement was retired (R41). Each module (a connection) keeps its own Close / Expand to Configure fold. Modules use the shared Cancel | Save pair, status/action buttons (Healthy, Sync Now, Fix), and On | Off toggles.

## Product Owner note: resize bar (2026-11-23)

The shared resize bar (UIC-16, `lib/src/ui/resize_bar.dart`) is kept as an unused component. A much later feature will add notes, tasks and email to the main screen (not yet defined); that is what will bring the resize bar back. The calendar's own resize bar rows (CAL-04.b/c/g/j) stay retired.
