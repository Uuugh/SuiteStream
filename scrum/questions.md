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

## 1. Suzuki, Sprint 015 What marks a question or verification as new
Status: open
Question: SCB-17.e says a new open item is marked new until the Product Owner has seen it. On the board you are the reader. Where is "seen" kept? PBI-086 is planned with choice a until you answer.
   a) In your browser, like the zoom (SCB-24): an item is no longer new once the column has shown it. (recommended)
   b) Drop the new mark; keep only the count badge on the heading.
   c) In the file: a "Seen:" line the board writes when you open the item.
Answer:
