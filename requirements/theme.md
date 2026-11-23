# Requirements: theme

How the app looks: colors, fonts, icons, corners and sizes, in a light and a dark palette. Every component uses this theme by default; a row elsewhere states a look only to depart from it. Components, and what they do, are in `common.md`. Values are written here once and no other file repeats them. Converted from the old theme notes (moved with the old app; the legacy file is no longer used).

| ID | status | statement | test |
|---|---|---|---|
| THM-01 | backlog | All text uses one font family; text that is typed or copied exactly uses a monospace family; sizes and weights follow the text styles below. | — |
| THM-01.a | done | IBM Plex Sans is the font for everything. | test/theme/theme_test.dart |
| THM-01.b | done | IBM Plex Mono is used only for what is typed or copied exactly: links, IDs, the Username, the client ID and the stream name. | test/theme/theme_test.dart |
| THM-01.c | done | The module kind is 17 px at weight 700 (15 px in a phone-width window, DEF-01). | test/theme/theme_test.dart |
| THM-01.d | done | Default text is 14 px, labels are weight 600, and notes are 13 px. | test/theme/theme_test.dart |
| THM-02 | planned | Light and dark app colors follow Flutter Material 3 theming with `ColorScheme.fromSeed` and seed `#93B4FF`. App-owned colors follow component defaults and semantic roles from the active theme. This applies to the app's own chrome and components and does not define event or calendar colors (THM-09 does). | test/theme/theme_test.dart |
| THM-02.a | done | Muted text reaches a contrast of 4.5:1 against the card, background and soft surfaces in both light and dark. | test/theme/theme_test.dart |
| THM-03 | backlog | Icons use one family and style. | — |
| THM-03.a | backlog | The icon family is Material Symbols Rounded at weight 400. | — |
| THM-03.b | backlog | Icons are 13 to 24 px. Adding an icon does not change an existing one. | — |
| THM-04 | backlog | Corners are rounded rectangles, never pills, and components have the sizes below; every border is 1 px. | — |
| THM-04.a | backlog | Controls have 8 px corners. Sections, modules, pop-ups and menus have 12 px corners. Small marks (a color, today, a switch) have 4 to 6 px corners. | — |
| THM-04.b | planned | Controls (fields and buttons) are 34 px high: one height for every single-line text box and dropdown on the site, set once as the control height token. | test/ui/control_height_test.dart, test/events/event_dialog_test.dart |
| THM-04.f | backlog | Module headers are 50 px high. | — |
| THM-04.c | backlog | Status/Action buttons are 132 × 50 px. Cancel/Save buttons are 130 × 34 px. | — |
| THM-04.d | backlog | Icon buttons are 34 × 34 px in the general toolbar and 28 × 28 px in the compact calendar toolbar; the calendar header's previous and next buttons are 34 × 34 px. | — |
| THM-04.e | backlog | Today's day in the calendar and the focus outline are marks of 2 px, not borders. | — |
| THM-01.e | planned | A field label is 12 px and sits over a 34 px field. | test/ui/control_height_test.dart, test/events/event_dialog_test.dart |
| THM-05 | backlog | Buttons share one look, and a status has one look per meaning. | — |
| THM-05.a | backlog | Icon buttons show their hover state. | — |
| THM-05.c | backlog | A disabled Cancel \| Save pair cannot be activated. A first change triggers the pulse in THM-06.c. | — |
| THM-06 | backlog | Every change of state moves as the rows below say. When reduced motion is requested nothing slides, grows, fades, spins or pulses: each state replaces the last, with the same words and hold times. | — |
| THM-06.a | backlog | A pop-up opens with a fade and a scale from 0.96 to 1 in 0.2 s ease-out. Its backdrop fades in and the page blurs by 2 px. | — |
| THM-06.b | backlog | The color box and the emoji list open at once, with no motion. | — |
| THM-06.c | backlog | One animation time (DEF-01, SET-03.g; zero when reduced motion is requested) sets every Cancel \| Save animation: the pressed side slides over the whole pair, then pulses gently while its word is held; Save pulses while idle; hover fades in. | test/ui/cancel_save_pair_test.dart |
| THM-06.d | backlog | A good status word shrinks to its ✓ in 0.5 s ease. A ✓ saved in place fades in in 0.45 s ease (messages 0.3 s). | — |
| THM-06.e | backlog | The triangles of Expand and Close turn in 0.15 s; Close points up. | — |
| THM-06.f | backlog | A Status/Action button grows from the bottom 22 px to the whole box in 0.25 s ease while its chip fades out in 0.2 s; its working words fade in in 0.25 s ease-out beside an icon that turns once a second, linear. | — |
| THM-06.g | backlog | A done, failed or found result shows a state and a ring pulses out from 0 to 9 px, twice, in 1.1 s ease-out each. | — |
| THM-06.h | backlog | After its hold the button shrinks to the bottom in 0.25 s ease; then the new status word fades in, 0.2 s after a 0.25 s delay, never through the old word. | — |
| THM-06.i | backlog | The words of the top-bar Update now fade in in 0.25 s ease-out; the bar under them slides in 1.2 s ease-in-out, repeating. | — |
| THM-07 | backlog | Spacing between content parts uses one set of values. Internal control geometry, calendar cells and anchored header layouts use the component sizes (THM-04), not these. | — |
| THM-07.a | backlog | There are 5 px between parts: sections, modules, the parts of a module or a dialog, and buttons in a row. | — |
| THM-07.b | backlog | There is 1 px between a label and its field (the label over it); From and To beside their dates have 5 px. | — |
| THM-07.e | backlog | A module's Close line has 2 px less above and below it. | — |
| THM-08 | backlog | Sections, modules and dialogs follow the shared component appearance. | — |
| THM-08.a | backlog | In a phone-width window a dialog's corners are square and edge to edge (UIC-01). | — |
| THM-08.b | backlog | The grip of a handle is two columns of three faint dots, centered on the module's 50 px header or on the rule line. | — |
| THM-08.c | backlog | The (?) icon is 15 px, raised after the word it explains. | — |
| THM-09 | planned | The event color palette (UIC-10) is Google Calendar's eleven colors. | test/events/event_logic_test.dart, test/events/event_dialog_test.dart |
| THM-09.a | planned | Tomato #d50000, Flamingo #e67c73, Tangerine #f4511e, Banana #f6bf26, Sage #33b679, Basil #0b8043, Peacock #039be5, Blueberry #3f51b5, Lavender #7986cb, Grape #8e24aa, Graphite #616161. | test/events/event_logic_test.dart, test/events/event_dialog_test.dart |
| THM-09.b | planned | The default event color is #1d4ed8. | test/events/event_logic_test.dart, test/events/event_dialog_test.dart |
| THM-10 | backlog | An event on the calendar has the look below. | — |
| THM-10.c | backlog | A hidden or deleted event is shown muted and struck through, on the calendar and in print. | — |
| THM-10.d | planned | An opened event has a shadow, like every popup (UIC-43). Built in Week and Day (the opened event and the hour-density menu scale with the Popup shadow setting); other views are not covered, and CAL-10.d (opening an event) is still backlog. | test/events/week_event_style_test.dart ("CAL-10.d, THM-10.d", "SET-03.e"); test/ui/popup_shadow_test.dart covers the other popups |
| THM-10.g | backlog | Event text in the hourly grid is 11.5 px. | — |
| THM-10.h | planned | Event text reaches a contrast of 4.5:1 against its own chip or bar in light and dark, whatever the event color (a pale color such as yellow gets dark text in light mode); the same rule covers every view and print. | test/events/event_text_contrast_test.dart (palette contrast over 11 event and 24 calendar colors, both brightnesses) |
| THM-10.e | backlog | An event in a lane is narrower than its share of the column by 3 px (the lane gap) and starts 1 px right of its lane's edge (the lane offset). | — |
| THM-10.f | backlog | A List row's date column is 150 px wide. | — |
