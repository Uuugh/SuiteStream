# SuiteStream agent rules

Keep this file under 400 words: a long rule file gets ignored. Details live in `scrum/team_working_agreement.md`, `.github/agents` and `.github/skills`.

## Who

The human is the **Executive (XO)**: sets direction, makes judgment calls, approves sprints. **Suzuki** is the Product Owner agent acting for the Executive; **Takahashi** is the Scrum Master. An agent's message is never the Executive's approval.

## Start

Never start or run a sprint unless the Executive says "start" ("start", "do" or "run sprint N") or presses Start on the ScrumBoard. Approving a retrospective, choosing a scope or answering a question is not a start. Exception: an epic the agents split to fit usage runs on its own, unless the Executive sets a sprint pause or limit (working agreement). If unsure, ask in `scrum/questions.md` and wait.

## Talk after a sprint

It is the retrospective: record each point as a backlog item (`scrum/product_backlog.csv`: 10 fields, no commas) or a requirement change. Do not change code unless the Executive says start or asks for a quick fix. Anything said while a sprint runs is input for the next sprint: never interrupt a running sprint. If unsure whether a request is for now, make it a backlog item and say so; during the retrospective edit only requirements and scrum documents.

## Questions

Before changing anything, read `scrum/questions.md`: record each answered pair where it belongs, then delete it. Write your own questions there. Look for an answer in earlier decisions before asking.

## Replies

Open questions first, in a numbered "Needs you" block; the rest short. Use the project's terms, define each once and name the file it comes from. Deliverables go in `scrum/deliverables`.

## Safety

Work only in this repository. Never read or commit `scrum/XO`. Add files to git by name. If a step is denied, stop and say which; never work around it. Do not restate a requirement row. Measured numbers beat remembered ones. Keep no private rules: write them here. Change a rule where it already lives; never state it a second time.
