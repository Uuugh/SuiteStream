# Requirements: Google one-way sync

A Google connection: a Google calendar destination with its own account that SuiteStream publishes to. Common connection rules are in connections.md; the Google plugin is plugins.d/google_api.md.

| ID | status | statement | test |
|---|---|---|---|
| CGOW-01 | proposed | Each Google connection signs in with its own Google account, and the user can invite someone else to sign in. | — |
| CGOW-01.a | proposed | Google consent requests use the public callback address and request explicit consent. | — |
| CGOW-01.b | proposed | Successful consent connects the selected account, identifies its email and clears an earlier sign-in error. | — |
| CGOW-01.c | proposed | A consent state is single-use, belongs to its account and expires after the time in DEF-01; an expired, unknown, reused or other-account state is not accepted. | — |
| CGOW-01.d | proposed | Refused calendar permission leaves the account disconnected and explains how to grant permission; cancelled sign-in reports cancellation. Successful later consent clears the error. | — |
| CGOW-01.e | proposed | Different Google accounts receive separate account identities and calendar mappings. | — |
| CGOW-01.f | proposed | Revoked sign-in requires connecting again. A credential that cannot be decrypted after changing the database password reports that configuration cause. | — |
| CGOW-01.g | proposed | A new Google connection starts with its own unconnected account; it does not silently use another connection’s account or create a remote calendar before its own sign-in. | — |
| CGOW-01.h | proposed | A connection can invite another person to connect it: the invite identifies the connection, and successful consent connects that invited account without changing another account’s assignment. | — |
| CGOW-01.i | proposed | An invitation is single-use, can be withdrawn and expires after the time in DEF-01; a consumed, withdrawn, expired or invented link is not accepted. | — |
| CGOW-01.j | proposed | Inviting a replacement account does not change the current connection assignment while consent is pending; withdrawing it keeps the original assignment. | — |
| CGOW-01.k | proposed | Connect me can sign a new connection into the user’s account. Removing a same-account connection does not revoke access still used by another connection; removing a separately invited account revokes its credentials. | — |
| CGOW-01.l | proposed | A connection not yet synchronized does not claim Last synced; a failed sign-in offers a way to reconnect. | — |
| CGOW-01.m | proposed | Google sign-in requests offline access with an S256 challenge; pending sign-in requests are bounded (DEF-01) and persist across API instances using the same storage. | — |
| CGOW-01.n | proposed | Google sign-in accepts an account email only from a verified Google identity issued for this app's client. | — |
| CGOW-01.o | proposed | Pending invitation consent remains usable across an app restart until it is consumed or expires. | — |
| CGOW-01.p | proposed | Google authorization requests the app-created-calendar scope and email identity, limiting calendar access to calendars created by this app. | — |
| CGOW-01.q | proposed | After connection consent completes, the user returns to the destination involved in that consent. | — |
| CGOW-01.r | proposed | When the API client is removed (PGAP-01.d), the Google accounts are disconnected with their remote calendars kept, and the page reports that each Google connection needs its account restored after the client is set up again. | — |
| CGOW-01.s | proposed | Repeating a Google setup submission does not create duplicate or orphan connections. | — |
| CGOW-02 | proposed | Connecting a connection creates or reuses its Google calendar, which holds only what the connection publishes. | — |
| CGOW-02.a | proposed | Connection creates a calendar named for the destination, using the calendar’s configured time zone. | — |
| CGOW-02.b | proposed | Reconnecting the same account reuses its retained calendar rather than creating a duplicate, preserving its synchronized event set. | — |
| CGOW-02.c | proposed | Disconnecting without deleting revokes access and clears connection while keeping the remote calendar and its remembered mapping. | — |
| CGOW-02.d | proposed | Disconnecting with deletion removes the remote calendar, forgets its mapping and clears synchronization tracking. | — |
| CGOW-02.e | proposed | Removing a Google destination can keep its remote calendar while clearing its local mapping, or delete that remote calendar. | — |
| CGOW-02.f | proposed | Connecting a different client creates a new mapping without repeatedly recreating it, leaving the unreachable former calendar for manual cleanup. | — |
| CGOW-02.g | proposed | After first calendar creation, opening it waits for synchronization and then opens Google Calendar for the correct account. The setup action is no longer offered once shown; ordinary feeds do not support this action. | — |
| CGOW-02.h | proposed | Concurrent consent completion and synchronization reuse the same remote calendar mapping rather than creating duplicates. | — |
| CGOW-02.i | proposed | Renaming a destination updates the existing Google calendar’s name. | — |
| CGOW-02.j | proposed | The initial default Google publication window starts on the first day of the current month. | — |
| CGOW-02.l | proposed | Each Google destination publishes only its selected sources; a combined destination may include multiple sources. | — |
| CGOW-02.m | proposed | Connecting requests a full synchronization; initial synchronization publishes eligible nonhidden events in the configured window. | — |
| CGOW-03 | proposed | The events published to Google keep their time, title, reminders and color as the app shows them. | — |
| CGOW-03.a | proposed | Google sync follows the common time rules (TIM-01 to TIM-07): it reads the time zone of the Google calendar and of each incoming event and records it with the event, and it sends each event's recorded time zone. A stored all-day event is sent to Google as an all-day event for its stored time zone, so it shows on the right days in Google Calendar. | — |
| CGOW-03.b | proposed | The busy or free state of an event is kept when it is published. | — |
| CGOW-03.c | proposed | Google events retain source titles and indicate that SuiteStream synchronized them. | — |
| CGOW-03.d | proposed | A Google event carries the reminders of CON-09.b with Google's default reminders disabled. | — |
| CGOW-03.e | proposed | An event without a color rule does not force a Google event color. Color rules apply the corresponding Google color (UIC-20). | — |
| CGOW-03.f | proposed | The Google calendar follows its connection’s selected calendar color when the upstream service accepts it. | — |
| CGOW-03.g | proposed | If a calendar color cannot be applied, the connection explains that the color does not carry to Google; repeating the same color does not retry it, and selecting a different accepted color applies it and clears the note. A color request that could not reach Google is not remembered as refused. | — |
| CGOW-03.h | proposed | A meeting link appears before the notes in the Google description (CON-09.c), and is not copied back into the notes when the event is read from Google. | — |
| CGOW-04 | proposed | Events published to Google are kept in step with SuiteStream: a change made here reaches Google. | — |
| CGOW-04.k | proposed | Google one-way sync is a feed: it publishes events to Google and does not read them back. | — |
| CGOW-04.a | proposed | An unchanged normal or full synchronization performs no event writes; editing an event schedules synchronization and updates the remote event. | — |
| CGOW-04.b | proposed | A normal synchronization does not inspect Google’s event copy; full checks reconcile Google changes. | — |
| CGOW-04.c | proposed | A full check removes obsolete SuiteStream-owned remote events while keeping handmade remote events eligible for import. | — |
| CGOW-04.d | proposed (?) | Advancing the synchronization window leaves past remote events alone while dropping obsolete tracking; extending it backward can republish eligible events. The backward-extension check is permissive: what exact write behavior should be guaranteed? | — |
| CGOW-04.e | proposed (?) | If the remote calendar is deleted, synchronization recreates it with a new mapping and publishes eligible events. How does this automatic repair interact with the later missing-calendar paused recovery policy? | — |
| CGOW-04.f | proposed | Sync Now requests a full check. | — |
| CGOW-04.g | proposed | One-way sync restores a remote-deleted local event rather than hiding it locally; two-way sync is CGTW-01. | — |
| CGOW-04.h | proposed | When a write budget prevents completing remote cleanup in one sync, remaining work continues at the next full sync. | — |
| CGOW-04.i | proposed | Synchronization resumes after the database becomes available following a restart. | — |
| CGOW-04.j | proposed (?) | Eligible local changes and valid remote change notices trigger reconciliation within seconds under normal service availability. What measurable latency target should replace “within seconds”? | — |
| CGOW-05 | proposed | Google tells the app about changes at once, so they do not wait for the next scheduled check. | — |
| CGOW-05.a | proposed | Instant updates start with synchronization. Registering them uses the HTTPS public notification address and the selected calendar; they need HTTPS and have the lifetime in DEF-01. | — |
| CGOW-05.b | proposed | Notifications with a wrong token or unknown channel are acknowledged and ignored; a channel sync message does not trigger a check. | — |
| CGOW-05.c | proposed | A valid change notification requests a full check without a page login; processing it records the last notice time and retains Google edits locally. | — |
| CGOW-05.d | proposed | A change-notification watch is renewed the time in DEF-01 before it expires and the old one stopped; a fresh watch is reused, and a changed public address replaces the target rather than accumulating watches. | — |
| CGOW-05.e | proposed | Refused instant updates report the reason without preventing ordinary autosync; a later successful retry clears the error. After a refusal the retry waits the time in DEF-01. | — |
| CGOW-05.f | proposed | Disconnecting stops the instant-update channel, and a notice that arrives late is still acknowledged. | — |
| CGOW-06 | proposed | Each account's health is shown clearly, and a failure never turns into a false success. | — |
| CGOW-06.a | proposed | Revoked access is shown as an error rather than successful sync. | — |
| CGOW-06.b | proposed | Disconnected connections remain Not connected and are skipped without turning the whole sync into an error. | — |
| CGOW-06.c | proposed | A color-update failure does not stop event synchronization or falsely report that sign-in was lost. | — |
| CGOW-06.d | proposed | A transient server failure degrades only the affected account and defers its next sync; a skipped degraded account does not fail the whole job. An explicit health reset permits syncing again. | — |
| CGOW-06.e | proposed | Readiness distinguishes missing client, signed-out account, API error, not-yet-synced account and successful sync; a nonempty error overrides prior success, while an empty error does not. | — |
| CGOW-06.f | proposed | Successful recovery, or a new successful sign-in, restores the healthy state and clears the retry count, keeping the account's calendar mappings and settings. New accounts start healthy and eligible to sync. | — |
| CGOW-06.g | proposed | A saved health error is shown in full; a line that is too long for its space follows the clipping rule (UIC-14, UIC-07). | — |
| CGOW-06.h | proposed | Each account’s recorded health and retry deadline persist across an app restart. | — |
| CGOW-01.t | proposed | The accounts in use are the first account and the account of each Google connection, without duplicates, the first account first. | — |
| CGOW-01.u | proposed | Each account keeps its refresh credential, email, time connected, last synchronization and its result, last error and the calendars of its connections. | — |
| CGOW-03.i | proposed | The nearest of Google's event colors to a color is the one with the least squared difference in red, green and blue; a tie goes to the first in the order of THM-09.a. | — |
| CGOW-05.g | proposed | Registering a watch uses the notification address (the public address followed by /google/notify), a random channel identifier and a random token of the sizes in DEF-01, and asks for the lifetime in DEF-01. | — |
| CGOW-05.h | proposed | A stored channel keeps its identifier, Google's resource identifier, its token encrypted (ACC-05), its address, its calendar, its expiry (Google's, else now plus the requested lifetime), the time it was last tried and the last notice received. | — |
| CGOW-05.i | proposed | The notification address is empty when the public host is localhost, 127.0.0.1 or ends in .local, and no watch is registered. | — |
| CGOW-05.j | proposed | Channels are checked after each connection's synchronization when its account is connected and a notification address exists; a connection with no calendar records the attempt and starts nothing. | — |
| CGOW-05.k | proposed | A failure to start instant updates records a warning in History once with msg:googleInstantUpdatesArenT ({error}) and is not repeated for the same error; the first success records msg:googleInstantUpdatesTurnedOn. | — |
| CGOW-05.l | proposed | A notification is accepted when its channel identifier and token match the stored channel; the token is compared in constant time and a stored token that cannot be decrypted never matches. | — |
| CGOW-05.m | proposed | The connection shows instant updates off with msg:needsAPublicHttpsAddress, off with the stored error as the reason (msg:instantUpdatesFromGoogleOff, {why}), on with msg:lastNoticeFromGoogle ({when}) once a notice arrived (msg:instantUpdatesFromGoogleOn), or msg:startsWithTheNextSync before the first synchronization. | — |
| CGOW-05.n | proposed | The status line reads msg:nextPushInstantaneous when instant updates are on and msg:instantUpdatesOffShort when off, with tooltips msg:instantTipOn and msg:instantTipDaily. | — |
| CGOW-06.i | proposed | Each account's health holds its state (healthy, degraded, recovering, reauthorization required or paused), the failure kind, a reason, the number of attempts, the next retry time and the last error (cut to the length in DEF-01) with its time. | — |
| CGOW-06.j | proposed | A failure adds one attempt when the decision is to retry, and sets the next retry to now plus the wait when the decision retries and the wait is not zero. | — |
| CGOW-06.k | proposed | The states recovering, paused and reauthorization required are set only by the recovery decisions; health belongs to the account, not to a connection. | — |
| CGOW-06.l | proposed | A connection whose account is not connected shows msg:invited when an invitation exists and msg:notConnected otherwise; one with an error shows msg:syncProblem (bad when the error begins with msg:googleSyncFailed, a warning otherwise); a synchronized one shows msg:connected; a new one shows msg:starting. | — |
| CGOW-06.m | proposed | A connection whose error says the sign-in failed shows msg:signInFailedStatus with a msg:fixButton button that restarts that account's sign-in. | — |
| CGOW-06.n | proposed | A synchronization failure is logged at error when its text differs from the account's previous last error; an unexpected failure reads msg:googleSyncFailed with {error} the kind and the message. | — |
| CGOW-07 | proposed | Connect and the return from Google complete the sign-in and report every outcome. | — |
| CGOW-07.a | proposed | Connect is refused with msg:saveTheGoogleOauthClient when no client is saved and with msg:setThePublicAddressSettings when no usable public address is set. | — |
| CGOW-07.b | proposed | A sign-in request carries a random state and a random verifier of the sizes in DEF-01 (Google sign-in random values); the verifier is stored encrypted (ACC-05). | — |
| CGOW-07.c | proposed | Pending sign-ins older than the time in DEF-01 are dropped first; when the limit in DEF-01 is reached the oldest is removed to make room. | — |
| CGOW-07.d | proposed | An unknown, expired or already used state is reported as msg:thisGoogleSignInHas. | — |
| CGOW-07.e | proposed | The returned code is exchanged with the same callback address, the sign-in's verifier and the client's ID and secret. | — |
| CGOW-07.f | proposed | An exchange that returns no refresh credential fails with msg:googleDidnTSendA. | — |
| CGOW-07.g | proposed | A new email that differs from the account's stored email clears the account's stored details and calendars. | — |
| CGOW-07.h | proposed | On success the refresh credential is stored encrypted, the client check is saved as accepted and listed (PGAP-03.a) and the access credential is cached until the margin in DEF-01 before it expires. | — |
| CGOW-07.i | proposed | History records msg:googleCalendarConnectedAsCalendar or msg:googleCalendarConnectedAsCalendar2 for each connection of the account ({email} the account's email or msg:yourAccount, {calendar} its calendar). | — |
| CGOW-07.j | proposed | A failed sign-in is stored as the account's last error and logged at error as msg:google ({text} the message). | — |
| CGOW-07.k | proposed | The return from Google needs the page login when its state belongs to a normal sign-in; an invitation sign-in return needs none (CGOW-08.g). | — |
| CGOW-08 | proposed | An invitation lets another person sign a Google account in for one connection. | — |
| CGOW-08.a | proposed | An invitation is made only for a Google connection while the API client is set up; its token is random with the size in DEF-01; a connection has one live invitation and a new one replaces the old. | — |
| CGOW-08.b | proposed | Making an invitation records History msg:googleInviteMade ({name} the connection, {days} the lifetime in DEF-01 in days); withdrawing it records msg:googleInviteWithdrawn. | — |
| CGOW-08.c | proposed | An invitation link is valid when its token has the length in DEF-01, the invitation is live and the connection still exists on the account the invitation was made from; any other link shows msg:googleInviteUnavailable. | — |
| CGOW-08.d | proposed | The invitation page is titled msg:calendarInvite, shows msg:youAreInvitedToGet ({name} the connection), a msg:continueWithGoogle button and msg:googleInviteSignInNote. | — |
| CGOW-08.e | proposed | Continuing needs the token the invitation page issued; a missing or wrong token shows msg:googleInvitePageExpired. | — |
| CGOW-08.f | proposed | Continuing shows msg:googleInviteCantSignIn when the API client is not set up or the callback address is not acceptable. | — |
| CGOW-08.g | proposed | An invitation sign-in is remembered for the time in DEF-01, at most the number in DEF-01, the oldest dropped first; its return needs no page login. | — |
| CGOW-08.h | proposed | A cancelled or failed invitation sign-in shows msg:googleInviteCancelled. | — |
| CGOW-08.i | proposed | A successful invitation sign-in records History msg:googleConnectedThroughInvite ({name}, {email} or msg:googleInvitedAccount), shows msg:calendarNowInYourGoogle and runs a full synchronization. | — |
| CGOW-09 | proposed | Moving a connection between accounts and disconnecting one leave every other account as it was. | — |
| CGOW-09.a | proposed | Back on the first account puts the connection on the first account, records History msg:googleBackOnFirstAccount and requests a full synchronization. | — |
| CGOW-09.b | proposed | Disconnecting a connection on the first account gives it a new unconnected account; the first account and every other connection stay signed in. | — |
| CGOW-09.c | proposed | A disconnection runs while no synchronization runs, stops the connection's instant-update channel and keeps its calendar; Google's grant is revoked when no other connected account uses the same Gmail address (compared without regard to letter case). | — |
| CGOW-09.d | proposed | History records msg:googleCalendarDisconnected, msg:googleCalendarDisconnected2 or their calendar-deleted forms (msg:googleCalendarDisconnectedAndIts, msg:googleCalendarDisconnectedAndIts2), as a warning when there are notes and as information otherwise. | — |
| CGOW-09.e | proposed | Revoking posts the refresh credential to Google; a success or an already revoked grant is accepted, and otherwise the note is msg:googleDidnTConfirmRemoving ({code}) or msg:couldnTReachGoogleTo2; a calendar that could not be deleted adds msg:theCalendarWasnTDeleted ({error}). | — |
| CGOW-09.f | proposed | Disconnect for the first account in Settings stops every channel, offers msg:alsoDeleteThisCalendarIn, forgets each event's per-event state when the calendars are deleted and records its History line. | — |
| CGOW-10 | proposed | A connection's calendar color reaches Google by the first way Google accepts. | — |
| CGOW-10.a | proposed | The ways are tried in order: the RGB color (with a white foreground), the nearest of Google's calendar colors (DEF-01, Google calendar colors), and a full replacement of the calendar's list entry; the way accepted last is tried first. | — |
| CGOW-10.b | proposed | The nearest calendar color is the one with the least squared difference in red, green and blue. | — |
| CGOW-10.c | proposed | The full replacement starts from Google's copy of the entry without its color identifier, tag and kind, marked selected and not hidden, with RGB colors turned on. | — |
| CGOW-10.d | proposed | Only a refusal by Google moves to the next way; an unreachable, busy or revoked answer stops at once; the refusals are joined with "; ". | — |
| CGOW-10.e | proposed | History records msg:googleColorSet ({who} the connection, {how} a space and the way: msg:googleColorWayRgb, msg:googleColorWayNearest ({color} the calendar color used) or msg:googleColorWayFull, followed by msg:googleColorWayKept when the way differs from the one kept before). | — |
| CGOW-11 | proposed | Each synchronization writes what changed to Google and reports it. | — |
| CGOW-11.a | proposed | A calendar that Google reports gone, or refuses because another client made it, is made again; any other failure fails the synchronization. | — |
| CGOW-11.b | proposed | A stored calendar that differs from the last synchronized one drops all per-event state and runs a full synchronization. | — |
| CGOW-11.c | proposed | A connection that is switched off is skipped by every synchronization. | — |
| CGOW-11.d | proposed | A Google event's identifier is the lower-case base32hex of the SHA256 digest of the event's UID without padding; its status is confirmed and it carries private properties marking SuiteStream and holding the UID cut to the length in DEF-01. | — |
| CGOW-11.e | proposed | A Google event has Google's default reminders off and the event's reminders as popups, earliest first, at most the number in DEF-01 (Reminders per event). | — |
| CGOW-11.f | proposed | Each event's hash of its body (keys sorted) is stored with its end, Google identifier and Google's updated time. | — |
| CGOW-11.g | proposed | Each event's result is added, updated (content changed), repaired (the Google copy was deleted or changed by hand) or unchanged. | — |
| CGOW-11.h | proposed | A known event is replaced at its fixed identifier and is inserted when Google no longer has it; a new event is inserted and is replaced when Google already has it, reviving a deleted one; no event is ever duplicated. | — |
| CGOW-11.i | proposed | A synchronization makes at most the writes in DEF-01 (Google writes per connection per sync); the rest wait for the next and the History line reads msg:moreAtTheNextSync. | — |
| CGOW-11.j | proposed | The summary joins msg:added2, msg:updated2, msg:removed and msg:repaired with commas, leaving out zero counts, then msg:calendarRenamed when the calendar was renamed, or reads msg:noChanges. | — |
| CGOW-11.k | proposed | History records msg:googleNameText ({name} the connection, {text} the summary and any notes) when something changed or there are notes. | — |
| CGOW-11.l | proposed | A completed synchronization stores the connection's last synchronization time and event count and the account's last synchronization and result, and clears the last error. | — |
| CGOW-11.m | proposed | A Google copy counts as changed when it is missing, cancelled or its updated time differs from the last write; with no stored time the tolerance in DEF-01 (Google copy changed tolerance) applies. | — |
| CGOW-12 | proposed | A background job keeps the connections synchronized. | — |
| CGOW-12.a | proposed | The job runs at start with a full check, when a change wakes it, and at least as often as the full-check interval in DEF-01 (Google job timing). | — |
| CGOW-12.b | proposed | After a wake-up the job waits the settle time in DEF-01 so bursts of changes become one run, and the wait for the next run is never shorter than the minimum in DEF-01. | — |
| CGOW-12.c | proposed | An unexpected exception is logged and counts as a failed run; the job continues. | — |
| CGOW-12.d | proposed | One synchronization or disconnection runs at a time; a run covers all connections account by account and does nothing when no client is saved or no connection exists. | — |
