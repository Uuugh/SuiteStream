import 'package:flutter/material.dart';
import 'package:scrumboard/src/api/reload_scope.dart';
import 'package:scrumboard/src/api/scrumboard_api.dart';
import 'package:scrumboard/src/board/board_tokens.dart';
import 'package:scrumboard/src/l10n/messages.dart';

/// The board along the top (SCB-06): the Backlog block fixed at the left and
/// the sprint timeline scrolling sideways under it. Read only.
class BacklogTimeline extends StatefulWidget {
  const BacklogTimeline({super.key, required this.api});

  final ScrumBoardApi api;

  @override
  State<BacklogTimeline> createState() => _BacklogTimelineState();
}

class _Data {
  const _Data(this.requirements, this.sprint);
  final List<Requirement> requirements;
  final SprintFile sprint;

  Map<String, Requirement> get byId => {for (final r in requirements) r.id: r};

  List<SprintBlock> childrenOf(String id, Set<String> trail) => [
        for (final b in sprint.blocks)
          if (b.parent == id && !trail.contains(b.id)) b,
      ];

  List<SprintMember> membersOf(String id) => [
        for (final m in sprint.members)
          if (m.block == id) m,
      ];
}

class _BacklogTimelineState extends State<BacklogTimeline> {
  final ScrollController _timeline = ScrollController();
  Future<_Data>? _future;
  int? _generation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final g = ReloadScope.generationOf(context);
    if (g != _generation) {
      _generation = g;
      _future = _load();
    }
  }

  Future<_Data> _load() async {
    final results = await Future.wait<Object>([widget.api.requirements(), widget.api.sprint()]);
    return _Data(results[0] as List<Requirement>, results[1] as SprintFile);
  }

  @override
  void dispose() {
    _timeline.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_Data>(
      future: _future,
      builder: (context, snap) {
        if (snap.hasError) return _LoadError(error: snap.error!);
        final data = snap.data;
        if (data == null) return const Center(child: CircularProgressIndicator());
        return _Board(key: ValueKey(data), data: data, controller: _timeline);
      },
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.error});
  final Object error;

  @override
  Widget build(BuildContext context) {
    final e = error;
    final text = e is ScrumBoardUnreachableException
        ? context.msg('scbServerUnreachable', {'reason': e.reason})
        : context.msg('scbLoadFailed', {'reason': e is ScrumBoardApiException ? e.reason : '$e'});
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(BoardTokens.padding),
        child: Text(
          text,
          key: const ValueKey('board-error'),
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
  }
}

class _Board extends StatefulWidget {
  const _Board({super.key, required this.data, required this.controller});
  final _Data data;
  final ScrollController controller;

  @override
  State<_Board> createState() => _BoardState();
}

class _BoardState extends State<_Board> {
  @override
  void initState() {
    super.initState();
    // SCB-06.e: the timeline opens scrolled to its right end.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = widget.controller;
      if (mounted && c.hasClients) c.jumpTo(c.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final backlog = data.requirements.where((r) => r.status == 'backlog').toList();
    final ids = {for (final b in data.sprint.blocks) b.id};
    final top = [
      for (final b in data.sprint.blocks)
        if (b.parent == null || !ids.contains(b.parent)) b,
    ];
    const left = BoardTokens.blockWidth + 2 * BoardTokens.gap;
    return Stack(
      children: [
        Positioned.fill(
          child: Scrollbar(
            controller: widget.controller,
            child: SingleChildScrollView(
              key: const ValueKey('timeline'),
              controller: widget.controller,
              scrollDirection: Axis.horizontal,
              // The timeline starts to the right of the Backlog block and
              // slides in from behind it (SCB-06).
              padding: const EdgeInsets.fromLTRB(left, BoardTokens.gap, BoardTokens.gap, BoardTokens.gap),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final b in top)
                    Padding(
                      padding: const EdgeInsets.only(right: BoardTokens.gap),
                      // SCB-06.g: every top-level block has the same width.
                      child: SizedBox(
                        width: BoardTokens.blockWidth,
                        child: _BlockCard(block: b, data: data, trail: {b.id}, topLevel: true),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: BoardTokens.gap,
          top: BoardTokens.gap,
          bottom: BoardTokens.gap,
          width: BoardTokens.blockWidth,
          child: _BacklogBlock(backlog: backlog),
        ),
      ],
    );
  }
}

/// A bordered surface with a heading row and a body that scrolls inside.
class _Frame extends StatelessWidget {
  const _Frame({required this.heading, required this.body});
  final Widget heading;
  final List<Widget> body;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(BoardTokens.radius),
        border: Border.all(color: cs.outlineVariant, width: BoardTokens.borderWidth),
      ),
      child: Padding(
        padding: const EdgeInsets.all(BoardTokens.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            heading,
            // SCB-06.g: the contents scroll inside the block.
            Expanded(child: ListView(children: body)),
          ],
        ),
      ),
    );
  }
}

class _BacklogBlock extends StatelessWidget {
  const _BacklogBlock({required this.backlog});
  final List<Requirement> backlog;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final features = <String, List<Requirement>>{};
    for (final r in backlog) {
      features.putIfAbsent(r.feature, () => []).add(r);
    }
    return KeyedSubtree(
      key: const ValueKey('backlog-block'),
      child: _Frame(
        heading: Row(
          children: [
            Text(context.msg('scbBacklog'), style: t.titleSmall),
            const SizedBox(width: BoardTokens.gap),
            Text(backlog.length.toString(), key: const ValueKey('backlog-count'), style: t.labelMedium),
          ],
        ),
        body: [
          for (final e in features.entries) ...[
            Padding(
              padding: const EdgeInsets.only(top: BoardTokens.gap),
              child: Text(e.key, style: t.labelLarge),
            ),
            for (final r in e.value) _ItemRow(id: r.id, title: r.statement),
          ],
        ],
      ),
    );
  }
}

String _kindKey(String kind) => switch (kind) {
      'story' => 'scbKindStory',
      'epic' => 'scbKindEpic',
      _ => 'scbKindSprint',
    };

/// One sprint-file block. A top-level block fills the height it is given and
/// scrolls inside; a nested block is drawn inside its parent (SCB-06.c) and is
/// as tall as its own content.
class _BlockCard extends StatelessWidget {
  const _BlockCard({required this.block, required this.data, required this.trail, this.topLevel = false});

  final SprintBlock block;
  final _Data data;

  /// Block IDs on the way down, so a loop in the parents cannot recurse forever.
  final Set<String> trail;
  final bool topLevel;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final byId = data.byId;
    final heading = Row(
      children: [
        Flexible(child: Text(block.name, style: t.titleSmall, overflow: TextOverflow.ellipsis)),
        const SizedBox(width: BoardTokens.gap),
        Text(context.msg(_kindKey(block.kind)), style: t.labelSmall),
      ],
    );
    final body = [
      // SCB-06.d: each member with its ID and title.
      for (final m in data.membersOf(block.id)) _ItemRow(id: m.item, title: byId[m.item]?.statement),
      for (final c in data.childrenOf(block.id, trail))
        Padding(
          padding: const EdgeInsets.only(top: BoardTokens.nestGap),
          child: _BlockCard(block: c, data: data, trail: {...trail, c.id}),
        ),
    ];
    if (topLevel) return KeyedSubtree(key: ValueKey('block-${block.id}'), child: _Frame(heading: heading, body: body));
    return DecoratedBox(
      key: ValueKey('block-${block.id}'),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(BoardTokens.nestedRadius),
        border: Border.all(color: cs.outlineVariant, width: BoardTokens.borderWidth),
      ),
      child: Padding(
        padding: const EdgeInsets.all(BoardTokens.nestGap),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [heading, ...body]),
      ),
    );
  }
}

/// One requirement or issue with its ID (or number) and title (SCB-06.d).
class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.id, required this.title});
  final String id;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: BoardTokens.nestGap),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: cs.outlineVariant, width: BoardTokens.borderWidth),
          borderRadius: BorderRadius.circular(BoardTokens.nestedRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(BoardTokens.nestGap),
          child: Text.rich(
            TextSpan(children: [
              TextSpan(text: id, style: t.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
              if (title != null) TextSpan(text: '  $title', style: t.bodyMedium),
            ]),
            key: ValueKey('item-$id'),
          ),
        ),
      ),
    );
  }
}
