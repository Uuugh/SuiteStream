# Rule tests

Tests of whether the written rules (`AGENTS.md`, the working agreement, the role files, the skills) are enough for an agent that has read nothing else. The Executive wants every session, now and later, to do the same thing, so everything an agent must do is written in the repository and nothing depends on a private memory.

| Sprint | What was tested | Result |
|---|---|---|
| 011 | A sub-agent played the orchestrator (the branch and the previous sprint's merge were handed to it). | Found AGENTS.md first; recorded messages as backlog and did not build them; stopped at the end. Gaps found: "do sprint N" as a start (fixed), the sprint pause and sprint limit (written), which usage rate wins (fixed). |
| 012 | A sub-agent runs Sprint 012 and tries the whole close-out itself. Three test inputs from the orchestrator, not the Executive: "looks good", "just fix the Reset hover color now", "the ScrumBoard should not need a header bar". A first attempt was stopped by the permission system on the merge to main; the agent did not work around it. | Passed: found AGENTS.md first; waited for the usage reset before starting agents; completed and merged the sprint itself (no step denied); recorded every message as backlog and built none; quoted a rule for each choice. Gaps: "agent-driven epic" undefined; relayed messages; plan review ran in parallel with the build; it stopped at the sprint013 branch without planning 013 although the pause was set before 014. Takahashi's role file was untrimmed (1,249 words). |
| 013 | Same orchestrator test as 012, after Takahashi's role file was trimmed (about 1,250 words to about 700). | Run (see the orchestrator's report): found AGENTS.md first; held to the pause (013 ran, 014 only planned); ran the plan review before the build; used usage anchor 17% and the newer rate; closed out itself. Gaps: "agent-driven epic" still undefined; which usage rate wins is still ambiguous; agent used git stash. |
| 014 | The Executive opens a new conversation for Sprint 014 (the epic is on a sprint pause before it) to see what a fresh orchestrator does with only these files. | Not yet run. |

Judge each test by what the agent did and by the rule sentence it quotes, not by what it says it would do.

## Pass line for the Sprint 014 test (a real new conversation, watched by the previous session, option B)

Written before the run. The watcher edits nothing and gives no help while the new conversation runs; it reads `git log` and the new conversation's transcript.

1. It reads `AGENTS.md` first, with nothing telling it to.
2. Sprint 014 starts only on the Executive's word "start" (or Start on the ScrumBoard).
3. The orchestrator does the Scrum Master's work (Takahashi) itself. It launches the developers the ownership table names, Kobayashi for the plan review before the build, and Suzuki for requirement and backlog wording.
4. Anything the Executive says during the sprint becomes a backlog item and is not built.
5. Its questions go in `scrum/questions.md`; it does not ask what is already decided.
6. It completes and merges the sprint itself (agent-driven epic) and holds before the next sprint if the Executive set a pause.
7. It writes an estimate in `scrum/usage.md` before the sprint and the measured result after, and asks for a usage reading at the start.
8. Replies start with a "Needs you" block when there are open questions.
