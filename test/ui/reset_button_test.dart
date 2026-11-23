import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suitestream/src/theme/suite_theme.dart';
import 'package:suitestream/src/ui/reset_button.dart';

/// UIC-46: the one Reset look.
void main() {
  for (final brightness in Brightness.values) {
    testWidgets('Reset uses the error role, the control height and presses ($brightness)', (tester) async {
      var pressed = 0;
      final theme = buildSuiteTheme(brightness);
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(child: ResetButton(label: 'Reset', onPressed: () => pressed++)),
          ),
        ),
      );
      final button = tester.widget<TextButton>(find.byType(TextButton));
      expect(button.style!.foregroundColor!.resolve({}), theme.colorScheme.error);
      expect(button.style!.overlayColor!.resolve({WidgetState.hovered}), theme.colorScheme.errorContainer);
      expect(button.style!.minimumSize!.resolve({})!.height, suiteControlHeight);
      expect(tester.getSize(find.byType(TextButton)).height, suiteControlHeight);
      await tester.tap(find.byType(ResetButton));
      expect(pressed, 1);
    });
  }
}
