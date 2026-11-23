# Requirements: calendar

Month, week, day and list views, the stretch bar. Printing is its own feature (print.md, PRT-03).

Terms: the **Local time zone** is defined in TIM-03; an **event line** is one event's line height, with its padding and margins, defined in the theme.

| ID | status | statement | test |
|---|---|---|---|
| CAL-01 | backlog | The calendar shows the user's events in the view the user chooses and lets them move to any date. | — |
| CAL-01.a | done | The calendar displays the events of its source calendars, as far as the Calendar filter (FLT-01) and event visibility (CAP-02) allow. | test/calendar/calendar_test.dart |
| CAL-01.b | done | Month, Week, 5-day (Monday through Friday), Day and List can be selected from the shared dropdown (UIC-12); the chosen view is indicated as selected. Choosing a view closes the menu and shows it at once (UIC-13). Week, 5-day and Day provide an hourly view. | test/calendar/calendar_test.dart |
| CAL-01.c | done | Week view shows its date range and navigates backward and forward by one week. | test/calendar/calendar_test.dart |
| CAL-01.d | done | Selecting a month and year navigates the calendar to that month and year; date selection follows UIC-09. | test/calendar/calendar_test.dart |
| CAL-01.e | done | Today returns the main calendar to the current month. | test/calendar/views_test.dart |
| CAL-01.f | done | Before the user has chosen a view, a phone-width window (DEF-01) opens the calendar in List view. | test/calendar/views_test.dart |
| CAL-01.g | done | A day cell shows how many of its visible events do not fit; event visibility follows CAP-02 and the Calendar filter. | test/calendar/views_test.dart |
| CAL-01.h | done | Week and Day show an hourly grid: every hour of the day in a scrolling area that starts at the first event or at the hour in DEF-01; events are placed by their time, side by side when they overlap, and all-day events sit above. | test/calendar/calendar_test.dart |
| CAL-01.i | done | Today is marked by a filled date and a border around its whole day (THM-04.e). | test/calendar/calendar_test.dart |
| CAL-01.j | done | On a touch screen a horizontal swipe on the calendar turns the page (left: next, right: previous); a vertical swipe still scrolls. A swipe counts only when it meets the swipe size in DEF-01; a swipe with more than one finger is ignored. | test/calendar/views_test.dart |
| CAL-02 | planned | The calendar shows times in the Local time zone (TIM-03), and the user can look at another zone. | test/calendar/header_test.dart, test/calendar/calendar_test.dart |
| CAL-02.a | planned | Selecting a time zone in the calendar's own picker shows event times in that zone as a view choice kept on the device (CAL-06.b); the Time Zones setting (SET-02) is not changed. | test/calendar/header_test.dart |
| CAL-03 | backlog | The user can move an event they may edit by pressing and dragging it. | — |
| CAL-03.a | planned | A long-press-drag moves an event, for the events that can be edited (CAP-01); while it is dragged the event follows the pointer, the original is dimmed and the day (and in Week and Day the time) it would land on is shown. | test/calendar/drag_test.dart |
| CAL-03.b | planned | In Week and Day the start snaps to the drag step in DEF-01. | test/calendar/drag_test.dart |
| CAL-03.c | planned | In Month the event moves to the day it is dropped on and keeps its time. | test/calendar/drag_test.dart |
| CAL-03.d | planned | The press must be held for the long-press time set in Settings > Theme (SET-03, DEF-01). | test/calendar/drag_test.dart |
| CAL-04 | backlog | The user can change how tall the calendar is. | — |
| CAL-04.d | backlog | The hour height in Week and Day is measured in event lines per hour, changed by whole lines and saved, within the limits in DEF-01, so a line of an event always fits. | — |
| CAL-06 | backlog | The calendar header's right zone holds the view controls in a fixed order, and what the user chooses with them stays on the device until the user changes it. | — |
| CAL-06.a | backlog | The header has a left, a center and a right zone (UIC-14): the previous and next buttons, Today and the title are in the left zone (CAL-01.l) and the buttons are in the right zone, flush right. The right zone holds, in this order: Time Zone, View, 12/24 clock, Print (PRT-05.a), and + last (UIC-24). Zone alignment and stacking follow UIC-14; what each control does is in its own requirement (CAL-02.a, CAL-01.b, TIM-10, PRT-03, CAL-04). | — |
| CAL-06.b | planned | The state of each right-zone control that holds one (the time zone, the view, the time format) is a user setting (SET-01). A default is stated in the control's own requirement. | test/calendar/header_test.dart |
| CAL-06.c | backlog | The view picker shows icons, not words: closed it shows only the current view's icon (Month calendar_month, Week view_week, Day view_day, List view_list); open, each choice shows its icon left of its word. Its tooltip is msg:viewTooltip, where {name} is the current view's name (msg:viewMonth, msg:viewWeek, msg:viewFiveDay, msg:viewDay or msg:viewList), and its accessible name is msg:viewName. The 12h \| 24h control is one hollow clock icon with the current format as a badge, and its tooltip names the mode. Time Zone is a globe whose tooltip names the zone and which opens the zone picker. When the right zone's controls do not fit on one line, UIC-14.b applies. | — |
| CAL-01.k | done | Until the user chooses a view, the calendar is in Month view (CAL-01.f says what a phone-width window starts with). | test/calendar/views_test.dart |
| CAL-01.l | done | The top left of the calendar header holds, in this order: the previous button, the next button, Today (msg:today) and then the title. | test/calendar/views_test.dart |
| CAL-01.m | done | Previous and next move by one month in Month and List (to the last day of the previous month, or the first day of the next), by one week in Week and by one day in Day. | test/calendar/views_test.dart |
| CAL-01.n | done | The tooltip and accessible name of previous and next name the step of the view: msg:previousMonth and msg:nextMonth (Month, List), msg:previousWeek and msg:nextWeek (Week), msg:previousDay and msg:nextDay (Day). | test/calendar/views_test.dart |
| CAL-01.o | done | The calendar shows only dates in the supported years in DEF-01; a date outside them, or none, puts the calendar on today. | test/calendar/views_test.dart |
| CAL-01.p | planned | Selecting a month in the date picker (CAL-01.s) goes back down to the days of that month, and selecting a year in the year list goes back to the month list; picking a day goes to that date and closes the picker (CAL-01.t). | test/calendar/calendar_test.dart |
| CAL-01.q | done | The title of Month and List is the month name and year, first letter capitalised, in the page language; the title of Day is the weekday, month, day and year in the page language. | test/calendar/views_test.dart |
| CAL-01.r | done | The month picker's year row has msg:previousYear and msg:nextYear buttons that change the shown year by one with no limit; the shown year starts at the displayed month's year each time the picker opens. | test/calendar/views_test.dart |
| CAL-01.s | done | The month picker shows the page language's twelve abbreviated month names in calendar order, with the displayed year and month marked. | test/calendar/views_test.dart |
| CAL-01.t | done | The date picker (UIC-09) opens on the displayed month as a small month calendar with its days; picking a day goes to that date and closes it, in every view, and Today in the picker goes to today. Its title opens the month list (CAL-01.s) and the year there opens the year list. | test/calendar/views_test.dart |
| CAL-06.d | backlog | Whether the right zone's controls fit on one line, and when that is decided again, is the standard in UIC-14.a. | — |
| CAL-06.e | planned | The 12h \| 24h control sets 12-hour or 24-hour and never returns to the default of TIM-10. The badge shows 12 filled; for 24 it is inverted (outlined, accent text). | test/calendar/header_test.dart |
| CAL-07 | backlog | Each view shows its days and cells as the rows below say. | — |
| CAL-07.a | backlog | Month shows whole weeks, Sunday first, from the Sunday on or before the 1st to the Saturday on or after the last day: 4 to 6 weeks. | — |
| CAL-07.b | backlog | Week shows the seven days, Sunday to Saturday, that contain the date. | — |
| CAL-07.c | backlog | List shows one row for each day of the date's month that has events; a month with none shows msg:noEventsThisMonth. | — |
| CAL-07.d | backlog | Weekday headings are the page language's two-letter day names, Sunday first. | — |
| CAL-07.e | backlog | In Month, the displayed month is visually distinct from the adjacent month's days. | — |
| CAL-07.g | backlog | Clicking an empty spot of a Month day cell, a Week or Day column or an all-day cell opens Add event for that date (EVT-01.a); the Month cell's tooltip is msg:clickAnEmptySpotTo ({day} is the day). | — |
| CAL-07.h | backlog | A List row shows the day number and the day text; the date sits above its events in a window no wider than the narrow list width in DEF-01, and in a column of the date column width in DEF-01 beside them otherwise. | — |
| CAL-07.i | backlog | In the page the Month grid is at least the Month grid width in DEF-01 and scrolls sideways when the area is narrower. | — |
| CAL-07.j | backlog | In Month, all-day and timed events both use a one-line bar. | — |
| CAL-08 | backlog | An event is shown on the days it covers, in order. | — |
| CAL-08.a | backlog | An event is shown on every day it covers in the displayed zone (CAL-02), from its first day to its last. | — |
| CAL-08.b | backlog | A timed event's last day is the day of its end; an end exactly at midnight does not include the new day, and an end at or before the start leaves the event on its start day only. | — |
| CAL-08.c | backlog | An all-day event covers its start date up to the day before its end date, and at least its first day. | — |
| CAL-08.d | backlog | Within a day, events are in the order of their start. | — |
| CAL-09 | backlog | Each event line shows a time label, the title and marks. | — |
| CAL-09.a | backlog | An event line wraps in the hourly grid, in List and in all-day cells, and is cut with an ellipsis in Month. | — |
| CAL-09.b | backlog | The tooltip of an event line is msg:eventLineTooltip, where {title} is the title and {state} is where the event was deleted (EVT-07.c) or msg:hiddenFromGoogle; an event that is neither deleted nor hidden has the title alone. | — |
| CAL-09.c | backlog | A timed event within one day is labelled "start–end"; across days the first day is labelled "start →", the last "→ end" and the days between msg:cont. | — |
| CAL-09.d | backlog | A single-day all-day event has no label; a multi-day all-day event has none on its first day and msg:cont on each following day. | — |
| CAL-09.e | backlog | After the title come marks: a warning when the source changed an edited event (msg:unitedChangedThisSinceYour for United's schedule, msg:feedChangedThisSinceYourEdit for another source); else an edit icon (msg:editedHere); else, for an event added by a rule, an icon with msg:addedByRule. A deleted event shows none of these. | — |
| CAL-09.f | backlog | An event with reminders shows a reminder icon (msg:hasReminders) after the other marks. | — |
| CAL-10 | backlog | The hourly grid places each timed event by its minutes. | — |
| CAL-10.a | backlog | Hour labels run from midnight to 11 pm in the time format (TIM-10): 12am to 11pm, or 00:00 to 23:00; the midnight label is hidden. | — |
| CAL-10.b | backlog | A timed event starts at its minutes from the start of the day and is as tall as its duration, at least the shortest drawn event in DEF-01; an event that continues past midnight is cut at 24:00 and continues from 00:00 on the next day. | — |
| CAL-10.c | backlog | The scrolling hour area is at most the hour area height in DEF-01. | — |
| CAL-10.d | backlog | An opened event expands to the full column width and its own height, above the others; like every popup it opens with a shadow (UIC-43, THM-10.d). | — |
| CAL-11 | backlog | Events that overlap in time in Week and Day are placed side by side in lanes. | — |
| CAL-11.a | backlog | Lanes exist only in Week and Day, are worked out for each day, and a multi-day event has its own segment, and lane, on each day. | — |
| CAL-11.b | backlog | The timed events of one day are ordered by start, and by longer first when the start is the same. | — |
| CAL-11.c | backlog | A cluster is a run of overlapping events; a new cluster starts when an event starts at or after the latest end of the current cluster, so events that touch do not overlap. | — |
| CAL-11.d | backlog | An event takes the first lane, counted from 0, whose last event ends at or before its start, or a new lane. | — |
| CAL-11.e | backlog | Every event of a cluster has the cluster's number of lanes (at least 1); its width is 1 over that number of the column less the lane gap, and its left edge is its lane over that number of the column plus the lane offset (THM-10.e). | — |
