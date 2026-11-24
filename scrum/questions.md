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