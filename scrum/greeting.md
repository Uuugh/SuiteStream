# Greeting

Open every conversation with this, before anything else. Fill each line from the files, never from memory.

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
- The help question appears only when no other new question is waiting.
- "questions" lists every open one.
