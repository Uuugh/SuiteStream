// Not in test/: run by hand to regenerate scrum/deliverables/button_states_matrix.png
//   flutter test tool/button_matrix/button_matrix_test.dart --update-goldens
import 'dart:io';
import 'package:flutter/gestures.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suitestream/src/theme/suite_icons.dart';
import 'package:suitestream/src/theme/suite_theme.dart';

const _states = [
  'enabled (default)', 'disabled', 'pressed', 'hovered',
  'focused', 'selected', 'dragged', 'error',
];
const _cols = [
  ('Text button', 175.0), ('Outlined button', 125.0), ('Contained button', 135.0),
  ('Toggle', 300.0), ('Icon button', 80.0), ('Cancel | Save (proposed)', 240.0),
  ('Reset', 125.0), ('Confirm', 215.0), ('Back / header icon', 85.0),
  ('Stepper arrows', 80.0), ('Checkbox', 70.0), ('Resize handle', 100.0),
  ('Elevated button', 125.0),
];
const _order = [0, 1, 2, 12, 3, 4, 5, 6, 7, 8, 9, 10, 11];
const _labelW = 105.0;
const _rowH = 92.0;

Future<void> _font(String family, String path) async {
  final l = FontLoader(family)
    ..addFont(Future.value(ByteData.sublistView(File(path).readAsBytesSync())));
  await l.load();
}

/// Builds a widget with a statesController and forces [forced] states after frame 1.
class _Forced extends StatefulWidget {
  const _Forced(this.forced, this.build);
  final Set<WidgetState> forced;
  final Widget Function(WidgetStatesController c) build;
  @override
  State<_Forced> createState() => _ForcedState();
}

class _ForcedState extends State<_Forced> {
  final c = WidgetStatesController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final s in widget.forced) {
        c.update(s, true);
      }
    });
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.build(c);
}

double _naW = 120;
bool _wasNa = false;
String _shorten(String w) => switch (w) {
      _noDrag => 'not draggable',
      _noErr => 'no error state',
      _ => w,
    };
Widget _na(String why) {
  _wasNa = true;
  if (_naW < 100) why = _shorten(why);
  return Padding(
      padding: const EdgeInsets.all(6),
      child: SizedBox(
        width: _naW,
        child: Text('n/a: $why',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Color(0xFF8A8A8A), height: 1.2)),
      ),
    );
}

final _keys = <(int, int), GlobalKey>{};
const _noSel = 'no selected look in stock';
const _noDrag = 'only scrollbars, sliders, resize handle';
const _noErr = 'only text fields';

WidgetState? _forceOf(int r) => switch (r) {
      2 => WidgetState.pressed,
      3 => WidgetState.hovered,
      4 => WidgetState.focused,
      _ => null,
    };

const _captions = {2: 'pressed overlay 10 %', 3: 'hover overlay 8 %', 4: 'focus overlay 10 %'};

Widget _cell(BuildContext context, int col, int r) {
  _wasNa = false;
  final w = _cell0(context, col, r);
  if (_wasNa || !_captions.containsKey(r)) return w;
  return Column(mainAxisSize: MainAxisSize.min, children: [
    w,
    Text(_captions[r]!, style: const TextStyle(fontSize: 9, color: Color(0xFF8A8A8A))),
  ]);
}

Widget _cell0(BuildContext context, int col, int r) {
  _naW = _cols[col].$2 - 16;
  final cs = Theme.of(context).colorScheme;
  final f = _forceOf(r);
  final off = r == 1;
  final forced = <WidgetState>{?f};
  VoidCallback? tap() => off ? null : () {};
  Widget w(Widget Function(WidgetStatesController c) b) => _Forced(forced, b);
  // Plain buttons: selected, dragged, error are n/a.
  Widget? plainNa() => switch (r) {
        5 => _na(_noSel),
        6 => _na(_noDrag),
        7 => _na(_noErr),
        _ => null,
      };
  switch (col) {
    case 0:
      return plainNa() ??
          w((c) => Row(mainAxisSize: MainAxisSize.min, children: [
                TextButton(statesController: c, onPressed: tap(), child: const Text('Text')),
                TextButton.icon(
                    onPressed: tap(),
                    icon: const Icon(SuiteIcons.add, size: 18),
                    label: const Text('Add')),
              ]));
    case 1:
      return plainNa() ??
          w((c) => OutlinedButton(
              statesController: c, onPressed: tap(), child: const Text('Outlined')));
    case 12:
      return plainNa() ??
          w((c) => ElevatedButton(
              statesController: c, onPressed: tap(), child: const Text('Elevated')));
    case 2:
      return plainNa() ??
          w((c) => FilledButton(
              statesController: c, onPressed: tap(), child: const Text('Contained')));
    case 3:
      if (r == 6) return _na(_noDrag);
      if (r == 7) return _na(_noErr);
      if (r == 2 || r == 3 || r == 4) {
        return _na('SegmentedButton has no statesController, cannot force');
      }
      final sel = r == 5 ? 'Dark' : 'Light';
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SegmentedButton<String>(
          showSelectedIcon: true,
          selectedIcon: const Icon(SuiteIcons.check),
          segments: const [
            ButtonSegment(value: 'Light', label: Text('Light')),
            ButtonSegment(value: 'Dark', label: Text('Dark')),
            ButtonSegment(value: 'Match system', label: Text('Match system')),
          ],
          selected: {sel},
          onSelectionChanged: off ? null : (_) {},
        ),
        const SizedBox(height: 6),
        Row(mainAxisSize: MainAxisSize.min, children: [
          const Text('today: ', style: TextStyle(fontSize: 10, color: Color(0xFF8A8A8A))),
          ChoiceChip(
              label: const Text('Dark'),
              selected: r == 5,
              onSelected: off ? null : (_) {},
              visualDensity: VisualDensity.compact),
        ]),
      ]);
    case 4:
    case 8:
      if (r == 6) return _na(_noDrag);
      if (r == 7) return _na(_noErr);
      return w((c) => IconButton(
          statesController: c,
          isSelected: r == 5,
          onPressed: tap(),
          icon: Icon(col == 4 ? SuiteIcons.edit : SuiteIcons.arrowBack)));
    case 5:
      return plainNa() ??
          w((c) => Column(mainAxisSize: MainAxisSize.min, children: [
                Row(mainAxisSize: MainAxisSize.min, children: [
                  TextButton(statesController: c, onPressed: tap(), child: const Text("Cancel")),
                  const SizedBox(width: 4),
                  FilledButton(onPressed: tap(), child: const Text("Save")),
                ]),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Text("or ", style: TextStyle(fontSize: 10, color: Color(0xFF8A8A8A))),
                  ElevatedButton(onPressed: tap(), child: const Text("Save as elevated")),
                ]),
              ]));
    case 6:
      if (r == 5) return _na(_noSel);
      if (r == 6) return _na(_noDrag);
      final style = ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(cs.error),
        iconColor: WidgetStatePropertyAll(cs.error),
        overlayColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.hovered) ? cs.errorContainer : null),
      );
      return w((c) => TextButton.icon(
          statesController: c,
          style: style,
          onPressed: tap(),
          icon: const Icon(SuiteIcons.restartAlt, size: 18),
          label: const Text('Reset')));
    case 7:
      return plainNa() ??
          w((c) => Row(mainAxisSize: MainAxisSize.min, children: [
                const Text('Are you sure? ', style: TextStyle(fontSize: 11)),
                TextButton(statesController: c, onPressed: tap(), child: const Text('Yes')),
                TextButton(onPressed: tap(), child: const Text('No')),
              ]));
    case 9:
      return plainNa() ??
          w((c) => Column(mainAxisSize: MainAxisSize.min, children: [
                IconButton(
                    statesController: c,
                    iconSize: 18,
                    visualDensity: VisualDensity.compact,
                    onPressed: tap(),
                    icon: const Icon(SuiteIcons.keyboardArrowUp)),
                IconButton(
                    iconSize: 18,
                    visualDensity: VisualDensity.compact,
                    onPressed: tap(),
                    icon: const Icon(SuiteIcons.keyboardArrowDown)),
              ]));
    case 10:
      if (r == 6) return _na(_noDrag);
      if (r == 7) return _na(_noErr);
      if (r == 2 || r == 3) return _na('cannot force here');
      return _CheckCell(focus: r == 4, value: r == 5, off: off);
    default:
      if (r == 6) {
        return CustomPaint(size: const Size(34, 34), painter: _Grip(cs.onSurface));
      }
      if (r == 0) {
        return _na('custom, no stock equivalent; the only control with a dragged state');
      }
      return _na('custom: no stock states');
  }
}

class _CheckCell extends StatefulWidget {
  const _CheckCell({required this.focus, required this.value, required this.off});
  final bool focus, value, off;
  @override
  State<_CheckCell> createState() => _CheckCellState();
}

class _CheckCellState extends State<_CheckCell> {
  final node = FocusNode();
  @override
  void initState() {
    super.initState();
    if (widget.focus) {
      WidgetsBinding.instance.addPostFrameCallback((_) => node.requestFocus());
    }
  }

  @override
  void dispose() {
    node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Checkbox(
      focusNode: node, value: widget.value, onChanged: widget.off ? null : (_) {});
}

class _Grip extends CustomPainter {
  _Grip(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 1; i <= 3; i++) {
      final d = i * 8.0;
      canvas.drawLine(Offset(s.width - 2, d + 2), Offset(d + 2, s.height - 2), p);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

const _notes = [
  'Elevated: stock ElevatedButton; the main side of a pair could be Contained or Elevated (UIC-27.h).',
  'COMBINED: Icon button and Back / header icon are one stock IconButton (same look, different icon). '
      'Reset is a TextButton plus the error role (error and errorContainer). '
      'Cancel | Save is proposed as two stock buttons (TextButton and FilledButton) in a Row; today it is a custom widget with its own slide and pulse. '
      'Toggle is proposed as one SegmentedButton instead of five ChoiceChips (the current chip is shown small). '
      'Stepper arrows are proposed as small IconButtons; today they are InkWell. Confirm is a row of stock TextButtons: composition, no stock widget.',
  'BUILT-IN FLUTTER FEATURES: ButtonStyle.backgroundBuilder gives the Cancel | Save slide and pulse with every state staying stock. '
      'WidgetStatesController forces and reads states (used to draw this sheet). '
      'AnimationStyle gives the popup transition. SegmentedButton gives toggles.',
  'CUSTOM, NO STOCK EQUIVALENT: resize handle, colour swatches, picker fields. '
      'Dragged and error have no stock button state, so those cells say n/a and why. '
      'Stock buttons show no selected look, so those cells are n/a. Pressed and hovered are real pointer events on the real engine; focused uses a focus node or WidgetStatesController.',
];

void main() {
  setUpAll(() async {
    await _font('IBM Plex Sans', 'assets/fonts/IBMPlexSans-Variable.ttf');
    await _font('IBM Plex Mono', 'assets/fonts/IBMPlexMono-Regular.ttf');
    await _font(SuiteIcons.fontFamily, 'assets/fonts/MaterialSymbolsRounded.ttf');
  });

  testWidgets('button states matrix', (tester) async {
    tester.view.physicalSize = const Size(2000, 960);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
    final key = GlobalKey();
    final theme = buildSuiteTheme(Brightness.dark);
    final line = theme.dividerColor;
    const small = TextStyle(fontSize: 11, fontWeight: FontWeight.w600);

    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: RepaintBoundary(
        key: key,
        child: Builder(builder: (context) {
          return Material(
            color: theme.scaffoldBackgroundColor,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Button states: stock Flutter widgets with buildSuiteTheme(dark) only',
                      style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Row(children: [
                    const SizedBox(width: _labelW),
                    for (final c in _order.map((i) => _cols[i]))
                      Container(
                        width: c.$2,
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                        decoration: BoxDecoration(border: Border.all(color: line, width: .5)),
                        child: Text(c.$1, textAlign: TextAlign.center, style: small),
                      ),
                  ]),
                  for (var r = 0; r < _states.length; r++)
                    Row(children: [
                      Container(
                        width: _labelW,
                        height: _rowH,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 4),
                        decoration: BoxDecoration(border: Border.all(color: line, width: .5)),
                        child: Text(_states[r], style: small),
                      ),
                      for (final c in _order)
                        Container(
                          width: _cols[c].$2,
                          height: _rowH,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(border: Border.all(color: line, width: .5)),
                          child: Center(
                              child: KeyedSubtree(key: _keys[(c, r)] ??= GlobalKey(), child: FittedBox(fit: BoxFit.scaleDown, child: _cell(context, c, r)))),
                        ),
                    ]),
                  const SizedBox(height: 12),
                  for (final n in _notes)
                    SizedBox(
                      width: 1950,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(n, style: const TextStyle(fontSize: 12, height: 1.35)),
                      ),
                    ),
                ]),
              ),
            ),
          );
        }),
      ),
    ));
    await tester.pump();
    for (final c in [0, 1, 2, 12, 4, 5, 6, 7, 8, 9]) {
      for (final r in [2, 3]) {
        final target = find
            .descendant(
                of: find.byKey(_keys[(c, r)]!),
                matching: find.byWidgetPredicate((w) => w is ButtonStyleButton || w is IconButton))
            .first;
        final pos = tester.getCenter(target);
        if (r == 3) {
          final p = TestPointer(1, PointerDeviceKind.mouse, 100 + c);
          await tester.sendEventToBinding(p.hover(Offset.zero));
          await tester.sendEventToBinding(p.hover(pos));
        } else {
          final g = await tester.createGesture(pointer: 200 + c);
          await g.down(pos);
        }
      }
    }
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));
    await expectLater(find.byKey(key), matchesGoldenFile('../../scrum/deliverables/button_states_matrix.png'));
  });
}
