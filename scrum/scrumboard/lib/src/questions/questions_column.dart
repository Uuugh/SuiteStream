import 'package:flutter/material.dart';

import 'package:scrumboard/src/api/reload_scope.dart';
import 'package:scrumboard/src/api/scrumboard_api.dart';
import 'package:scrumboard/src/features/scb_filter_bar.dart';
import 'package:scrumboard/src/l10n/messages.dart';
import 'package:scrumboard/src/theme/scrum_theme.dart';

/// The status of an item that waits for the Executive (SCB-17.c).
const String _open = 'open';

/// SCB-17.b: the reason of a write whose item an agent changed or deleted.
const String _gone = 'gone';

/// DEF-01: a hint wraps rather than being cut in a narrow column or a long
/// language.
const int _hintLines = 3;

String _itemKind(BoardItem i) => i.kind;

/// Numbers repeat across the two files, so kind and number together identify
/// an item.
String _itemId(BoardItem i) => '${i.kind}-${i.number}';
String _itemStatus(BoardItem i) => i.status;

/// A verification is named by the PBI it waits for, a question by its number.
String _itemIdText(BoardItem i) => i.pbi ?? i.number.toString();

String _kindText(Messages m, String kind) => switch (kind) {
      BoardItem.question => m('scbKindQuestion'),
      BoardItem.verification => m('scbKindVerification'),
      _ => kind,
    };

String _itemStatusText(Messages m, String status) => switch (status) {
      'open' => m('scbStatusOpen'),
      'answered' => m('scbAnswered'),
      'accepted' => m('scbAccepted'),
      'returned' => m('scbReturned'),
      _ => status,
    };

/// SCB-04: the filters of the Questions and Verifications column: kind
/// (msg:scbFilterKind), number or PBI (msg:scbFilterItem) and status.
const questionFilterFields = ScbFilterFields<BoardItem>(
  group: _itemKind,
  id: _itemId,
  status: _itemStatus,
  statuses: ['open', 'answered', 'accepted', 'returned'],
  groupName: 'scbFilterKind',
  idName: 'scbFilterItem',
  groupText: _kindText,
  statusText: _itemStatusText,
  idText: _itemIdText,
);

/// SCB-17.c: the one order of the column, merged from the API's two lists
/// (each already newest first): the open questions, then the open
/// verifications, then the answered (or closed) questions, then the accepted
/// or returned verifications. Within each group the API's order is kept.
List<BoardItem> questionColumnOrder(List<BoardItem> questions, List<BoardItem> verifications) => [
      ...questions.where((i) => i.status == _open),
      ...verifications.where((i) => i.status == _open),
      ...questions.where((i) => i.status != _open),
      ...verifications.where((i) => i.status != _open),
    ];

/// SCB-17: the third column of the bottom row: the questions the agents ask
/// the Executive and the verifications waiting for the Executive. It fills
/// the space the page gives it and scrolls inside with its own scrollbar
/// (SCB-17.d, SCB-15.b).
class QuestionsColumn extends StatefulWidget {
  const QuestionsColumn({super.key, required this.api});

  final ScrumBoardApi api;

  @override
  State<QuestionsColumn> createState() => _QuestionsColumnState();
}

class _QuestionsColumnState extends State<QuestionsColumn> {
  int? _loadedGeneration;
  List<BoardItem> _all = const [];
  String? _error;
  bool _loading = true;

  // SCB-04: what the user chose to hide, kept in memory only.
  ScbHiddenFilters _hidden = const ScbHiddenFilters();

  final ScrollController _scroll = ScrollController();

  // SCB-17.b: the answer or result typed under each open item, by item id.
  final Map<String, TextEditingController> _typed = {};

  // SCB-17.b: the items whose write is on its way; their controls wait.
  final Set<String> _writing = {};

  // SCB-17.b: what the last write said when it wrote nothing
  // (msg:scbItemGone, a refusal or an unreachable server).
  String? _notice;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // SCB-01.c, SCB-22: read again whenever the page's generation changes.
    final generation = ReloadScope.generationOf(context);
    if (_loadedGeneration != generation) {
      _loadedGeneration = generation;
      _load();
    }
  }

  @override
  void didUpdateWidget(QuestionsColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Another API reads other files: read again from it.
    if (oldWidget.api != widget.api) _load();
  }

  @override
  void dispose() {
    _scroll.dispose();
    for (final c in _typed.values) {
      c.dispose();
    }
    super.dispose();
  }

  // Counts reads; only the latest read may apply its answer, so an older
  // read that finishes last never shows a stale list.
  int _reads = 0;

  Future<void> _load() async {
    final m = context.msg;
    final read = ++_reads;
    try {
      final lists = await widget.api.boardItems();
      if (!mounted || read != _reads) return;
      setState(() {
        _all = questionColumnOrder(lists.questions, lists.verifications);
        _error = null;
        _loading = false;
        _dropClosedFields();
      });
    } on ScrumBoardUnreachableException catch (e) {
      if (read == _reads) _fail(m('scbServerUnreachable', {'reason': e.reason}));
    } on ScrumBoardApiException catch (e) {
      if (read == _reads) _fail(m('scbLoadFailed', {'reason': e.reason}));
    }
  }

  /// Drops the typed text of every item that is no longer open (answered,
  /// accepted, returned or gone).
  void _dropClosedFields() {
    final open = {for (final i in _all) if (i.status == _open) _itemId(i)};
    _typed.removeWhere((id, c) {
      if (open.contains(id)) return false;
      c.dispose();
      return true;
    });
  }

  TextEditingController _field(String id) => _typed.putIfAbsent(id, TextEditingController.new);

  /// SCB-17.b: writes one answer or result through [write]. `ok` reads the
  /// column again, so the item stays listed with its new status; `gone`
  /// says msg:scbItemGone and reads again; a refusal (400) or an unreachable
  /// server is shown and nothing else changes.
  Future<void> _write(BoardItem item, Future<({bool ok, String reason})> Function() write) async {
    final m = context.msg;
    final id = _itemId(item);
    setState(() {
      _writing.add(id);
      _notice = null;
    });
    String? notice;
    var reload = false;
    try {
      final result = await write();
      if (result.ok) {
        reload = true;
      } else if (result.reason == _gone) {
        notice = m('scbItemGone');
        reload = true;
      } else {
        notice = result.reason;
      }
    } on ScrumBoardUnreachableException catch (e) {
      notice = m('scbServerUnreachable', {'reason': e.reason});
    } on ScrumBoardApiException catch (e) {
      notice = e.reason;
    }
    if (!mounted) return;
    setState(() {
      _writing.remove(id);
      _notice = notice;
    });
    if (reload) await _load();
  }

  void _answer(BoardItem item, String answer) =>
      _write(item, () => widget.api.answerQuestion(item.number, item.heading, answer));

  void _result(BoardItem item, String status) => _write(
      item, () => widget.api.setVerificationResult(item.number, item.heading, _field(_itemId(item)).text, status));

  void _fail(String text) {
    if (!mounted) return;
    setState(() {
      _error = text;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final m = context.msg;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // SCB-17: the heading is text only, with no count.
        Padding(
          padding: const EdgeInsets.all(scrumPartGap),
          child: Text(m('scbQuestions'), key: const ValueKey('scb-questions-heading'), style: theme.textTheme.titleMedium),
        ),
        // SCB-04: the shared filter bar, always with the question fields.
        ScbFilterBar<BoardItem>(
          items: _all,
          fields: questionFilterFields,
          hidden: _hidden,
          onChanged: (h) => setState(() => _hidden = h),
        ),
        // SCB-17.b: what the last write said when it wrote nothing.
        if (_notice != null)
          Padding(
            padding: const EdgeInsets.all(scrumErrorPadding),
            child: Text(_notice!,
                key: const ValueKey('scb-questions-notice'), style: TextStyle(color: theme.colorScheme.error)),
          ),
        Expanded(child: _body(m, theme)),
      ],
    );
  }

  Widget _body(Messages m, ThemeData theme) {
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(scrumErrorPadding),
        child: Text(_error!,
            key: const ValueKey('scb-questions-error'), style: TextStyle(color: theme.colorScheme.error)),
      );
    }
    if (_loading) return const Center(child: CircularProgressIndicator());
    // SCB-17.c: with no item the column says so.
    if (_all.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(scrumPagePadding),
        child: Text(m('scbNoQuestions'), key: const ValueKey('scb-no-questions'), style: theme.textTheme.bodyMedium),
      );
    }
    final listed = _hidden.applyWith(_all, questionFilterFields);
    // SCB-17.d: the column's own scrollbar.
    return Scrollbar(
      key: const ValueKey('scb-questions-scrollbar'),
      controller: _scroll,
      thumbVisibility: true,
      child: ListView.builder(
        key: const ValueKey('scb-questions-list'),
        controller: _scroll,
        itemCount: listed.length,
        itemBuilder: (context, i) => _item(m, theme, listed[i]),
      ),
    );
  }

  Widget _item(Messages m, ThemeData theme, BoardItem item) {
    final id = _itemId(item);
    final pbi = item.pbi;
    // SCB-17.b: only an open item has answer controls; after a write it
    // stays listed with its new status and none.
    final open = item.status == _open;
    final busy = _writing.contains(id);
    return Container(
      key: ValueKey('scb-item-$id'),
      padding: const EdgeInsets.all(scrumPagePadding),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: theme.dividerColor))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The status token is right-aligned at the end of the first line,
          // as in the Features column (SCB-23); kind, number and PBI wrap
          // before it.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: scrumPartGap,
                  children: [
                    Text(_kindText(m, item.kind), style: theme.textTheme.labelLarge),
                    Text(item.number.toString(), style: theme.textTheme.labelLarge),
                    // SCB-17.a: each verification shows the PBI it waits for.
                    if (pbi != null)
                      Text(pbi,
                          key: ValueKey('scb-item-pbi-$id'),
                          style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
                  ],
                ),
              ),
              const SizedBox(width: scrumPartGap),
              Text(_itemStatusText(m, item.status),
                  key: ValueKey('scb-item-status-$id'),
                  style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary)),
            ],
          ),
          Text(item.heading, style: theme.textTheme.labelMedium),
          if (item.text.isNotEmpty) Text(item.text, style: theme.textTheme.bodySmall),
          for (final (n, choice) in item.choices.indexed)
            Padding(
              padding: const EdgeInsets.only(left: scrumPagePadding),
              child: open
                  // SCB-17.b: picking a choice writes that choice line,
                  // trimmed, its letter included.
                  ? TextButton(
                      key: ValueKey('scb-choice-$id-$n'),
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: scrumPartGap),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: busy ? null : () => _answer(item, choice.trim()),
                      child: Text(choice, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary)),
                    )
                  : Text(choice, style: theme.textTheme.bodySmall),
            ),
          if (item.answer.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: scrumPartGap),
              child: Text(item.answer,
                  key: ValueKey('scb-item-answer-$id'),
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ),
          if (open && item.kind == BoardItem.question) _answerControls(m, item, id, busy),
          if (open && item.kind == BoardItem.verification) _resultControls(m, item, id, busy),
        ],
      ),
    );
  }

  /// SCB-17.b: under an open question, the answer space (msg:scbAnswerHint)
  /// with the Answered button (msg:scbAnswered) to its right; typed text is
  /// written as typed. The button waits for some text.
  Widget _answerControls(Messages m, BoardItem item, String id, bool busy) {
    final typed = _field(id);
    return Padding(
      padding: const EdgeInsets.only(top: scrumPartGap),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: typed,
        builder: (context, value, _) => Row(
          children: [
            Expanded(
              child: TextField(
                key: ValueKey('scb-answer-field-$id'),
                controller: typed,
                enabled: !busy,
                decoration: InputDecoration(hintText: m('scbAnswerHint'), hintMaxLines: _hintLines, isDense: true),
              ),
            ),
            const SizedBox(width: scrumPartGap),
            FilledButton(
              key: ValueKey('scb-answered-$id'),
              onPressed: busy || value.text.trim().isEmpty ? null : () => _answer(item, value.text),
              child: Text(m('scbAnswered')),
            ),
          ],
        ),
      ),
    );
  }

  /// SCB-17.b: under an open verification, the result (msg:scbResultHint)
  /// with Accepted (msg:scbAccepted) and Returned (msg:scbReturned);
  /// Returned is disabled while the result is empty.
  Widget _resultControls(Messages m, BoardItem item, String id, bool busy) {
    final typed = _field(id);
    return Padding(
      padding: const EdgeInsets.only(top: scrumPartGap),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: typed,
        builder: (context, value, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              key: ValueKey('scb-result-field-$id'),
              controller: typed,
              enabled: !busy,
              decoration: InputDecoration(hintText: m('scbResultHint'), hintMaxLines: _hintLines, isDense: true),
            ),
            const SizedBox(height: scrumPartGap),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: scrumPartGap,
              runSpacing: scrumPartGap,
              children: [
                FilledButton(
                  key: ValueKey('scb-accepted-$id'),
                  onPressed: busy ? null : () => _result(item, 'accepted'),
                  child: Text(m('scbAccepted')),
                ),
                OutlinedButton(
                  key: ValueKey('scb-returned-$id'),
                  onPressed: busy || value.text.trim().isEmpty ? null : () => _result(item, 'returned'),
                  child: Text(m('scbReturned')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
