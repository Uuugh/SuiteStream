import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suitestream/src/theme/suite_theme.dart';

void main() {
  testWidgets('capture Material 3 Cancel and Save button gallery', (
    tester,
  ) async {
    await (
      FontLoader('IBM Plex Sans')
        ..addFont(rootBundle.load('assets/fonts/IBMPlexSans-Variable.ttf'))
    ).load();
    tester.view.physicalSize = const Size(1800, 1300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const _ButtonGallery());
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const ValueKey('button-gallery')),
      matchesGoldenFile('goldens/cancel-save-material3.png'),
    );
  });
}

class _ButtonGallery extends StatelessWidget {
  const _ButtonGallery();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Material(
        color: const Color(0xFFE9EDF2),
        child: RepaintBoundary(
          key: const ValueKey('button-gallery'),
          child: Row(
            children: [
              Expanded(child: _ThemePanel(brightness: Brightness.light)),
              const SizedBox(width: 24),
              Expanded(child: _ThemePanel(brightness: Brightness.dark)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemePanel extends StatelessWidget {
  const _ThemePanel({required this.brightness});

  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final theme = buildSuiteTheme(brightness);
    return Theme(
      data: theme,
      child: Builder(
        builder: (context) {
          final scheme = Theme.of(context).colorScheme;
          final isLight = brightness == Brightness.light;
          return Material(
            color: scheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isLight ? 'LIGHT THEME' : 'DARK THEME',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Flutter Material 3 defaults under SuiteStream theme',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 22),
                  for (final option in _options(scheme)) ...[
                    _ButtonOptionRow(option: option),
                    const SizedBox(height: 10),
                  ],
                  const Spacer(),
                  Text(
                    'Cancel is a default TextButton in each pair. The Save column uses the listed built-in widget with no custom ButtonStyle.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Default enabled appearance only; Flutter provides each button type’s built-in interaction states.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<_ButtonOption> _options(ColorScheme scheme) {
    return [
      _ButtonOption(
        name: 'TextButton',
        description: 'Text action',
        colors: [
          _ColorUse('text: primary', scheme.primary),
          _ColorUse('fill: transparent', null),
        ],
        save: () => TextButton(
          onPressed: () {},
          child: const Text('Save'),
        ),
      ),
      _ButtonOption(
        name: 'OutlinedButton',
        description: 'Outlined action',
        colors: [
          _ColorUse('text: primary', scheme.primary),
          _ColorUse('outline: outline', scheme.outline),
          _ColorUse('fill: transparent', null),
        ],
        save: () => OutlinedButton(
          onPressed: () {},
          child: const Text('Save'),
        ),
      ),
      _ButtonOption(
        name: 'ElevatedButton',
        description: 'Raised surface action',
        colors: [
          _ColorUse('text: primary', scheme.primary),
          _ColorUse('fill: surfaceContainerLow', scheme.surfaceContainerLow),
          _ColorUse('shadow: shadow', scheme.shadow),
        ],
        save: () => ElevatedButton(
          onPressed: () {},
          child: const Text('Save'),
        ),
      ),
      _ButtonOption(
        name: 'FilledButton',
        description: 'Primary filled action',
        colors: [
          _ColorUse('fill: primary', scheme.primary),
          _ColorUse('text: onPrimary', scheme.onPrimary),
        ],
        save: () => FilledButton(
          onPressed: () {},
          child: const Text('Save'),
        ),
      ),
      _ButtonOption(
        name: 'FilledButton.tonal',
        description: 'Tonal filled action',
        colors: [
          _ColorUse('fill: secondaryContainer', scheme.secondaryContainer),
          _ColorUse('text: onSecondaryContainer', scheme.onSecondaryContainer),
        ],
        save: () => FilledButton.tonal(
          onPressed: () {},
          child: const Text('Save'),
        ),
      ),
    ];
  }
}

class _ButtonOption {
  const _ButtonOption({
    required this.name,
    required this.description,
    required this.colors,
    required this.save,
  });

  final String name;
  final String description;
  final List<_ColorUse> colors;
  final Widget Function() save;
}

class _ColorUse {
  const _ColorUse(this.label, this.color);

  final String label;
  final Color? color;
}

class _ButtonOptionRow extends StatelessWidget {
  const _ButtonOptionRow({required this.option});

  final _ButtonOption option;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 190,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        border: Border.all(color: scheme.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  option.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  option.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 14),
                for (final color in option.colors)
                  _ColorCallout(colorUse: color),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {},
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 10),
              SizedBox(width: 135, child: option.save()),
            ],
          ),
        ],
      ),
    );
  }
}

class _ColorCallout extends StatelessWidget {
  const _ColorCallout({required this.colorUse});

  final _ColorUse colorUse;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = colorUse.color;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: color ?? scheme.surface,
              border: Border.all(color: scheme.outline),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${colorUse.label}${color == null ? '' : '  ${_hex(color)}'}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(
            width: 30,
            height: 20,
            child: CustomPaint(
              painter: _ArrowPainter(color ?? scheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  const _ArrowPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final end = Offset(size.width - 2, size.height / 2);
    canvas.drawLine(const Offset(1, 9), end, paint);
    final arrow = Path()
      ..moveTo(size.width - 8, 3)
      ..lineTo(size.width - 2, size.height / 2)
      ..lineTo(size.width - 8, size.height - 3);
    canvas.drawPath(arrow, paint);
  }

  @override
  bool shouldRepaint(_ArrowPainter oldDelegate) => oldDelegate.color != color;
}

String _hex(Color color) =>
    '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
