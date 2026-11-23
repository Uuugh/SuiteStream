# Requirements: history

| ID | status | statement | test |
|---|---|---|---|
| HIS-01 | backlog | History records what changes in the app and what happens with Google, so the user can see what happened and why. | — |
| HIS-01.a | backlog | Activity records calendar changes, identifying the changed calendar. | — |
| HIS-01.b | backlog | A synchronization that changes events records in its activity summary how many events it added and how many it updated. | — |
| HIS-01.c | backlog | When a Google change is saved locally, History records that outcome; when a newer local change wins, it records that the local change was kept. | — |
| HIS-01.d | backlog | A deletion received from Google is recorded with its Google origin. | — |
| HIS-01.e | backlog | If a former Google client’s calendar cannot be reached for cleanup, History warns that manual deletion is needed. | — |
| HIS-01.f | backlog | A Google color-update failure records the failed operation, the upstream status and its reasons so the refusal can be diagnosed (CGOW-03). | — |
| HIS-01.g | backlog | An unsigned Google connection produces one not-signed-in or unsynced warning; resetting the remembered warning permits a new one. | — |
| HIS-01.h | backlog | A failure or warning that repeats unchanged is recorded in History once, until it changes or clears. | — |
| HIS-01.i | backlog | An external removal or Google notification without an undoable local change does not become the current Undo entry. | — |
| HIS-01.j | backlog | History's Activity health is the section health of UIC-05.g, with its sources as its items. | — |
| HIS-01.k | backlog | When remote cleanup is deferred because the write budget was reached, History reports the deferred work. | — |
| HIS-01.l | backlog | Completing Google API setup records a message identifying each Google connection that needs sign-in, has a sync error or has not completed its first sync. | — |
| HIS-02 | backlog | History lists its entries with their type, in a table the user can filter and rearrange. | — |
| HIS-02.a | backlog | History names the type of each change: Calendar, Rule, Event, Sync, Feed, Google, Settings or Update. | — |
| HIS-02.b | backlog | History has a filter that follows the common filter rules (UIC-21), with three parts: the change type (the types in HIS-02), words in its entries, and the time of its entries. | — |
| HIS-02.c | backlog | The user can choose the order of History's columns by sliding a header, or with the left and right arrows when a header is focused; Undo starts at the end. | — |
| HIS-02.d | backlog | History is a table: Time \| Type \| Event \| Undo with newest entries first and Undo and Redo where they apply. | — |
| HIS-02.e | backlog | Something done outside SuiteStream (deleted in Google, removed by United) has no Undo icon; Restore is on the event. | — |
| HIS-02.f | backlog | An accepted sign-in is shown as a ✓ with no words; the word stays as its tooltip and accessible name. | — |
| HIS-02.g | backlog | History's three latest lines sit left-aligned in its section header, before its Healthy box. | — |
| HIS-03 | backlog | The user can undo and redo what History records. | — |
| HIS-03.a | backlog | Only the newest completed undoable change can be undone. | — |
| HIS-03.b | backlog | Undo restores the state before any undoable change and Redo reapplies it (HIS-03), in the order HIS-03 sets. This covers rule deletions; feed and event-template changes; an import (the event set before it); a calendar merge (the original calendar and its rule scope, with the merged events removed from the target); CCS+ removal (the source and its saved credentials); and Hide (the event's visible state, EVT-04). | — |
| HIS-03.c | backlog | An undoable change records what is needed to restore it, before and after. | — |
| HIS-03.d | backlog | A deleted event kept for Undo is permanently removed when its deletion leaves the retained history. | — |
| HIS-03.e | backlog | When removal of a CCS+ calendar leaves retained Undo history, its retained sign-in credentials are forgotten; protection while retained follows ACC-05. | — |
| HIS-04 | backlog | History keeps a limited number of changes and does not show secrets unless the user may see them. | — |
| HIS-04.a | backlog | History keeps the number of changes set in Settings (DEF-01 has the default and the limits); saving a different number updates the effective retention and the displayed value, and a number outside the limits is not valid (UIC-19). | — |
| HIS-04.b | backlog | History has a Show secrets switch for every log view on the page. By default secrets are masked: authorization headers, client secrets, tokens, authorization codes, and any secret value the app stores, wherever it appears in the text. Turning the switch on shows them, only to a user authorized to see secrets, and it turns off again whenever the page is opened (ACC-05.d). | — |
| HIS-02.h | backlog | History's Type menu starts with msg:historyEveryType and then lists the eight types of HIS-02.a. | — |
| HIS-02.i | backlog | History's words box is labelled msg:historyWords; its Time menu offers msg:historyAnyTime, msg:historyLastHour, msg:historyLast24Hours, msg:historyLast7Days and msg:historyLast30Days. | — |
| HIS-02.j | backlog | Changing a History filter acts on the lines already loaded, without reloading the page. | — |
| HIS-02.k | backlog | A History filter request names the type, the words, the earliest time and the number of lines; words match without regard to letter case, and the characters %, _ and backslash match as themselves. | — |
| HIS-02.l | backlog | Each line has the type it was recorded with: calendar added, removed, emptied, imported, saved, switched On or Off and default-calendar lines are Calendar; destination lines are Feed; rule lines are Rule; event lines are Event; Google deletions and Google account lines are Google; Settings lines are Settings; update lines are Update; every other line is Sync. | — |
| HIS-03.f | backlog | Each line has an undo state: none, done or undone; a change made on the page is done. | — |
| HIS-03.g | backlog | Undo shows only on the newest done line, and Redo only on the oldest undone line that is newer than it. | — |
| HIS-03.h | backlog | Asking to undo or redo any other line is not allowed and shows msg:historyNewerFirst. | — |
| HIS-03.i | backlog | Asking to undo a line that has nothing left to restore shows msg:historyCantUndo. | — |
| HIS-03.j | backlog | After an undo the line is undone; after a redo it is done again. | — |
| HIS-03.k | backlog | An undo or redo writes msg:historyUndone or msg:historyRedone ({message} is the line's message) to the container log and makes no History line. | — |
| HIS-03.l | backlog | Recording a new undoable change discards the restore data and state of every undone line, so they cannot be redone. | — |
| HIS-03.m | backlog | A change's restore data holds, for each calendar: its name, color, tags, rule list, defaults, note, interval, download cache, status, counters and On or Off, and for CCS+ also its login and Calendar Sync link. | — |
| HIS-03.n | backlog | A change may name single events whose edit data and added-event data are held for it. | — |
| HIS-03.o | backlog | A restore is all or nothing: it succeeds completely in one step or changes nothing, and settings the saved data does not hold are deleted. | — |
| HIS-03.p | backlog | After a restore the checks start or stop for each calendar, the data of calendars that are gone is forgotten, every status is read again and the calendars are rebuilt. | — |
| HIS-03.q | backlog | A deleted event stays visible, struck through and greyed, labelled with where it was deleted: SuiteStream, Google, United or its feed. | — |
| HIS-03.r | backlog | Undoing the deletion of a calendar-source event removes its hidden mark and any edit record made only for the deletion, and writes the event to Google again. | — |
| HIS-04.c | backlog | Saving a History count records msg:historyKeepSaved ({n} the count), with type Settings, and trims at once. | — |
| HIS-04.d | backlog | Trimming keeps the restore data of the newest lines that have any, up to the count in Settings; older lines keep their text and lose their restore data and state. It also runs after every recorded change and finishes the deletions whose undo is gone (HIS-03.d). | — |
| HIS-04.e | backlog | History keeps the number of lines in DEF-01; recording a line removes the oldest beyond it. | — |
| HIS-05 | backlog | Every line History records has a level, a type, a time and a message, and is written so that no secret reaches it. | — |
| HIS-05.a | backlog | A line's level is info, warn or error; the Event cell shows each level in its own color of the theme. | — |
| HIS-05.b | backlog | A line is shown in the language of the page when it is read; one with no translation in that language is shown in English. | — |
| HIS-05.c | backlog | A line about a connection whose message does not name it starts with the connection's name and ": ". | — |
| HIS-05.d | backlog | Every line is also written to the container log at the matching level. | — |
| HIS-05.e | backlog | When a line cannot be saved the failure is logged as msg:historyWriteFailed ({reason} the cause) and the work carries on. | — |
| HIS-05.f | backlog | A line's time is the moment it was recorded, with its time zone. | — |
| HIS-05.g | backlog | A download that finds nothing new records msg:scheduleNoChanges ({how} is the source of the schedule) and sets the status msg:upToDateEventsIn ({n} events); a republished identical schedule does the same. | — |
| HIS-05.h | backlog | A refused hand-made upload records the error msg:uploadRejected ({error} the reason). | — |
| HIS-05.i | backlog | A line that mentions a link or a key holds only a safe part of it: a feed link its host (msg:feedLinkChangedTo), a Calendar Sync link its host and path (msg:calendarSyncLinkSetTo), a Google client the start of its ID (PGAP-01.t), a CCS+ login only msg:ccsUsernameAndCalendarSyncSaved; a password, secret or token is never written. | — |
| HIS-05.j | backlog | Page login lines name the user: msg:statusPageLoginCreatedFor and msg:statusPageLoginChangedUser. | — |
| HIS-05.k | backlog | Calendar lines are msg:calendarSourceAdded, msg:calendarSourceRemoved, msg:defaultCalendarName, msg:calendarEmptied ({name}, {note}), msg:importedFileInto, msg:calendarSettingsSaved, msg:calendarSwitchedOff, msg:calendarSwitchedOn, msg:checksEveryMinFromNow and msg:calendarSyncLinkResetTo. | — |
| HIS-05.l | backlog | Destination lines are msg:destinationAddedCalendarFeed, msg:destinationSwitchedOff, msg:destinationSwitchedOn, msg:streamNameChanged and msg:morePublicAddresses ({list} the addresses, or msg:remindersNone when there are none). | — |
| HIS-05.m | backlog | Event lines are msg:added, msg:updated, msg:edited, msg:deleted, msg:eventHidFromFeeds, msg:eventShownInFeeds, msg:eventReverted, msg:eventRestored and msg:remindersChanged; linked events add msg:eventDeletedWithLinked and msg:eventMovedWithLinked ({when} the new start). | — |
| HIS-05.n | backlog | Event template changes record msg:templatesSaved. | — |
| HIS-05.o | backlog | Update lines have type Update: msg:updateAvailableAuto, msg:updateAvailablePress or msg:updateAvailableSuitestreamRunThe by how the update can be installed ({v} the version); msg:updatingTo and msg:autoUpdatingTo when an update starts; and, as warnings, msg:updateNotStarted and msg:autoUpdateNotStarted ({reason} the cause). | — |
| HIS-05.p | backlog | Sign-in protection records, as warnings, msg:statusPageLockedForAfter and msg:lockedManyAddresses ({n} the count and {minutes} the period in DEF-01), and with type Settings msg:unlockLinkUsedFrom. | — |
| HIS-05.q | backlog | Importing logins from the old secret files at start-up records msg:importedTheCcsUidAnd, msg:importedTheCcsUidAnd2 or msg:importedTheStatusPageLogin. | — |
| HIS-06 | backlog | Settings > History shows the state of its sources and Google before its table. | — |
| HIS-06.a | backlog | History shows in this order: one status line per source, the Google line, the filter, the table (msg:nothingYet when it has no lines), the footer and the debug links of DIA-01. | — |
| HIS-06.b | backlog | A source's status line shows msg:notYet, msg:accepted or msg:rejected with its time for the sign-in of a connection that signs in; then msg:lastCheck, msg:scheduleChanged, msg:nextCheck and msg:eventsInFeed ({n}); and, when above 0, msg:rejectedSignInsInA ({n}). The source's name is in bold when there is more than one. | — |
| HIS-06.c | backlog | A time in the status line is a clock time when it is today, otherwise the short date and a clock time, and msg:never when there is none. | — |
| HIS-06.d | backlog | The Google line is shown when a Google account is connected: an error when its last call failed, msg:syncing while a sync runs, otherwise the time of the last sync or msg:notYet. | — |
| HIS-06.e | backlog | Activity is unhealthy when a source's status is Sign-in rejected, Blocked, Error, Internal error or Paused, or when Google is connected and its last call failed; Healthy, Running, Starting and Setup do not make it unhealthy. | — |
| HIS-06.f | backlog | The table lists the newest lines, the number in DEF-01, newest first. | — |
| HIS-06.g | backlog | A saved column order that holds each of the four columns once is used; any other is replaced by the default order, and a bad order is not saved and shows msg:historyColumnOrderUnknown. | — |
| HIS-06.h | backlog | The Undo column's header is text for screen readers only. | — |
| HIS-06.i | backlog | A line whose change was undone ends with msg:historyUndoneMark and is greyed. | — |
