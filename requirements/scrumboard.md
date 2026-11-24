# Requirements: ScrumBoard

The ScrumBoard: one web page where the Product Owner and the team see the backlog, build the sprint by dragging, follow its progress and usage, and see what the agents are doing.

Terms. A **status** is one of `proposed`, `backlog`, `planned` or `done` (`requirements/README.md`, Line format); it says where a requirement or an issue is: not yet agreed, waiting for a story, in a story, or accepted. A **block** is a story, an epic or a sprint, with a name; blocks nest as SCB-06.c says. The **Backlog block** is the first block of the board and holds every requirement and issue whose status is `backlog`. A **story** names the requirements and issues it will meet. **Usage** is the agent work a story has used, and the **estimate** is the usage planned for it, both counted in **usage points**, the unit defined in DEF-01. A **feature** is the area of one requirements file; an issue's feature is named by its `feature:` label. The **server** is the program of SCB-13 that serves the web app and its data. A **progress file** is a file in the progress folder whose name is an agent's label and whose content is `done/total`.

| ID | status | statement | test |
|---|---|---|---|
| SCB-01 | backlog | The ScrumBoard is one web page, served by a local server (SCB-13), that shows the backlog, the sprint blocks, their usage and the agents' progress. | — |
| SCB-01.a | backlog | The ScrumBoard changes only the sprint file, the status cell of a requirement row, the questions file (SCB-17), the issues and labels of the issue tracker through the user's own signed-in access, and nothing else; it reads the progress files; no token or secret is in its code or in the repository. | — |
| SCB-01.b | backlog | When the issue tracker cannot be reached, the issue column says why (msg:scbTrackerUnreachable, with the reason as {reason}) and the rest of the ScrumBoard keeps working. | — |
| SCB-01.c | backlog | A Reload control (msg:scbReload) reads the sprint file, the requirement files, the issues and the progress files again. | — |
| SCB-01.d | backlog | Every label, heading and note the ScrumBoard shows is a cited message key (rule 14 of `requirements/README.md`) with translations in `requirements/messages/`; the rows below cite them. | — |
| SCB-01.f | backlog | When the sprint file or the requirement files cannot be read, the page says why (msg:scbLoadFailed, with the reason as {reason}) in the places that need them and the other places keep working. | — |
| SCB-01.g | backlog | The ScrumBoard's colors come from the theme built from the THM-02 colors, in light and dark; no widget names a color. | — |
| SCB-02 | backlog | The sprint file `SCRUM.d/sprint.md` holds the blocks, which requirements and issues each story holds, the review and the retrospective. | — |
| SCB-02.a | backlog | The file has a Blocks table, a Members table, a Review section and a Retrospective section. | — |
| SCB-02.b | backlog | A Blocks row has: block ID, kind (story, epic or sprint), name, parent block ID (blank at the top), assignee, estimate and usage. | — |
| SCB-02.c | backlog | A Members row has a story's block ID and one item: a requirement ID or an issue number written #N. | — |
| SCB-02.d | backlog | Every change made in the ScrumBoard is written to the file at once, and the review and retrospective text is kept as it was. | — |
| SCB-02.e | backlog | When the file does not exist the sprint is empty, and the first change creates the file. | — |
| SCB-02.f | backlog | What the ScrumBoard does not edit is written back as it was: text before the first table, other sections, headings inside the Review or Retrospective text, and a row it cannot read. | — |
| SCB-03 | backlog | The Requirements column lists the requirements read from the requirement files, each with its ID, status, statement and feature. | — |
| SCB-03.a | backlog | Every row of a feature file in `requirements/` is read, including the files in `connections.d` and `plugins.d`; the README, `oldkey.md` and `open-questions.md` hold no requirements. | — |
| SCB-03.b | backlog | A status is shown as a message (msg:scbStatusProposed, msg:scbStatusBacklog, msg:scbStatusPlanned, msg:scbStatusDone); a blank status counts as `backlog`. | — |
| SCB-03.c | backlog | The column's heading is msg:scbRequirements. | — |
| SCB-04 | backlog | The Requirements column and the Issues column each have the shared filter (UIC-21) for the feature, for the requirement and for the status. | — |
| SCB-04.a | backlog | The feature filter's choices are the features of what the column lists (msg:scbFilterFeature). | — |
| SCB-04.b | backlog | The requirement filter's choices are the requirement IDs of what the column lists (msg:scbFilterRequirement). | — |
| SCB-04.c | backlog | The status filter's choices are the four statuses (msg:scbFilterStatus). | — |
| SCB-04.d | backlog | An entry is listed when it meets all three filters, and the column shows how many entries are listed out of all (msg:scbShownOf, {shown} the entries listed, {total} all entries). | — |
| SCB-05 | backlog | The Issues column lists the open issues read from the issue tracker, each with its number, title, status, feature, requirement and assignee; its heading is msg:scbIssues. | — |
| SCB-05.a | backlog | An issue's status is the one of its labels `proposed`, `backlog`, `planned` or `done`; an issue with none counts as `backlog`. | — |
| SCB-05.b | backlog | An issue's feature is the name after `feature:` in its labels. | — |
| SCB-05.c | backlog | An issue's requirement is the ID on the line starting `Requirement:` in its description. | — |
| SCB-05.d | backlog | An issue without a feature or a requirement shows a dash in its place. | — |
| SCB-05.e | backlog | The issue list holds at most the number of issues in DEF-01, newest first, and says when more exist (msg:scbIssuesTruncated, with the number as {limit}). | — |
| SCB-06 | backlog | The board along the top has the Backlog block fixed at its left edge, and to the right of it the sprint timeline: the sprint blocks run from the oldest on the left to the newest on the right, and the timeline scrolls sideways in from behind the Backlog block; the add control is the `+` in the right zone of the board's header (SCB-16.a). | — |
| SCB-06.a | backlog | The Backlog block (heading msg:scbBacklog) is the queue for a sprint: it holds the features (requirements) and the issues whose status is `backlog`. | — |
| SCB-06.b | backlog | The add control (msg:scbAddBlock) asks which kind of block (msg:scbBlockKind, msg:scbKindStory, msg:scbKindEpic, msg:scbKindSprint) and its name (msg:scbBlockName), and adds the block at the end of the board; its Cancel is msg:cancel and its Save is msg:scbSave. | — |
| SCB-06.c | backlog | A story can sit in an epic or in a sprint, an epic can sit in a sprint, and a sprint sits at the top of the board; a block is drawn inside the block it sits in. | — |
| SCB-06.d | backlog | A story holds the requirements and the issues that were dropped on it and shows each with its ID or number and title. | — |
| SCB-06.e | backlog | The Backlog block does not scroll with the timeline; the sprint blocks stand in one row that scrolls sideways under it, and when the page opens the timeline is scrolled to its right end, so the newest sprints are in view. | — |
| SCB-06.f | backlog | A scrollbar on the board moves to older sprints, to the left; they are read from `scrum/sprints` and loaded in batches of the size in DEF-01 only when the scroll nears them, never all at once. | — |
| SCB-06.g | backlog | The Backlog block is as wide as a sprint block; every block of the top level has the same width, and its contents scroll inside it (SCB-15.b). | — |
| SCB-07 | backlog | The Product Owner and the team build the sprint by dragging and dropping. | — |
| SCB-07.a | backlog | A block can be dragged onto a block it may sit in (SCB-06.c) and then sits there, written to the sprint file (SCB-02.d). | — |
| SCB-07.b | backlog | A block can be dragged to the top of the board and then sits there if it may (SCB-06.c). | — |
| SCB-07.c | backlog | A requirement or an issue can be dropped only on the Backlog block or on a story. | — |
| SCB-07.d | backlog | Dropping a `proposed` requirement or issue on the Backlog block sets its status to `backlog`. | — |
| SCB-07.e | backlog | Dropping a requirement or an issue on a story sets its status to `planned` and records it in the story's Members rows. | — |
| SCB-07.f | backlog | Dropping a requirement or an issue that is in a story on the Backlog block removes it from the story's Members rows and sets its status to `backlog`. | — |
| SCB-07.g | backlog | A drop that would move a status down in any other way, or that is not allowed by SCB-07.c, changes nothing and says why (msg:scbMoveRefused, with the reason as {reason}). | — |
| SCB-07.h | backlog | Dropping something where it already is changes nothing. | — |
| SCB-07.i | backlog | Dragging a requirement or an issue out of the Backlog block, onto nothing, removes it from the Backlog and puts it back to the status it had before it entered the Backlog; the board keeps that earlier status in the sprint file (SCB-02.d) when the item enters the Backlog. The item stays listed in its own column in every case, with the status changed in the requirement file or the issue tracker; the board is a window onto the existing process. | — |
| SCB-08 | backlog | A sprint block has one lifecycle button (msg:scbStart, msg:scbStop, msg:scbAccept) in its header to the right of its usage metric; stories have none. A sprint's state is shown as a chip: planned, running, complete, accepted. | — |
| SCB-08.a | backlog | On a planned sprint the button is Start. It is the Executive's word "start": pressing it sets the sprint to running in the sprint file (SCB-02.d), and agents begin the sprint only when they read that state. | — |
| SCB-08.b | backlog | Start is inactive on every planned sprint that is not the next to run, and on every sprint while another sprint is running; the Backlog block has no lifecycle button. | — |
| SCB-08.c | backlog | While the sprint is running the button is Stop; pressing it sets the sprint to stopped in the sprint file and the agents stop at their next safe point and report where they stopped. | — |
| SCB-08.d | backlog | When the orchestrator records that the sprint work is finished (analysis, tests and the retrospective draft done) the sprint is complete and the button becomes Accept. | — |
| SCB-08.e | backlog | Accept is the Executive's approval of the retrospective: it sets the status of every requirement and issue of every story in the sprint to `done`, sets the sprint to accepted and removes the button; an accepted sprint shows the chip only. | — |
| SCB-09 | backlog | The Issues column has a New issue control (msg:scbNewIssue) that opens a form to enter an issue: a title, a description, and dropdowns for the feature, the requirement and the status. | — |
| SCB-09.a | backlog | The form's requirement dropdown lists the requirements of the chosen feature, and choosing another feature clears it. | — |
| SCB-09.b | backlog | The status dropdown offers the four statuses and nothing else, and starts as `backlog`. | — |
| SCB-09.c | backlog | The Save control (msg:scbSave) stays off until the title is filled; the form's labels are msg:scbIssueTitle, msg:scbIssueDescription, msg:scbFilterFeature, msg:scbFilterRequirement and msg:scbFilterStatus. | — |
| SCB-09.d | backlog | Saving creates one issue in the issue tracker with the label `issue`, its `feature:` label (SCB-05.b), its status label (SCB-05.a) and its `Requirement:` line (SCB-05.c). | — |
| SCB-09.e | backlog | When the issue cannot be created the form stays filled and says why (msg:scbIssueFailed, with the reason as {reason}). | — |
| SCB-09.f | backlog | The form has a Cancel control (msg:cancel) that closes it without creating an issue. | — |
| SCB-09.g | backlog | After saving, the new issue is listed in the Issues column. | — |
| SCB-10 | backlog | The ScrumBoard shows usage against estimate on every story and sprint block. | — |
| SCB-10.a | backlog | A story's estimate and usage can be changed on its block and are written to the sprint file (SCB-02.d); labels msg:scbEstimate and msg:scbUsage. | — |
| SCB-10.b | backlog | A sprint or an epic shows the sum of the estimates and the sum of the usage of the stories it holds. | — |
| SCB-10.c | backlog | Each of these blocks shows its usage and estimate as a bar, in the warn color (THM-02.j) when usage is above the estimate. | — |
| SCB-11 | backlog | The Requirements column lists each requirement with its sub-requirements beneath it as an outline. | — |
| SCB-11.a | backlog | A sub-requirement is indented from its requirement by the sub-requirement indent in DEF-01. | — |
| SCB-11.b | backlog | A requirement that has sub-requirements shows a triangle that collapses or expands them, pointing right when they are collapsed and down when they are expanded; a requirement without sub-requirements shows no triangle (msg:scbExpandRow, msg:scbCollapseRow name it). | — |
| SCB-11.c | backlog | A switch above the list (msg:scbExpandAll) collapses every requirement's sub-requirements, so only the requirements with no parent remain visible, or expands them all again at once; collapsing never hides a requirement that has no parent. | — |
| SCB-11.d | backlog | When the page opens every requirement shows without its sub-requirements, so the column is never empty while requirements are listed. | — |
| SCB-11.e | backlog | The outline is built from the listed entries: a sub-requirement whose requirement is not listed is listed on its own, without an indent. | — |
| SCB-11.f | backlog | The switch of SCB-11.c sits on the row of the column's filters, at the right end of that row. | — |
| SCB-11.g | backlog | The Issues column lists the issues under the feature they belong to: a feature row with a triangle that collapses or expands its issues, the same control as SCB-11.b; collapsing hides only the issues and leaves every feature row visible. | — |
| SCB-11.h | backlog | An issue belongs to its feature (SCB-05.b) or, when it has none, to the feature of the requirement it names (SCB-05.c); an issue with neither is a top-level row under no feature and always stays visible. | — |
| SCB-11.i | backlog | The Issues column has the switch of SCB-11.c on its filter row, collapsing or expanding the issues of every feature, and opens collapsed (SCB-11.d). | — |
| SCB-15 | backlog | The page fits the window and every part of it scrolls on its own. | — |
| SCB-15.a | backlog | The page itself does not scroll. It has three rows: the board along the top (SCB-06) with 40 % of the window's height, a middle row with the usage chart and the running agents (SCB-12, SCB-14) with 20 %, and a bottom row of three columns, Features (the Requirements column, SCB-03), Issues (SCB-05) and Questions (SCB-17), each a third of the page width, with 40 % of the height. | — |
| SCB-15.b | backlog | Each column, and each block's contents, has its own vertical scrollbar when its content is longer than its area. | — |
| SCB-15.c | backlog | Nothing is clipped or overflows at the window sizes in DEF-01. | — |
| SCB-12 | backlog | The middle row has two parts side by side: the usage chart (SCB-14) and the running agents (heading msg:scbAgentProgress), each agent with its name and a completion bar next to it. | — |
| SCB-12.a | backlog | An agent's bar shows jobs done over total jobs, the jobs being that agent's tasks in the sprint backlog (the Done column, SCB-12.e), and the text `done/total`; the points of the stories done over the points of all stories of the sprint are shown in the same way on the sprint's own bar. | — |
| SCB-12.b | backlog | With no sprint backlog, or no task in it, the agents part is empty and says so (msg:scbNoProgress). | — |
| SCB-12.c | backlog | The bars are read again at the interval in DEF-01 and on Reload (SCB-01.c). | — |
| SCB-12.d | backlog | A sprint backlog without a Done column shows no bars. | — |
| SCB-12.e | backlog | The sprint backlog table (`sprint_backlog.md`) has a Done column; the task owner marks a task done there when it is finished, and the server counts the done tasks of each owner (SCB-12.a). | — |
| SCB-13 | backlog | One command starts the server, which serves the web app and gives it the data over HTTP; the progress folder is given with `--progress <dir>`. | — |
| SCB-13.a | backlog | The server listens on the local machine only, on the port given with `--port` (it starts as the port in DEF-01), and answers only a request whose Host is that address or `localhost` and whose Origin, when present, matches it. | — |
| SCB-13.b | backlog | The server answers only these requests: read and write the sprint file, list the requirements, set a requirement's status, list the issues, create an issue, set an issue's status, create a requirement, list the progress, read the usage file; any other request is answered not found. | — |
| SCB-13.c | backlog | The server checks every status change: a status only moves up the order `proposed`, `backlog`, `planned`, `done`, and the only move down is `planned` to `backlog`; any other change is refused with its reason. | — |
| SCB-13.d | backlog | A requirement's status change edits only the status cell of that row in its file, and the file is replaced as a whole or not at all. | — |
| SCB-13.e | backlog | An issue's status change removes the other status labels and adds the new one, creating the label when it is missing, and leaves the issue's open or closed state as it is. | — |
| SCB-13.f | backlog | The server runs the issue tracker's commands with each argument passed separately and never through a shell, and holds no token or secret. | — |
| SCB-13.g | backlog | When the issue tracker's command fails, the server answers with its reason and its other answers keep working. | — |
| SCB-13.h | backlog | When the web app cannot reach the server it says so (msg:scbServerUnreachable, with the reason as {reason}). | — |
| SCB-14 | backlog | In the middle row, beside the running agents, a usage chart (heading msg:scbUsageChart) shows the readings of the 5-hour session and of the 7-day week against the estimates, read from `SCRUM.d/usage.md`. | — |
| SCB-14.a | backlog | The usage file has a Usage table whose rows are: block ID, estimate session %, estimate weekly %, before session %, before weekly %, after session % and after weekly %; a cell that is not known is a dash. | — |
| SCB-14.b | backlog | The chart has two meters, one for the session (msg:scbMeterSession) and one for the week (msg:scbMeterWeek), each on a scale from 0 to 100. | — |
| SCB-14.c | backlog | For each row with a before and an after reading, a meter draws a bar from the before reading to the after reading in the data color of the theme, and names the block. | — |
| SCB-14.d | backlog | For each row with an estimate, a meter draws the estimate as a lighter band from the before reading, as wide as the estimate plus and minus the share in DEF-01. | — |
| SCB-14.e | backlog | For the next planned sprint the meter draws the projected after reading, the before reading plus the estimate, as a band that ends in a mark; a projection is never drawn as a dot. | — |
| SCB-14.f | backlog | When planned work goes past the end of a window, the meter splits at the session break: its track is the window up to 100, then a gap, then a second track for the next window after the reset, marked with the reset symbol; the planned work that falls after the reset starts from 0 on that second track. The week meter is one track unless its own reset is passed. A bar that goes past 100 is not an error and not in the warn color; the meter's heading says it is over 100 (off-scale) and the tooltip lists the real numbers. The reference picture is `scrum/deliverables/scrumboard_usage_reference.png`. | — |
| SCB-14.h | backlog | Each planned build (a story or a sprint of the plan, lettered or numbered as in the plan) is a marker, in the accent color, at the place where it should end on the track it falls on; a build after the reset sits on the second track. | — |
| SCB-14.i | backlog | To the right of each meter one line reads the reported reading, an arrow, the forecast and the reset time, for example `30% → ↻45% · resets Mon 12:50 AM`; the reset symbol means the figure is after the session reset, and a meter that does not pass its reset shows only `60% → 68% · resets Wed 5:00 PM`. | — |
| SCB-14.j | backlog | A legend under the meters says what the colors and marks mean: the reported reading, the markers of the planned builds, and the reset symbol. | — |
| SCB-14.k | backlog | Each reading in the usage file carries the reset time of its window (weekday and time), which the meter and its line use. | — |
| SCB-14.g | backlog | When the usage file is missing or has no Usage table the chart is empty and says so (msg:scbNoUsage). | — |
| SCB-13.i | backlog | Text from the issue tracker's commands is read as Unicode (the UTF 8 form) and the server's answers declare that character set, so characters such as ’, — and › show as written (a defect found in use: they showed as â€™, â€” and â€º). | — |
| SCB-16 | backlog | The three add controls (a new block on the board, a new requirement in the Requirements column, a new issue in the Issues column) are one shared control that opens one shared add popup. | — |
| SCB-16.a | backlog | Each add control is a `+` button in the right zone of the header of its section (UIC-14): the board, Features and Issues; its tooltip and accessible name are msg:scbAddBlock, msg:scbNewRequirement or msg:scbNewIssue. Any section that has an add feature has this `+` in the same place. | — |
| SCB-16.b | backlog | The popup for a new requirement or a new issue has an optional ID field (msg:scbIdOptional): the ID of the new requirement, or for an issue the ID of the requirement it names; it may be left empty. | — |
| SCB-16.c | backlog | The popup for a new requirement has a statement field (msg:scbRequirementStatement) and the one for a new issue has the title and description of SCB-09. | — |
| SCB-16.d | backlog | When the ID is empty and text has been entered, the popup lists suggested places (heading msg:scbSuggestions), at most the number in DEF-01, best first; with none it says so (msg:scbNoSuggestions). | — |
| SCB-16.e | backlog | A suggestion for a requirement gives its feature, its next free ID and, when it fits under an existing requirement, that parent (msg:scbSuggestNew, msg:scbSuggestSub); a suggestion for an issue gives a feature and the requirement it names. | — |
| SCB-16.f | backlog | Suggestions are ranked by how many words of the entered text appear in the feature names and in the statements of the requirements; the ScrumBoard computes them and calls no outside service. | — |
| SCB-16.g | backlog | Choosing a suggestion fills the feature, the ID and the parent; the user can instead type their own feature and ID. | — |
| SCB-16.h | backlog | Saving a new requirement writes a new row with status `proposed` into its feature's requirement file, after its parent's last sub-requirement when it has a parent and at the end of the file's table otherwise. | — |
| SCB-16.i | backlog | A new ID is refused with its reason when it exists already, when its prefix is not the feature's, or when its parent does not exist. | — |
| SCB-16.j | backlog | Saving a new issue creates it as SCB-09.d says, with the feature and the requirement of the chosen place. | — |
| SCB-13.j | backlog | The server also answers the request to create a requirement: it checks SCB-16.i, adds the row as SCB-16.h says, changes nothing else in the file, and replaces the file as a whole or not at all. | — |
| SCB-17 | backlog | The third column of the bottom row is Questions (heading msg:scbQuestions): what the agents are asking the Executive, each with a space for the answer after it, so a question is never lost in a long conversation. | — |
| SCB-17.a | backlog | The questions are read from `scrum/questions.md`, one per heading with its asker (the agent and the sprint), the question, the answer choices when there are some, the answer and a status of open or answered; the file is added to what the ScrumBoard may change (SCB-01.a). | — |
| SCB-17.b | backlog | Under each open question there is a space for the answer (a choice or typed text) with the Answered button (msg:scbAnswered) to the right of the answer text; pressing it saves the answer under the question and sets its status to answered. | — |
| SCB-17.c | backlog | An answered pair is the agents' queue: before making any change an agent reads `scrum/questions.md`; for each answered pair it records the decision where it belongs and then deletes the pair from the file, so it leaves the board. Open questions come first, newest first; with no question the column says so (msg:scbNoQuestions). | — |
| SCB-17.d | backlog | The column has its own vertical scrollbar (SCB-15.b). | — |
| SCB-17.e | backlog | A new open question shows a count badge on the column's heading and is marked new until the Product Owner has seen it. | — |
