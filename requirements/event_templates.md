# Requirements: Event templates

| ID | status | statement | test |
|---|---|---|---|
| TPL-01 | backlog | An event template is a reusable event that the user saves once and uses for new events and for rules. | — |
| TPL-01.a | backlog | A template stores a title, a duration, a color, a location and notes, and a saved template keeps its color and location exactly (its duration is normalized by TPL-01.c). | — |
| TPL-01.b | backlog | A duration is accepted as hours and minutes in the forms 1:30, 2, 1.5, 90m and 1h15; a duration that is not a time is not valid (UIC-19). | — |
| TPL-01.c | backlog | Saving normalizes a template: an invalid ID is ignored, runs of spaces in the title collapse, a duration under the shortest in DEF-01 is raised to it. | — |
| TPL-02 | backlog | Templates are listed in their own section and offered when the user adds an event. | — |
| TPL-02.a | backlog | Settings > Event Templates is a section (UIC-05) listing the templates. | — |
| TPL-02.b | backlog | Choosing a template in the new-event editor fills the title, location and end time. | — |
| TPL-02.c | backlog | A calendar's saved events do not offer a template picker (only new events do). | — |
| TPL-01.d | backlog | A duration is also accepted as h:m, 1h, a decimal with a comma (1,5) and 90min, with at most the hour digits in DEF-01; an empty duration means the default in DEF-01. | — |
| TPL-01.e | backlog | A duration that is not a time is not valid (UIC-19) and shows msg:templateCheckLength ({title} the template's title); an all-day template keeps the default length in DEF-01. | — |
| TPL-01.f | backlog | When stored templates are read back, the title, location and notes are cut to their lengths in DEF-01, a length outside its range becomes the default, and a color that is not a palette color (THM-09) is dropped. | — |
| TPL-01.g | backlog | A template keeps notes; the page does not offer to edit them. | — |
| TPL-02.d | backlog | The Event Templates header has the + of UIC-24, the counts msg:templateAllDayCount and msg:templateTimedCount ({n}), msg:templateCountOne or msg:templateCount ({n}), and when empty msg:noTemplatesYet. | — |
| TPL-02.e | backlog | A template row has a Title field (placeholder msg:templateTitlePlaceholder), a choice of msg:timed or msg:allDay, a Length, a Location, a color or msg:templateCalendarColor, a delete button and a + that adds a row. | — |
| TPL-02.f | backlog | The + opens a dialog titled msg:addEventTemplate whose defaults are Timed, the default length in DEF-01 and no color; saving without a title is not valid (UIC-19) and shows msg:templateGiveTitle. | — |
| TPL-02.g | backlog | At most the number of templates in DEF-01 are kept; one more is not valid (UIC-19) and shows msg:templatesLimit ({n} the limit); rows with an empty title are dropped when saved. | — |
| TPL-02.h | backlog | Removing a template makes the rules that use it stop adding events and leaves the rules; History records the save as msg:templatesSaved ({n} the number of templates). | — |
