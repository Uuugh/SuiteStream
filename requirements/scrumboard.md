# Requirements: ScrumBoard

The ScrumBoard: one web page where the Product Owner and the team see the backlog, build the sprint by dragging, follow its progress and usage, and see what the agents are doing.

Terms. A **status** is one of `proposed`, `backlog`, `planned` or `done` (`requirements/README.md`, Line format); it says where a requirement or an issue is: not yet agreed, waiting for a story, in a story, or accepted. A **block** is a story, an epic or a sprint, with a name; blocks nest as SBD-06.c says. The **Backlog block** is the first block of the board and holds every requirement and issue whose status is `backlog`. A **story** names the requirements and issues it will meet. **Usage** is the agent work a story has used, and the **estimate** is the usage planned for it, both counted in **usage points**, the unit defined in DEF-01. A **feature** is the area of one requirements file; an issue's feature is named by its `feature:` label. The **server** is the program of SBD-13 that serves the web app and its data. A **progress file** is a file in the progress folder whose name is an agent's label and whose content is `done/total`.

| ID | status | statement | test |
|---|---|---|---|
| SBD-01 | backlog | The ScrumBoard is one web page, served by a local server (SBD-13), that shows the backlog, the sprint blocks, their usage and the agents' progress. | — |
| SBD-01.a | backlog | The ScrumBoard changes only the sprint file, the status cell of a requirement row, the issues and labels of the issue tracker through the user's own signed-in access, and nothing else; it reads the progress files; no token or secret is in its code or in the repository. | — |
| SBD-01.b | backlog | When the issue tracker cannot be reached, the issue column says why (msg:sbdTrackerUnreachable, with the reason as {reason}) and the rest of the ScrumBoard keeps working. | — |
| SBD-01.c | backlog | A Reload control (msg:sbdReload) reads the sprint file, the requirement files, the issues and the progress files again. | — |
| SBD-01.d | backlog | Every label, heading and note the ScrumBoard shows is a cited message key (rule 14 of `requirements/README.md`) with translations in `requirements/messages/`; the rows below cite them. | — |
| SBD-01.f | backlog | When the sprint file or the requirement files cannot be read, the page says why (msg:sbdLoadFailed, with the reason as {reason}) in the places that need them and the other places keep working. | — |
| SBD-01.g | backlog | The ScrumBoard's colors come from the theme built from the THM-02 colors, in light and dark; no widget names a color. | — |
| SBD-02 | backlog | The sprint file `SCRUM.d/sprint.md` holds the blocks, which requirements and issues each story holds, the review and the retrospective. | — |
| SBD-02.a | backlog | The file has a Blocks table, a Members table, a Review section and a Retrospective section. | — |
| SBD-02.b | backlog | A Blocks row has: block ID, kind (story, epic or sprint), name, parent block ID (blank at the top), assignee, estimate and usage. | — |
| SBD-02.c | backlog | A Members row has a story's block ID and one item: a requirement ID or an issue number written #N. | — |
| SBD-02.d | backlog | Every change made in the ScrumBoard is written to the file at once, and the review and retrospective text is kept as it was. | — |
| SBD-02.e | backlog | When the file does not exist the sprint is empty, and the first change creates the file. | — |
| SBD-02.f | backlog | What the ScrumBoard does not edit is written back as it was: text before the first table, other sections, headings inside the Review or Retrospective text, and a row it cannot read. | — |
| SBD-03 | backlog | The Requirements column lists the requirements read from the requirement files, each with its ID, status, statement and feature. | — |
| SBD-03.a | backlog | Every row of a feature file in `requirements/` is read, including the files in `connections.d` and `plugins.d`; the README, `oldkey.md` and `open-questions.md` hold no requirements. | — |
| SBD-03.b | backlog | A status is shown as a message (msg:sbdStatusProposed, msg:sbdStatusBacklog, msg:sbdStatusPlanned, msg:sbdStatusDone); a blank status counts as `backlog`. | — |
| SBD-03.c | backlog | The column's heading is msg:sbdRequirements. | — |
| SBD-04 | backlog | The Requirements column and the Issues column each have the shared filter (UIC-21) for the feature, for the requirement and for the status. | — |
| SBD-04.a | backlog | The feature filter's choices are the features of what the column lists (msg:sbdFilterFeature). | — |
| SBD-04.b | backlog | The requirement filter's choices are the requirement IDs of what the column lists (msg:sbdFilterRequirement). | — |
| SBD-04.c | backlog | The status filter's choices are the four statuses (msg:sbdFilterStatus). | — |
| SBD-04.d | backlog | An entry is listed when it meets all three filters, and the column shows how many entries are listed out of all (msg:sbdShownOf, {shown} the entries listed, {total} all entries). | — |
| SBD-05 | backlog | The Issues column lists the open issues read from the issue tracker, each with its number, title, status, feature, requirement and assignee; its heading is msg:sbdIssues. | — |
| SBD-05.a | backlog | An issue's status is the one of its labels `proposed`, `backlog`, `planned` or `done`; an issue with none counts as `backlog`. | — |
| SBD-05.b | backlog | An issue's feature is the name after `feature:` in its labels. | — |
| SBD-05.c | backlog | An issue's requirement is the ID on the line starting `Requirement:` in its description. | — |
| SBD-05.d | backlog | An issue without a feature or a requirement shows a dash in its place. | — |
| SBD-05.e | backlog | The issue list holds at most the number of issues in DEF-01, newest first, and says when more exist (msg:sbdIssuesTruncated, with the number as {limit}). | — |
| SBD-06 | backlog | The board along the top shows the Backlog block, then the add control, then the blocks of the sprint. | — |
| SBD-06.a | backlog | The Backlog block (heading msg:sbdBacklog) holds the requirements and the issues whose status is `backlog`. | — |
| SBD-06.b | backlog | The add control (msg:sbdAddBlock) asks which kind of block (msg:sbdBlockKind, msg:sbdKindStory, msg:sbdKindEpic, msg:sbdKindSprint) and its name (msg:sbdBlockName), and adds the block at the end of the board; its Cancel is msg:cancel and its Save is msg:sbdSave. | — |
| SBD-06.c | backlog | A story can sit in an epic or in a sprint, an epic can sit in a sprint, and a sprint sits at the top of the board; a block is drawn inside the block it sits in. | — |
| SBD-06.d | backlog | A story holds the requirements and the issues that were dropped on it and shows each with its ID or number and title. | — |
| SBD-06.e | backlog | The board's blocks start at the left edge of the board area, in one row, and the row scrolls sideways inside the board area when the blocks do not fit; the board is never centered. | — |
| SBD-07 | backlog | The Product Owner and the team build the sprint by dragging and dropping. | — |
| SBD-07.a | backlog | A block can be dragged onto a block it may sit in (SBD-06.c) and then sits there, written to the sprint file (SBD-02.d). | — |
| SBD-07.b | backlog | A block can be dragged to the top of the board and then sits there if it may (SBD-06.c). | — |
| SBD-07.c | backlog | A requirement or an issue can be dropped only on the Backlog block or on a story. | — |
| SBD-07.d | backlog | Dropping a `proposed` requirement or issue on the Backlog block sets its status to `backlog`. | — |
| SBD-07.e | backlog | Dropping a requirement or an issue on a story sets its status to `planned` and records it in the story's Members rows. | — |
| SBD-07.f | backlog | Dropping a requirement or an issue that is in a story on the Backlog block removes it from the story's Members rows and sets its status to `backlog`. | — |
| SBD-07.g | backlog | A drop that would move a status down in any other way, or that is not allowed by SBD-07.c, changes nothing and says why (msg:sbdMoveRefused, with the reason as {reason}). | — |
| SBD-07.h | backlog | Dropping something where it already is changes nothing. | — |
| SBD-08 | backlog | A story that sits in a sprint has an Accept control (msg:sbdAccept). | — |
| SBD-08.a | backlog | Accept sets the status of every requirement and issue of the story to `done`. | — |
| SBD-08.b | backlog | A story that does not sit in a sprint has no Accept control. | — |
| SBD-09 | backlog | The Issues column has a New issue control (msg:sbdNewIssue) that opens a form to enter an issue: a title, a description, and dropdowns for the feature, the requirement and the status. | — |
| SBD-09.a | backlog | The form's requirement dropdown lists the requirements of the chosen feature, and choosing another feature clears it. | — |
| SBD-09.b | backlog | The status dropdown offers the four statuses and nothing else, and starts as `backlog`. | — |
| SBD-09.c | backlog | The Save control (msg:sbdSave) stays off until the title is filled; the form's labels are msg:sbdIssueTitle, msg:sbdIssueDescription, msg:sbdFilterFeature, msg:sbdFilterRequirement and msg:sbdFilterStatus. | — |
| SBD-09.d | backlog | Saving creates one issue in the issue tracker with the label `issue`, its `feature:` label (SBD-05.b), its status label (SBD-05.a) and its `Requirement:` line (SBD-05.c). | — |
| SBD-09.e | backlog | When the issue cannot be created the form stays filled and says why (msg:sbdIssueFailed, with the reason as {reason}). | — |
| SBD-09.f | backlog | The form has a Cancel control (msg:cancel) that closes it without creating an issue. | — |
| SBD-09.g | backlog | After saving, the new issue is listed in the Issues column. | — |
| SBD-10 | backlog | The ScrumBoard shows usage against estimate on every story and sprint block. | — |
| SBD-10.a | backlog | A story's estimate and usage can be changed on its block and are written to the sprint file (SBD-02.d); labels msg:sbdEstimate and msg:sbdUsage. | — |
| SBD-10.b | backlog | A sprint or an epic shows the sum of the estimates and the sum of the usage of the stories it holds. | — |
| SBD-10.c | backlog | Each of these blocks shows its usage and estimate as a bar, in the warn color (THM-02.j) when usage is above the estimate. | — |
| SBD-11 | backlog | The Requirements column lists each requirement with its sub-requirements beneath it as an outline. | — |
| SBD-11.a | backlog | A sub-requirement is indented from its requirement by the sub-requirement indent in DEF-01. | — |
| SBD-11.b | backlog | A requirement that has sub-requirements shows a triangle that collapses or expands them, pointing right when they are collapsed and down when they are expanded; a requirement without sub-requirements shows no triangle (msg:sbdExpandRow, msg:sbdCollapseRow name it). | — |
| SBD-11.c | backlog | A switch above the list (msg:sbdExpandAll) collapses every requirement's sub-requirements, so only the requirements with no parent remain visible, or expands them all again at once; collapsing never hides a requirement that has no parent. | — |
| SBD-11.d | backlog | When the page opens every requirement shows without its sub-requirements, so the column is never empty while requirements are listed. | — |
| SBD-11.e | backlog | The outline is built from the listed entries: a sub-requirement whose requirement is not listed is listed on its own, without an indent. | — |
| SBD-11.f | backlog | The switch of SBD-11.c sits on the row of the column's filters, at the right end of that row. | — |
| SBD-11.g | backlog | The Issues column lists the issues under the feature they belong to: a feature row with a triangle that collapses or expands its issues, the same control as SBD-11.b; collapsing hides only the issues and leaves every feature row visible. | — |
| SBD-11.h | backlog | An issue belongs to its feature (SBD-05.b) or, when it has none, to the feature of the requirement it names (SBD-05.c); an issue with neither is a top-level row under no feature and always stays visible. | — |
| SBD-11.i | backlog | The Issues column has the switch of SBD-11.c on its filter row, collapsing or expanding the issues of every feature, and opens collapsed (SBD-11.d). | — |
| SBD-15 | backlog | The page fits the window and every part of it scrolls on its own. | — |
| SBD-15.a | backlog | The page itself does not scroll: the board takes the share of the window's height in DEF-01 and the columns below it take the rest. | — |
| SBD-15.b | backlog | Each column, and each block's contents, has its own vertical scrollbar when its content is longer than its area. | — |
| SBD-15.c | backlog | Nothing is clipped or overflows at the window sizes in DEF-01. | — |
| SBD-12 | backlog | The Agent progress column (heading msg:sbdAgentProgress) shows the usage chart (SBD-14) and then one bar for each progress file the server reads. | — |
| SBD-12.a | backlog | A bar shows the file's name as the label, the fraction `done/total` as the bar and the text `done/total`. | — |
| SBD-12.b | backlog | With no progress folder, or none with a progress file, the column is empty and says so (msg:sbdNoProgress). | — |
| SBD-12.c | backlog | The bars are read again at the interval in DEF-01 and on Reload (SBD-01.c). | — |
| SBD-12.d | backlog | A progress file whose content is not `done/total` shows no bar. | — |
| SBD-13 | backlog | One command starts the server, which serves the web app and gives it the data over HTTP; the progress folder is given with `--progress <dir>`. | — |
| SBD-13.a | backlog | The server listens on the local machine only, on the port given with `--port` (it starts as the port in DEF-01), and answers only a request whose Host is that address or `localhost` and whose Origin, when present, matches it. | — |
| SBD-13.b | backlog | The server answers only these requests: read and write the sprint file, list the requirements, set a requirement's status, list the issues, create an issue, set an issue's status, create a requirement, list the progress, read the usage file; any other request is answered not found. | — |
| SBD-13.c | backlog | The server checks every status change: a status only moves up the order `proposed`, `backlog`, `planned`, `done`, and the only move down is `planned` to `backlog`; any other change is refused with its reason. | — |
| SBD-13.d | backlog | A requirement's status change edits only the status cell of that row in its file, and the file is replaced as a whole or not at all. | — |
| SBD-13.e | backlog | An issue's status change removes the other status labels and adds the new one, creating the label when it is missing, and leaves the issue's open or closed state as it is. | — |
| SBD-13.f | backlog | The server runs the issue tracker's commands with each argument passed separately and never through a shell, and holds no token or secret. | — |
| SBD-13.g | backlog | When the issue tracker's command fails, the server answers with its reason and its other answers keep working. | — |
| SBD-13.h | backlog | When the web app cannot reach the server it says so (msg:sbdServerUnreachable, with the reason as {reason}). | — |
| SBD-14 | backlog | At the top of the Agent progress column a usage chart (heading msg:sbdUsageChart) shows the readings of the 5-hour session and of the 7-day week against the estimates, read from `SCRUM.d/usage.md`. | — |
| SBD-14.a | backlog | The usage file has a Usage table whose rows are: block ID, estimate session %, estimate weekly %, before session %, before weekly %, after session % and after weekly %; a cell that is not known is a dash. | — |
| SBD-14.b | backlog | The chart has two meters, one for the session (msg:sbdMeterSession) and one for the week (msg:sbdMeterWeek), each on a scale from 0 to 100. | — |
| SBD-14.c | backlog | For each row with a before and an after reading, a meter draws a bar from the before reading to the after reading in the data color of the theme, and names the block. | — |
| SBD-14.d | backlog | For each row with an estimate, a meter draws the estimate as a lighter band from the before reading, as wide as the estimate plus and minus the share in DEF-01. | — |
| SBD-14.e | backlog | For the next planned sprint the meter draws the projected after reading, the before reading plus the estimate, as a band that ends in a mark; a projection is never drawn as a dot. | — |
| SBD-14.f | backlog | A value above 100 is drawn as a triangle on the 100 line with the real number in its tooltip. | — |
| SBD-14.g | backlog | When the usage file is missing or has no Usage table the chart is empty and says so (msg:sbdNoUsage). | — |
| SBD-13.i | backlog | Text from the issue tracker's commands is read as Unicode (the UTF 8 form) and the server's answers declare that character set, so characters such as ’, — and › show as written (a defect found in use: they showed as â€™, â€” and â€º). | — |
| SBD-16 | backlog | The three add controls (a new block on the board, a new requirement in the Requirements column, a new issue in the Issues column) are one shared control that opens one shared add popup. | — |
| SBD-16.a | backlog | Each add control is a `+` button whose tooltip and accessible name are msg:sbdAddBlock, msg:sbdNewRequirement or msg:sbdNewIssue. | — |
| SBD-16.b | backlog | The popup for a new requirement or a new issue has an optional ID field (msg:sbdIdOptional): the ID of the new requirement, or for an issue the ID of the requirement it names; it may be left empty. | — |
| SBD-16.c | backlog | The popup for a new requirement has a statement field (msg:sbdRequirementStatement) and the one for a new issue has the title and description of SBD-09. | — |
| SBD-16.d | backlog | When the ID is empty and text has been entered, the popup lists suggested places (heading msg:sbdSuggestions), at most the number in DEF-01, best first; with none it says so (msg:sbdNoSuggestions). | — |
| SBD-16.e | backlog | A suggestion for a requirement gives its feature, its next free ID and, when it fits under an existing requirement, that parent (msg:sbdSuggestNew, msg:sbdSuggestSub); a suggestion for an issue gives a feature and the requirement it names. | — |
| SBD-16.f | backlog | Suggestions are ranked by how many words of the entered text appear in the feature names and in the statements of the requirements; the ScrumBoard computes them and calls no outside service. | — |
| SBD-16.g | backlog | Choosing a suggestion fills the feature, the ID and the parent; the user can instead type their own feature and ID. | — |
| SBD-16.h | backlog | Saving a new requirement writes a new row with status `proposed` into its feature's requirement file, after its parent's last sub-requirement when it has a parent and at the end of the file's table otherwise. | — |
| SBD-16.i | backlog | A new ID is refused with its reason when it exists already, when its prefix is not the feature's, or when its parent does not exist. | — |
| SBD-16.j | backlog | Saving a new issue creates it as SBD-09.d says, with the feature and the requirement of the chosen place. | — |
| SBD-13.j | backlog | The server also answers the request to create a requirement: it checks SBD-16.i, adds the row as SBD-16.h says, changes nothing else in the file, and replaces the file as a whole or not at all. | — |
