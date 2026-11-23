# Requirements: account

Terms used below (defined once):
- **Authentik**: the identity provider in the stack (DEP-06.a). It owns the sign-in: user names, passwords, password rules, lockout, recovery and remembered devices. SuiteStream signs users in through it (an OpenID Connect sign-in) and never sees or stores a sign-in password.
- **App session**: the session SuiteStream keeps in the browser after Authentik has signed the user in (ACC-02.d).
- **Address**: the visitor's network address as reported by a trusted proxy (DEP-03).

Test cells that name `server/test/server_test.dart` are covered by the Dart server tests in `server/` (in-memory store, fake Authentik; the Postgres store and a real Authentik are not tested). Compose files under `docker/` are written but not run, so rows covered only by them keep `—`.

| ID | status | statement | test |
|---|---|---|---|
| ACC-01 | backlog | A new installation is set up by creating the first administrator in Authentik; SuiteStream has no setup code or login of its own. | — |
| ACC-01.a | backlog | Before the first Authentik administrator exists, page and status requests lead to Authentik's initial setup; feed and health endpoints remain accessible. | — |
| ACC-01.e | backlog | After the first administrator is created in Authentik, that user is signed in to SuiteStream through Authentik (ACC-02). | — |
| ACC-01.l | backlog | The first sign-in of a new user through Authentik records a History entry msg:statusPageLoginCreatedFor ({user} is the user name) and renews the form security token (ACC-03.c). | — |
| ACC-02 | backlog | A person signs in through Authentik to see or change anything on the page, and can sign out. | — |
| ACC-02.a | backlog | An unauthenticated page request goes to Authentik's sign-in and does not expose destination content; a successful app session can read the page. Any change to settings, including update settings, requires that signed-in app session. | — |
| ACC-02.b | backlog | SuiteStream accepts a sign-in only when Authentik reports it as successful; a refused one establishes no app session. | server/test/server_test.dart |
| ACC-02.j | backlog | An unauthenticated request that is not a page request (a background request from the page) is answered 401 with msg:signInAgainReloadThePage. | server/test/server_test.dart |
| ACC-02.f | backlog | After sign-in through Authentik the user goes to the page they asked for only when it is a path on this site. A destination that starts with //, contains a backslash, or contains a tab, line break or other control character (browsers drop those, so "/<tab>/other.site" would go to another site) is not followed; the user goes to the home page instead. The query and fragment of a followed destination are kept. | server/test/server_test.dart |
| ACC-02.c | backlog | Signing out ends the app session and the Authentik session; subsequent page requests go to Authentik's sign-in. The status API accepts a token issued by Authentik or authenticated HTTP Basic checked by Authentik. | — |
| ACC-02.d | backlog | A successful sign-in through Authentik establishes an app session valid for the time in DEF-01, and no longer than the Authentik session. | — |
| ACC-02.k | backlog | The app session cookie cannot be read by the page script, is sent only to this site (SameSite lax) and is marked secure when the request arrived over HTTPS, directly or through a trusted proxy. | server/test/server_test.dart |
| ACC-02.l | backlog | App sessions are signed with a random key of the size in DEF-01 kept in the database; a missing or too-short key is replaced by a new one. | — |
| ACC-02.m | backlog | HTTP Basic credentials are passed to Authentik: a correct pair succeeds, a wrong pair is one failed sign-in counted by Authentik (ACC-06), and a request with none counts nothing. | — |
| ACC-02.e | backlog | Login settings identify the signed-in Authentik user and the signed-in state, and link to the user's Authentik account page. | — |
| ACC-03 | backlog | The user changes their login (user name and password) in Authentik, and the change takes effect for every browser. | — |
| ACC-03.d | backlog | When the user changes the password in Authentik, the app sessions of the other browsers end at their next request. | — |
| ACC-05 | backlog | Google client secrets, notification tokens and other stored credentials are protected: stored safely and never exposed; sign-in passwords are held only by Authentik. | — |
| ACC-05.a | backlog | SuiteStream stores no sign-in password; Authentik keeps it only as a one-way hash, never in plaintext. | — |
| ACC-05.b | backlog | A credential the app must send on (the CCS+ password, Google client secret and tokens) is stored encrypted with a key from the database password; after the database password changes they cannot be read until entered again (CGOW-01). | — |
| ACC-05.c | backlog | A secret is never written to a log. | — |
| ACC-05.d | backlog | A secret is shown on a page only when a user who is authorized to see secrets turns on the Show secrets switch in History (HIS-04). | — |
| ACC-09 | backlog | Changes to the page are accepted only from the page itself, and page responses carry basic browser protections. | — |
| ACC-09.a | backlog | Form tokens are tied to the signed-in app session; a mismatched form token is refused and cannot authorize a public-address change. | — |
| ACC-09.b | backlog | Cross-site form changes are refused and leave the saved value unchanged. | — |
| ACC-09.c | backlog | Page responses restrict framing to the same origin, prevent content-type sniffing and suppress referrer disclosure. | — |
| ACC-05.f | backlog | Encrypted credentials use a key derived from the database password and a random salt with the rounds in DEF-01 (Secret encryption); sealing with no database password fails. | — |
| ACC-05.g | backlog | A credential that cannot be decrypted reads as not set: a CCS+ password counts as unset, a Google client secret is empty, and a Google token reports an error text saying it cannot be decrypted. | — |
| ACC-05.h | backlog | A saved secret is never shown again; leaving its field blank keeps the saved one. | — |
| ACC-10 | backlog | The installer configures Authentik with the password policy and the lockout and global-block values in DEF-01 (password requirements, failed-sign-in limits, lock time, recovery link time), so SuiteStream itself checks none of them; they are Authentik settings. | — |
