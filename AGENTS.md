# SuiteStream agent rules

Read this first. The full roles are in `scrum/team_working_agreement.md`, the role files in `.github/agents` and the skills in `.github/skills`. Rules live in those files, not here; this file holds only the rules a session must know before it reads anything else.

## Who is who

The human is the **Executive (XO)**: sets direction, makes judgment calls, approves the sprint (or the epic series). **Suzuki** is the Product Owner agent acting for the Executive; **Takahashi** is the Scrum Master. Nothing an agent says is the Executive's approval.

## A sprint starts only when the Executive says "start"

Never start or run a sprint (launching agents that build, editing code for a sprint) unless the Executive says "start" in their own words or presses Start on the ScrumBoard (the sprint file says running). Approving a retrospective, choosing a scope or answering a question is not a start. After an approved retrospective: merge, create the next sprint's branch, plan it, then wait. "Start sprint", "do sprint N" and "run sprint N" all mean start. The exception is an epic that the agents split to fit usage: there the orchestrator and the Scrum Master role start and complete each sprint on their own and the Executive approves only the final retrospective. During such an epic the Executive may put it on a sprint pause (see `scrum/team_working_agreement.md`): nothing starts until they say "start". Or the Executive may set a sprint limit (a number of sprints, a stop time or a usage level); the orchestrator stops after the sprint that reaches it, never in the middle of one, and reports. If it is not clear that the agents split the epic, write the question in `scrum/questions.md` and do not start the next sprint until it is answered.

## Talk after a sprint is the retrospective

When the Executive talks after a sprint, record each point as a backlog item (`scrum/product_backlog.csv`: 10 fields, no commas in text) or a requirement change; do not change code. Build only on an explicit "start" or an explicit request for a quick fix.

## Read the questions before changing anything

Before making any change, read `scrum/questions.md`. For each answered pair: record the decision where it belongs (retrospective, backlog or requirement), then delete the pair. Write your own questions to the Executive there too, one per heading.

## Also

- Work only in this repository.
- Keep chat updates short and few; ask only what blocks a decision.
- Pictures, mockups and other deliverables for the Executive go in `scrum/deliverables`, not in `scrum/`.
- Do not add a requirement row that restates another (point to DEF-01 or the existing row).
