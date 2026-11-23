# Requirements: print

Printing what the user sees. Print is its own feature, used by every section of the page; the feature being printed says what can be printed and supplies the details (which views, which orientation each gets).

| ID | status | statement | test |
|---|---|---|---|
| PRT-01 | backlog | Printing anything opens Print Preview, where the user chooses what to print, its theme and its orientation; the printed result shows what the user sees. | — |
| PRT-01.a | planned | The print follows what the user sees: the Local or temporary time zone, the time format (TIM-10), the language and the active filter (UIC-21). | test/calendar/calendar_print_test.dart |
| PRT-01.b | backlog | The user's print choices (what to print, theme, orientation) are user settings (SET-01), and Print Preview opens with them; before any are saved, it starts with what is on screen. | — |
| PRT-01.c | backlog | The orientation is one segmented choice in Print Preview: Auto, Landscape or Portrait. Auto is chosen from what is printed; the feature being printed says which orientation each kind of content gets (CAL-05.a). | — |
| PRT-01.d | backlog | Each print sheet fits one page of the paper: Letter for English, A4 otherwise. A day or page that would not fit gets smaller type, and whole titles wrap. | — |
| PRT-01.i | backlog | The paper's margins are 5 mm. | — |
| PRT-01.e | backlog | Printed titles wrap to show the complete title. | — |
| PRT-01.f | backlog | Print Preview and the printed result honor the theme selected for printing. | — |
| PRT-01.g | backlog | Print Preview opens as a dialog (UIC-01 to UIC-03), and a date range in it, where the content has one, is the shared control (UIC-23). | — |
| PRT-01.h | backlog | Every section of the page can be printed; each section says what is printed and its orientation (PRT-01.c). The print layout of All Rules, Event Templates and History is still to be designed. | — |
| PRT-02 | backlog | The calendar prints pages of days, weeks and months from a date range, as the rows below say. | — |
| PRT-02.a | backlog | Week prints one page for each week, Sunday to Saturday, from the week that contains From until a week starts after To, up to the page limit in DEF-01. | — |
| PRT-02.b | backlog | 5-day prints the same weeks as Week, Monday to Friday, up to the page limit in DEF-01. | — |
| PRT-02.c | backlog | Day prints one page for each day from From through To, up to the page limit in DEF-01. | — |
| PRT-02.d | backlog | Print Preview has an Include weekends choice (msg:includeWeekends), on until changed; turned off, Week, Month and Itinerary leave out Saturday and Sunday, and Day and 5-day print as before. | — |
| PRT-02.e | backlog | Week, 5-day, Day and Itinerary pages show each event's location after " · " and, when there is more than one calendar, the calendar's name after " · "; Month pages show neither. | — |
| PRT-02.f | backlog | A Week or Month page's title is the calendar's title for that week or month; a Day page's title is the day's title (CAL-01.q). | — |
| PRT-02.g | backlog | A Day page with no events shows msg:noEvents. | — |
| PRT-02.h | backlog | A printed Month shades the days outside its month. | — |
| PRT-02.i | backlog | From starts as the 1st of the current month and To as the last day of From's month, in the displayed zone. | — |
| PRT-02.j | backlog | The range reaches at most the number of days in DEF-01 after From. | — |
| PRT-02.k | backlog | Print type scales with the sheet so the preview and the paper look alike; the heading is the heading size in DEF-01 times the base size. | — |
| PRT-02.l | backlog | The printed background matches the background shown in the chosen print theme in Print Preview. | — |
| PRT-02.m | backlog | Printed events display their resolved event colors (EVT-03.i), and hidden events are struck through (THM-10.c). | — |
