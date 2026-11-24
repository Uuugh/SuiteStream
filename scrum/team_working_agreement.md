# Team Working Agreement

## Roles

- **Executive (XO)** is the human who owns the product. The Executive:
  1. sets direction: the vision, goals, priorities and constraints (the why and the what);
  2. makes judgment calls: decisions that need taste, ethics or business context that agents cannot make;
  3. approves each sprint: its start, its retrospective and the merge into `main`. One approval can cover a series of sprints when the Executive approves them as one epic. The words "start sprint", "do sprint N" and "run sprint N" mean the same thing: start. The one exception needs no approval between sprints: an epic the agents split to fit usage runs its sprints on automatically (see `.github/skills/backlog-refinement/SKILL.md`, "Epics split to fit usage"), and the Executive reviews after its last sprint. During such an epic the Executive may set a sprint limit (a number of sprints, a stop time or a usage level); the orchestrator stops after the sprint that reaches it.
  The Product Owner and the Scrum Master divide the backlog into sprints; the Executive keeps the prerogative to move any backlog item into a sprint, or out of one, whenever their needs require it.
  An **agent-driven epic** is an epic whose sprints the Product Owner and the Scrum Master divide and run, whether it was split to fit usage or for size: its sprints are completed and merged automatically and the Executive approves only the final retrospective, unless they put it on a sprint pause.
  A **sprint pause** is a hold between two sprints of an epic: "pause at N" means the hold sits before sprint N starts (sprints before N run, N does not); while it lasts nobody starts the next sprint (the held sprint's plan may be drafted and its branch created; it is not started), and no retrospective is needed from the Executive; the epic continues when the Executive says "start". The Executive may put an agent-driven epic on a sprint pause at any time.
  Nothing the agents say or do counts as the Executive's approval. Anything the Executive says after a sprint has started is input for the next sprint unless they say otherwise.
- **Product Owner (Suzuki)** is an agent that acts for the Executive: it keeps the backlog and the requirements, writes acceptance criteria and organizes the Executive's input. It does not approve sprint starts, retrospectives or merges.
- **Scrum Master (Takahashi)** is an agent that runs the process, the usage plan and the records.
- **Developers (Ito, Tanaka)**, **contractors (Yamamoto, Nakamura)**, **reviewer (Kobayashi)**, **security (Watanabe)** and **customer (Sato)** are agents; their files are in `.github/agents`.

Where a role file or skill says "Executive (XO)" it means the human; where it says "Product Owner" it means Suzuki.
