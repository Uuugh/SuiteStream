# Requirements: connections

This file establishes the rules for creating a connection module: what every connection does and what each one must state in its own file in `connections.d/` (its role, its connection method when it downloads, and the plugin it needs), and nothing else that is common. Connections are modules listed in a section; a connection is a local, one-way or two-way synchronization (plugins are in plugins.md).
Terms: **one-way** moves events in one direction only (a source brings them in, a feed sends them out), **two-way** does both; a **downloaded** connection (CCS+, a calendar link) reads a calendar from the internet and is read-only here; a **published** event is an event sent out by a feed or by a Google connection.

| ID | status | statement | test |
|---|---|---|---|
| CON-01 | backlog | A connection synchronizes calendar events locally, one-way or two-way. | — |
| CON-01.a | backlog | Every kind of connection is a connection module with its own file in `connections.d/`. | — |
| CON-01.c | backlog | Each connection is a source (it brings events in), a feed (it sends events out) or both, and says so in its own file. A section contains every connection that has its capability, so a connection that is both is contained by the Sources and the Feeds sections: it is one module, and a change or removal made in either place applies to the connection. | — |
| CON-01.b | backlog | A connection that needs a plugin can be added only while that plugin is set up: a Google connection requires the Google plugin (PGAP-01). | — |
| CON-01.d | backlog | The number of connections has the limit in DEF-01; at the limit the + of a section is disabled and says the limit. | — |
| CON-01.e | backlog | Each connection has a generated identifier that is never equal to another's: the letter f and six hexadecimal digits for a calendar link, the letter l and six hexadecimal digits for a Local calendar. | — |
| CON-01.f | backlog | Adding a source records History msg:calendarSourceAdded (can be undone), builds its calendar content and starts its checks at once. | — |
| CON-02 | backlog | A connection is named, colored and annotated. | — |
| CON-02.a | backlog | A source can be renamed and given a note; saving updates its name and explanatory note, and clearing the note removes its content. | — |
| CON-02.b | backlog | Source color can be changed and saved; the new color is reflected immediately in its source display. | — |
| CON-02.c | backlog | A note that merely repeats the connection's kind is treated as no note. | — |
| CON-02.d | backlog | A connection's kind is fixed text in its module header, stated in its own file. | — |
| CON-02.e | backlog | A connection is shown as a module: its header, Expand and Close follow UIC-29, and its look follows THM-08. | — |
| CON-02.f | backlog | A connection's name is cut to the length in DEF-01 after repeated whitespace is collapsed, and its note to the length in DEF-01. | — |
| CON-02.g | backlog | Saving a name or color records History msg:sourceSaved ({source} is the connection, {name} its name, {color} #rrggbb or msg:defaultColor2), can be undone and rebuilds the connection's calendar content (CON-07). | — |
| CON-02.h | backlog | A color is #rrggbb in any letter case, stored in lower case. Other values are refused with msg:chooseTheColorWithThe. Choosing the default color deletes the saved one. A connection without an explicit color uses the active theme for display and publishes its events without a color. | — |
| CON-03 | backlog | Each source shows its status and can be synced or turned off. | — |
| CON-03.a | backlog | Sync Now updates a source in the background: it reports Syncing during work and Healthy on success, and keeps unrelated unsaved source edits. Sync Now answers after the time in DEF-01 and, if the run is still going, the page follows its status until it is done. | — |
| CON-03.b | backlog | A source reports when it last synced (a download or an upload) or that a read, check or download failed. | — |
| CON-03.c | backlog | A successful feed download reports healthy status even when another source has no events. | — |
| CON-03.d | backlog | The source status event count counts the published feed events, with event visibility determined by CAP-02. | — |
| CON-03.e | backlog | A source can be turned off and back on, with its saved off state cleared when reenabled. | — |
| CON-03.f | backlog | Turning a source off removes its events from published feeds while retaining its selected feed memberships for reenabling. | — |
| CON-03.g | backlog | A connection's status line says when it last did its work, with its time, in its own words: "Last synced" or "Sync failed" for a connection that synchronizes, "Last read" for a feed (CFED-05); never "Last check was successful". A connection that checks on a schedule also shows "Next check @" with its time beside the action. | — |
| CON-03.h | backlog | A source's status chip reads msg:healthy (good), msg:syncing, msg:starting, msg:setupNeeded, msg:paused (in progress), msg:signInRejected, msg:blocked, msg:error (warning) or msg:internalError (bad). | — |
| CON-03.i | backlog | A download run ends Healthy, Sign-in rejected, Blocked, Error or Internal error, and records History msg:signInRejected2 for a rejected sign-in, msg:blocked2 for a block, msg:downloadFailed for any other source error and msg:unexpectedError for a failure of the app itself. | — |
| CON-03.j | backlog | An accepted download sets the status to Healthy, records the last-success time and, when the calendar differs, the last-change time; its detail is msg:firstCopy for the first copy, msg:newRemoved ({n} new and {n2} removed events, counted by identifier) when it changed and msg:noChanges when it did not; the status message is msg:eventsInFeed2 and History records msg:scheduleEventsInFeed, where {how} is msg:downloadedFromCcs, msg:uploadedByHand or msg:downloadedFromHost. | — |
| CON-03.k | backlog | A source's status, message, attempt, success and change times, last sign-in, count of rejected sign-ins, event count and last detail are kept across a restart; a status of Syncing at the time of the stop comes back as Starting. | — |
| CON-03.l | backlog | A source's module opens by itself when its status is not Healthy, Syncing or Starting, or when CCS+ has no credentials. | — |
| CON-03.m | backlog | A paused connection shows msg:automaticChecksPaused in place of the next-check time. | — |
| CON-03.n | backlog | Turning a calendar Off or On is recorded in History as msg:calendarSwitchedOff or msg:calendarSwitchedOn and can be undone, and every Google connection that carries the calendar then runs a full sync (CGOW-04). | — |
| CON-03.o | backlog | Verifying a downloaded connection waits for a running download (at most the time in DEF-01), runs a download as Sync Now does and answers msg:validated or msg:verifyFailed; it succeeds when the status is Healthy afterward (CCCS-02 adds a condition for CCS+). | — |
| CON-04 | backlog | The user can remove a source, and keep or merge its events. | — |
| CON-04.a | backlog | Removing a source removes its stored events and its membership from destinations, while keeping a combined Google destination. | — |
| CON-04.b | backlog | Removing a source can preserve its events by creating a Local calendar with its prior color and destination memberships, or by merging into an existing Local calendar. The original source is removed. | — |
| CON-04.c | backlog | Calendar removal identifies its owned rules, and deleting the calendar removes those rules. | — |
| CON-04.d | backlog | When merging a calendar into another, the user can transfer its owned rules to the target or delete those rules. | — |
| CON-04.e | backlog | Removing a source asks what to do with its events: delete them (the default) or merge them into another calendar; with a merge it also asks whether its own rules move with them or are deleted (the default). | — |
| CON-04.f | backlog | Merged events are in their current state with their edits, without hidden events and events made by rules; their start and end are kept, their time-zone overrides are cleared, and their reminders and links follow them. | — |
| CON-04.g | backlog | The rules that belong only to the removed calendar are deleted or moved to the target; a rule that belongs to several calendars loses the removed one; a rule that belongs to all calendars stays. | — |
| CON-04.h | backlog | Removing a source stops its checks, removes it from every feed and deletes all its stored settings, and records History msg:calendarSourceRemoved, msg:calendarSourceRemovedMerged or msg:calendarSourceRemovedMergedRules; the removal can be undone. | — |
| CON-04.i | backlog | Before a source is removed the user is offered a copy of its calendar to download. | — |
| CON-05 | backlog | A source is downloaded automatically on a schedule, and the user can change the schedule. | — |
| CON-05.a | backlog | The automatic-download interval is an admin setting kept in the database; the installation's value is only its starting value (DEP-05, DEF-01). | — |
| CON-05.b | backlog | The download interval stays within the limits in DEF-01; a value outside them, or not a number, is not valid (UIC-19). | — |
| CON-05.c | backlog | The next download is scheduled from the last attempt plus the configured interval; if that time has passed, changing the interval schedules an immediate download. | — |
| CON-05.d | backlog | Changes to download settings or source credentials follow the shared form-security rules (ACC-09). | — |
| CON-05.e | backlog | Each source that downloads is checked once when the app starts or the source is added, and then once per interval after the previous check ended. | — |
| CON-05.f | backlog | After an unexpected failure of a scheduled check the next check is made after the time in DEF-01. | — |
| CON-05.g | backlog | Saving the interval wakes the schedule and records History msg:checksEveryMinFromNow. | — |
| CON-05.h | backlog | The interval field offers whole numbers in the step in DEF-01, within the limits in DEF-01. | — |
| CON-06 | backlog | A download gets the calendar safely and reports clearly when it cannot. | — |
| CON-06.a | backlog | A downloaded connection states its connection method in its own file (for example HTTPS, curl, web scrape or RSS), and downloads with it. | — |
| CON-06.b | backlog | A redirect on the same host can complete the download; a redirect to a less secure address than the connection's method is refused, and a redirect loop is reported. | — |
| CON-06.c | backlog | Following a calendar redirect to a different host does not forward the source’s authorization credentials. | — |
| CON-06.d | backlog | Calendar downloads keep sign-in credentials out of process command-line arguments; stored and displayed secret protection follows ACC-05. | — |
| CON-06.e | backlog | A download larger than the size limit in DEF-01 is not accepted. | — |
| CON-06.f | backlog | A download keeps at most the number of events in DEF-01; the earliest events are kept, whatever the input order. | — |
| CON-06.g | backlog | A downloaded calendar retains calendar content and cache validators; a matching ETag can return an unchanged result rather than downloading the content again. | — |
| CON-06.h | backlog | A wrong download password is reported as a credential rejection; upstream protection denial is reported as blocking, not as invalid credentials. A rejected password ends the download attempt at once, without trying another connection mode or spending a retry delay. | — |
| CON-06.i | backlog | A successful HTTP response containing HTML instead of calendar data is refused; malformed calendar data is also refused. | — |
| CON-06.j | backlog | A download that does not reply reports a timeout and explains the manual-upload alternative. | — |
| CON-06.k | backlog | Download failure feedback distinguishes failure to connect from a connected server that does not reply. | — |
| CON-06.l | proposed (?) | Automatic downloading retries a transient nonreply and can succeed on a later attempt; a persistent nonreply eventually fails. What retry budget and timing should be promised beyond the observed attempts? | — |
| CON-06.m | backlog | A failed source download preserves the previously downloaded schedule. | — |
| CON-06.n | backlog | A download that returns no events while the connection already has events is refused and the previous schedule stays; an empty download is accepted only when there were no events. | — |
| CON-06.o | backlog | Cache validators are stored when a download is accepted and are sent when they are not empty; a not-modified answer sets the status to Healthy, records History msg:scheduleNoChanges as information and shows msg:upToDateEventsIn. | — |
| CON-06.p | backlog | The first bytes of a reply (the length in DEF-01) must contain the calendar start BEGIN:VCALENDAR; a reply that lacks it is reported as msg:whoAnsweredNotCalendar ({who} is CCS+ or the link's host, {type} the content type or msg:unknownType, {details} the first characters of the reply, the length in DEF-01). | — |
| CON-06.q | backlog | HTTP 403 is reported as a block: msg:accessDeniedByHttp4032, or msg:accessDeniedByHttp403 when the reply carries a reference number ({ref}); {who} is msg:akamaiUnitedsBotProtection when the Server header contains akamai in any letter case, else the Server header, else msg:theServer. | — |
| CON-06.r | backlog | Any other HTTP status of 400 or more is reported as msg:whoAnsweredHttp ({who} as above, {details} the first characters of the reply without tags, the length in DEF-01, or msg:noDetails). | — |
| CON-06.s | backlog | Failing to connect within the connect time limit in DEF-01 is reported as msg:couldnTConnectToWithin and any other network failure as msg:couldnTReach. | — |
| CON-06.t | backlog | A reply over the download size in DEF-01 is reported with msg:sentMoreThan5Mb. | — |
| CON-07 | backlog | A downloaded or imported schedule becomes events with their times and recurrences. | — |
| CON-07.a | backlog | Recurring source events expand into distinct occurrences while retaining source-qualified identities. Moving one recurrence preserves the occurrence identities and updates its changed title. | — |
| CON-07.b | backlog | Recurring source events are expanded over the period in DEF-01. | — |
| CON-07.c | backlog | When a recurring source occurrence moves, its existing local edits remain attached using its original-start identity. | — |
| CON-07.d | backlog | Free/busy information from an imported calendar is preserved: events marked transparent remain free. | — |
| CON-07.e | backlog | When source events conflict, the earlier source in the saved source order has priority. | — |
| CON-07.f | backlog | A future event that disappears from a refreshed source schedule is kept for restoration, with its title, until its deletion leaves History (HIS-03). It is kept, struck through, while it ends today or later, at most the number per download in DEF-01; an ended, hidden or rule-made event is not kept; History records msg:unitedRemovedEvents for CCS+ or msg:goneFromTheFeedEvents for a link, listing the first events in DEF-01 and ending with " …" when there are more, and each can be restored. | — |
| CON-07.g | backlog | An event without a start is skipped; its end is its end time, else its start plus its duration; an all-day event with no end lasts one day. | — |
| CON-07.h | backlog | An event with no title is titled msg:noTitle, its notes are cut to the length in DEF-01, and an event with no identifier gets one made from its start and title. | — |
| CON-07.i | backlog | A repeating event with an invalid rule is skipped without dropping the rest of the file, an event whose status is cancelled is skipped, and of two events with the same identifier in one file the first is kept. | — |
| CON-07.j | backlog | Events of different sources never merge or replace one another. | — |
| CON-07.k | backlog | Any change of a connection's name, color, rules or events rebuilds its calendar from the last downloaded copy without downloading again, applying in this order: time changes by rules, edits and added events, events made by rules, rule colors and emoji, reminders; hidden events are not counted. | — |
| CON-08 | backlog | A connection's calendar can be exported. | — |
| CON-08.a | backlog | Calendar export downloads an ICS attachment containing its events. | — |
| CON-08.b | backlog | An export holds the connection's events as they are now with their edits, without hidden events and events made by rules. | — |
| CON-08.c | backlog | The exported file is named after the connection with every character other than letters, digits, space, dot, underscore and hyphen removed, plus .ics (calendar.ics when nothing is left); its header carries the name, the Local time zone and the color in the format of a feed (CFED-04). | — |
| CON-09 | backlog | Events published by a feed or a Google connection carry the same event content. | — |
| CON-09.a | backlog | A published event keeps its own time zone (TIM-07), its title, and its start and end; the page's display time zone does not change them. | — |
| CON-09.b | backlog | A published event carries its display reminders, including fifteen-minute and one-hour reminders. Reminder selection belongs to EVT-03. | — |
| CON-09.c | backlog | A published event's online meeting address is also the first line of its notes (EVT-03 owns the ICS URL). | — |
| CON-09.d | backlog | A hidden event is not published, and hiding an event removes its published copy. Visibility is CAP-02 and EVT-04. | — |
| CON-09.e | backlog | A published calendar can be limited by a date range (UIC-23); with no range it publishes its full event set. | — |
| CON-09.f | backlog | A published event carries its identifier, the time it was published (UTC), its title, and its location and notes when they are not empty; a free event is marked transparent. | — |
| CON-09.g | backlog | A published event carries a marker saying whether it was added on the page (added), made by a rule (rule), a source event changed on the page (edited) or unchanged from its source (source). | — |
| CON-09.h | backlog | A published event's reminders are display reminders titled with the event's title, in whole minutes, without duplicates, largest first. | — |
| CON-01.g | backlog | A Google account added later gets an identifier of the letter a and six hexadecimal digits, and the CCS+ connection has the identifier ccs. | — |
| CON-03.p | backlog | A failed download of a feed is always Error, with the reason as its message. | — |
| CON-03.q | backlog | A rejected sign-in raises the count of rejected sign-ins in a row by one, and a successful reply sets it to 0. | — |
| CON-03.r | backlog | A CCS+ check with no login saved sets only the status Setup with msg:enterYourCcsUsernameAnd and records no History line. | — |
| CON-06.u | backlog | Checks start when the app starts and when a source is added; a Local calendar has no checks. | — |
| CON-06.v | backlog | The browser-like download client imitates the newest browser version it knows; a feed is always downloaded with the plain client. | — |
| CON-06.w | backlog | Every download waits for the connect time and the total time in DEF-01 (Download time limits) and reports a timeout as a download failure. | — |
| CON-06.x | backlog | A reply that does not look like a calendar is quoted in the error from the start of the reply up to the length in DEF-01, shortened to the snippet length in DEF-01. | — |
| CON-07.l | backlog | A source event with a date only as its start is an all-day event, lasting one day when it has no end. | — |
| CON-07.m | backlog | A timed source event starting exactly at midnight with no end or duration becomes one all-day event. | — |
| CON-07.n | backlog | A timed source event not starting at midnight with no end is read with its end equal to its start and flagged as having no end, so that rules decide its length; one that no rule changes gets the default length (the event hours setting). | — |
