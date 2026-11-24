# Sprint 013 Review

Slice 3 of the ScrumBoard epic (PBI-049): PBI-097 (header icons, status token menu), PBI-098 (change stamp), PBI-099 (Reload removed), PBI-101 (less padding). 10 points built; acceptance pending the Executive.

## What was built
- Server: `GET /api/changes`, `POST /api/requirements/<id>/retire` (row moved to `requirements/retired.md`; `retired.md` is not listed as a requirement file).
- Header right zone: zoom out and in (80 to 160 %), theme toggle, bin (drop target that retires), disabled `+`. No Reload, no footer. The page polls the stamp every 2 s.
- Status token menu (proposed, backlog, the next 3 stories, retired) in the Features & Requirements column and on Backlog block and story entries (the token is new there). Retired members are hidden.
- Padding tokens lowered (page 12 to 8, gap 5 to 3).

## Checks
- `flutter analyze` 0 issues; 145 ScrumBoard tests and 596 root tests pass; web build succeeds.
- Server check by Nakamura (port 8091, stopped afterwards): stamp answered; retire of an unknown id refused with no file changed. A real retire was not run (it would change a requirement file).
- Kobayashi's audit: `kobayashi_audit.md`.

## Visual checks the Executive must do (light and dark, hard refresh)
1. Header right zone: zoom - and +, theme, bin and the greyed +; no Reload; no footer.
2. Zoom steps and stops at the limits.
3. Click a status token in the Features column, the Backlog block and a story: menu offers proposed, backlog, up to 3 stories, retired; a refused move shows a message.
4. Drag a requirement onto the bin: it disappears everywhere (this moves a real row to `requirements/retired.md`; use a test row).
5. Edit a requirement file outside the page: the page updates within about 2 seconds with no button.
6. Padding looks right and nothing is clipped at the DEF-01 window sizes.
