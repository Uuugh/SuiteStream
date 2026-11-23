# Requirements: theme

How the app looks: colors, fonts, icons, corners and sizes, in a light and a dark palette. Every component uses this theme by default; a row elsewhere states a look only to depart from it. Components, and what they do, are in `common.md`. Values are written here once and no other file repeats them. Converted from the old theme notes (moved with the old app; the legacy file is no longer used).

| ID | status | statement | test |
|---|---|---|---|
| THM-01 | backlog | All text uses one font family; text that is typed or copied exactly uses a monospace family; sizes and weights follow the text styles below. | — |
| THM-01.a | done | IBM Plex Sans is the font for everything. | test/theme/theme_test.dart |
| THM-01.b | done | IBM Plex Mono is used only for what is typed or copied exactly: links, IDs, the Username, the client ID and the stream name. | test/theme/theme_test.dart |
| THM-01.c | done | The module kind is 17 px at weight 700 (15 px in a phone-width window, DEF-01). | test/theme/theme_test.dart |
| THM-01.d | done | Default text is 14 px; labels are weight 600; notes are 13 px in the muted color. | test/theme/theme_test.dart |
| THM-02 | backlog | Every color is a named token with a light value and a dark value. The light palette is the Soft palette. The event colors a user picks are the palette of THM-09, not tokens. | — |
| THM-02.a | done | bg is the page: light #f7f6f3, dark #0f1218. | test/theme/theme_test.dart |
| THM-02.b | done | card is sections, modules and pop-ups, and the words on a button filled with a status color: light #fdfcfa, dark #171b23. | test/theme/theme_test.dart |
| THM-02.c | done | soft is quiet fills (instruction tiles, hover): light #f1efeb, dark #1d222c. | test/theme/theme_test.dart |
| THM-02.d | done | line is every border and divider: light #e8e4de, dark #2a303b. | test/theme/theme_test.dart |
| THM-02.e | done | text is the text color: light #2b2f36, dark #e6e8ec. muted is labels, notes and status lines: light #626c7c, dark #98a2b3. | test/theme/theme_test.dart |
| THM-02.f | done | Muted text reaches a contrast of 4.5:1 against card, bg and soft in both palettes. | test/theme/theme_test.dart |
| THM-02.g | done | accent is for pressable buttons only: light #40609c, dark #93b4ff; the text on it (onaccent) is light #ffffff, dark #0f1218. | test/theme/theme_test.dart |
| THM-02.h | done | ok (green: done, OK) is light #2f7d62 on #eef5f0, dark #4ade80 on #0f2a20 (the second color is okbg, its background). | test/theme/theme_test.dart |
| THM-02.i | done | run (pressed: in action, or waiting on you) is light #40609c on #eef1f7, dark #93b4ff on #14203d (runbg). | test/theme/theme_test.dart |
| THM-02.j | done | warn (amber: a problem outside SuiteStream) is light #946a24 on #faf3e6, dark #fbbf24 on #2b2110 (warnbg). | test/theme/theme_test.dart |
| THM-02.k | done | bad (red: SuiteStream itself failed) is light #b4483c on #faeeeb, dark #f87171 on #2d1414 (badbg). | test/theme/theme_test.dart |
| THM-02.l | done | Each section has its own border color, shown as 35% of the color mixed with line, on card: Calendar slate blue #5b6f9a, Calendars teal #2a9d8f, Feeds clear blue #2f86c8, All Rules lavender #9b8ad6, Event Templates copper #b8733a, History grey #8a8f98. | test/theme/theme_test.dart |
| THM-02.m | done | The title's two words use the logo colors: Calendar is navy #0b1f44 in light and #e6e8ec in dark; Stream is #1a8cff in light and #4aa8ff in dark. | test/theme/theme_test.dart |
| THM-03 | backlog | Icons are one family in one style, and take their color from the part they sit in (the text color in text, THM-05.a in an icon button). | — |
| THM-03.a | backlog | The icon family is Material Symbols Rounded at weight 400. | — |
| THM-03.b | backlog | Icons are 13 to 24 px. Adding an icon does not change an existing one. | — |
| THM-04 | backlog | Corners are rounded rectangles, never pills, and components have the sizes below; every border is 1 px. | — |
| THM-04.a | backlog | Controls have 8 px corners. Sections, modules, pop-ups and menus have 12 px corners. Small marks (a color, today, a switch) have 4 to 6 px corners. | — |
| THM-04.b | backlog | Module headers are 50 px high; controls (fields and buttons) are 34 px high. | — |
| THM-04.c | backlog | Status/Action buttons are 132 × 50 px. Cancel/Save buttons are 130 × 34 px. | — |
| THM-04.d | backlog | Icon buttons are 34 × 34 px in the general toolbar and 28 × 28 px in the compact calendar toolbar; the calendar header's previous and next buttons are 34 × 34 px. | — |
| THM-04.e | backlog | Today's day in the calendar and the focus outline are marks of 2 px, not borders. | — |
| THM-04.f | backlog | A trash icon's lines are tinted red (30% of bad in muted, at least 3:1 contrast), the button itself unchanged; fully red on hover. | — |
| THM-01.e | backlog | A field label is 12 px, in the muted color, over a 34 px field. | — |
| THM-05 | backlog | Buttons share one look, and a status has one look per meaning. | — |
| THM-05.a | backlog | An icon button's icon is the muted color, with soft behind it on hover. | — |
| THM-05.b | backlog | A pressable button that shows no status, other than a Cancel \| Save pair (UIC-27), uses the accent look: accent fill and onaccent words. Accent is never used for a status. | — |
| THM-05.c | backlog | A disabled Cancel \| Save pair cannot be activated. A first change triggers the pulse in THM-06.c. | — |
| THM-05.d | backlog | Done or OK is green: ok words on okbg; a done button fills ok. | — |
| THM-05.e | backlog | In action, or waiting on the user, is pressed: run words on runbg; a working button is card with run words. | — |
| THM-05.f | backlog | A problem outside SuiteStream (United, Google, GitHub, the internet), or an entry that was refused, is amber: warn words on warnbg; a failed button fills warn. | — |
| THM-05.g | backlog | SuiteStream itself failing is red: bad words on badbg; a failed button fills bad. | — |
| THM-06 | backlog | Every change of state moves as the rows below say. When reduced motion is requested nothing slides, grows, fades, spins or pulses: each state replaces the last, with the same words and hold times. | — |
| THM-06.a | backlog | A pop-up opens with a fade and a scale from 0.96 to 1 in 0.2 s ease-out; its backdrop (black at 55%, the page blurred 2 px) fades in. | — |
| THM-06.b | backlog | The color box and the emoji list open at once, with no motion. | — |
| THM-06.c | backlog | The pressed side of a Cancel \| Save pair grows over the pair and fades its words in 0.3 s ease; Cancel takes 1 s, in and back. Save pulses once a second, five times, in 1 s ease-out. | — |
| THM-06.d | backlog | A good status word shrinks to its ✓ in 0.5 s ease. A ✓ saved in place fades in in 0.45 s ease (messages 0.3 s). | — |
| THM-06.e | backlog | The triangles of Expand and Close turn in 0.15 s; Close points up. | — |
| THM-06.f | backlog | A Status/Action button grows from the bottom 22 px to the whole box in 0.25 s ease while its chip fades out in 0.2 s; its working words fade in in 0.25 s ease-out beside an icon that turns once a second, linear. | — |
| THM-06.g | backlog | A done, failed or found result fills the button with its status color and a ring pulses out from 0 to 9 px, twice, in 1.1 s ease-out each. | — |
| THM-06.h | backlog | After its hold the button shrinks to the bottom in 0.25 s ease; then the new status word fades in, 0.2 s after a 0.25 s delay, never through the old word. | — |
| THM-06.i | backlog | The words of the top-bar Update now fade in in 0.25 s ease-out; the bar under them slides in 1.2 s ease-in-out, repeating. | — |
| THM-07 | backlog | Spacing between content parts uses one set of values. Internal control geometry, calendar cells and anchored header layouts use the component sizes (THM-04), not these. | — |
| THM-07.a | backlog | There are 5 px between parts: sections, modules, the parts of a module or a dialog, and buttons in a row. | — |
| THM-07.b | backlog | There is 1 px between a label and its field (the label over it); From and To beside their dates have 5 px. | — |
| THM-07.c | backlog | Inside a module's border there are 9 px at the sides and 5 px at the top and bottom, the 50 px header unchanged; a box inside a module (Include, an instruction tile) is 5 px by 9 px. The bottom padding is the same folded and open: 5 px in a module, 18 px in a module-like section. | — |
| THM-07.d | backlog | Inside every dialog there are 12 px, and the panels of anchored menus have 12 px padding and corners. | — |
| THM-07.e | backlog | A folded section keeps 14 px below it for the Expand line in its border. A module's Close line has 2 px less above and below it. | — |
| THM-07.f | backlog | The calendar key starts 5 px below the calendar. The header's date and navigation gaps are 8 px, tool gaps 5 px, and the wrapped second row has a 6 px gap. | — |
| THM-08 | backlog | A module's border is its calendar's or feed's color at 45%, its header a 6% tint and the rest a 3% tint of it, in light and dark. Each section has its own border color (THM-02.l) on card. | — |
| THM-08.a | backlog | In a phone-width window a dialog's corners are square and edge to edge (UIC-01). | — |
| THM-08.b | backlog | The grip of a handle is two columns of three faint dots, centered on the module's 50 px header or on the rule line. | — |
| THM-08.c | backlog | The (?) icon is 15 px, raised after the word it explains. | — |
| THM-09 | planned | The event color palette (UIC-10) is Google Calendar's eleven colors. | — |
| THM-09.a | planned | Tomato #d50000, Flamingo #e67c73, Tangerine #f4511e, Banana #f6bf26, Sage #33b679, Basil #0b8043, Peacock #039be5, Blueberry #3f51b5, Lavender #7986cb, Grape #8e24aa, Graphite #616161. | test/events/event_logic_test.dart |
| THM-09.b | planned | The default event color is #1d4ed8. | test/events/event_logic_test.dart |
| THM-10 | backlog | An event on the calendar has the look below. | — |
| THM-10.a | backlog | An event's bar is its color mixed with the card color at 18% in the dark palette and 12% in the light palette; its text is its color mixed with the text color at 70% in dark and 60% in light. | — |
| THM-10.b | backlog | The custom look of an event added here or by a rule is, in dark, #2e1a47 with text #e9d5ff and, in light, #f4eef8 with text #5e3f7a. | — |
| THM-10.c | backlog | A hidden event's line is struck through at 55% opacity on the calendar and 60% in print; a deleted event is 85% grayscale at 45% opacity. | — |
| THM-10.d | backlog | Event text in the hourly grid is 11.5 px, and an opened event has a shadow. | — |
| THM-10.e | backlog | An event in a lane is narrower than its share of the column by 3 px (the lane gap) and starts 1 px right of its lane's edge (the lane offset). | — |
| THM-10.f | backlog | A List row's date column is 150 px wide. | — |
