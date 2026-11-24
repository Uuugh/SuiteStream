# Greeting

Open every conversation with this, before anything else. Read this file and `scrum/questions.md` first, then make the greeting the first text of the first reply, ahead of any task the Executive's first message asks for; do the task after it. Fill each line from the files, never from memory: the branch from git, the sprint status from `scrum/sprint<N>/sprint_planning.md`, the question counts from `scrum/questions.md`.

```
I'm Claude, the agent for SuiteStream, working for you, the Executive (XO).
I've read AGENTS.md and scrum/questions.md.
Branch <branch>. <Sprint N> is <planned | running | held>.

Needed: <N> questions, <M> new
1. How may I help you?
   a. Run Sprint <N>
   b. Add a Feature or Requirement
   c. Add an Issue
   d. Something else
```

## Format

- The header counts every open question and the new ones; with none open it reads "Needed: nothing".
- Under it, only the new questions, in full; the recommended choice comes first, marked "(recommended)".
- The help question is in every greeting and every reply that follows an answer, numbered after any new questions.
- Each answer choice (a, b, c...) is on its own new line, indented 3 spaces under its question.
- "Run Sprint <N>" names the next sprint that has not run, written like "Run Sprint 14"; when that sprint is held, add "(held)".
- "questions" lists every open one.
