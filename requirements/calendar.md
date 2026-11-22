# Requirements: calendar

Month, week, day and list views, the stretch bar, print.

Terms: the **Local time zone** is defined in TIM-03; an **event line** is one event's line height, with its padding and margins, defined in the theme; **Itinerary** is a printed list of events grouped by day.

| ID | status | statement | test |
|---|---|---|---|
| CAL-01 | backlog | The calendar shows the user's events in the view the user chooses and lets them move to any date. | — |
| CAL-01.a | done | The calendar displays the events of its source calendars, as far as the Calendar filter (FLT-01) and event visibility (CAP-02) allow. | test/calendar/calendar_test.dart |
| CAL-01.b | done | Month, Week, 5-day (Monday through Friday), Day and List can be selected from the shared dropdown (UIC-12); the chosen view is indicated as selected. Choosing a view closes the menu and shows it at once (UIC-13). Week, 5-day and Day provide an hourly view. | test/calendar/calendar_test.dart |
| CAL-01.c | done | Week view shows its date range and navigates backward and forward by one week. | test/calendar/calendar_test.dart |
| CAL-01.d | done | Selecting a month and year navigates the calendar to that month and year; date selection follows UIC-09. | test/calendar/calendar_test.dart |
| CAL-01.e | backlog | Today returns the main calendar to the current month. | — |
| CAL-01.f | backlog | Before the user has chosen a view, a phone-width window (DEF-01) opens the calendar in List view. | — |
| CAL-01.g | backlog | A day cell shows how many of its visible events do not fit; event visibility follows CAP-02 and the Calendar filter. | — |
| CAL-01.h | done | Week and Day show an hourly grid: every hour of the day in a scrolling area that starts at the first event or at the hour in DEF-01; events are placed by their time, side by side when they overlap, and all-day events sit above. | test/calendar/calendar_test.dart |
| CAL-01.i | done | Today is marked by a filled date and an accent border around its whole day (THM-04.e). | test/calendar/calendar_test.dart |
| CAL-01.j | backlog | On a touch screen a horizontal swipe on the calendar turns the page (left: next, right: previous); a vertical swipe still scrolls. A swipe counts only when it meets the swipe size in DEF-01; a swipe with more than one finger is ignored. | — |
| CAL-02 | backlog | The calendar shows times in the Local time zone (TIM-03), and the user can look at another zone. | — |
| CAL-02.a | backlog | Selecting a time zone in the calendar's own picker shows event times in that zone as a view choice kept on the device (CAL-06.b); the Time Zones setting (SET-02) is not changed. | — |
| CAL-03 | backlog | The user can move an event they may edit by pressing and dragging it. | — |
| CAL-03.a | backlog | A long-press-drag moves an event, for the events that can be edited (CAP-01). | — |
| CAL-03.b | backlog | In Week and Day the start snaps to the drag step in DEF-01. | — |
| CAL-03.c | backlog | In Month the event moves to the day it is dropped on and keeps its time. | — |
| CAL-03.d | backlog | The press must be held for the long-press time set in Settings > Theme (SET-03, DEF-01). | — |
| CAL-04 | backlog | The user can change how tall the calendar is, and Full page gives it the whole window. | — |
| CAL-04.a | backlog | The Full page icon hides every other section and becomes the restore-down icon (two squares) while it is on. Full page always resizes to the available window; that is its definition. | — |
| CAL-04.b | backlog | The calendar uses the shared resize bar (UIC-16). Its height is measured in event lines, not pixels, changes by whole lines, is saved, and has no fixed pixel minimum or maximum. | — |
| CAL-04.c | backlog | Collapse gives the fewest lines the view needs; Expand gives the most lines that fit the visible window. | — |
| CAL-04.d | backlog | The hour height in Week and Day is measured in event lines per hour, changed by whole lines and saved, within the limits in DEF-01, so a line of an event always fits. | — |
| CAL-04.e | backlog | Full page also hides the page footer. | — |
| CAL-04.f | backlog | In Full page a day is at most 2:3 (width:length), weeks of the next and previous month are added until the page is full, and the page fits the window with no scrollbar of its own. | — |
| CAL-05 | backlog | The user can print the calendar through Print Preview (PRT-01). | — |
| CAL-05.a | backlog | Until the user chooses an orientation it is automatic: landscape for Month, Week and 5-day sheets, portrait for Day and Itinerary sheets (PRT-01.c). | — |
| CAL-05.b | backlog | The views that can be printed are the calendar's views (CAL-01.b) and Itinerary, which lists events grouped by day. | — |
| CAL-05.c | backlog | Printing two months produces a sheet for each month. | — |
| CAL-05.d | backlog | Print All uses the empty date range (UIC-23, All), which prints from the first event through the last event. | — |
| CAL-05.e | backlog | Printing one event uses Day view for that print (EVT-06). | — |
| CAL-06 | backlog | The calendar header's right zone holds the view controls in a fixed order, and what the user chooses with them stays on the device until the user changes it. | — |
| CAL-06.a | backlog | The right zone holds, in this order: Time Zone, View, 12/24 clock, Print, Full page, and + last (UIC-24). Zone alignment and stacking follow UIC-14; what each control does is in its own requirement (CAL-02.a, CAL-01.b, TIM-10, CAL-05, CAL-04). | — |
| CAL-06.b | backlog | The state of each right-zone control that holds one (the time zone, the view, the time format, Full page) is a user setting (SET-01). A default is stated in the control's own requirement. | — |
| CAL-06.c | backlog | The view picker shows icons, not words: closed it shows only the current view's icon (Month calendar_month, Week view_week, Day view_day, List view_list); open, each choice shows its icon left of its word. Its tooltip is msg:viewTooltip, where {name} is the current view's name (msg:viewMonth, msg:viewWeek, msg:viewFiveDay, msg:viewDay or msg:viewList), and its accessible name is msg:viewName. The 12h \| 24h control is one hollow clock icon with the current format as a badge, and its tooltip names the mode. Time Zone is a globe whose tooltip names the zone and which opens the zone picker. When the right zone's controls do not fit on one line the right group drops to a second line. | — |
| CAL-01.k | backlog | Until the user chooses a view, the calendar is in Month view (CAL-01.f says what a phone-width window starts with). | — |
| CAL-01.l | backlog | The top left of the calendar header holds, in this order: the previous button, the next button, Today (msg:today) and then the title. | — |
| CAL-01.m | backlog | Previous and next move by one month in Month and List (to the last day of the previous month, or the first day of the next), by one week in Week and by one day in Day. | — |
| CAL-01.n | backlog | The tooltip and accessible name of previous and next name the step of the view: msg:previousMonth and msg:nextMonth (Month, List), msg:previousWeek and msg:nextWeek (Week), msg:previousDay and msg:nextDay (Day). | — |
| CAL-01.o | backlog | The calendar shows only dates in the supported years in DEF-01; a date outside them, or none, puts the calendar on today. | — |
| CAL-01.p | backlog | Selecting a month in the picker puts the calendar on the 1st of that month, or on today when it is the current month. | — |
| CAL-01.q | backlog | The title of Month and List is the month name and year, first letter capitalised, in the page language; the title of Day is the weekday, month, day and year in the page language. | — |
| CAL-01.r | backlog | The month picker's year row has msg:previousYear and msg:nextYear buttons that change the shown year by one with no limit; the shown year starts at the displayed month's year each time the picker opens. | — |
| CAL-01.s | backlog | The month picker shows the page language's twelve abbreviated month names in calendar order, with the displayed year and month marked. | — |
| CAL-04.g | backlog | Stretching enlarges the calendar by dividing the added height equally among the displayed weeks in Month, and enlarges the scrolling hour area in Week and Day. | — |
| CAL-04.h | backlog | Only Month adds weeks in Full page (CAL-04.f). Week and Day limit the hour area to the available height (at least the hour area minimum in DEF-01), and List scrolls inside the available height. | — |
| CAL-04.i | backlog | The available height in Full page is the window's height minus the calendar body's top, the key's height and the margin in DEF-01, and is at least the Full page height minimum in DEF-01. | — |
| CAL-04.j | backlog | The resize bar is not shown in Full page or in List. | — |
| CAL-04.k | backlog | Full page is fitted again when the window is resized (after the delay in DEF-01) and when fonts finish loading. | — |
| CAL-04.l | backlog | In Full page a Month day cell has no minimum height and scrolls its own content. | — |
| CAL-06.d | backlog | The right zone decides again whether its controls fit on one line when the window is resized (after the delay in DEF-01) and when fonts finish loading. | — |
| CAL-06.e | backlog | The 12h \| 24h control sets 12-hour or 24-hour and never returns to the default of TIM-10. | — |
| CAL-07 | backlog | Each view shows its days and cells as the rows below say. | — |
| CAL-07.a | backlog | Month shows whole weeks, Sunday first, from the Sunday on or before the 1st to the Saturday on or after the last day: 4 to 6 weeks. | — |
| CAL-07.b | backlog | Week shows the seven days, Sunday to Saturday, that contain the date. | — |
| CAL-07.c | backlog | List shows one row for each day of the date's month that has events; a month with none shows msg:noEventsThisMonth. | — |
| CAL-07.d | backlog | Weekday headings are the page language's two-letter day names, Sunday first. | — |
| CAL-07.e | backlog | In Month, days outside the displayed month have a muted background and a muted day number. | — |
| CAL-07.f | backlog | A Month day cell shows its day number and a + that opens Add event for that day (msg:addAnEventOn, {day} is the day); the + shows on hover or focus, and dimmed but always on a device without hover. | — |
| CAL-07.g | backlog | Clicking an empty spot of a Month day cell, a Week or Day column or an all-day cell opens Add event for that date (EVT-01.a); the Month cell's tooltip is msg:clickAnEmptySpotTo ({day} is the day). | — |
| CAL-07.h | backlog | A List row shows the day number, the day text and a + as in CAL-07.f; the date sits above its events in a window no wider than the narrow list width in DEF-01, and in a column of the date column width in DEF-01 beside them otherwise. | — |
| CAL-07.i | backlog | In the page the Month grid is at least the Month grid width in DEF-01 and scrolls sideways when the area is narrower; in Full page it fits the window (CAL-04.f). | — |
| CAL-07.j | backlog | In Month, all-day and timed events look alike: each is a one-line colored bar. | — |
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
| CAL-10.c | backlog | The scrolling hour area is at most the hour area height in DEF-01 plus the stretch (CAL-04.g), or the available height in Full page (CAL-04.h). | — |
| CAL-10.d | backlog | An opened event expands to the full column width and its own height, with a shadow, above the others (THM-10.d). | — |
| CAL-11 | backlog | Events that overlap in time in Week and Day are placed side by side in lanes. | — |
| CAL-11.a | backlog | Lanes exist only in Week and Day, are worked out for each day, and a multi-day event has its own segment, and lane, on each day. | — |
| CAL-11.b | backlog | The timed events of one day are ordered by start, and by longer first when the start is the same. | — |
| CAL-11.c | backlog | A cluster is a run of overlapping events; a new cluster starts when an event starts at or after the latest end of the current cluster, so events that touch do not overlap. | — |
| CAL-11.d | backlog | An event takes the first lane, counted from 0, whose last event ends at or before its start, or a new lane. | — |
| CAL-11.e | backlog | Every event of a cluster has the cluster's number of lanes (at least 1); its width is 1 over that number of the column less the lane gap, and its left edge is its lane over that number of the column plus the lane offset (THM-10.e). | — |
