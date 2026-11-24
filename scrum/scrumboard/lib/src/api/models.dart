/// Data classes shared by every ScrumBoard pane. They mirror the JSON of the
/// API contract in `scrum/sprint011/handoffs.md`.
library;

/// One requirement row read from `requirements/**.md` (SCB-03).
class Requirement {
  const Requirement({
    required this.id,
    required this.status,
    required this.statement,
    required this.feature,
    required this.file,
  });

  factory Requirement.fromJson(Map<String, dynamic> json) => Requirement(
        id: json['id'] as String,
        status: json['status'] as String,
        statement: json['statement'] as String,
        feature: json['feature'] as String,
        file: json['file'] as String,
      );

  /// For example `SCB-11.a`.
  final String id;

  /// `proposed`, `backlog`, `planned`, `done` (or another word found in the
  /// file, for example `defect`). A blank status is already `backlog`.
  final String status;
  final String statement;

  /// The area of the requirement file (its file name without `.md`).
  final String feature;

  /// Path of the file relative to the repository root.
  final String file;

  /// The parent ID: drop the last `.segment` (the parent of `SCB-11.a` is
  /// `SCB-11`). Null for a top-level requirement (sprint plan decision 5).
  String? get parentId {
    final dot = id.lastIndexOf('.');
    return dot < 0 ? null : id.substring(0, dot);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
        'statement': statement,
        'feature': feature,
        'file': file,
      };
}

/// One row of the Blocks table of `scrum/sprint.md` (SCB-02.b).
class SprintBlock {
  const SprintBlock({
    required this.id,
    required this.kind,
    required this.name,
    this.parent,
    this.assignee,
    this.estimate,
    this.usage,
  });

  factory SprintBlock.fromJson(Map<String, dynamic> json) => SprintBlock(
        id: json['id'] as String,
        kind: json['kind'] as String,
        name: json['name'] as String,
        parent: json['parent'] as String?,
        assignee: json['assignee'] as String?,
        estimate: json['estimate'] as num?,
        usage: json['usage'] as num?,
      );

  final String id;

  /// `story`, `epic` or `sprint`.
  final String kind;
  final String name;

  /// Parent block ID; null at the top.
  final String? parent;
  final String? assignee;
  final num? estimate;
  final num? usage;

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind,
        'name': name,
        'parent': parent,
        'assignee': assignee,
        'estimate': estimate,
        'usage': usage,
      };
}

/// One row of the Members table (SCB-02.c): a story and one item, a
/// requirement ID or an issue number written `#N`.
class SprintMember {
  const SprintMember({required this.block, required this.item});

  factory SprintMember.fromJson(Map<String, dynamic> json) => SprintMember(
        block: json['block'] as String,
        item: json['item'] as String,
      );

  final String block;
  final String item;

  Map<String, dynamic> toJson() => {'block': block, 'item': item};
}

/// The sprint file as the API shows it. `exists` is false when the file is
/// missing (SCB-02.e); then both lists are empty.
class SprintFile {
  const SprintFile({
    required this.exists,
    this.blocks = const [],
    this.members = const [],
  });

  factory SprintFile.fromJson(Map<String, dynamic> json) => SprintFile(
        exists: json['exists'] as bool? ?? true,
        blocks: [
          for (final b in json['blocks'] as List<dynamic>)
            SprintBlock.fromJson(b as Map<String, dynamic>),
        ],
        members: [
          for (final m in json['members'] as List<dynamic>)
            SprintMember.fromJson(m as Map<String, dynamic>),
        ],
      );

  final bool exists;
  final List<SprintBlock> blocks;
  final List<SprintMember> members;

  Map<String, dynamic> toJson() => {
        'exists': exists,
        'blocks': [for (final b in blocks) b.toJson()],
        'members': [for (final m in members) m.toJson()],
      };
}

/// One agent's progress file (`done/total`).
class ProgressEntry {
  const ProgressEntry({
    required this.label,
    required this.done,
    required this.total,
  });

  factory ProgressEntry.fromJson(Map<String, dynamic> json) => ProgressEntry(
        label: json['label'] as String,
        done: json['done'] as int,
        total: json['total'] as int,
      );

  final String label;
  final int done;
  final int total;

  Map<String, dynamic> toJson() =>
      {'label': label, 'done': done, 'total': total};
}

/// One row of the Usage table (SCB-14.a). A dash cell is null.
class UsageRow {
  const UsageRow({
    required this.block,
    this.estimateSession,
    this.estimateWeekly,
    this.beforeSession,
    this.beforeWeekly,
    this.afterSession,
    this.afterWeekly,
  });

  factory UsageRow.fromJson(Map<String, dynamic> json) => UsageRow(
        block: json['block'] as String,
        estimateSession: json['estimateSession'] as num?,
        estimateWeekly: json['estimateWeekly'] as num?,
        beforeSession: json['beforeSession'] as num?,
        beforeWeekly: json['beforeWeekly'] as num?,
        afterSession: json['afterSession'] as num?,
        afterWeekly: json['afterWeekly'] as num?,
      );

  final String block;
  final num? estimateSession;
  final num? estimateWeekly;
  final num? beforeSession;
  final num? beforeWeekly;
  final num? afterSession;
  final num? afterWeekly;

  Map<String, dynamic> toJson() => {
        'block': block,
        'estimateSession': estimateSession,
        'estimateWeekly': estimateWeekly,
        'beforeSession': beforeSession,
        'beforeWeekly': beforeWeekly,
        'afterSession': afterSession,
        'afterWeekly': afterWeekly,
      };
}

/// The usage file as the API shows it (decision 3 of the sprint plan).
class UsageData {
  const UsageData({required this.exists, this.rows = const []});

  factory UsageData.fromJson(Map<String, dynamic> json) => UsageData(
        exists: json['exists'] as bool,
        rows: [
          for (final r in json['rows'] as List<dynamic>)
            UsageRow.fromJson(r as Map<String, dynamic>),
        ],
      );

  final bool exists;
  final List<UsageRow> rows;

  Map<String, dynamic> toJson() => {
        'exists': exists,
        'rows': [for (final r in rows) r.toJson()],
      };
}
