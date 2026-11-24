# Sprint 012 Handoffs

Owners publish here what others need.

## Yamamoto (wave 0): public names

Import `package:scrumboard/src/features/scb_filter_bar.dart` and `package:scrumboard/src/features/requirement_drag_data.dart`.

```dart
// The hidden sets (SCB-04). Immutable; the owner keeps one in its State.
class ScbHiddenFilters {
  const ScbHiddenFilters({this.features = const {}, this.ids = const {}, this.statuses = const {}});
  final Set<String> features, ids, statuses;
  ScbHiddenFilters copyWith({Set<String>? features, Set<String>? ids, Set<String>? statuses});
  bool shows(Requirement r);                       // meets all three filters (SCB-04.d)
  List<Requirement> apply(List<Requirement> all);  // the listed entries, order kept
}

// The one filter bar (SCB-04): Feature, Requirement, Status filters and the shown-of count.
class ScbFilterBar extends StatelessWidget {
  const ScbFilterBar({
    super.key,
    required List<Requirement> items,         // ALL entries of the column (choices and total come from it)
    required ScbHiddenFilters hidden,
    required ValueChanged<ScbHiddenFilters> onChanged,
    Widget? trailing,                          // placed at the right end of the same row (the Features expand-all switch)
  });
}
// Use: final listed = _hidden.apply(_all);  ScbFilterBar(items: _all, hidden: _hidden, onChanged: (h) => setState(() => _hidden = h))

// Drag payload for a requirement row (SCB-07.c).
class RequirementDragData {
  const RequirementDragData(this.id, this.status);
  final String id;      // requirement ID
  final String status;  // status when the drag began (lower case)
}
```
Features rows are `LongPressDraggable<RequirementDragData>` (long press on touch, immediate-feeling on desktop). Drop targets use `DragTarget<RequirementDragData>`. Count text key: `scb-shown-of`; filter button keys `scb-filter-button-<label>`.
