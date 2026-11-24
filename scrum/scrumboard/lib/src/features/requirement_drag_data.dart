/// SCB-07.c: what a dragged requirement row carries. Drop targets read it from
/// a `DragTarget<RequirementDragData>`.
class RequirementDragData {
  const RequirementDragData(this.id, this.status);

  /// The requirement ID.
  final String id;

  /// The status when the drag began (lower case).
  final String status;

  @override
  bool operator ==(Object other) => other is RequirementDragData && other.id == id && other.status == status;

  @override
  int get hashCode => Object.hash(id, status);
}
