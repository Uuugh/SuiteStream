# Requirements: rules

All Rules lives in Settings (SET-01.b).
The app's Rules: the rule model and engine, the rule dialog, All Rules, link rules.

| ID | status | statement | test |
|---|---|---|---|
| RUL-01 | backlog | A rule has conditions that decide which events it matches. | — |
| RUL-01.a | backlog | A text condition matches by equality (trimmed), contains, whole word, prefix, suffix or regex; whole word `RDO` does not match `RDOS`. Case is ignored. | — |
| RUL-01.b | backlog | `*` and `#` wildcards are supported: `*E####` matches `Trip E1234` and `e9999` but not `E12345`. | — |
| RUL-01.c | backlog | The wildcard ? matches exactly one character in a text pattern (RUL-01). | — |
| RUL-01.d | backlog | A condition on "Any text" matches title, location or notes. | — |
| RUL-01.e | backlog | Conditions combine with AND/OR in order with optional brackets: `A OR B AND C` differs from `(A OR B) AND C`. | — |
| RUL-01.f | backlog | Day conditions cover selected days, a Fri-Mon range, after and before a day. Conditions on days and times are judged in the event's own time zone: a rule has no time zone of its own. | — |
| RUL-01.g | backlog | A time range may be overnight (22:00-06:00 matches 23:00, not daytime). | — |
| RUL-01.h | backlog | Date conditions: a range (reversed order is accepted) and "after date". | — |
| RUL-01.i | backlog | Length conditions distinguish no end time, a normal event, a near whole-day event and an exact duration. | — |
| RUL-02 | backlog | A regular expression in a condition is checked as the user types and cannot slow the app down. | — |
| RUL-02.a | backlog | A typed regex is checked for legality as it is typed or saved; when it is not legal, the site says why and highlights the broken part of the pattern. Regexes use Dart (ECMAScript) syntax; Python-only syntax is not supported. | — |
| RUL-02.b | backlog | A regex that takes too long is stopped within the pattern budget in DEF-01 and reported as Too slow; the regex tester reports an invalid pattern, shows the match spans and highlights the match. | — |
| RUL-02.c | backlog | A pattern that exceeds its evaluation budget (DEF-01) matches no further events during that evaluation run (RUL-02). | — |
| RUL-03 | backlog | A rule has actions that change the events it matches. | — |
| RUL-03.a | backlog | Actions: Color, Emoji, Change title, Change notes, Add text, Change length, Change time, Delete, Move, Add event, Record changes, link rules (delete/move). | — |
| RUL-03.b | backlog | Each action asks for what it needs: minutes for Change length, a title or an event template for Add event, a color for Color (UIC-10). | — |
| RUL-03.c | backlog | Color: the higher rule wins; a lower rule still adds its emoji; a second pass does not duplicate it; several emoji actions prefix the title in order. | — |
| RUL-03.d | backlog | Change title replaces the title; Add appends (a new line for notes, a space for location). | — |
| RUL-03.e | backlog | Delete hides the event with a rule-labelled marker; non-matching events stay. | — |
| RUL-03.f | backlog | Move shifts start and end together, forward or back by a number of minutes. | — |
| RUL-03.g | backlog | Change length makes a near whole-day event all-day (keeping an original-time note) or shortens a normal one. | — |
| RUL-03.h | backlog | An Emoji action lets the user find and choose any emoji by searching (UIC-11). | — |
| RUL-03.i | backlog | A newly added Emoji action starts without a chosen emoji; selection follows UIC-11. | — |
| RUL-03.j | backlog | Then actions are reordered as UIC-30 says; the saved action order determines their priority and emoji sequence (RUL-03). | — |
| RUL-04 | backlog | A rule can create events, follow events and record changes. | — |
| RUL-04.a | backlog | Add event creates a rule-origin event relative to the matching event (e.g. a Prep event 08:00-08:45, an hour before), from an existing event template. | — |
| RUL-04.b | backlog | An Add-event action can place a template-derived event before or after the matching event’s start or after its end (RUL-04). | — |
| RUL-04.c | backlog | Changing an event template updates the events generated from it by rules (RUL-04). | — |
| RUL-04.d | backlog | An Add-event rule that names an event template that does not exist, and has no title, is not valid (UIC-19). | — |
| RUL-04.e | backlog | Record changes remembers later edits to a matching event and annotates it ("Changed ... time"). | — |
| RUL-04.f | backlog | Record changes tracks source title, time and location changes, moved recurring occurrences and dropped events, annotates the affected event and records the observed changes in activity (RUL-04, HIS-01). | — |
| RUL-04.g | backlog | An event deleted by a rule follows that rule’s current outcome: changing or removing the deleting action brings the event back (RUL-03, CAP-02). | — |
| RUL-04.h | backlog | A new Then action, "Link to Event", links the rule to a specific event chosen with the existing date picker, alongside "Delete this event" and "Move this event". | — |
| RUL-04.i | backlog | "Link to" in the rule dialog is simplified to "Link to a Rule": it keeps its place in the dialog but uses the layout of the Sources > Rules subsection. | — |
| RUL-05 | backlog | A rule applies to all calendars or to chosen ones, and rules have an order. | — |
| RUL-05.a | backlog | A rule applies to all calendars or to chosen ones; unapplying removes it from that calendar and keeps it in All Rules. | — |
| RUL-05.b | backlog | A rule scoped to All calendars applies to calendars added later as well as current calendars (RUL-05). | — |
| RUL-05.c | backlog | Editing a rule preserves its calendar applicability until the user changes that applicability (RUL-05). | — |
| RUL-05.d | backlog | A new calendar-specific rule is first in that calendar's list; an all-calendar rule goes last; renaming a calendar keeps its rules. | — |
| RUL-05.e | backlog | Rules are reordered as UIC-30 says, and the order is stored and shown. | — |
| RUL-05.f | backlog | A rule whose calendar was removed still shows the saved name; a rule with no calendar says so. | — |
| RUL-05.g | backlog | When adding a rule, the user can reuse an existing rule from another calendar when such a rule is available (RUL-05, RUL-06). | — |
| RUL-05.h | backlog | A source color change updates the source’s color in rule applicability badges (RUL-05, UIC-13, UIC-15). | — |
| RUL-05.i | backlog | A rule shows which calendars it applies to: All, one calendar, or several (with the count). | — |
| RUL-06 | backlog | The user creates, shows, clones and deletes rules. | — |
| RUL-06.a | backlog | A rule can be cloned; the clone is unapplied and placed right after the original. | — |
| RUL-06.b | backlog | Deleting a rule removes it from every list; default rules (RUL-06) cannot be deleted. | — |
| RUL-06.c | backlog | A calendar starts with two predefined rules (items without an end time, 24-hour events), kept in All Rules like any rule. Default rules are permanent: they can be unassigned from a calendar and assigned again, but never deleted. Adding CCS+ again re-assigns its starters. The 24-hour rule aligns a whole-day event to the local day: an event spanning about 24 hours becomes all-day, local midnight to the next local midnight in the event's time zone, so daylight-saving days stay correct. | — |
| RUL-06.d | backlog | The rule dialog opens from "New rule…" in a calendar (that calendar preselected) or from All Rules (All preselected); dialog behavior follows UIC-02. | — |
| RUL-06.e | backlog | A rule shows its title (if any), what it does, and its color by name. | — |
| RUL-06.f | backlog | Saving a rule without a title generates a title from its conditions and actions (RUL-06). | — |
| RUL-06.g | backlog | How rules work is explained from the rule dialog. | — |
| RUL-06.h | backlog | A rule with no actions is not valid (UIC-19). | — |
| RUL-06.i | backlog | A malformed regex, an unmatched bracket, an incomplete date range or an empty Add is not valid (UIC-19). | — |
| RUL-06.j | backlog | A rule has at most the number of conditions and of actions in DEF-01; one more is not valid (UIC-19) and the message names the limit; a rule at the limit saves. | — |
| RUL-06.k | backlog | A rule line says what the rule does, titled or not (for example "Items without an end time → Change length to 1:00"); its color reads "Color ■ (Name)". | — |
| RUL-07 | backlog | Rules that conflict or repeat each other are reported, and the user chooses what to do. | — |
| RUL-07.a | backlog | All Rules reports a higher rule that shadows a lower one's color, and duplicate rules, with the choices Put first, Keep as is, Drop and Merge. | — |
| RUL-07.b | backlog | Merging rules unions their calendars (All if any is All). | — |
| RUL-07.c | backlog | Saving a condition identical to an existing rule offers Save as new or Merge; the stored count does not change until chosen. | — |
| RUL-07.d | backlog | Dropping a conflicting action removes the selected field-specific action, preserving actions for other fields (RUL-07). | — |
| RUL-07.e | backlog | Conflict reporting identifies a higher rule that shadows a lower rule’s Emoji or Time action (RUL-07). | — |
| RUL-07.f | backlog | Choosing Keep as is suppresses that same conflict warning on subsequent observations (RUL-07). The conflicts remembered are limited as DEF-01 says, the oldest forgotten first. | — |
| RUL-01.j | backlog | A rule with no condition matches every event; its label is msg:everyEvent. | — |
| RUL-01.k | backlog | A condition that is incomplete (a date or time range with an end missing, a day condition with no day, a text condition with no value in a rule that has other conditions) is not valid (UIC-19): saving shows msg:fillInEveryConditionOr and stores nothing. | — |
| RUL-01.l | backlog | A rule whose only condition is a text condition with no value drops it when saved, so the rule matches every event (RUL-01.j). | — |
| RUL-01.m | backlog | A stored condition of a kind the app does not know is dropped when rules are read back. | — |
| RUL-01.n | backlog | A stored condition whose operator is not allowed for its kind gets the first operator of that kind when rules are read back. | — |
| RUL-01.o | backlog | A stored condition that is incomplete (RUL-01.k) is dropped when rules are read back. | — |
| RUL-01.p | backlog | The text operators are, in this order: msg:opIs, msg:opContains, msg:opWholeWord, msg:opBeginsWith, msg:opEndsWith, msg:opMatchesPattern, msg:opContainsRegex. | — |
| RUL-01.q | backlog | A new text condition starts with the operator msg:opContains. | — |
| RUL-01.r | backlog | msg:opBeginsWith and msg:opEndsWith ignore white space at the start or end of the text they are compared with. | — |
| RUL-01.s | backlog | msg:opIs, msg:opContains, msg:opWholeWord, msg:opBeginsWith and msg:opEndsWith take the typed value literally, so wildcard and regex characters in it are ordinary characters; wildcards belong to msg:opMatchesPattern (RUL-01.b, RUL-01.c) and regular expressions to msg:opContainsRegex (RUL-02). | — |
| RUL-01.t | backlog | A text value is trimmed, must not be empty, and is cut to the text value length in DEF-01 (the shorter pattern and regex length for msg:opMatchesPattern and msg:opContainsRegex). | — |
| RUL-01.u | backlog | In a pattern, `*` and `?` also match line breaks, so a pattern on msg:fieldAnyText can match across the title, the location and the notes. | — |
| RUL-01.v | backlog | A Date condition offers msg:opIs, msg:opAfter, msg:opBefore and msg:opBetween on a calendar date; after and before leave out the date typed, between includes both its dates. | — |
| RUL-01.w | backlog | A Time condition offers msg:opIs, msg:opAfter, msg:opBefore and msg:opBetween on a time of day; after and before leave out the time typed, between includes both its times. | — |
| RUL-01.x | backlog | A time of day in a condition is kept with two digits for the hour (9:05 is kept as 09:05). | — |
| RUL-01.y | backlog | A Day condition with msg:opIs holds any number of days, kept once each in week order from Monday to Sunday. | — |
| RUL-01.z | backlog | A Day condition with msg:opAfter or msg:opBefore holds exactly one day and compares inside the Monday-to-Sunday week without wrapping; with msg:opBetween it holds exactly two days. | — |
| RUL-08 | backlog | A Length condition matches events by how long they last. | — |
| RUL-08.a | backlog | The Length operators are msg:opIs and msg:opIsWholeDays; whole days needs no length typed. | — |
| RUL-08.b | backlog | A length is typed in four boxes, weeks, days, hours and minutes, and is their sum; it is none or more, up to the longest length in DEF-01. | — |
| RUL-08.c | backlog | msg:opIs with a length at or above the threshold in DEF-01 matches events whose length is within the tolerance in DEF-01 of it, both ends included. | — |
| RUL-08.d | backlog | msg:opIs with a shorter length matches only events of exactly that length. | — |
| RUL-08.e | backlog | msg:opIs with length none matches only timed events whose end is their start. | — |
| RUL-08.f | backlog | A length condition reads msg:lengthIsValue, where {value} is the weeks and days (with msg:unitWeekShort and msg:unitDayShort) followed by hours:minutes, such as 1 w 2 d 3:30; length none reads msg:noEndTime and whole days reads msg:lengthIsWholeDays. | — |
| RUL-09 | backlog | A Day condition is entered by clicking days in a row of the seven weekdays. | — |
| RUL-09.a | backlog | With msg:opIs a click selects one day, Ctrl or Cmd with a click adds or removes a day, and Shift with a click selects the run of days between the last click and this one. | — |
| RUL-09.b | backlog | With msg:opAfter, msg:opBefore and msg:opBetween a click selects one day; with msg:opBetween a Shift click selects the second end. | — |
| RUL-09.c | backlog | Changing a Day condition's operator keeps the first chosen day for after and before and the first two chosen days for between. | — |
| RUL-10 | backlog | The dialog joins conditions with and or or and groups them with brackets (RUL-01.e). | — |
| RUL-10.a | backlog | A condition has at most the number of opening and of closing brackets in DEF-01, and groups nest. | — |
| RUL-10.b | backlog | A stored rule whose brackets do not balance is read back with every bracket of its conditions removed; its conditions stay. | — |
| RUL-10.c | backlog | Every condition after the first shows a join button that switches between msg:joinAnd and msg:joinOr, drawn as & and \|. | — |
| RUL-10.d | backlog | Every condition has an x that removes it; the x is hidden while only one condition is left. | — |
| RUL-10.e | backlog | Removing the first condition sets the next condition's join to msg:joinAnd; the join of the first condition is not used. | — |
| RUL-10.f | backlog | Typing a closing bracket that has no opening bracket before it adds an opening bracket on the first line of its group, which flashes for the time in DEF-01. | — |
| RUL-11 | backlog | A text condition has a test box that shows which sample titles it matches (RUL-02.b). | — |
| RUL-11.a | backlog | The samples start as the next different event titles from today on across all calendars, then earlier ones newest first (the count in DEF-01); hidden events and events made by a rule are left out; the user can edit the samples. | — |
| RUL-11.b | backlog | The test box holds at most the number of samples in DEF-01, cuts a sample and the typed value to their lengths in DEF-01, and shows no results while the value is empty or the pattern is not valid. | — |
| RUL-11.c | backlog | Each sample shows a check when it matches and a cross when it does not, with the summary msg:matchCount ({n} matching samples, {total} samples). | — |
| RUL-11.d | backlog | Apply is disabled while a pattern or regex condition shows an error (UIC-19). | — |
| RUL-11.e | backlog | An empty pattern value shows the placeholder msg:patternPlaceholder and offers insert buttons msg:insAnyText for `*`, msg:insDigit for `#` and msg:insOneChar for `?`. | — |
| RUL-11.f | backlog | An empty regex value offers insert buttons msg:insStarts (`^`), msg:insEnds (`$`), msg:insWord (`\b…\b`), msg:insEither (`(A\|B)`), msg:insAny (`.*`), msg:insDigits (`\d+`), msg:insSpace (`\s`), msg:insOptional (`?`) and msg:insLiteral (`a\.b`). | — |
| RUL-11.g | backlog | The start and end insert buttons put their character at the start or at the end of the value, once; the other insert buttons put theirs at the cursor and wrap the selected text for word, either and literal; literal escapes the characters that have a meaning in a regex. | — |
| RUL-12 | backlog | A rule is shown in words: its conditions, then what it does. | — |
| RUL-12.a | backlog | A condition reads field, operator and value, such as msg:title msg:opContains “RDO” with the mark Aa added when case matters; a range reads a – b; msg:fieldDays lists days separated by commas, and a day range reads first day – last day. | — |
| RUL-12.b | backlog | A rule reads its conditions joined by msg:joinAnd or msg:joinOr, with its brackets, then → and its actions; with no condition it starts with msg:everyEvent. | — |
| RUL-12.c | backlog | An action reads msg:actChangeToAllDay, msg:actChangeLength ({value} as h:mm), msg:actChangeField ({field} is the field's name, {value} the new text), msg:actAddToField ({text} with line breaks shown as ⏎, {field}), msg:actEmojiInFront ({emoji}), msg:actColorNamed ({name} the color's display name), msg:actDeleteEvent or msg:actCreateEvent ({title}, {offset} as h:mm, {placement} one of msg:placeBeforeStart, msg:placeAfterStart, msg:placeAfterEnd). | — |
| RUL-12.d | backlog | A link rule reads msg:linkedTo, →, then msg:actDeleteEvent and msg:actMoveWithLinked separated by semicolons. | — |
| RUL-13 | backlog | Each kind of action has its own entry rules and effect. | — |
| RUL-13.a | backlog | A color is kept as lower-case #rrggbb; a stored color that is not one of the palette colors (THM-09) is shown as the palette color with the smallest squared difference in red, green and blue (UIC-20). | — |
| RUL-13.b | backlog | A new Color action starts as Tomato (THM-09.a). | — |
| RUL-13.c | backlog | A + after the last action adds an Emoji action; every action has an x that removes it, hidden while only one action is left. | — |
| RUL-13.d | backlog | An action that is not valid when rules are read back is dropped; the rule stays while one action remains. | — |
| RUL-13.e | backlog | An Emoji action's text is at most the emoji length in DEF-01, with white space collapsed and without the characters < > & and double quotes; empty text drops the action. | — |
| RUL-13.f | backlog | Only the highest rule that matches and has Emoji actions supplies the emoji: they are joined by spaces and put before the title followed by one space, and nothing is added when the title already starts with that text. | — |
| RUL-13.g | backlog | A Change length action sets the length to the number of minutes entered, between the least and the most in DEF-01 (default in DEF-01); it applies to timed events, an event with no end time stops having none, and an all-day event is left as it is. | — |
| RUL-13.h | backlog | An event that becomes all-day gets a first line in its notes, msg:allDayNoteStart ({time}) when it had no end time and otherwise msg:allDayNoteOriginal ({range} is its start and end with weekday, month, day and 24-hour time); the notes are cut to the length in DEF-01. | — |
| RUL-13.i | backlog | Of the rules that match, the first one with a time change supplies it, and only that rule's first time action counts. | — |
| RUL-13.j | backlog | A Change Title or Change Notes action needs a new text that is not empty and is cut to its length in DEF-01; a title collapses white space, notes keep their line breaks and are trimmed. | — |
| RUL-13.k | backlog | A Change of text is not applied to an event the user edited; an Add still is. | — |
| RUL-13.l | backlog | After all rules, notes and location are cut to their lengths in DEF-01. | — |
| RUL-13.m | backlog | An Add action targets Title, Notes or Location (Title is the default); empty text drops the action; its text is cut to the length in DEF-01 for that field. | — |
| RUL-13.n | backlog | Every Add for a field of the highest matching rule that has one applies, in order, also to an event the user edited. | — |
| RUL-13.o | backlog | A Move action is a number of minutes within the range in DEF-01, not zero, typed as +h:mm or -h:mm with the placeholder msg:movePlaceholder and the tooltip msg:moveByTooltip. | — |
| RUL-13.p | backlog | Move is applied after the time changes, from the first matching rule that has one. | — |
| RUL-13.q | backlog | A Delete action is not applied to an event that is already hidden or deleted. | — |
| RUL-14 | backlog | When several rules match an event, each effect has one winner and the effects are applied in a fixed order. | — |
| RUL-14.a | backlog | For each kind of effect (color, emoji, time change, move, delete, each text Change) the highest rule in the list that matches and has that effect supplies it; Create event actions come from every matching rule. | — |
| RUL-14.b | backlog | Rules apply to a calendar's events in this order: time changes and Move, then the user's edits and events added by hand, then Create event, then text Change and Add, then emoji, then color, then delete. | — |
| RUL-15 | backlog | A Create event action makes an event beside each event the rule matches (RUL-04.a). | — |
| RUL-15.a | backlog | A Create event action places its event before the start, after the start or after the end of the matching event (msg:placeBeforeStart, msg:placeAfterStart, msg:placeAfterEnd), plus an offset entered as h:mm within the range in DEF-01. | — |
| RUL-15.b | backlog | When the matching event is all-day, the created event runs from midnight of its first day to midnight after its last day. | — |
| RUL-15.c | backlog | A created timed event lasts the length of its template from the placed moment; a created all-day event covers the day that contains that moment. | — |
| RUL-15.d | backlog | A created event has a stable identity made from the matching event, the rule and the action's position, so a repeat run updates the same event and two actions that make the same identity produce one event. | — |
| RUL-15.e | backlog | An event that is hidden, or was made by a rule, or is deleted by a rule, produces no created events. | — |
| RUL-15.f | backlog | A Create event action whose event template no longer exists creates nothing. | — |
| RUL-16 | backlog | The rule dialog adds a rule or changes one (RUL-06.d). | — |
| RUL-16.a | backlog | The dialog's heading is msg:newRule when adding and msg:changeRule when changing. | — |
| RUL-16.b | backlog | The rule's Title is optional, at most the title length in DEF-01, with white space collapsed and the placeholder msg:ruleTitlePlaceholder. | — |
| RUL-16.c | backlog | Remove is offered while a rule is being changed. | — |
| RUL-16.d | backlog | Apply is enabled while the dialog differs from how it opened and disabled while it matches it. | — |
| RUL-16.e | backlog | Apply to shows one tick box for each calendar with its color; msg:allCalendars and the single calendars exclude each other, and with no calendar yet it shows msg:noCalendarYet. | — |
| RUL-16.f | backlog | Saving keeps only calendars that exist, each once; a rule may apply to no calendar and then does nothing. | — |
| RUL-17 | backlog | All Rules shows what the rules are and which need attention (RUL-07). | — |
| RUL-17.a | backlog | The header has the + of UIC-24 and a count box, msg:ruleCountOne or msg:ruleCount ({n}) when no conflict is open, and msg:rulesToCheck ({n} conflicts) otherwise. | — |
| RUL-17.b | backlog | With no conflict open, the status lines are msg:rulesForAll, msg:rulesForChosen and msg:rulesWithoutCalendar ({n} rules each); otherwise up to the number of lines in DEF-01 show the conflicts. | — |
| RUL-17.c | backlog | An empty list shows msg:noRulesYet. | — |
| RUL-17.d | backlog | A rule line shows the rule in words (RUL-12), a badge naming its calendars (RUL-05.i), edit, copy and delete buttons, the handle of UIC-30 and a mark while a conflict of it is open. | — |
| RUL-17.e | backlog | Adding a calendar to a rule that applies to all calendars leaves it applying to all; taking a calendar off such a rule makes it list every other calendar. | — |
| RUL-17.f | backlog | Copying a rule opens a copy in the rule dialog with the same title; it is stored when it is saved. | — |
| RUL-17.g | backlog | Delete asks msg:deleteRuleAsk (UIC-06); a rule that no longer exists shows msg:ruleMissing. | — |
| RUL-18 | backlog | Stored rules have a limit, identities and History entries. | — |
| RUL-18.a | backlog | At most the number of rules in DEF-01 are kept; one more, added or copied, is not valid (UIC-19) and shows msg:rulesLimit ({n} the limit). | — |
| RUL-18.b | backlog | A rule's ID is 1 to the length in DEF-01 of lower-case letters and digits; an ID that is invalid or already used is replaced by a new one, and a stored list with the same ID twice keeps the first. | — |
| RUL-18.c | backlog | History (HIS-01) records msg:ruleAdded, msg:ruleChanged, msg:ruleMergedInto, msg:ruleDeleted and msg:ruleCopied ({label} the rule's label); a conflict settled records msg:ruleConflictSettled ({how} the choice, {label}); adding or taking off a calendar records msg:ruleAddedToCalendar or msg:ruleTakenOffCalendar ({calendar}, {label}). | — |
| RUL-18.d | backlog | Every change to the rules rebuilds the calendars and feeds that use them. | — |
| RUL-19 | backlog | A link rule makes one event follow another (EVT-05). | — |
| RUL-19.a | backlog | A link records its event and calendar, the linked event and its calendar, the linked event's start when it was last seen and its title (length in DEF-01); a link whose two events are the same, or that lacks one, is not valid (UIC-19). | — |
| RUL-19.b | backlog | A link rule applies only while its calendar is ticked in Apply to. | — |
| RUL-19.c | backlog | When the linked event is missing, an event whose link rule has a Delete action is deleted; otherwise the link is removed. | — |
| RUL-19.d | backlog | The linked event's title in the rule is refreshed when it changes. | — |
| RUL-19.e | backlog | The dialog's info line for a link rule is msg:followsInfo ({name} the linked event's title). | — |
| RUL-04.j | backlog | The note that Record changes adds to an event's notes reads msg:changedNote ({date}, {parts} the changed parts separated by semicolons: msg:changePartTime, msg:changePartTitle, msg:changePartLocation, an empty value shown as —); only the last changes in DEF-01 are kept per event, each separated from other notes by a blank line. | — |
| RUL-04.k | backlog | A noted change is also recorded in History as msg:historyChanged ({calendar}, {title}, {parts}); an event that vanished from its source is recorded as msg:historyRemoved ({calendar}, {title}, {when} its day and time) and its notes are discarded. | — |
| RUL-04.l | backlog | Nothing is recorded for a calendar's first download. | — |
| RUL-06.l | backlog | The title made for an untitled rule is the rule in words (RUL-12), for example Title contains “RDO” → Color (Tomato), with white space collapsed. | — |
| RUL-07.g | backlog | A new rule that has at least one condition is a duplicate of a stored rule when their conditions are identical, their sets of actions are identical (order ignored) and they share a calendar; link rules are not compared. The user sees msg:thisLooksTheSameAs ({label}) and chooses as RUL-07.c says. | — |
| RUL-07.h | backlog | Merging into a rule that no longer exists shows msg:ruleIsntThereAnyMore and changes nothing. | — |
| RUL-07.i | backlog | Two rules conflict when they share a calendar and the higher one matches at least everything the lower one matches: it has no conditions, or the same conditions (text is compared ignoring case; a case-sensitive condition or a regex is compared exactly); a link rule is never part of a conflict. | — |
| RUL-07.j | backlog | A conflict is a duplicate when the higher rule has conditions and both rules have the same set of actions. | — |
| RUL-07.k | backlog | A conflict names the calendars where the rules overlap as msg:conflictIn ({calendars}) when they do not apply to all calendars. | — |
