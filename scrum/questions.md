# Questions for the Executive

One question per heading. An agent writes the question; the Executive writes the answer under it and sets the status to answered (the ScrumBoard's Answered button does this, SCB-17.b). Before making any change, an agent reads this file; for each answered pair it records the decision where it belongs and then deletes the pair.

A question's number is the lowest number not used by an open question when it is written. It keeps that number until its pair is deleted; then the number is free for a new question. Deleting a pair renumbers nothing.

## Format

- The header counts every open question and the new ones; with none open it reads "Needed: nothing".
- Under it, only the new questions, in full; the recommended choice comes first, marked "(recommended)".
- The help question is in every greeting and every reply that follows an answer, numbered after any new questions.
- Each answer choice (a, b, c...) is on its own new line, indented 3 spaces under its question.
- "Run Sprint <N>" names the next sprint that has not run, written like "Run Sprint 14"; when that sprint is held, add "(held)".
- "questions" lists every open one.

```
## <number>. <asker, sprint> <short title>
Status: open
Question: ...
   Choices: ... (optional)
Answer:
```