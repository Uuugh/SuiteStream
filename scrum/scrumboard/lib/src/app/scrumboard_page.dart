import 'package:flutter/material.dart';
import 'package:scrumboard/src/api/reload_scope.dart';
import 'package:scrumboard/src/l10n/messages.dart';
import 'package:scrumboard/src/theme/scrum_theme.dart';

/// The ScrumBoard page (SCB-15.a): the page itself does not scroll. Three rows
/// share the height 40 / 20 / 40. The top row holds [board]; the bottom row has
/// three equal columns, [features] first, then the Issues and Questions
/// placeholders; the middle row is a placeholder. Each part scrolls on its own
/// (SCB-15.b): a pane fills the space it gets and scrolls inside.
class ScrumBoardPage extends StatefulWidget {
  const ScrumBoardPage({super.key, required this.board, required this.features});

  final Widget board;
  final Widget features;

  @override
  State<ScrumBoardPage> createState() => _ScrumBoardPageState();
}

class _ScrumBoardPageState extends State<ScrumBoardPage> {
  final ReloadController _reload = ReloadController();

  @override
  void dispose() {
    _reload.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ReloadScope(
      controller: _reload,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: scrumToolbarHeight,
          actions: [
            TextButton.icon(
              key: const ValueKey('scbReload'),
              onPressed: _reload.reload,
              icon: const Icon(Icons.refresh),
              label: Text(context.msg('scbReload')),
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
