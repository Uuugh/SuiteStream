# Requirements: calendar_filter

| ID | status | statement | test |
|---|---|---|---|
| FLT-01 | backlog | The Calendar filter chooses which calendars and event states the calendar shows, and what is printed. | — |
| FLT-01.a | done | The Calendar filter is one filter icon with a dropdown (UIC-12). It lists every calendar with its color and the event states (Edited, Changed by the source since the edit, Hidden from Google, Deleted); choosing items shows only those events. It changes only what the calendar shows: nothing changes in Sources, Feeds, Rules or the other sections. | test/calendar/filter_test.dart |
| FLT-01.b | done | The Calendar filter follows the common filter rules (UIC-21). | test/calendar/filter_test.dart |
| FLT-01.d | backlog | The filter applies in every calendar view and Print follows it: what the user chooses to see is what is printed. | — |
| FLT-01.e | done | A calendar's name and color in the filter follow its source: renaming it or changing its color shows at once (UIC-13). | test/calendar/filter_test.dart |
| FLT-01.i | done | The calendar header shows the title and controls only. The filter lists calendars and event states only, with no Timed, All-day or Added color labels. | test/calendar/filter_test.dart |
| FLT-01.k | done | Hiding Hidden from Google hides the events that are hidden from Google and not deleted. | test/calendar/filter_test.dart |
| FLT-01.l | done | Hiding Changed by the source since the edit hides the events the source changed since an edit and that are not deleted. | test/calendar/filter_test.dart |
| FLT-01.m | done | Hiding Edited hides the edited events whose source has not changed since and that are not deleted. | test/calendar/filter_test.dart |
