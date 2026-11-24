
## 2026-11-24 Nakamura
- model landed: scrum/scrumboard/lib/src/api/models.dart (`BoardItem`, with `BoardItem.question` and `BoardItem.verification` kind constants; `text`, `choices`, `answer` default to empty, `pbi` null for questions). Check: `flutter analyze lib/src/api/models.dart` -> No issues found.

## 2026-11-24 Tanaka

Tasks 2 and 3 (PBI-126) done: 44 PBIs have status In Review in `scrum/product_backlog.csv`; items 1-8 already covered 8 of them; verifications 9-44 added to `scrum/verifications.md` (one each, oldest first). For task 4 (Takahashi), PBI -> verification:

PBI-108 -> 1, PBI-107 -> 2, PBI-109 -> 3, PBI-106 -> 4, PBI-119 -> 5, PBI-120 -> 6, PBI-122 -> 7, PBI-092 -> 8,
PBI-011 -> 9, PBI-013 -> 10, PBI-014 -> 11, PBI-018 -> 12, PBI-037 -> 13, PBI-046 -> 14, PBI-047 -> 15, PBI-048 -> 16,
PBI-050 -> 17, PBI-051 -> 18, PBI-052 -> 19, PBI-053 -> 20, PBI-054 -> 21, PBI-057 -> 22, PBI-058 -> 23, PBI-059 -> 24,
PBI-060 -> 25, PBI-061 -> 26, PBI-062 -> 27, PBI-063 -> 28, PBI-068 -> 29, PBI-069 -> 30, PBI-070 -> 31, PBI-071 -> 32,
PBI-072 -> 33, PBI-077 -> 34, PBI-078 -> 35, PBI-079 -> 36, PBI-080 -> 37, PBI-081 -> 38, PBI-090 -> 39, PBI-097 -> 40,
PBI-098 -> 41, PBI-099 -> 42, PBI-101 -> 43, PBI-105 -> 44.

Checks taken from sprint review files where listed (Sprints 009 to 013). Suzuki: please read the wording of 9-44.

Task 9 (PBI-086) done: `ScrumBoardPage` has `required Widget questions`, shown in `scbColumnQuestions` (key already existed). `lib/main.dart` passes `const SizedBox.shrink()` until task 10b. No file outside mine constructs `ScrumBoardPage`; nothing needed from other owners.
- fake writes landed: scrum/scrumboard/lib/src/api/scrumboard_api.dart. `ScrumBoardApi` has `boardItems()`, `answerQuestion(number, heading, answer)`, `setVerificationResult(number, heading, result, status)`. `FakeScrumBoardApi(questionList:, verificationList:)` answers the lists as given (give them in column order); writes match number AND heading, set `answered` / `accepted` / `returned` and the answer, give `(ok: false, reason: 'gone')` when no item matches, and throw `ScrumBoardApiException` with statusCode 400 for an empty answer, a line break, or `returned` with an empty result (as the HTTP client will). Calls are in `answerCalls` and `resultCalls`; a write changes `changeStamp()`. `HttpScrumBoardApi` writes answer `(ok: false, reason: boardWritesNotAvailable)` until task 14. No other file implements `ScrumBoardApi`, so nothing outside my files needed a change.
- GET /api/questions landed (task 7): `lib/server/board_items.dart` (`readBoardItems`, `parseBoardItems`, `orderBoardItems`); route and stamp in `lib/server/server.dart`. `BoardItem.heading` is the text after `## <n>. `; `pbi` is the heading's first word when it is `PBI-<n>`.
- Tests: `flutter analyze lib test` -> No issues found; `flutter test` (in scrum/scrumboard) -> +207: All tests passed!

## 2026-11-24 Yamamoto
- keys landed: the 13 keys of the Keys table in the six `requirements/messages/app_*.arb` (all six languages), synced with `bash tool/sync_messages.sh` into `scrum/scrumboard/assets/messages/`.
- bar landed: `lib/src/features/scb_filter_bar.dart` has `ScbFilterFields<T>`, `const requirementFilterFields`, `ScbFilterBar<T>({items, fields, hidden, onChanged, trailing})` (null `fields` = requirements, asserted) and `ScbHiddenFilters.applyWith<T>(items, fields)`; `apply` and `shows` unchanged; widget keys unchanged. For Ito (task 10): give `fields: questionFilterFields` with `groupName: 'scbFilterKind'`, `idName: 'scbFilterItem'`, and filter the list with `hidden.applyWith(items, questionFilterFields)`. Note: `find.byType(ScbFilterBar)` no longer matches (the type is `ScbFilterBar<Requirement>` or `ScbFilterBar<BoardItem>`); find it with `find.descendant` of the column key and `find.byType(ScbFilterBar<BoardItem>)`.
- SCB-04 bar test on `BoardItem` is in `test/features/scb_filter_bar_test.dart`; the questions column is not built yet, so the bar sits under a stand-in `KeyedSubtree` keyed `scbColumnQuestions` and is found with `find.descendant` of it.
- Check: `flutter test` in scrum/scrumboard -> +199 All tests passed!

## 2026-11-24 Suzuki
- Verifications 9-44 read against their backlog rows: wording fixed in 12, 22 (light and dark added), 34, 41 (hard refresh added), 32 (names the SuiteStream server, `server/bin/server.dart`). Numbers, statuses and format unchanged.
- Decision, order in the Questions and Verifications column (task 10, SCB-17.c): one order across both kinds, as decided in planning ("Order in the column (Suzuki)", `sprint_planning.md`) and as SCB-17.c says for "the items": all open items first (open questions, then open verifications, each newest first, reverse file order), then all answered or closed items (answered questions, then accepted or returned verifications, each newest first). The API keeps its two lists; the column merges them in this order.
- Decision, SCB-04 and SCB-01.a: agreed, both stay status backlog. Each also covers Issues work (SCB-04 for the Issues column, PBI-082; SCB-01.a issue writes through the SuiteStream API, PBI-094) not in this sprint; setting them planned would let an accepted PBI-086 or PBI-125 mark them done with that part unbuilt. Their tests for this sprint's part still run and pass.
