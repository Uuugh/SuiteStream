# Requirements: calendar link

The calendar-link connection: a calendar published at a web address (webcal or HTTPS), downloaded as a read-only calendar. Download rules are in `connections.md`.

| ID | status | statement | test |
|---|---|---|---|
| CLNK-01 | backlog | A calendar link, such as a secret address from Google, Outlook or iCloud, is downloaded as a connection. | — |
| CLNK-01.d | backlog | A calendar link is a source. | — |
| CLNK-01.a | backlog | A webcal source address is saved as its equivalent HTTPS address with its chosen name; duplicate source addresses are refused. | — |
| CLNK-01.b | backlog | Calendar links from Outlook, Microsoft 365 and iCloud can be downloaded as source calendars. | — |
| CLNK-01.c | backlog | Source presets identify the provider and offer provider-specific setup guidance, including Google secret-address guidance and the United Airlines CCS+ name. Choosing Apple selects the Apple preset. | — |
| CLNK-01.e | backlog | A calendar link is downloaded over HTTPS: a plain HTTP address is not valid. The address is trimmed, must use https and have a host, and the refusal reads msg:feedLinkMustStartHttpsWebcal. | — |
| CLNK-01.f | backlog | The preset a link is added with changes only the help and the description shown for it; an unknown preset is treated as Calendar Feed. | — |
| CLNK-01.g | backlog | The address of an existing calendar link can be changed under the same address rules; the change discards the stored download validators, records History msg:feedLinkChangedTo ({name} and {host}) and starts a download. | — |
| CLNK-01.h | backlog | A calendar link is named by default as the host of its address (msg:calendarWord when it has none), and a blank name returns to that default. | — |
| CLNK-01.i | backlog | A calendar link is downloaded with curl, with no sign-in and no retries, with the attempt time limits in DEF-01 and the same size, redirect and event limits as CCS+ (CCCS-03.d, CON-06). | — |
| CLNK-01.j | backlog | Download errors of a link name its host where CCS+ errors name CCS+ (CON-06): HTTP 401 reads msg:hostWantsALogin, a silent hold msg:connectedToButItSentTryLater, a link that is not https msg:feedLinkMustStartHttps, and too many redirects msg:redirectedTooManyTimesCheckFeed. | — |
| CLNK-01.k | backlog | A calendar link's status is Healthy, Error or Internal error; it does not become Sign-in rejected, Blocked or Paused. | — |
| CLNK-01.l | backlog | History entries of a link start with its name and ": "; a not-modified answer shows msg:upToDateEventsIn and records msg:scheduleNoChanges with {how} = msg:downloadedFromHost. | — |
