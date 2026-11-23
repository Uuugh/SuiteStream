---
name: sprint-retrospective
description: Conduct a sprint retrospective. Reflect on individuals, interactions, process, tools, and the Definition of Done, analyze Keep/Problem/Try items, and identify improvement actions. Use for the final event of a sprint.
---

# Conduct the Sprint Retrospective

Use each sub-agent started in "Preparation" according to the instructions below to conduct the sprint retrospective.

## Preparation
- Run the Suzuki agent (`.github/agents/product-owner.suzuki.agent.md`) as a sub-agent with the model "Claude Opus 4.7".
- Run the Ito agent (`.github/agents/developer.ito.agent.md`) as a sub-agent with the model "Claude Opus 4.7".
- Run the Tanaka agent (`.github/agents/developer.tanaka.agent.md`) as a sub-agent with the model "Claude Opus 4.7".
- Run the Takahashi agent (`.github/agents/scrum-master.takahashi.agent.md`) as a sub-agent with the model "Claude Opus 4.7".
- Run the Kobayashi agent (`.github/agents/reviewer.kobayashi.agent.md`) as a sub-agent with the model "GPT-5.5".

Yamamoto and Nakamura cannot participate in the retrospective due to contractual constraints. Proceed on the assumption that any feedback will be provided through Tanaka and Ito.

## Target Sprint
Target the latest sprintXXX in the scrum folder (XXX is sequential).

## Pre-check
1. Read `scrum/${sprint_number}/sprint_backlog.md` and review sprint results.
2. Read `scrum/${sprint_number}/sprint_review.md` and review the sprint review outcome.
3. Read `scrum/impediment_log.csv` and check impediment occurrence and resolution.
4. Read `scrum/velocity.csv` and review the velocity trend.
5. Read `scrum/definition_of_done.md` and review the Definition of Done.

## Conduct the Retrospective

Have the Takahashi agent facilitate and perform the following reviews:

### 1. Inspection Scope
Based on the Scrum Guide, have the Suzuki, Ito, and Tanaka agents reflect on the sprint from these perspectives:
- **Individuals**: Member work patterns, motivation, and skills.
- **Interactions**: Team communication and collaboration.
- **Process**: Scrum event execution and workflows.
- **Tools**: Effectiveness of tools in use.
- **Definition of Done**: Validity of the current Definition of Done.

### 2. Keep
- From the perspectives of the Ito and Tanaka agents, identify good practices to preserve.
- From the Suzuki agent's perspective, identify collaboration that worked well.

### 3. Problem
- From the perspectives of the Ito and Tanaka agents, identify difficulties and problems.
- From the Takahashi agent's perspective, identify process issues.

### 4. Try
- Discuss improvement measures the whole team wants to try in the next sprint.
- Prioritize improvements with the greatest impact.

### 5. Decide Improvement Action Items
- Decide on specific actions, owners, and deadlines.
- Address the highest-impact improvements as soon as possible.
- Add them to the next sprint backlog if needed.
- For improvement actions that have "graduated," add them to `scrum/scrum_team_culture`.

### 6. Review the Definition of Done
- Have the team discuss whether the Definition of Done needs to change.
- If it changes, update `scrum/definition_of_done.md`.

### 7. Periodic Requirements and Test Audit
- Count completed `sprint_retrospective.md` records, including the current retrospective. On every fifth retrospective (5th, 10th, 15th, etc.), audit completed requirements and their associated tests.
- Kobayashi runs this audit and applies the `flutter-dart-code-review` skill to `lib/` and `test/` alongside the requirement checks below.
- Check for mismatches between requirement wording/status and test behavior, missing or stale test traceability, and relevant edge cases not covered.
- Identify duplicated tests or opportunities to combine related coverage. A shared test may cover multiple requirement IDs only when each behavior and relevant edge case remains traceable; do not reduce coverage for efficiency.
- Record findings and prioritized actions in the retrospective, with owners and deadlines. Do not change requirement status or remove tests without supporting evidence.

### 8. Audit the Retrospective Results
- Use the Kobayashi agent to audit the sprint retrospective results.
  - Check that every file requiring an update was updated correctly and that nothing was missed.

### 9. Apply Changes to the Repository
- Use the Takahashi agent to merge the necessary files and apply everything to the main repository.
 - Finally, run git pull origin main and review and retrieve the differences.

## Recording
- Record the retrospective outcome in `scrum/${sprint_number}/sprint_retrospective.md`.
- Move resolved impediments to `scrum/impediment_log_resolved.csv`.

## Notes
- Focus on improving the process and system, not criticizing individuals.
- Ensure psychological safety so everyone can speak candidly.
- The sprint ends with the sprint retrospective.
- Preserve all necessary elements in the record while keeping it as concise as possible.

## Commit and merge on approval

Every sprint works on its own branch (`sprintNNN`, see the sprint-planning skill). When the Product Owner approves the retrospective:
run `flutter analyze` and the full test suite first (continue only if they pass; otherwise report the failures and stop);
commit everything for the sprint (except stray or generated files) on the sprint branch with a message like
"Complete Sprint NNN <short summary>"; push the sprint branch; merge it into `main` and push `main`.
The next sprint starts on a new branch from the updated `main`.

## Automatic completion inside a usage epic

If this sprint is part of an epic that was split to fit usage (see the Epics section of the `backlog-refinement` skill), the retrospective is recorded and the sprint is completed automatically (commit, push, merge, new branch) without waiting for approval. Tests and analysis must pass. The next sprint of the epic starts at once. The Product Owner reviews after the epic's last sprint.
