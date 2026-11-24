# Requirements: deployment

Test cells that name `server/test/server_test.dart` are covered by the Dart server tests in `server/` (in-memory store, fake Authentik; the Postgres store and a real Authentik are not tested). Compose files under `docker/` are written but not run, so rows covered only by them keep `—`.

| ID | status | statement | test |
|---|---|---|---|
| DEP-01 | backlog | The app runs in the user's own Docker stack and keeps all of its data there. | — |
| DEP-01.b | backlog | The installer supports Linux, macOS (Docker Desktop) and Windows (WSL). | — |
| DEP-01.c | backlog | Prebuilt app images run on amd64 and arm64 hosts without building the app locally. | — |
| DEP-01.d | backlog | The configured user and group identity and the restart policy are applied to the stack. | — |
| DEP-01.e | backlog | When the database is not ready at startup, the app retries the connection at the interval in DEF-01 for up to the wait in DEF-01; if it still cannot connect, startup fails with a message that the database cannot be reached. | server/test/server_test.dart |
| DEP-01.f | backlog | Deleting the Postgres directory resets the app to a fresh install: sources, destinations, edits, rules, templates, settings, logins, the Google connection and feed links. | — |
| DEP-01.g | backlog | The database (including the Authentik database) and the calendar data are backed up and restored from Settings > Site Admin (SET-06). A restored database needs the deployment secrets (the database password) to read its encrypted credentials. | — |
| DEP-02 | backlog | An installer sets up the stack and can be run again to keep it current. | — |
| DEP-02.a | backlog | The installer asks for a subdomain or stack prefix, stable or beta, the app, config and data paths and whether to install the updater (enabled by default), and offers working defaults; an existing folder is detected and reused. | — |
| DEP-02.b | backlog | When the chosen app folder already exists, the installer offers using it, choosing a numbered folder, choosing another path or cancelling. | — |
| DEP-02.c | backlog | A second install on the same host detects the existing containers and picks distinct container names and ports, and remembers them (STACK_NO and PORT). | — |
| DEP-02.d | backlog | The installer generates the database credentials, downloads the deployment files, starts the stack and prints the app address and the address of Authentik's initial setup (see ACC-01). Running it again keeps the saved settings, the database password and the data folder, offers the saved settings as its defaults, and installs the newest image of the selected release (see SET-05). | — |
| DEP-02.e | backlog | Host-address lookup failures are reported to the user rather than silently terminating installation. | — |
| DEP-02.f | backlog | The installer writes the environment configuration with read access restricted to its owner. | — |
| DEP-02.g | backlog | Installer answers containing pipe or ampersand characters are preserved literally in the saved configuration. | — |
| DEP-02.h | backlog | The installer accepts stable and latest as names for the stable release channel. | — |
| DEP-02.i | backlog | The installer accepts an exact release identifier, including a beta, and installs that release with its own matching deployment definition. | — |
| DEP-02.j | backlog | Starting or recreating the app deployment checks the selected image tag for an updated image before starting the app. | — |
| DEP-02.k | backlog | The installer lower-cases the subdomain and the names it is given and keeps only letters, digits, dot, underscore and hyphen. | — |
| DEP-02.l | backlog | Without an answer the installer uses port 8080, the time zone America/Chicago, the image tag latest and the restart policy unless-stopped. | — |
| DEP-03 | backlog | The stack works behind a proxy and with Google's notifications. | — |
| DEP-03.a | backlog | FORWARDED_ALLOW_IPS lists the proxies trusted to report the visitor's address and HTTPS use (see ACC-07). | — |
| DEP-03.b | backlog | Google notifications need valid TLS and proxy access to the unauthenticated notification endpoint; without it the daily check still runs (see CGOW-05). | — |
| DEP-04 | backlog | Watchtower, the update mechanism of the stack (DEP-06.a), updates only the app container, only when asked or on its schedule, and is not reachable from outside. | — |
| DEP-04.a | backlog | Watchtower updates the app container when the user presses Update now, or when automatic updating is on and a check finds a newer version (SET-05). It never updates the database container and removes old images after an update. | — |
| DEP-04.b | backlog | Watchtower is not reachable from outside the Docker network, needs a generated secret token for the requests the app makes and uses the Docker socket; the installer can remove it without losing other data (see SET-05). | — |
| DEP-05 | backlog | Settings can start in the environment and move to the database, and a Python installation can be migrated. | — |
| DEP-05.a | backlog | Environment (.env) values are only starting values: a value saved in the database always overrides the matching environment setting (time zone, sync interval, CCS+ client, calendar name, default event hours, 24-hour rule). The only settings that stay environment-only are the ones the app needs before it can read the database: the stack name and folders, the image tag, the updater profile, the user, group and restart policy, the trusted proxy addresses, the database password and the Authentik secrets (its secret key and the client secret SuiteStream signs in with). | — |
| DEP-05.b | backlog | The installer sets the installation's time zone (the server's TZ setting). It is the default zone for an imported event that carries no zone and for server work without a device (scheduled downloads), until the user defines otherwise: a default zone saved in Settings > Site Admin (SET-06) overrides the installer's. | — |
| DEP-05.c | backlog | A one-time migration tool copies all data from a Python-app database into the new Dart database (events, edits, custom events, History, rules, sources, destinations, settings, Google connection and feeds), never changes the old database, and prints a report of what it copied for the Developer to check. The page password is not carried over: after migration the user signs in through Authentik with an account created there (ACC-01). The tool is tested in three steps: first on a made-up demo database, then on a copy of the real database, and only then on the real database. | — |
| DEP-02.m | backlog | Every installer question shows its default in square brackets and Enter accepts it; later runs default to the current settings, and answers are read from the terminal even when the installer's input is piped. | — |
| DEP-02.n | backlog | The installer stops at the first failure. | — |
| DEP-02.o | backlog | The installer finds a previous installation in the current folder (a compose file naming calendar_stream) or else in the default stack folder, and takes its defaults from that folder's .env. | — |
| DEP-02.p | backlog | The subdomain slug is lower case with every run of other characters replaced by one hyphen and leading and trailing hyphens and dots removed; an empty slug becomes suitestream. | — |
| DEP-02.q | backlog | A folder path accepts ~ and relative paths, is made absolute, loses a trailing slash and is created when missing. | — |
| DEP-02.r | backlog | The default port and stack number follow DEF-01 (Installer stack defaults); containers are named prefix and number, prefix_db and number, prefix_authentik and number, and prefix_updater and number, the prefix defaulting to calendar_stream. | — |
| DEP-02.s | backlog | The installer writes its answers to .env (the image tag, stack prefix, data folder, stack number, port and profiles), replacing an existing or commented line and keeping the others. | — |
| DEP-02.t | backlog | The installer creates the updater token file, owner-readable, even when the updater is declined, with the length in DEF-01. | — |
| DEP-06 | backlog | The stack's parts are fixed. | — |
| DEP-06.a | backlog | The stack is one Docker stack of four containers: the app in its own lightweight image (a small image that serves the Flutter web build and the API); a Postgres database (a second database in it may serve Authentik); Authentik, the identity provider that signs users in (ACC); and Watchtower as the update mechanism. | — |
| DEP-06.b | backlog | The database reports ready by the check in DEF-01 (Database health check). | — |
| DEP-06.c | backlog | The container reports health by calling the health interface (DIA-03) at the interval in DEF-01 (Container health check). | — |
| DEP-06.d | backlog | The database name and user take effect when the database is first created. | — |
| DEP-06.e | backlog | The entrypoint starts as root, reads the secret files with line breaks removed, then runs the app as the configured user and group, without extra groups; a missing secret file is warned about. | — |
| DEP-06.f | backlog | The app listens on all addresses on the port in DEF-01 (Installer stack defaults) inside the container. | — |
| DEP-06.g | backlog | The public address is set on the page, not in .env; an older environment value is read once and moved to the page setting, and a value naming only a host address and the app port counts as not set. | — |
| DEP-06.h | backlog | The defaults of .env are in DEF-01 (Environment defaults). | — |
| DEP-06.i | backlog | The CCS+ calendar address defaults to the one in DEF-01; a saved link replaces it. | — |
| DEP-06.j | backlog | A feed token from an older version is made once as a random URL-safe value, and a typed stream name wins over it. | — |
| DEP-06.k | backlog | Old login files and their secret variants are not imported; the first administrator is created in Authentik (ACC-01). | — |
| DEP-06.l | backlog | The database host, port and password (from its secret file) come from the environment; a missing password is warned about, and the user and password are percent-encoded. | — |
| DEP-06.m | backlog | The database uses the connection pool in DEF-01, and shutdown cancels the background loops and closes the database. | — |
| DEP-06.n | backlog | A beta image is built when the version changes and the suites pass and the image scan has no fixable high or critical finding; it is tagged with the version, the version with its v prefix, and beta; the latest tag moves when the stable version changes. | — |
| DEP-06.o | backlog | An event length setting accepts decimals, an h suffix and the all-day words; an invalid one is warned about and the default length in DEF-01 is used. | — |
| DEP-06.p | backlog | The 24-hour rule setting is off for 0, false, no and off. | — |
