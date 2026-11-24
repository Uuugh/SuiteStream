# Verifications for the Executive

One verification per heading, for one PBI that is In Review.

1. An agent writes the verification when the PBI reaches In Review.
2. The Executive checks it, writes the result under "Result:" and sets the status to accepted or returned.
3. Before making any change, an agent reads this file. For each accepted or returned item it acts on the PBI as "Acting on the result" says, then deletes the item.

Write new verifications oldest first. A verification's number is the lowest number not used by an open one. Deleting an item renumbers nothing.

When the Executive types "verifications", list every open one in the format below.

## Acting on the result

- accepted: the PBI moves to `scrum/product_backlog_done.csv` (status Done); the requirement rows it met are set to `done`.
- returned: the PBI goes back to Backlog with the Executive's result added to its acceptance criteria; the requirement rows stay as they are.

## Format

- Every PBI In Review has exactly one open verification, and the PBI's acceptance field ends with "waits for verification <number> (`scrum/verifications.md`)".
- Each item names its PBI, what to check (light and dark, hard refresh, for the board) and where.

```
## <number>. <PBI id> <short title>
Status: open
Verify: ...
Result:
```

## 1. PBI-108 Features column backlog choice
Status: open
Verify: On the board, choose backlog for a requirement that belongs to a story, in the Features column. It should leave its story, as the Backlog block does (SCB-07.f).
Result:

## 2. PBI-107 A change in the first seconds
Status: open
Verify: Reload the page, then change a file the board reads within 2 seconds. The change shows on the board (SCB-22).
Result:

## 3. PBI-109 Block widths
Status: open
Verify: The Backlog and sprint blocks look the right width at the DEF-01 window sizes, in light and dark, with no clipping (SCB-06.g).
Result:

## 4. PBI-106 Real usage.sh on Windows
Status: open
Verify: Run the server on Windows with the real `scrum/usage/usage.sh`; the usage estimate and trend routes answer (SCB-14.o). The board shows no usage yet; this checks the server and API only.
Result:

## 5. PBI-119 Definition of Done line
Status: open
Verify: Read `scrum/definition_of_done.md` line 21. It says each added or changed option, route or setting is in its doc file, checked on Windows and web.
Result:

## 6. PBI-120 Daily scrum record
Status: open
Verify: Read `.github/skills/one-day-in-scrum/SKILL.md` line 50. It says each developer writes the test command and the pass count.
Result:

## 7. PBI-122 Stale audit sentence
Status: open
Verify: `.github/skills/sprint-retrospective/SKILL.md` line 65 and `.github/agents/reviewer.kobayashi.agent.md` line 24 no longer say the first audit is owed.
Result:

## 8. PBI-092 Shared filter bar
Status: open
Verify: On the board, in light and dark after a hard refresh, the Features & Requirements column and the Backlog block show the same filter bar (feature, requirement and status filters and the shown-of count), and filtering in each hides the same kind of items (SCB-04).
Result:

## 9. PBI-011 Calendar event drag
Status: open
Verify: In the calendar in the browser (hard refresh), drag an event to another time and day in Week and Day; it moves and keeps its length (CAL-03.a to CAL-03.d).
Result:

## 10. PBI-013 Event dialog
Status: open
Verify: In the calendar, click an event: its details open; add, edit and remove one of your own events in the dialog (EVT-01 to EVT-03, EVT-07). Partly built: report what is missing.
Result:

## 11. PBI-014 Local event store
Status: open
Verify: In the calendar, add an event with a time zone and restart the app: it is still there at the same time (TIM-01). Remove a custom event and undo: it comes back (CAP-02).
Result:

## 12. PBI-018 End time zone label
Status: open
Verify: Open the event dialog in a narrow and a wide window, light and dark: the different-end-time-zone label shows in full or as the short label, never clipped, and the paired time fields line up (EVT-01.j).
Result:

## 13. PBI-037 Settings in the database
Status: open
Verify: Change a setting in one browser, open the app in another: the setting is the same (DEF-01). Partly built and needs PBI-063: report what is missing.
Result:

## 14. PBI-046 Popup transitions
Status: open
Verify: In the calendar, light and dark, open and close dialogs, dropdowns, the color picker and the hour-density menu: each animates in and out; with animation time 0 none does (SET-03.g, UIC-43).
Result:

## 15. PBI-047 Kobayashi reviews and audit
Status: open
Verify: Read `.github/agents/reviewer.kobayashi.agent.md` and the sprint-planning and sprint-retrospective skills: Kobayashi reviews each plan, runs the retrospective audit and the audit every fifth retrospective.
Result:

## 16. PBI-048 Stricter static analysis
Status: open
Verify: Read the root `analysis_options.yaml`: strict-casts, strict-inference, strict-raw-types and the listed lints are on; `flutter analyze lib test` at the root reports no issues.
Result:

## 17. PBI-050 Settings auto-save and back button
Status: open
Verify: In Settings, change the animation time, then choose another page or press the back button at the upper left; reopen Settings: the value is kept (UIC-45).
Result:

## 18. PBI-051 Theme settings layout
Status: open
Verify: Open Settings > Theme, light and dark, in a wide and a narrow window: two columns wide, one narrow, groups under titled rules, press-and-hold here and not in General (SET-03.b, SET-09).
Result:

## 19. PBI-052 Event text on pale colors
Status: open
Verify: In light mode, look at events in pale colors (for example yellow) in every view: the text is readable (THM-10.h).
Result:

## 20. PBI-053 Reset look and header fit
Status: open
Verify: In Settings > Theme, light and dark, the Reset button looks like the delete controls; the header fits in a narrow window (UIC-14).
Result:

## 21. PBI-054 Multi-day labels and event color
Status: open
Verify: In Month and Week, a multi-day event shows its start with a dash on the first day and its end on the last (CAL-09.c); the event color shows in every view and print, light and dark (EVT-03.b).
Result:

## 22. PBI-057 Settings layout fixes
Status: open
Verify: Open Settings in a narrow and a wide window, light and dark: no resize bar; General, Theme and Admin at the bottom of the left menu below a rule. Reset placement is checked in verification 33 (PBI-072).
Result:

## 23. PBI-058 Press-and-hold and status word
Status: open
Verify: After a page load, the first press-and-hold reacts at the set delay, not after about 1 second; after Cancel or Save the status word shows for 1 second, set in Settings > Theme (SET-03.m).
Result:

## 24. PBI-059 Events in color in Week
Status: open
Verify: Light and dark, events fill with their chosen color with readable text in Week, 5-day, Day, List and Month (EVT-03.b, THM-10.h).
Result:

## 25. PBI-060 Drag an event's bottom edge
Status: open
Verify: In Week, 5-day and Day, drag an event's bottom edge with mouse and touch: the end time changes live and snaps; release saves; Escape cancels; the start stays (CAL-12, CAL-12.a).
Result:

## 26. PBI-061 Title bar without a tint
Status: open
Verify: Light and dark, hard refresh: the title bar behind the SuiteStream name and the Settings icon has no tinted background (SHL-01.h).
Result:

## 27. PBI-062 Multi-day label in the shown zone
Status: open
Verify: Change the display zone so an event crosses midnight, then so it no longer does: the dash appears and goes away (CAL-09.c).
Result:

## 28. PBI-063 Docker stack
Status: open
Verify: Start the stack from the installer and compose files: app, Postgres, Authentik and Watchtower run and sign-in works (DEP-01 to DEP-06). The stack files were never run: report what fails.
Result:

## 29. PBI-068 Reset asks Are you sure
Status: open
Verify: In Settings > Theme, light and dark, press Reset: it turns into "Are you sure?" with Yes and No in the same font and color; No, Escape and a click elsewhere go back; Yes resets (UIC-48).
Result:

## 30. PBI-069 Event text black or white
Status: open
Verify: Light and dark, event text is pure black or pure white on every event color in all views, details and print (THM-10.h).
Result:

## 31. PBI-070 No Resize bar setting
Status: open
Verify: Settings > Theme has no Resize bar size row; the event bottom-edge handle still works.
Result:

## 32. PBI-071 Server database retry
Status: open
Verify: Start the SuiteStream server (`server/bin/server.dart`) with the database stopped: it retries every 5 seconds for up to 60 seconds (DEF-01, DEP-01.e).
Result:

## 33. PBI-072 Reset replaces Close
Status: open
Verify: Settings has no Close button; on the Theme page Reset sits where Close was and its confirm opens in the same place with nothing jumping, in a narrow and a wide window; Escape still leaves Settings (UIC-45, UIC-48).
Result:

## 34. PBI-077 ScrumBoard project and server
Status: open
Verify: Start the ScrumBoard server with the command in `scrum/scrumboard/README.md` and open the page with a hard refresh: it loads on 127.0.0.1 port 8081 (SCB-13, SCB-13.a).
Result:

## 35. PBI-078 Board layout and error messages
Status: open
Verify: On the board, light and dark, hard refresh, at the DEF-01 window sizes: three rows, each column scrolls on its own; stop the server: the unreachable message shows (SCB-15.a, SCB-15.b, SCB-13.h).
Result:

## 36. PBI-079 Backlog block and timeline
Status: open
Verify: On the board, light and dark, hard refresh: the Backlog block stays at the left while the timeline scrolls sideways and opens at its right end; blocks are the same width (SCB-06.a, SCB-06.e, SCB-06.g).
Result:

## 37. PBI-080 Features column filters and outline
Status: open
Verify: On the board, light and dark, hard refresh: the column opens collapsed; Expand all opens it; the feature, requirement and status filters and the shown-of count work (SCB-03, SCB-04, SCB-11).
Result:

## 38. PBI-081 Drag and drop and status writes
Status: open
Verify: On the board, light and dark, hard refresh: drag a requirement onto a story (it turns planned), then back to the Backlog block (backlog); a refused drop shows the refusal banner (SCB-07, SCB-13.c, SCB-13.d).
Result:

## 39. PBI-090 Features & Requirements heading
Status: open
Verify: On the board, light and dark, hard refresh: the left column heading reads "Features & Requirements" (SCB-03.c).
Result:

## 40. PBI-097 Header icons and status token menu
Status: open
Verify: On the board, light and dark, hard refresh: the header right zone holds zoom - and +, theme, bin and +, with no footer; a status token click offers proposed, backlog, up to 3 stories and retired (SCB-15.d, SCB-19).
Result:

## 41. PBI-098 Board keeps in sync
Status: open
Verify: Open the board with a hard refresh, then edit a requirement file outside the page: the board updates within about 2 seconds with no button (SCB-22).
Result:

## 42. PBI-099 No Reload button
Status: open
Verify: On the board, light and dark, hard refresh: there is no Reload button anywhere (SCB-01.c).
Result:

## 43. PBI-101 Less padding
Status: open
Verify: On the board, light and dark, hard refresh: padding in the board, columns and blocks looks right and nothing clips at the DEF-01 window sizes (SCB-15.c).
Result:

## 44. PBI-105 Usage log and script
Status: open
Verify: Run `scrum/usage/usage.sh` with a reading: it appends to `scrum/usage/usage.log` and prints the estimate; `scrum/usage.md` is only a pointer.
Result:
