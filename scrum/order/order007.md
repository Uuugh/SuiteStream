# Request 007 — ScrumBoard changes and agent names

The Executive's words, 2026-11-24, while Sprint 015 ran. They are input for Sprint 016 refinement (the epic is paused at 016, `order005.md`); they change no scope of Sprint 015.

## ScrumBoard changes (change the existing rows and reset their status; add no new rows)

1. The Retire bin (SCB-19) is white now. It takes the built-in theme colors that SuiteStream already uses for reset and trash (`colorScheme.error`, as `lib/src/ui/reset_button.dart` does). The bin's function stays as SCB-19 specifies.
2. The expand-all and collapse-all control (SCB-11.c; the Issues column's copy is SCB-11.i) becomes Material expand and collapse icons, in the right zone of each section's header (the column heading), not a switch on the filter row. The row triangle (SCB-11.b) is not changed; confirm that with the Executive if refinement doubts it.

## Agent renames, after Sprint 015 is finished

Change these names everywhere (role files and their file names under `.github/agents`, skills, `AGENTS.md`, `scrum/`, requirements, the board's text):

| Old | New |
|---|---|
| Sato | CustomerProxy |
| Suzuki | ProductOwner |
| Takahashi | ScrumMaster |
| Ito | Coder_1 |
| Tanaka | Coder_2 |

The Executive gave no new names for Yamamoto, Nakamura, Kobayashi and Watanabe: they keep theirs until the Executive says. Records of past sprints keep the names they were written with unless the Executive says otherwise; ask once.
