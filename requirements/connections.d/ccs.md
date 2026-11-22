# Requirements: CCS+

The CCS+ connection: the user's own United Airlines schedule, downloaded with their own sign-in (read only; SuiteStream never changes CCS+). Download rules every downloaded connection shares are in `connections.md`.

| ID | status | statement | test |
|---|---|---|---|
| CCCS-01 | backlog | There is one CCS+ connection: the user's own United Airlines schedule. | — |
| CCCS-01.c | backlog | CCS+ is a source. | — |
| CCCS-01.a | backlog | One CCS+ source can be added; attempting to add a second is refused. | — |
| CCCS-01.b | backlog | Removing CCS+ also removes its active saved login. | — |
| CCCS-01.d | backlog | The CCS+ source has the fixed identifier ccs, which no other source can have. | — |
| CCCS-01.e | backlog | Adding CCS+ lets the user choose which of the predefined rules (RUL-06.c) come with it; the chosen rules apply to CCS+. | — |
| CCCS-01.f | backlog | The CCS+ source is named by default as the installation's calendar name setting says (United CCS Schedule when it is not set); a blank name returns to that default and a name equal to it is not stored. | — |
| CCCS-01.g | backlog | SuiteStream only reads from CCS+: it sends no request that changes anything in CCS+. | — |
| CCCS-02 | backlog | The user signs in to CCS+ with their own credentials, which the app keeps safe, so it can read their schedule. | — |
| CCCS-02.a | backlog | CCS+ guidance distinguishes Calendar Sync credentials from CCS login credentials and explains enabling CCS+. | — |
| CCCS-02.b | backlog | CCS+ setup is available directly with the source when it needs configuration, rather than only in Settings. Successful credential saving returns to that source. | — |
| CCCS-02.c | backlog | Missing CCS+ credentials are reported as Setup needed rather than an error, and Sync now is unavailable until credentials are entered. The message shown is msg:enterYourCcsUsernameAnd, and no download is attempted until the credentials are entered. | — |
| CCCS-02.d | backlog | Credentials are labeled Username. | — |
| CCCS-02.e | backlog | Changing the CCS+ username while leaving the password blank keeps the saved password. | — |
| CCCS-02.f | backlog | An invalid CCS+ username is refused with a username error. The username is trimmed and has the length and characters in DEF-01; the refusal reads msg:enterYourUsernameLetters. | — |
| CCCS-02.g | backlog | The saved CCS+ password is protected (ACC-05); the page shows the saved username and explains how to keep its password. | — |
| CCCS-02.h | backlog | Saved CCS+ credentials are used for the next download. | — |
| CCCS-02.i | backlog | Rejected CCS+ credentials show a failure reason beside the credential fields; successful verification reports Validated. Editing the credentials removes stale validation or rejection feedback. | — |
| CCCS-02.j | backlog | Credential saving reports saving/verification progress and a saved acknowledgement before successful validation. Shared save/cancel interaction follows UIC-27; this rule specifies the verification outcome. | — |
| CCCS-02.k | backlog | CCS+ setup guidance explains enabling trips as one event and the other calendar options, setting a dedicated Calendar Sync password, and completing the Accomplished checklist. | — |
| CCCS-02.l | proposed (?) | Existing CCS+ credentials can be imported from the old configuration, stored encrypted, and recorded as imported activity. Is this still needed after the port, given that the migration tool (DEP-05) copies the saved credentials? | — |
| CCCS-02.m | backlog | The password has one trailing line break removed; other whitespace is kept as typed. | — |
| CCCS-02.n | backlog | A blank password is refused with msg:enterTheCalendarSyncPassword when no password is saved; a saved password that cannot be read counts as not saved. | — |
| CCCS-02.o | backlog | A password longer than the length in DEF-01 is refused with msg:thatPasswordIsTooLong. | — |
| CCCS-02.p | backlog | Saving the credentials sets the count of rejected sign-ins to 0, discards the stored download validators (CON-06) and records the History entry msg:ccsUsernameAndCalendarSyncSaved. | — |
| CCCS-02.q | backlog | After the credentials are saved, Sync Now starts at once (CON-03) and the page returns to the CCS+ module (CCCS-02.b) after the time in DEF-01. | — |
| CCCS-02.r | backlog | Verifying CCS+ (CON-03) succeeds when the last sign-in succeeded and the status is Healthy. | — |
| CCCS-03 | backlog | CCS+ is downloaded with a browser-like connection when the site's protection requires it. | — |
| CCCS-03.a | backlog | CCS+ downloading offers auto, browser, browser-patient and curl modes, initially auto. | — |
| CCCS-03.b | backlog | In auto mode, an unanswered or blocked CCS+ download tries the browser-like connection, retries with twice the wait, then tries curl. | — |
| CCCS-03.c | backlog | Browser-patient mode makes the number of CCS+ download attempts in DEF-01, each with its response allowance. | — |
| CCCS-03.d | backlog | A CCS+ download follows no more redirects than DEF-01 allows; HTTPS and credential forwarding follow CON-06. | — |
| CCCS-03.e | backlog | The download diagnostic record identifies the connection mode that answered and the modes previously attempted. | — |
| CCCS-03.f | backlog | After the number of rejected CCS+ sign-ins in DEF-01, automatic checks pause until the user corrects the credentials and requests Sync Now. | — |
| CCCS-03.g | backlog | CCS+ is downloaded over HTTPS. | — |
| CCCS-03.h | backlog | A CCS+ download sends the saved Username and password as its sign-in and asks for a calendar reply (content type text/calendar). | — |
| CCCS-03.i | backlog | The connection mode comes from the installation's CCS+ client setting, read without regard to letter case or surrounding spaces; an unknown value means auto (CCCS-03.a). | — |
| CCCS-03.j | backlog | In curl mode a CCS+ download makes one attempt with curl, and in browser mode one attempt with the browser-like client, each with the attempt time limit in DEF-01 and no pause before it. | — |
| CCCS-03.k | backlog | Browser-patient mode pauses before its attempts, and auto mode before its second attempt, as DEF-01 says; auto mode makes the attempts in DEF-01 (browser-like; browser-like with twice the time limit; then curl). | — |
| CCCS-03.l | backlog | A CCS+ attempt has the overall time limit and the connect time limit in DEF-01. | — |
| CCCS-03.m | backlog | When every attempt fails, the error of the last attempt is reported; each failed attempt is logged as a warning naming its client and reason (msg:attemptNoReplyIn, msg:attemptRefused), and when a later attempt answers the log notes msg:ccsDownloadAnsweredAfter ({attempts} lists the attempts). | — |
| CCCS-03.n | backlog | The browser-like client presents the newest browser profile it supports; an attempt fails with msg:browserLikeClientNotInstalled when that client is missing from the installation, and an attempt with curl fails with msg:curlNotInstalled when curl is missing. | — |
| CCCS-03.o | backlog | HTTP 401 from CCS+ is reported as a rejected sign-in with msg:ccsRejectedTheUsernameOr. | — |
| CCCS-03.p | backlog | A CCS+ silent hold is reported as msg:connectedToButItSent2; a link that is not https, too many redirects and a reply over the size limit are reported as msg:theCalendarSyncLinkMust3, msg:redirectedTooManyTimesCheck and msg:sentMoreThan5Mb. | — |
| CCCS-03.q | backlog | Each rejected CCS+ sign-in adds 1 to the count of rejected sign-ins and a successful download, including a not-modified answer (CON-06), sets it to 0; a block, a silent hold or any other error leaves it unchanged. | — |
| CCCS-03.r | backlog | While automatic checks are paused (CCCS-03.f) the status is msg:paused with the message msg:automaticDownloadsPausedUsername ({n} is the count of rejected sign-ins). | — |
| CCCS-04 | backlog | A CCS+ import keeps its source identifiers and its full-day times. | — |
| CCCS-04.a | backlog | CCS+ import preserves the source event identifiers and details; event times follow TIM-01–TIM-06 and normalization follows RUL-06. | — |
| CCCS-04.b | backlog | When CCS+ full-day times are normalized, the original times remain available in the event notes. | — |
| CCCS-05 | backlog | The user can upload a CCS+ schedule instead of downloading it. | — |
| CCCS-05.a | backlog | Upload & publish for CCS+ replaces the downloaded schedule with the uploaded schedule. | — |
| CCCS-05.b | backlog | Successful upload ends the source’s setup-needed configuration state. | — |
| CCCS-05.c | backlog | An uploaded file larger than the download size in DEF-01 is refused with msg:thatFileIsTooLarge. | — |
| CCCS-05.d | backlog | An uploaded file whose first bytes (the length in DEF-01) lack the calendar start BEGIN:VCALENDAR is refused with msg:thatFileIsnTA; {snippet} is its first characters (the length in DEF-01) or msg:itSEmpty. | — |
| CCCS-05.e | backlog | An accepted upload is published like a download with the wording msg:uploadedByHand, discards the stored download validators and records the attempt time. | — |
| CCCS-05.f | backlog | A rejected upload is recorded in History as msg:uploadRejected ({error} is the refusal). | — |
| CCCS-06 | backlog | The user can change the Calendar Sync link that CCS+ is downloaded from. | — |
| CCCS-06.a | backlog | The default link is https://ccsplus.ual.com/calendarsyncapi/api/Calendar/GetCalendar; saving an empty link or the default link deletes the saved link, and a saved link takes priority over the installation's CCS+ link setting. | — |
| CCCS-06.b | backlog | A link that does not start with https:// or has no host is refused with msg:theCalendarSyncLinkMust. | — |
| CCCS-06.c | backlog | Saving a changed link discards the stored download validators, sets the count of rejected sign-ins to 0, starts a download and records History msg:calendarSyncLinkSetTo ({where} is the host and path). | — |
| CCCS-06.d | backlog | A reset action deletes the saved link, sets the count of rejected sign-ins to 0, starts a download and records History msg:calendarSyncLinkResetTo. | — |
