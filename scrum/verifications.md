# Verifications for the Executive

One verification per heading, for one PBI that is In Review.

1. An agent writes the verification when the PBI reaches In Review.
2. The Executive checks it, writes the result under "Result:" and sets the status to accepted or returned.
3. Before making any change, an agent reads this file. For each accepted or returned item it acts on the PBI as "Acting on the result" says, then deletes the item.

Write new verifications oldest first. A verification's number is the lowest number not used by an open one. Deleting an item renumbers nothing.

When the Executive types "verifications", list every open one in the format below.

## Acting on the result

- accepted: the PBI moves to `scrum/product_backlog_done.csv` (status Done); the requirement rows it met are set to `done`.
- returned: the PBI goes back to Backlog with the Executive's result added to its acceptance criteria; the requirement rows stay as they are.

## Format

- Every PBI In Review has exactly one open verification, and the PBI's acceptance field ends with "waits for verification <number> (`scrum/verifications.md`)".
- Each item names its PBI, what to check (light and dark, hard refresh, for the board) and where.

```
## <number>. <PBI id> <short title>
Status: open
Verify: ...
Result:
```

## 1. PBI-108 Features column backlog choice
Status: open
Verify: On the board, choose backlog for a requirement that belongs to a story, in the Features column. It should leave its story, as the Backlog block does (SCB-07.f).
Result:

## 2. PBI-107 A change in the first seconds
Status: open
Verify: Reload the page, then change a file the board reads within 2 seconds. The change shows on the board (SCB-22).
Result:

## 3. PBI-109 Block widths
Status: open
Verify: The Backlog and sprint blocks look the right width at the DEF-01 window sizes, in light and dark, with no clipping (SCB-06.g).
Result:

## 4. PBI-106 Real usage.sh on Windows
Status: open
Verify: Run the server on Windows with the real `scrum/usage/usage.sh`; the usage estimate and trend routes answer (SCB-14.o). The board shows no usage yet; this checks the server and API only.
Result:

## 5. PBI-119 Definition of Done line
Status: open
Verify: Read `scrum/definition_of_done.md` line 21. It says each added or changed option, route or setting is in its doc file, checked on Windows and web.
Result:

## 6. PBI-120 Daily scrum record
Status: open
Verify: Read `.github/skills/one-day-in-scrum/SKILL.md` line 50. It says each developer writes the test command and the pass count.
Result:

## 7. PBI-122 Stale audit sentence
Status: open
Verify: `.github/skills/sprint-retrospective/SKILL.md` line 65 and `.github/agents/reviewer.kobayashi.agent.md` line 24 no longer say the first audit is owed.
Result:
