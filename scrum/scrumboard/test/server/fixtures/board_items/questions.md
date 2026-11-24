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

## 3. Suzuki, Sprint 014 Which week to report
Status: answered
Question: Which week does the usage trend show?
   a) The current week. (recommended)
   b) The last full week.
Answer: a) The current week. (recommended)

## 1. Ito, Sprint 015 Column width
Status: open
Question: How wide is the Questions and Verifications column?
Answer:

## 2. Tanaka, Sprint 015 Where the result goes
Status: open
Question: Where does the board write a verification result?
   a) Under "Result:" in the file. (recommended)
   b) In a new file.
   c) Nowhere; the Executive writes it.
Answer:

## 4. Takahashi, Sprint 015 Closed one
Status: closed
Question: Is this question still needed?
Answer: No.
