# Requirements: Google plugin (API client)

The Google plugin: the access to Google that every Google connection requires. Common plugin rules are in plugins.md.
Terms: the **API client** is the Google client the user creates once in Google Cloud.

| ID | status | statement | test |
|---|---|---|---|
| PGAP-01 | backlog | The user sets up access to Google once, with their own Google client, and is guided through it. | — |
| PGAP-01.a | backlog | Until the API client is set up and accepted (CON-01.b), connecting is unavailable and setup guidance is offered. | — |
| PGAP-01.b | backlog | Client setup requires a well-formed client ID and an initial secret. Invalid or missing values are identified. | — |
| PGAP-01.c | backlog | Changing the Google client ID with the secret left blank keeps the previous secret; secrets are protected as in ACC-05. | — |
| PGAP-01.d | backlog | Removing the API client clears the configured and connected state and returns setup to Not set up; its effect on Google connections is CGOW-01.r. | — |
| PGAP-01.e | backlog | The Google client cannot be changed while an account is connected, because the sign-in belongs to that client; the user disconnects first (removing the client disconnects its accounts, PGAP-01.d). | — |
| PGAP-01.f | backlog | Saved refresh credentials, the client secret and pending sign-in verifiers are protected as ACC-05 says. | — |
| PGAP-01.g | backlog | Client checking distinguishes accepted credentials, rejected secrets, unknown client IDs and an unreachable service; unreachable is not reported as invalid credentials. | — |
| PGAP-01.h | backlog | Without an explicit public address, setup derives the callback from the request host; unsupported public IP/local-host addresses do not advertise an unusable callback and instead request public-address setup. Public-address rules: SET-04. | — |
| PGAP-01.i | backlog | A missing authorized redirect is reported separately from client acceptance and supplies the exact callback to authorize. Changing the public address invalidates stale address feedback. | — |
| PGAP-01.j | backlog | Setup provides the callback address and ordered guidance through the Google project, API, consent screen and client, and for redirect mismatch, denied access and invalid client errors. It tells the user to publish the OAuth app or add the signing-in account as a test user, covers a deleted client and repeated reconnection from an app left in testing, and uses the saved support email or asks for the user's Gmail support email. | — |
| PGAP-01.k | backlog | Guided Google setup confirms that the callback is authorized before continuing to consent. | — |
| PGAP-01.l | backlog | Google setup provides a copyable assisted-setup request and a guided route through the required provider configuration. | — |
| PGAP-01.m | backlog | Changing or adding a domain or the public address, with the API client already set up, shows a notice pointing at the Google plugin's setup guidance, since the API always becomes unhealthy. | — |
| PGAP-02 | backlog | Failures of Google's service are retried and reported honestly, whichever connection is affected. | — |
| PGAP-02.a | backlog | An expired access credential is refreshed and the call retried once; if that does not recover it, the next try is at the next scheduled synchronization and the page reports that timing. Revoked consent or a permission refusal requires reauthorization without an automatic retry. | — |
| PGAP-02.b | backlog | Transient failures, including rate limits, are retried with a wait that starts at the first wait in DEF-01, doubles each attempt up to the longest wait, is randomized upward by the jitter in DEF-01, and stops after the number of attempts in DEF-01; a longer wait asked for by the server (Retry-After) is honored. | — |
| PGAP-02.c | backlog | A missing calendar pauses recovery rather than retrying at once; an invalid event or a conflict does not make the account unhealthy. An unknown or unexpected failure is reported as unknown (degraded), never as success, and gets one automatic retry. | — |
| PGAP-02.d | backlog | Upstream Google refusals preserve Google’s explanation in diagnostic feedback. | — |
| PGAP-01.n | backlog | A client ID is trimmed before it is checked; it is valid when it has the length and characters in DEF-01 (Google client ID); any other value is refused with msg:thatDoesnTLookLike. | — |
| PGAP-01.o | backlog | A client secret is trimmed; one longer than the length in DEF-01 or containing whitespace is refused with msg:thatDoesnTLookLike2. | — |
| PGAP-01.p | backlog | A blank secret is refused with msg:enterTheClientSecretToo when none is saved; a saved secret is never shown again. | — |
| PGAP-01.q | backlog | A saved secret that cannot be decrypted reads as blank. | — |
| PGAP-01.r | backlog | The API client counts as configured when both its ID and its secret are not empty. | — |
| PGAP-01.s | backlog | Saving a new client clears the cached access credential and the error shown on the first account. | — |
| PGAP-01.t | backlog | Saving a client records History msg:googleOauthClientSavedShort, where {id} is the start of the client ID before its first period, cut to the length in DEF-01 (Client ID characters shown in History). | — |
| PGAP-01.u | backlog | Removing the client is the trash icon at the end of the credentials row and asks first (UIC-31). | — |
| PGAP-01.v | backlog | Adding a Google connection, making an invitation and pressing Connect while the API client is not set up are refused with msg:googleNeedsApiSync. | — |
| PGAP-01.w | backlog | One client serves the whole installation; the setup guide says how many people can sign in through it while the app is unverified (DEF-01) and ends with Google's error list and what fixes each. | — |
| PGAP-01.x | backlog | Report a problem says whether Google is connected and leaves out the client ID, credentials and secrets (DIA-02.c, ACC-05). | — |
| PGAP-02.e | backlog | A refusal for an expired access credential drops the cached one and retries at once when the credential was issued longer ago than the margin in DEF-01 (Google access credential margin). | — |
| PGAP-02.f | backlog | When every attempt fails, the user is told msg:googleCalendarIsBusySuitestream and the failure counts as transient. | — |
| PGAP-02.g | backlog | A conflict answer is reported at once and is not retried. | — |
| PGAP-02.h | backlog | Any other refusal is reported as msg:googleCalendarAnsweredTo ({code} the status, {reason} the first reason in Google's error list, {request} the method and path); Google's message parts are joined and cut to the length in DEF-01, the status is carried with the failure and the start of Google's answer, to the length in DEF-01, is logged. | — |
| PGAP-02.i | backlog | Every call to Google gives up after the time limits in DEF-01 (Google call time limits). | — |
| PGAP-02.j | backlog | A call that cannot reach Google is reported as msg:couldnTReachGoogleCalendar ({error} the kind of failure); revoked consent as msg:googleNoLongerAcceptsSuitestream2. | — |
| PGAP-02.k | backlog | A failure is classified as one kind: token expired, consent revoked, rate limit, transient, permission, calendar missing, event invalid, conflict or unknown; the first matching rule wins. | — |
| PGAP-02.l | backlog | Classification rules: revoked consent is consent revoked; a missing calendar is calendar missing; a conflict is conflict; an error that is not Google's is unknown; otherwise by Google's status: 401 token expired, 403 or a rejected client permission, 429 rate limit, 404 or 410 calendar missing, 409 conflict, 5xx or a transient failure transient, 400 event invalid, anything else unknown. | — |
| PGAP-02.m | backlog | A failed synchronization is not tried a second time inside the same run, because the calls were already retried. | — |
| PGAP-02.n | backlog | History gets one line for each new problem, not one at every retry. | — |
| PGAP-03 | backlog | Setup checks the client and the callback address with Google and remembers each answer. | — |
| PGAP-03.a | backlog | Each check stores whether it passed (yes, no or unknown), its message, its time (UTC), the callback address used and whether Google lists that address (yes, no or unknown). | — |
| PGAP-03.b | backlog | The address check sends Google a sign-in request that it does not follow, carrying the client ID, the callback address, offline access, forced consent and an S256 challenge. | — |
| PGAP-03.c | backlog | An answer that names an invalid, deleted or unauthorized client gives the verdict unknown. | — |
| PGAP-03.d | backlog | An answer that succeeds or redirects to anywhere but Google's sign-in error page gives the verdict listed; any other answer, or no answer, gives unknown. | — |
| PGAP-03.e | backlog | The verdict is saved with the last check, keeping that check's result and message. | — |
| PGAP-03.f | backlog | The callback address is the public address followed by /google/callback and must be listed exactly in the client's authorized redirect addresses. | — |
| PGAP-03.g | backlog | A callback address is acceptable when it is https with a host that is not a bare IP address and does not end in .local, or when its host is localhost or 127.0.0.1 with any scheme. | — |
| PGAP-03.h | backlog | A public address whose host differs from the host the page is open at, other than localhost, 127.0.0.1 or an IP address, is reported with msg:yourPublicAddressIsBut ({public}, {here}), to catch typing mistakes. | — |
| PGAP-04 | backlog | Connect runs four steps in order, shows each in its status box and stops at the first that fails, naming the fix. | — |
| PGAP-04.a | backlog | The steps are save, client, address and go; their working words are msg:googleStepSaving, msg:googleStepChecking and msg:googleStepCheckingAddress, and a finished step shows msg:healthy (UIC-28). | — |
| PGAP-04.b | backlog | Step save stores a typed client ID that differs from the saved one and any typed secret (PGAP-01.n); when the client is still not configured it stops with msg:googleClientValuesNeeded and shows the guide. | — |
| PGAP-04.c | backlog | Step client stops with msg:googleClientFix ({message} the check's message) and opens Google Cloud's client page when the client is not accepted; when the verdict is unknown it stops showing the check's message, or msg:googleCouldntCheckClient, and offers to try again. | — |
| PGAP-04.d | backlog | Step address stops with msg:googlePublicAddressFix when the callback address is not acceptable (PGAP-03.g). | — |
| PGAP-04.e | backlog | When Google does not list the callback address, step address records a warning in History with msg:googleRedirectNotListed ({uri}) and stops with msg:googleAddressNotOnClient ({uri}), offering Copy and Open. | — |
| PGAP-04.f | backlog | Step address passes when the verdict is listed or unknown; it is confirmed when the verdict is listed. | — |
| PGAP-04.g | backlog | Step go records History msg:googleApiSyncSetUp and one line (msg:googleNameText, {text} the readiness text of CGOW-06.e) for each Google connection that is not working, as a warning when it has synced before and as information when it has not; it starts no sign-in. | — |
| PGAP-04.h | backlog | A step name that is not one of the four is refused with msg:googleUnknownStep. | — |
| PGAP-05 | backlog | The access credential is obtained, kept and renewed so that every call to Google can use it. | — |
| PGAP-05.a | backlog | A credential request that cannot reach Google fails as transient with msg:couldnTReachGoogle ({error}); it succeeds when Google answers success with an access credential. | — |
| PGAP-05.b | backlog | When Google rejects the client the failure reads msg:googleRejectedTheOauthClient; when it says the redirect address is not authorized, msg:googleSaysTheRedirectUri; any other error reads msg:googleSignInFailed ({error} Google's error or the status). | — |
| PGAP-05.c | backlog | An access credential is reused until the margin in DEF-01 before it expires and then renewed with the refresh credential; simultaneous requests share one renewal. | — |
