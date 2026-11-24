import 'package:flutter/widgets.dart';

/// Counts Reload presses (SCB-01.c). `ScrumBoardPage` owns one, puts it in a
/// [ReloadScope], and each pane reads again when [generation] changes.
class ReloadController extends ChangeNotifier {
  int _generation = 0;

  int get generation => _generation;

  /// Ask every pane under the scope to read its data again.
  void reload() {
    _generation++;
    notifyListeners();
  }
}

/// Gives the panes the page's [ReloadController].
///
/// In a pane's `State`, read `ReloadScope.generationOf(context)` in
/// `didChangeDependencies` and load again when the number differs from the one
/// the pane last loaded with. Without a scope the number is always 0.
class ReloadScope extends InheritedNotifier<ReloadController> {
  const ReloadScope({
    super.key,
    required ReloadController controller,
    required super.child,
  }) : super(notifier: controller);

  /// The current generation, and subscribes [context] to changes.
  static int generationOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ReloadScope>();
    return scope?.notifier?.generation ?? 0;
  }
}
