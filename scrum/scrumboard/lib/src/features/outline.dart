import 'package:scrumboard/src/api/models.dart';

/// One row of the outline: a listed requirement and how deep it sits.
class OutlineRow {
  const OutlineRow(this.requirement, this.depth, this.hasChildren);
  final Requirement requirement;
  final int depth;
  final bool hasChildren;
}

/// SCB-11.e: builds the outline from the listed entries only. A requirement's
/// parent is its ID without the last `.segment` (decision 5); one whose parent
/// is not listed stands at the top, without an indent. Rows whose ancestors are
/// collapsed are left out (an id in [expanded] shows its children).
List<OutlineRow> buildOutline(List<Requirement> listed, Set<String> expanded) {
  final ids = {for (final r in listed) r.id};
  final children = <String, List<Requirement>>{};
  final roots = <Requirement>[];
  for (final r in listed) {
    final p = r.parentId;
    if (p != null && ids.contains(p)) {
      children.putIfAbsent(p, () => <Requirement>[]).add(r);
    } else {
      roots.add(r);
    }
  }
  final rows = <OutlineRow>[];
  void walk(Requirement r, int depth) {
    final kids = children[r.id] ?? const <Requirement>[];
    rows.add(OutlineRow(r, depth, kids.isNotEmpty));
    if (expanded.contains(r.id)) {
      for (final k in kids) {
        walk(k, depth + 1);
      }
    }
  }

  for (final r in roots) {
    walk(r, 0);
  }
  return rows;
}

/// The IDs that have listed children (the rows with a triangle).
Set<String> parentIds(List<Requirement> listed) {
  final ids = {for (final r in listed) r.id};
  return {
    for (final r in listed)
      if (r.parentId != null && ids.contains(r.parentId)) r.parentId!,
  };
}
