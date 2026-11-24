# Request 006 — Run SuiteStream and the ScrumBoard in the Linux Docker stack

## Requested outcome

The Executive said on 2026-11-24, while Sprint 015 ran: the backlogged items that install SuiteStream as a Docker stack on a Linux machine are what the Executive is waiting for. When it is installed there, the ScrumBoard can live there too, and every Linux function the team needs (for example Node, to run a usage reader such as ccusage) is available.

## For refinement of Sprint 016 (paused: plan only, start on the Executive's word)

- Move these items ahead of the remaining ScrumBoard slices (PBI-085, PBI-087, PBI-088, PBI-083, PBI-084, PBI-094, PBI-082): PBI-063 (single Docker stack), PBI-073 (installer setup.sh), PBI-066 (verify the stack and a real sign-in), PBI-074 (updates through Watchtower). Their text says "after the ScrumBoard epic"; that wording is wrong and is replaced by this order.
- Add an item for running the ScrumBoard in the stack (its server and web build, reading the repository and `scrum/usage/`), and one for the usage tooling on Linux (a ccusage or similar reader that gives measured tokens per model and per 5-hour block, so `usage.sh` needs fewer pasted readings). Research: `scrum/sprint015/` notes are not the source; ask Sato or Suzuki to cite the ccusage findings from this session.
- The installer targets Linux (DEP-01.b: Linux, macOS with Docker Desktop, Windows with WSL).
- This order changes no scope of Sprint 015.

## Addition, 2026-11-24 (Executive)

PBI-073's `setup.sh` is the CalendarStream installer (`CalendarStream/WORKING.d/CalendarStream.old/install.sh`, read only) with CalendarStream changed to SuiteStream, and it also installs the applications a Linux machine needs to run Dart and Flutter (the SDKs, and what they need), so that the ScrumBoard and the usage tooling run there. Refinement lists those applications from the Flutter and Dart Linux install documentation and names which are installed by the script and which are only checked for. Still to settle in refinement, not decided here: the Authentik container and its sign-in setup, the start message the script waits for, the released image and `.env.default`, and the download line (`curl | bash`) reviewed for security.
