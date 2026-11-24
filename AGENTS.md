# SuiteStream agent rules

Aim for under 500 words: a long rule file gets ignored. At or over 500, tell the Executive; never trim a rule to fit. Details live in `scrum/team_working_agreement.md`, `.github/agents` and `.github/skills`.

## Who

The human is the **Executive (XO)**: sets direction, makes judgment calls, approves sprints. **Suzuki** is the Product Owner agent acting for the Executive; **Takahashi** is the Scrum Master. An agent's message is never the Executive's approval.

## Start

Never start or run a sprint unless the Executive says "start" ("start", "do" or "run sprint N") or presses Start on the ScrumBoard. Approving a retrospective, choosing a scope or answering a question is not a start. Exception: an agent-driven epic runs on its own, unless the Executive sets a sprint pause or limit. If unsure whether to start, don't: write the question in `scrum/questions.md`, ask it once in the reply, and wait.

## Talk after a sprint

It is the retrospective: record each point as a backlog item (`scrum/product_backlog.csv`: 10 fields, no commas) or a requirement change. Do not change code unless the Executive says start or asks for a quick fix. Anything said while a sprint runs is input for the next sprint: never interrupt a running sprint. If unsure whether a request is for now, make it a backlog item and say so.

## Questions

Before changing anything, read `scrum/questions.md`: record each answered pair (answered in chat or on the ScrumBoard) where it belongs, then delete it. Look for an answer in earlier decisions before asking. Write each question there, oldest first, with the lowest number not used by an open question; a question keeps its number until its pair is deleted, then the number is free to reuse and no other question is renumbered. Ask it once. Open every conversation with `scrum/greeting.md`.

## Replies

Show questions as `scrum/greeting.md` says. The rest short. Use the project's terms, define each once and name the file it comes from. Deliverables go in `scrum/deliverables`.

## Safety

Work only in this repository. CalendarStream is an older project: read it only when the Executive sends you there, change nothing in it; SuiteStream lives only here. Never read or commit `scrum/XO`. Add files to git by name. If a step is denied, stop and say which; never work around it. Cite a requirement by its ID; never copy its text. Take numbers from `scrum/usage/`, `scrum/velocity.csv` or a measurement, never from memory. Keep no private rules: put a new rule here; edit an existing rule where it is.
