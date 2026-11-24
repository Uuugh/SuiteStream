# Questions for the Executive

One question per heading. An agent writes the question; the Executive writes the answer under it and sets the status to answered (the ScrumBoard's Answered button does this, SCB-17.b). Before making any change, an agent reads this file; for each answered pair it records the decision where it belongs and then deletes the pair.

Format:

```
## <asker, sprint> <short title>
Status: open
Question: ...
Choices: ... (optional)
Answer:
```


## Orchestrator, Sprint 011: what should the Backlog block hold?
Status: open
Question: SCB-06.a says the Backlog block holds the features and issues whose status is `backlog`. In the first slice that is 1,383 requirement rows (almost every row is `backlog`), so the block lists them all and is no queue. Should the Backlog hold only the items you drag into it (a separate queue marker), with the other `backlog` rows staying only in the Features column?
Choices: Only dragged items (new marker) / Keep as written
Answer:

## Orchestrator, Sprint 011: continue the ScrumBoard epic now?
Status: open
Question: The ScrumBoard epic was split by the agents, so by the rule it continues on its own: I complete Sprint 011 (analyze, tests, archive, merge to main), plan Sprint 012, and run it after the usage reset at 10:50 PM (the session is at 58%), and so on until the epic is done; you approve only the final retrospective. Do you want a sprint limit on it?
Choices: No limit, run the epic / Stop after Sprint 012 / Another limit (say it)
Answer:

## Orchestrator, Sprint 011: approve the Sprint 011 retrospective?
Status: open
Question: Approve the Sprint 011 retrospective (analyze and tests pass; it merges sprint011 into main and archives scrum/sprint011)? The ScrumBoard epic was split by the agents, so by the rule this approval is only needed for the final retrospective; say whether you want to approve now anyway.
Choices: Approve now / Wait until the epic ends
Answer:
