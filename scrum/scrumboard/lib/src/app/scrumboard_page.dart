import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scrumboard/src/api/scrumboard_api.dart';
import 'package:scrumboard/src/features/requirement_drag_data.dart';
import 'package:scrumboard/src/api/reload_scope.dart';
import 'package:scrumboard/src/l10n/messages.dart';
import 'package:scrumboard/src/theme/scrum_theme.dart';

/// The ScrumBoard page (SCB-15.a): the page itself does not scroll. Three rows
/// share the height 40 / 20 / 40. The top row holds [board]; the bottom row has
/// three equal columns, [features] first, then the Issues and Questions
/// placeholders; the middle row is a placeholder. Each part scrolls on its own
/// (SCB-15.b): a pane fills the space it gets and scrolls inside.
class ScrumBoardPage extends StatefulWidget {
  const ScrumBoardPage({
    super.key,
    required this.api,
    required this.board,
    required this.features,
    this.pollInterval = scrumPollInterval,
    this.zoomPercent = scrumZoomDefault,
    this.onZoomChanged,
    this.onToggleTheme,
  });

  final ScrumBoardApi api;
  final Widget board;
  final Widget features;

  /// SCB-22: how often the change stamp is asked for (tests inject a short one).
  final Duration pollInterval;

  /// SCB-20.a: the current zoom (percent) and the callback that sets a new one.
  final int zoomPercent;
  final ValueChanged<int>? onZoomChanged;

  /// SCB-20: toggles the light and dark themes.
  final VoidCallback? onToggleTheme;

  @override
  State<ScrumBoardPage> createState() => _ScrumBoardPageState();
}

class _ScrumBoardPageState extends State<ScrumBoardPage> {
  final ReloadController _reload = ReloadController();
  Timer? _poll;
  String? _stamp;
  bool _polling = false;
  bool _overBin = false;

  @override
  void initState() {
    super.initState();
    _poll = Timer.periodic(widget.pollInterval, (_) => _checkStamp());
  }

  /// SCB-22: a stamp that differs from the first one seen reloads every pane.
  /// A failed poll is ignored.
  Future<void> _checkStamp() async {
    if (_polling) return;
    _polling = true;
    try {
      final stamp = await widget.api.changeStamp();
      if (!mounted) return;
      if (_stamp == null) {
        _stamp = stamp;
      } else if (stamp != _stamp) {
        _stamp = stamp;
        _reload.reload();
      }
    } on Object {
      // The next poll tries again.
    } finally {
      _polling = false;
    }
  }

  /// SCB-19: a requirement dropped on the bin.
  Future<void> _retire(RequirementDragData data) async {
    final messenger = ScaffoldMessenger.of(context);
    final text = context.msg;
    final result = await widget.api.retire(data.id);
    if (!mounted) return;
    if (result.ok) {
      _reload.reload();
    } else {
      messenger.showSnackBar(SnackBar(content: Text(text('scbMoveRefused', {'reason': result.reason}))));
    }
  }

  @override
  void dispose() {
    _poll?.cancel();
    _reload.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final zoom = widget.zoomPercent;
    final onZoom = widget.onZoomChanged;
    return ReloadScope(
      controller: _reload,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: scrumToolbarHeight,
          actions: [
            IconButton(
              key: const ValueKey('scbZoomOut'),
              tooltip: context.msg('scbZoomOut'),
              icon: const Icon(Icons.zoom_out),
              onPressed: onZoom != null && zoom > scrumZoomMin ? () => onZoom(zoom - scrumZoomStep) : null,
            ),
            IconButton(
              key: const ValueKey('scbZoomIn'),
              tooltip: context.msg('scbZoomIn'),
              icon: const Icon(Icons.zoom_in),
              onPressed: onZoom != null && zoom < scrumZoomMax ? () => onZoom(zoom + scrumZoomStep) : null,
            ),
            IconButton(
              key: const ValueKey('scbTheme'),
              tooltip: context.msg('scbTheme'),
              icon: const Icon(Icons.brightness_6),
              onPressed: widget.onToggleTheme,
            ),
            DragTarget<RequirementDragData>(
              onWillAcceptWithDetails: (_) {
                setState(() => _overBin = true);
                return true;
              },
              onLeave: (_) => setState(() => _overBin = false),
              onAcceptWithDetails: (d) {
                setState(() => _overBin = false);
                _retire(d.data);
              },
              builder: (context, candidate, rejected) => Tooltip(
                message: context.msg('scbRetire'),
                child: Padding(
                  key: const ValueKey('scbRetire'),
                  padding: const EdgeInsets.all(scrumPartGap),
                  child: Icon(
                    Icons.delete_outline,
                    color: _overBin ? Theme.of(context).colorScheme.error : null,
                  ),
                ),
              ),
            ),
            IconButton(
              key: const ValueKey('scbAdd'),
              tooltip: context.msg('scbAdd'),
              icon: const Icon(Icons.add),
              onPressed: null,
            ),
            const SizedBox(width: scrumPartGap),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(scrumPagePadding),
          child: Column(
            children: [
              Expanded(flex: scrumTopRowFlex, child: _Part(key: const ValueKey('scbRowTop'), child: widget.board)),
              const SizedBox(height: scrumPartGap),
              const Expanded(flex: scrumMiddleRowFlex, child: _Part(key: ValueKey('scbRowMiddle'))),
              const SizedBox(height: scrumPartGap),
              Expanded(
                flex: scrumBottomRowFlex,
                child: Row(
                  key: const ValueKey('scbRowBottom'),
                  children: [
                    Expanded(child: _Part(key: const ValueKey('scbColumnFeatures'), child: widget.features)),
                    const SizedBox(width: scrumPartGap),
                    const Expanded(child: _Part(key: ValueKey('scbColumnIssues'))),
                    const SizedBox(width: scrumPartGap),
                    const Expanded(child: _Part(key: ValueKey('scbColumnQuestions'))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One framed area of the page; empty when it is a placeholder.
class _Part extends StatelessWidget {
  const _Part({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border.all(color: scheme.outlineVariant, width: scrumPanelBorderWidth),
        borderRadius: BorderRadius.circular(scrumPanelRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(scrumPanelRadius),
        child: SizedBox.expand(child: child),
      ),
    );
  }
}
