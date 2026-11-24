import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrumboard/src/api/reload_scope.dart';

void main() {
  testWidgets('SCB-01.c a pane under the scope sees each Reload', (t) async {
    final controller = ReloadController();
    final seen = <int>[];
    await t.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ReloadScope(
          controller: controller,
          child: Builder(
            builder: (context) {
              seen.add(ReloadScope.generationOf(context));
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    controller.reload();
    await t.pump();
    controller.reload();
    await t.pump();
    expect(seen, [0, 1, 2]);
  });

  testWidgets('SCB-01.c without a scope the generation is 0', (t) async {
    late int g;
    await t.pumpWidget(
      Builder(
        builder: (context) {
          g = ReloadScope.generationOf(context);
          return const SizedBox.shrink();
        },
      ),
    );
    expect(g, 0);
  });
}
