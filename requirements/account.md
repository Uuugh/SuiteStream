# Requirements: account

Terms used below (defined once):
- **Address**: the visitor's network address as reported by a trusted proxy (DEP-03).
- **Trusted network**: a network listed in ACC-07.b.
- **Known browser**: a browser holding the signed cookie issued at a successful sign-in (ACC-07.c).
- **Outside address**: an address that is not on a trusted network, not a known browser's, and has not signed in successfully recently (ACC-07.f).

| ID | status | statement | test |
|---|---|---|---|
| ACC-01 | backlog | A new installation is set up by creating the page login with the setup code; once it exists, setup is closed. | — |
| ACC-01.a | backlog | Before a page login exists, page and status requests lead to initial setup; feed and health endpoints remain accessible. | — |
| ACC-01.b | backlog | Initial setup requires its generated setup code, written as two groups of four hexadecimal characters. | — |
| ACC-01.g | backlog | The setup code is accepted in any letter case and with or without the dash between its groups. | — |
| ACC-01.h | backlog | An incorrect setup code creates no login. | — |
| ACC-01.c | backlog | Initial setup explains how to retrieve its setup code with a command that works independently of the chosen service name; incorrect-code guidance repeats that retrieval instruction (ACC-01.b, DEP-02). | — |
| ACC-01.d | backlog | Initial setup refuses a mismatched password confirmation, a password that does not meet the password requirements (ACC-04) and a user name that is empty, longer than the length in DEF-01 or contains a space, a colon or other whitespace (msg:chooseAUserNameWithout). | — |
| ACC-01.e | backlog | After initial login creation, setup is closed and the creating user is signed in. | — |
| ACC-01.i | backlog | A setup code is generated each time the app starts and finds no page login; a new start replaces the earlier code; the code is kept in memory only and is valid for that run. | — |
| ACC-01.j | backlog | Initial setup checks the setup code first; a problem with the user name or password is reported after a correct code. The user name is checked first, then the password requirements, then the password confirmation. | — |
| ACC-01.k | backlog | The initial-setup page has the title, intro and button of msg:welcome, msg:welcomeFirstCreateTheLogin and msg:createLogin; its fields are Setup code, User name, Password and Password again. | — |
| ACC-01.l | backlog | Creating the login records a History entry msg:statusPageLoginCreatedFor ({user} is the new user name), renews the form security token (ACC-03.c) and marks the browser as known (ACC-07.c). | — |
| ACC-02 | backlog | A person signs in to see or change anything on the page, and can sign out. | — |
| ACC-02.a | backlog | An unauthenticated page request goes to sign-in and does not expose destination content; a successful session can read the page. Any change to settings, including update settings, requires that signed-in session. | — |
| ACC-02.b | backlog | An incorrect login password is not accepted; a correct one establishes a session. | — |
| ACC-02.g | backlog | The sign-in page has a User name field (length limit in DEF-01), a Password field with Show/Hide (UIC-38) and a button msg:signInAction; the cursor starts in User name, or in Password after a failed sign-in that kept the user name. | — |
| ACC-02.h | backlog | A wrong sign-in shows the form again with the typed user name kept and the message msg:signInWrong, which never says whether the user name or the password was wrong. | — |
| ACC-02.i | backlog | A signed-in visitor who opens the sign-in page goes to the page they asked for (ACC-02.f). | — |
| ACC-02.j | backlog | An unauthenticated request that is not a page request (a background request from the page) is answered 401 with msg:signInAgainReloadThePage. | — |
| ACC-02.f | backlog | After sign-in the user goes to the page they asked for only when it is a path on this site. A destination that starts with //, contains a backslash, or contains a tab, line break or other control character (browsers drop those, so "/<tab>/other.site" would go to another site) is not followed; the user goes to the home page instead. The query and fragment of a followed destination are kept. | — |
| ACC-02.c | backlog | Signing out removes page access; subsequent page requests return to sign-in. Authenticated HTTP Basic remains supported for the status API. | — |
| ACC-02.d | backlog | A successful page sign-in establishes a session valid for the time in DEF-01. | — |
| ACC-02.k | backlog | The session cookie cannot be read by the page script, is sent only to this site (SameSite lax) and is marked secure when the request arrived over HTTPS, directly or through a trusted proxy. | — |
| ACC-02.l | backlog | Sessions are signed with a random key of the size in DEF-01 kept in the database; a missing or too-short key is replaced by a new one. | — |
| ACC-02.m | backlog | HTTP Basic credentials count as a sign-in: a correct pair succeeds, a wrong pair is one failed sign-in (ACC-06), and a request with none counts nothing. | — |
| ACC-02.e | backlog | Login settings identify the saved username and the signed-in state. | — |
| ACC-03 | backlog | The user can change the page login, and the change takes effect for every browser. | — |
| ACC-03.a | backlog | Changing credentials, including entering a replacement password, requires the correct current password and a matching new-password confirmation. A username change that fails for a wrong current password leaves the saved username unchanged and identifies the current-password error (UIC-19). | — |
| ACC-03.b | backlog | After a credential change, the old credentials are refused and the new credentials are accepted. Changing only the username retains the existing password. | — |
| ACC-03.c | backlog | Creating or changing the login renews the form security token and invalidates the previous token. | — |
| ACC-03.e | backlog | A wrong current password in Settings is one failed sign-in for the requester's address (ACC-06) and shows the field message msg:theCurrentPasswordIsnT (UIC-19). | — |
| ACC-03.f | backlog | An empty user name field in Login settings keeps the current user name. | — |
| ACC-03.d | backlog | Changing the page login invalidates all previously issued browser sessions. | — |
| ACC-04 | backlog | A new password must meet the password requirements, and the user sees how strong it is and which requirements it still misses. | — |
| ACC-04.a | backlog | A password is accepted only if it has at least the minimum length and at least the minimum number of capital letters, lowercase letters, numbers and special characters set in the password requirements (SET-06; the defaults and floors are in DEF-01). A character and a special character are as DEF-03 defines them. | — |
| ACC-04.b | backlog | The strength bar (UIC-18) is shown when a password is created or changed, with the hint msg:passwordNeeds, whose {rules} names the requirements not yet met, joined by semicolons. Sign-in only verifies the saved password (ACC-02.b). | — |
| ACC-04.d | backlog | The password requirements apply when a password is created or changed (initial setup, replacement), not to a password already saved; changing the requirements does not sign anyone out. | — |
| ACC-05 | backlog | Passwords, Google client secrets and notification tokens are protected: stored safely and never exposed. | — |
| ACC-05.a | backlog | A sign-in password (page login, setup, replacement) is stored only as a one-way hash, never in plaintext. | — |
| ACC-05.b | backlog | A credential the app must send on (the CCS+ password, Google client secret and tokens) is stored encrypted with a key from the database password; after the database password changes they cannot be read until entered again (CGOW-01). | — |
| ACC-05.c | backlog | A secret is never written to a log. | — |
| ACC-05.d | backlog | A secret is shown on a page only when a user who is authorized to see secrets turns on the Show secrets switch in History (HIS-04). | — |
| ACC-06 | backlog | Repeated failed sign-ins from one address lock that address for a time. | — |
| ACC-06.a | backlog | After the number of failed sign-ins in DEF-01 from one address, further attempts from it are refused for the lock time in DEF-01. | — |
| ACC-06.h | backlog | The failed sign-in that reaches the limit is itself refused with msg:tooManyFailedAttemptsTry. | — |
| ACC-06.i | backlog | When a lock starts, the address's failure count resets to 0 and the lock lasts the time in DEF-01; later attempts during the lock are refused without being counted and do not extend the lock. | — |
| ACC-06.j | backlog | Starting a lock records one History warning, msg:statusPageLockedForAfter for sign-ins or msg:statusPageLockedForAfter2 for setup codes ({ip} is the address, {n} the limit). | — |
| ACC-06.k | backlog | A correct setup code with an invalid user name or password is not counted as a failed attempt. | — |
| ACC-06.b | backlog | An incorrect initial-setup code counts toward the same per-address failure limit as an incorrect page login (ACC-06.a). | — |
| ACC-06.c | backlog | Concurrent failed sign-ins are all counted toward the applicable failure limits without causing internal errors (ACC-06, ACC-07). | — |
| ACC-06.d | backlog | An address remains blocked until its lockout expires; recording failures from other addresses does not remove an active block early (ACC-06.a). | — |
| ACC-06.e | backlog | Restarting SuiteStream clears the active sign-in lockout state. | — |
| ACC-06.f | backlog | A successful sign-in clears that address's failure count. | — |
| ACC-06.g | backlog | Failure records are kept only while needed: at most the number in DEF-01 at once, forgetting addresses that are not locked out first. | — |
| ACC-07 | backlog | Many failed sign-ins across addresses start a global block that refuses new outside addresses, while trusted and known visitors keep access. | — |
| ACC-07.a | backlog | The number of failed sign-ins from all addresses together within the window in DEF-01 starts a global block. | — |
| ACC-07.h | backlog | A global block ends when the failures within that window fall below the number in DEF-01. | — |
| ACC-07.e | backlog | During a global block, an outside address is refused even with the right password. | — |
| ACC-07.f | backlog | An address that signed in successfully within the trusted-address period in DEF-01 is not an outside address. | — |
| ACC-07.b | backlog | During the global block, requests from the trusted networks in DEF-01 and from SuiteStream's own public domain are not blocked. An address is judged from what a trusted proxy reports (DEP-03). | — |
| ACC-07.c | backlog | A successful sign-in, a login creation and a recovery link each issue a signed known-browser cookie valid for the time in DEF-01 from the last sign-in, renewed at each sign-in; a forged signature is refused. | — |
| ACC-07.d | backlog | A known browser can authenticate during the global block, but does not bypass a block applied specifically to its own address. A new browser remains blocked. | — |
| ACC-07.i | backlog | The initial-setup form is refused during a global block for every browser, known or not. | — |
| ACC-07.g | backlog | The record of addresses that signed in successfully keeps at most the number in DEF-01 (the oldest are forgotten first). | — |
| ACC-08 | backlog | When failed sign-ins lock the administrator out, a single-use recovery link restores access. | — |
| ACC-08.a | backlog | Reaching a global block records one recovery warning (HIS-01) pointing the administrator to the container log. | — |
| ACC-08.d | backlog | The warning includes an unlock link that works once and is valid for the time in DEF-01. | — |
| ACC-08.b | backlog | A fresh recovery link uses the configured public address, marks the visiting browser as known and directs it to login, allowing that browser to authenticate. | — |
| ACC-08.e | backlog | Using a recovery link records a History entry msg:unlockLinkUsedFrom ({ip} is the visitor's address). | — |
| ACC-08.c | backlog | Recovery links are single-use, and an expired link is not accepted. | — |
| ACC-09 | backlog | Changes to the page are accepted only from the page itself, and page responses carry basic browser protections. | — |
| ACC-09.a | backlog | Initial-setup and signed-in form tokens are distinct; a setup token cannot authorize a public-address change. Mismatched form tokens are refused. | — |
| ACC-09.b | backlog | Cross-site form changes are refused and leave the saved value unchanged. | — |
| ACC-09.c | backlog | Page responses restrict framing to the same origin, prevent content-type sniffing and suppress referrer disclosure. | — |
| ACC-05.e | backlog | A page password is hashed with scrypt using the cost, block size, parallelism, result length and fresh random salt length in DEF-01 (Password hashing). | — |
| ACC-05.f | backlog | Encrypted credentials use a key derived from the database password and a random salt with the rounds in DEF-01 (Secret encryption); sealing with no database password fails. | — |
| ACC-05.g | backlog | A credential that cannot be decrypted reads as not set: a CCS+ password counts as unset, a Google client secret is empty, and a Google token reports an error text saying it cannot be decrypted. | — |
| ACC-05.h | backlog | A saved secret is never shown again; leaving its field blank keeps the saved one. | — |
