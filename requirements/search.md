# Requirements: search

| ID | status | statement | test |
|---|---|---|---|
| SRH-01 | proposed | Search finds the user's data across the page and shows what it finds as it arrives. | — |
| SRH-01.a | proposed | Search is in the top bar, left of the language control. It finds the words typed in the names, titles and text of events, rules, calendars, feeds, event templates and History, and shows which feature each result belongs to; clicking a result takes the user there. | — |
| SRH-01.b | proposed | Search looks at everything: it ignores the Calendar filter. | — |
| SRH-01.c | proposed | Search finds an event however far ahead it is, with no date limit of its own; recurring events are searched over the expansion period in DEF-01. | — |
| SRH-01.d | proposed | Search shows a result count and the items matching the query; a query with no matches shows "Nothing found". | — |
| SRH-01.e | proposed | Event results can be narrowed by calendar and by a date range (UIC-23). | — |
| SRH-01.f | proposed | Search keeps the typed query while its results update (UIC-13). | — |
| SRH-01.g | proposed | Closing search returns to what was showing before. | — |
| SRH-02 | proposed | Results are grouped by feature, and the user can ask for more. | — |
| SRH-02.a | proposed | Results are grouped by feature, calendar events first. Each feature shows its first results, the number in DEF-01; the user can ask for more in steps of the same size. The size is set in SET-02. | — |
| SRH-02.b | proposed | Results show as they populate: the list fills in while the user types and as each feature answers, calendar events first (SRH-02), without waiting for all features to finish (UIC-13). | — |
| SRH-03 | proposed | An event matches a query by its words, over a range of dates. | — |
| SRH-03.a | proposed | The query is split on whitespace into words, compared without regard to case; an event matches when every word is in its title, location or notes. | — |
| SRH-03.b | proposed | The query is trimmed and cut to the length in DEF-01; an empty query is no search. | — |
| SRH-03.c | proposed | An event that spans several days is listed once, on its first day inside the range. | — |
| SRH-03.d | proposed | An event that ends before the range or starts after it is not listed. | — |
| SRH-03.e | proposed | An event in the results opens its details as in the calendar (EVT-07), and open details stay open when the results update. | — |
| SRH-01.h | proposed | Opening search puts the cursor in its box. | — |
| SRH-01.i | proposed | A search is not run again when its query and choices are the same as the last one's. | — |
