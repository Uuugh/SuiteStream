# Questions for the Executive

One question per heading. An agent writes the question; the Executive writes the answer under it and sets the status to answered (the ScrumBoard's Answered button does this, SCB-17.b). Before making any change, an agent reads this file; for each answered pair it records the decision where it belongs and then deletes the pair.

Write new questions oldest first. A question's number is the lowest number not used by an open question when it is written. It keeps that number until its pair is deleted; then the number is free for a new question. Deleting a pair renumbers nothing.

When the Executive types "questions", list every open question in the format below.

## Format

- The header counts every open question and the new ones; with none open it reads "Needed: nothing".
- Under it, only the new questions, in full; the recommended choice comes first, marked "(recommended)".
- Each answer choice (a, b, c...) is on its own new line, indented 3 spaces under its question.

```
## <number>. <asker, sprint> <short title>
Status: open
Question: ...
   Choices: ... (optional)
Answer:
```

## 1. Takahashi, Sprint 015 review What to do with devtools_options.yaml
Status: open
Question: devtools_options.yaml sits untracked at the repository root and has been left out of every commit. What should happen to it?
   a) Add it to .gitignore. (recommended)
   b) Commit it.
   c) Delete it.
Answer:

## 2. Takahashi, Sprint 015 review How PBI-132 groups verifications by sprint
Status: open
Question: PBI-132 groups the open verifications by the sprint of their PBI under collapsible group headings, and is not Ready until you decide two things: may a group heading show a count (SCB-17 rules out a count on the column heading), and does grouping replace the one-list order of SCB-17.c or sit inside it?
   a) No count on a group heading; the groups sit inside the SCB-17.c order, in the open verifications part, newest sprint first. (recommended)
   b) A group heading shows its number of open verifications; the groups sit inside the SCB-17.c order.
   c) Grouping replaces the SCB-17.c order: one group per sprint holding that sprint's questions and verifications of every status.
Answer:

## 3. Takahashi, Sprint 015 review How velocity counts points that are In Review
Status: open
Question: The sprint011 to sprint015 rows of scrum/velocity.csv count In Review points as completed, but scrum/team_working_agreement.md says In Review counts as completed only after acceptance. Which should hold?
   a) Keep counting In Review points as completed, say so in each row's notes, and change the working agreement to match. (recommended)
   b) Record completed as 0 or unknown until acceptance, and fix the earlier rows as their verifications are accepted.
Answer:
