# Requirements: account

Terms used below (defined once):
- **Authentik**: the identity provider in the stack (DEP-06.a). It owns the sign-in: user names, passwords, password rules, lockout, recovery and remembered devices. SuiteStream signs users in through it (an OpenID Connect sign-in) and never sees or stores a sign-in password.
- **App session**: the session SuiteStream keeps in the browser after Authentik has signed the user in (ACC-02.d).
- **Address**: the visitor's network address as reported by a trusted proxy (DEP-03).

| ID | status | statement | test |
|---|---|---|---|
| ACC-01 | backlog | A new installation is set up by creating the first administrator in Authentik; SuiteStream has no setup code or login of its own. | — |
| ACC-01.a | backlog | Before the first Authentik administrator exists, page and status requests lead to Authentik's initial setup; feed and health endpoints remain accessible. | — |
| ACC-01.b | backlog | Protecting the initial setup (a setup code or a first-run link) is Authentik's job; SuiteStream generates no setup code. | — |
| ACC-01.g | backlog | Accepting the setup code in any letter case, with or without a dash, no longer applies: SuiteStream has no setup code (ACC-01.b). | — |
| ACC-01.h | backlog | Refusing an incorrect setup code is Authentik's job (ACC-01.b); SuiteStream creates no login of its own. | — |
| ACC-01.c | backlog | The installer prints the address of Authentik's initial setup, and the container log repeats it while no administrator exists (DEP-02.d). | — |
| ACC-01.d | backlog | Checking the user name, the password confirmation and the password requirements at setup is Authentik's job (ACC-04). | — |
| ACC-01.e | backlog | After the first administrator is created in Authentik, that user is signed in to SuiteStream through Authentik (ACC-02). | — |
| ACC-01.i | backlog | Generating and expiring a setup code on each start is Authentik's job (ACC-01.b); SuiteStream keeps no setup code in memory. | — |
| ACC-01.j | backlog | The order in which setup checks the code, the user name and the password is Authentik's job (ACC-01.b). | — |
| ACC-01.k | backlog | The initial-setup page is Authentik's own page; SuiteStream shows none. | — |
| ACC-01.l | backlog | The first sign-in of a new user through Authentik records a History entry msg:statusPageLoginCreatedFor ({user} is the user name) and renews the form security token (ACC-03.c). | — |
| ACC-02 | backlog | A person signs in through Authentik to see or change anything on the page, and can sign out. | — |
| ACC-02.a | backlog | An unauthenticated page request goes to Authentik's sign-in and does not expose destination content; a successful app session can read the page. Any change to settings, including update settings, requires that signed-in app session. | — |
| ACC-02.b | backlog | SuiteStream accepts a sign-in only when Authentik reports it as successful; a refused one establishes no app session. | — |
| ACC-02.g | backlog | The sign-in page, its User name and Password fields, Show/Hide and the cursor placement are Authentik's (a login flow of Authentik); SuiteStream shows only a button msg:signInAction that starts the sign-in through Authentik. | — |
| ACC-02.h | backlog | The message for a wrong sign-in, which never says whether the user name or the password was wrong, is Authentik's job; SuiteStream shows msg:signInWrong only when Authentik returns the user with an error. | — |
| ACC-02.i | backlog | A signed-in visitor who opens the sign-in page goes to the page they asked for (ACC-02.f). | — |
| ACC-02.j | backlog | An unauthenticated request that is not a page request (a background request from the page) is answered 401 with msg:signInAgainReloadThePage. | — |
| ACC-02.f | backlog | After sign-in through Authentik the user goes to the page they asked for only when it is a path on this site. A destination that starts with //, contains a backslash, or contains a tab, line break or other control character (browsers drop those, so "/<tab>/other.site" would go to another site) is not followed; the user goes to the home page instead. The query and fragment of a followed destination are kept. | — |
| ACC-02.c | backlog | Signing out ends the app session and the Authentik session; subsequent page requests go to Authentik's sign-in. The status API accepts a token issued by Authentik or authenticated HTTP Basic checked by Authentik. | — |
| ACC-02.d | backlog | A successful sign-in through Authentik establishes an app session valid for the time in DEF-01, and no longer than the Authentik session. | — |
| ACC-02.k | backlog | The app session cookie cannot be read by the page script, is sent only to this site (SameSite lax) and is marked secure when the request arrived over HTTPS, directly or through a trusted proxy. | — |
| ACC-02.l | backlog | App sessions are signed with a random key of the size in DEF-01 kept in the database; a missing or too-short key is replaced by a new one. | — |
| ACC-02.m | backlog | HTTP Basic credentials are passed to Authentik: a correct pair succeeds, a wrong pair is one failed sign-in counted by Authentik (ACC-06), and a request with none counts nothing. | — |
| ACC-02.e | backlog | Login settings identify the signed-in Authentik user and the signed-in state, and link to the user's Authentik account page. | — |
| ACC-03 | backlog | The user changes their login (user name and password) in Authentik, and the change takes effect for every browser. | — |
| ACC-03.a | backlog | Requiring the current password and a matching confirmation for a credential change, and the current-password error, are Authentik's job (UIC-19 no longer applies to SuiteStream). | — |
| ACC-03.b | backlog | After a credential change in Authentik, the old credentials are refused and the new ones accepted; changing only the user name keeps the password. | — |
| ACC-03.c | backlog | A sign-in or a first sign-in renews the form security token and invalidates the previous token. | — |
| ACC-03.e | backlog | A wrong current password while changing the password is one failed sign-in counted by Authentik (ACC-06); the field message is Authentik's. | — |
| ACC-03.f | backlog | Keeping the current user name when the user name field is empty is Authentik's job. | — |
| ACC-03.d | backlog | When the user changes the password in Authentik, the app sessions of the other browsers end at their next request. | — |
| ACC-04 | backlog | A new password must meet the password requirements, which Authentik enforces, and the user sees how strong it is and which requirements it still misses. | — |
| ACC-04.a | backlog | A password is accepted only if it meets the password policy configured in Authentik (the minimum length and the minimum numbers of capital letters, lowercase letters, numbers and special characters; the defaults and floors are in DEF-01 and the policy is set up from SET-06). A character and a special character are as DEF-03 defines them. | — |
| ACC-04.b | backlog | The strength bar and the hint for the requirements not yet met are shown by Authentik's password stage when a password is created or changed; SuiteStream shows none. | — |
| ACC-04.d | backlog | The password policy applies when a password is created or changed in Authentik, not to a password already saved; changing the policy does not sign anyone out. | — |
| ACC-05 | backlog | Google client secrets, notification tokens and other stored credentials are protected: stored safely and never exposed; sign-in passwords are held only by Authentik. | — |
| ACC-05.a | backlog | SuiteStream stores no sign-in password; Authentik keeps it only as a one-way hash, never in plaintext. | — |
| ACC-05.b | backlog | A credential the app must send on (the CCS+ password, Google client secret and tokens) is stored encrypted with a key from the database password; after the database password changes they cannot be read until entered again (CGOW-01). | — |
| ACC-05.c | backlog | A secret is never written to a log. | — |
| ACC-05.d | backlog | A secret is shown on a page only when a user who is authorized to see secrets turns on the Show secrets switch in History (HIS-04). | — |
| ACC-06 | backlog | Repeated failed sign-ins from one address lock that address for a time; Authentik does this. | — |
| ACC-06.a | backlog | After the number of failed sign-ins in DEF-01 from one address, Authentik refuses further attempts from it for the lock time in DEF-01 (Authentik's reputation policy, set up by the installer). | — |
| ACC-06.h | backlog | The failed sign-in that reaches the limit is itself refused with Authentik's message; SuiteStream shows msg:tooManyFailedAttemptsTry when Authentik returns the user with that error. | — |
| ACC-06.i | backlog | When a lock starts, the address's failure count resets and the lock lasts the time in DEF-01; later attempts during the lock are refused without being counted. This is Authentik's job. | — |
| ACC-06.j | backlog | Starting a lock is recorded in Authentik's event log; SuiteStream records no History warning for it (a setup code no longer exists). | — |
| ACC-06.k | backlog | Counting a correct setup code with an invalid password no longer applies: SuiteStream has no setup code (ACC-01.b). | — |
| ACC-06.b | backlog | An incorrect first-run setup attempt in Authentik counts toward the same per-address failure limit as an incorrect sign-in, where Authentik applies it (ACC-06.a). | — |
| ACC-06.c | backlog | Concurrent failed sign-ins are all counted by Authentik toward its failure limits without causing internal errors (ACC-06, ACC-07). | — |
| ACC-06.d | backlog | An address remains blocked until Authentik's lockout expires (ACC-06.a). | — |
| ACC-06.e | backlog | Restarting SuiteStream does not clear the lockout; the lockout state lives in Authentik. | — |
| ACC-06.f | backlog | A successful sign-in clears that address's failure count in Authentik. | — |
| ACC-06.g | backlog | The failure records are kept and limited by Authentik, up to the number in DEF-01 at most. | — |
| ACC-07 | backlog | Many failed sign-ins across addresses start a global block that Authentik applies to new outside addresses, while trusted and known visitors keep access. | — |
| ACC-07.a | backlog | The number of failed sign-ins from all addresses together within the window in DEF-01 starts a global block in Authentik's policy. | — |
| ACC-07.h | backlog | A global block ends when the failures within that window fall below the number in DEF-01. | — |
| ACC-07.e | backlog | During a global block, Authentik refuses an outside address even with the right password. | — |
| ACC-07.f | backlog | An address that signed in successfully within the trusted-address period in DEF-01 is not an outside address. | — |
| ACC-07.b | backlog | During the global block, requests from the trusted networks in DEF-01 are not blocked; SuiteStream's own public domain is not blocked either, since SuiteStream's requests to Authentik come from it. An address is judged from what a trusted proxy reports (DEP-03). | — |
| ACC-07.c | backlog | A successful sign-in issues a signed known-browser (remembered device) cookie valid for the time in DEF-01 from the last sign-in, renewed at each sign-in; a forged signature is refused. This is Authentik's job. | — |
| ACC-07.d | backlog | A known browser can authenticate during the global block, but does not bypass a block applied specifically to its own address. A new browser remains blocked. | — |
| ACC-07.i | backlog | Authentik's first-run setup is refused during a global block for every browser, known or not. | — |
| ACC-07.g | backlog | The record of addresses that signed in successfully keeps at most the number in DEF-01 (the oldest are forgotten first), in Authentik. | — |
| ACC-08 | backlog | When failed sign-ins lock the administrator out, Authentik's recovery restores access. | — |
| ACC-08.a | backlog | Reaching a global block is reported in Authentik's event log, and the container log tells the administrator how to start Authentik's recovery. | — |
| ACC-08.d | backlog | Authentik's recovery link works once and is valid for the time in DEF-01. | — |
| ACC-08.b | backlog | A fresh recovery link uses Authentik's configured public address, marks the visiting browser as known and directs it to sign-in. | — |
| ACC-08.e | backlog | Using a recovery link is recorded in Authentik's event log with the visitor's address; SuiteStream records msg:unlockLinkUsedFrom in History only when Authentik reports it. | — |
| ACC-08.c | backlog | Recovery links are single-use, and an expired link is not accepted. | — |
| ACC-09 | backlog | Changes to the page are accepted only from the page itself, and page responses carry basic browser protections. | — |
| ACC-09.a | backlog | Form tokens are tied to the signed-in app session; a mismatched form token is refused and cannot authorize a public-address change. | — |
| ACC-09.b | backlog | Cross-site form changes are refused and leave the saved value unchanged. | — |
| ACC-09.c | backlog | Page responses restrict framing to the same origin, prevent content-type sniffing and suppress referrer disclosure. | — |
| ACC-05.e | backlog | Hashing a sign-in password (scrypt or the algorithm Authentik uses, with the cost and salt in DEF-01 Password hashing) is Authentik's job; SuiteStream hashes no password. | — |
| ACC-05.f | backlog | Encrypted credentials use a key derived from the database password and a random salt with the rounds in DEF-01 (Secret encryption); sealing with no database password fails. | — |
| ACC-05.g | backlog | A credential that cannot be decrypted reads as not set: a CCS+ password counts as unset, a Google client secret is empty, and a Google token reports an error text saying it cannot be decrypted. | — |
| ACC-05.h | backlog | A saved secret is never shown again; leaving its field blank keeps the saved one. | — |
