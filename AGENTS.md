# SuiteStream agent rules

Read this first. The full roles are in `scrum/team_working_agreement.md`, the role files in `.github/agents` and the skills in `.github/skills`. Rules live in those files, not here; this file holds only the rules a session must know before it reads anything else.

## Who is who

The human is the **Executive (XO)**: sets direction, makes judgment calls, approves the sprint (or the epic series). **Suzuki** is the Product Owner agent acting for the Executive; **Takahashi** is the Scrum Master. Nothing an agent says is the Executive's approval.

## A sprint starts only when the Executive says "start"

Never start or run a sprint (launching agents that build, editing code for a sprint) unless the Executive says "start" in their own words. Approving a retrospective, choosing a scope or answering a question is not a start. After an approved retrospective: merge, create the next sprint's branch, plan it, then wait. Only the next sprint of a usage-split epic starts on its own.

## Talk after a sprint is the retrospective

When the Executive talks after a sprint, record each point as a backlog item (`scrum/product_backlog.csv`: 10 fields, no commas in text) or a requirement change; do not change code. Build only on an explicit "start" or an explicit request for a quick fix.

## Also

- Work only in this repository.
- Keep chat updates short and few; ask only what blocks a decision.
- Do not add a requirement row that restates another (point to DEF-01 or the existing row).
