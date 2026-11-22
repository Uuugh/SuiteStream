# Requirements: Generic Feed

The Generic Feed connection: the user's events published as a calendar feed that other calendar apps subscribe to. Common connection rules and the content every published event carries are in `connections.md` (CON-09). Issues and history of this feature are in git.
Terms: the **stream token** is the part of a feed's address that identifies it (called the stream name in the old app); a **destination** is a feed or a Google calendar that the app publishes to.

| ID | status | statement | test |
|---|---|---|---|
| CFED-01 | backlog | A feed publishes the calendars the user chooses, under its own name, for other apps to read. | — |
| CFED-01.i | backlog | A Generic Feed is a feed. | — |
| CFED-01.a | backlog | A feed can publish all chosen source calendars under its own name; its calendar data includes those sources’ events and its chosen calendar name. | — |
| CFED-01.b | backlog | A feed’s included calendars can be changed independently of other destinations. | — |
| CFED-01.c | backlog | Each feed decides which calendars it carries; the required Local calendar is in a feed only as that feed's own settings say, never because of a rule special to Local. | — |
| CFED-01.e | backlog | A new feed's name and note default to the selected source's and follow it when the selected source changes; values the user typed are kept. | — |
| CFED-01.f | backlog | A feed’s subscription page identifies the feed by its name. | — |
| CFED-01.g | backlog | Turning a feed off makes its URL temporarily unavailable; turning it back on clears its off state without changing its included calendars. While a feed is off its address answers that it is unavailable with msg:thisCalendarFeedIsSwitchedOff and asks readers to try again after the time in DEF-01, so subscribers keep their last copy; the address of an unknown feed is still not found. | — |
| CFED-01.h | backlog | Removing a feed makes its subscription URL stop working. | — |
| CFED-01.d | backlog | A feed added with no calendars chosen carries every calendar, in the list order. | — |
| CFED-01.j | backlog | A feed's note is at most the length in DEF-01. | — |
| CFED-01.k | backlog | A feed's color is #rrggbb stored in lower case; anything else is refused with msg:chooseTheColorInTheColorBox. | — |
| CFED-01.l | backlog | Adding, changing and removing a feed is recorded in History and can be undone: msg:destinationAddedCalendarFeed, msg:destinationCalendars ({calendars} lists the chosen calendars, or msg:noSources) and msg:destinationRemoved. | — |
| CFED-01.m | backlog | Removing a feed also forgets its read times. | — |
| CFED-01.n | backlog | Turning a feed Off or On is recorded in History as msg:destinationSwitchedOff or msg:destinationSwitchedOn and can be undone. | — |
| CFED-01.o | backlog | A feed carries the events of its chosen calendars that are not Off and not hidden and that overlap its Start and End days, sorted by start; its calendar name is the feed's name and its color is the feed's own color, else the color of its only chosen calendar, else none. | — |
| CFED-02 | backlog | A feed has an address that contains its stream token, which is generated or chosen by the user. | — |
| CFED-02.a | backlog | A token is generated automatically when a feed is created, with the length and strength in DEF-01, from a cryptographically secure generator (OWASP's recommendation for unguessable identifiers). The user may enter a different token instead; its strength is shown as UIC-18, with the hint recommending the strength in DEF-01. Reusing an old feed link is CFED-02.b. | — |
| CFED-02.b | backlog | Pasting an old full feed URL restores its stream token, both when creating and updating a feed. Once replaced, the new token works and the replaced token no longer does. | — |
| CFED-02.c | backlog | A stream token may contain any character. Characters outside the RFC 3986 unreserved set (letters, digits, hyphen, period, underscore, tilde) are percent-encoded in the feed's address, so a space becomes %20. A character is as DEF-03 says. | — |
| CFED-02.d | backlog | A stream token has a length within the limits in DEF-01, wherever it is saved; the characters it may contain are CFED-02.c. | — |
| CFED-02.e | backlog | Each feed stream token is unique; a duplicate is not valid (UIC-19) and no second destination is created. | — |
| CFED-02.f | backlog | A feed can use a selected configured public base address, and its link combines that address with its stream token. Public-domain configuration belongs to settings. | — |
| CFED-02.g | backlog | A missing feed destination or an invalid feed token does not expose a feed and returns not found. | — |
| CFED-02.h | backlog | Changing a feed's stream token is recorded in History as msg:streamNameChanged. | — |
| CFED-02.i | backlog | Only a Calendar Feed has a stream token, and stream tokens are compared with letter case and in constant time. | — |
| CFED-02.j | backlog | A feed's links use the public address the feed selected (CFED-02.f); a feed that selected none uses the main public address, and with none set the address the page was opened at. | — |
| CFED-02.k | backlog | A public address entered while adding a feed is saved as the main public address and recorded as msg:publicAddressSetTo; an invalid one is refused with msg:enterTheAddressPeopleUse. | — |
| CFED-03 | backlog | The user can subscribe to a feed from other calendar apps. | — |
| CFED-03.a | backlog | A feed offers a subscription link and ways to add it to Google Calendar, Apple Calendar and Outlook, with instructions for those choices. | — |
| CFED-03.b | backlog | The user can share a feed subscription address by copying it, through the device's own sharing facility, or in an email or SMS link. | — |
| CFED-03.c | backlog | Subscription guidance (shown with the feed's instructions, CFED-03.a) tells the user: to enable calendar synchronization on Android and iPhone and to use Google's desktop site to add a subscription; that using a feed and direct synchronization for the same calendar can duplicate events; that Google may take up to twelve hours to read a feed; that Google may keep the name from its first read, so the user may need to rename the subscribed calendar (direct naming is CGOW-02); that Google subscriptions do not use the feed's color; and how the destination types compare, naming the current one (UIC-07). This is provider guidance, not a SuiteStream delivery guarantee. | — |
| CFED-03.d | backlog | A feed has five addresses made from its stream token and its base: the feed address (base/calendar/token.ics), the subscription page (base/subscribe/token), a link that adds it to Google (https://calendar.google.com/calendar/r?cid= followed by the feed address with webcal:// as its scheme, percent-encoded), the webcal:// address, and a link that adds it to Outlook (https://outlook.live.com/calendar/0/addfromweb with the feed address and the feed's name). | — |
| CFED-03.e | backlog | An address counts as public when it starts with https:// and is not localhost, 127.0.0.1 or a test host; for any other address the subscription page shows msg:thisLinkIsnTOn. | — |
| CFED-03.f | backlog | The subscription page appears in the visitor's browser language, shows the feed's name, the five addresses, step-by-step help and msg:lastUpdatedEvents (the latest successful check of the feed's calendars and the number of its visible events, shown once a calendar has been checked), and asks search engines not to list it. | — |
| CFED-04 | backlog | A feed's content reads correctly in calendar apps. | — |
| CFED-04.a | backlog | Published ICS carries the feed’s color in X-APPLE-CALENDAR-COLOR for consumers that support that calendar property. | — |
| CFED-04.b | backlog | An unchanged feed supports conditional reads with an ETag and an empty not-modified response; changing its events causes an old ETag to receive updated content. | — |
| CFED-04.c | backlog | A feed's ETag is the first 32 hexadecimal digits of the SHA256 hash of its body; a request that lists that tag gets the not-modified answer with the same tag. | — |
| CFED-04.d | backlog | A feed's calendar properties are: version 2.0, product identifier -//calendar_stream//EN, name, time zone (the Local time zone, TIM-03), and a refresh interval and published time-to-live of the time in DEF-01. | — |
| CFED-05 | backlog | A feed shows when it was last read. | — |
| CFED-05.a | backlog | A feed reports Not read yet until fetched; afterward it reports its last read, identifying Google when Google is the reader. | — |
| CFED-05.b | backlog | An ordinary feed reports reads rather than a next-push schedule. | — |
| CFED-05.c | backlog | A read of a feed counts as Google's when the requester's identification contains google in any letter case, otherwise as other; a not-modified answer counts as a read, an unavailable or not-found answer does not, and the read is saved at most once per the time in DEF-01. | — |
| CFED-05.d | backlog | A feed's status shows msg:readByGoogle (good) once Google read it, otherwise msg:notReadYet (in progress); its line reads msg:lastReadByGoogle, or msg:lastRead for another reader, and is empty before any read. | — |

