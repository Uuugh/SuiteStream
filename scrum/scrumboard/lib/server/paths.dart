import 'dart:io';

/// Thrown when a path would leave the allowed folder.
class PathOutsideRoot implements Exception {
  const PathOutsideRoot(this.path);

  final String path;

  @override
  String toString() => 'path outside the root: $path';
}

String _normalize(String p) {
  var s = p.replaceAll(r'\', '/');
  while (s.length > 1 && s.endsWith('/')) {
    s = s.substring(0, s.length - 1);
  }
  return Platform.isWindows ? s.toLowerCase() : s;
}

/// True when [path] is [root] or lies inside it. Both must already be
/// absolute and resolved.
bool isInside(String root, String path) {
  final r = _normalize(root);
  final p = _normalize(path);
  return p == r || p.startsWith(r.endsWith('/') ? r : '$r/');
}

/// Resolves [relative] under [root] (symbolic links followed, `..` removed)
/// and refuses anything that ends up outside [root] (SCB-13.b path rule).
/// The file need not exist: the nearest existing parent is resolved instead.
String resolveInside(Directory root, String relative) {
  final rootPath = root.resolveSymbolicLinksSync();
  final joined = Uri.directory(rootPath).resolve(
    relative.replaceAll(r'\', '/'),
  );
  final candidate = File.fromUri(joined).absolute.path;
  // Walk up to the first part that exists, resolve it, add the rest back.
  final tail = <String>[];
  var existing = FileSystemEntity.typeSync(candidate) != FileSystemEntityType.notFound
      ? candidate
      : null;
  var cursor = candidate;
  while (existing == null) {
    final parent = File(cursor).parent.path;
    if (parent == cursor) break;
    tail.insert(0, cursor.substring(parent.length).replaceAll(RegExp(r'^[\\/]+'), ''));
    cursor = parent;
    if (FileSystemEntity.typeSync(cursor) != FileSystemEntityType.notFound) {
      existing = cursor;
    }
  }
  if (existing == null) throw PathOutsideRoot(relative);
  var resolved = FileSystemEntity.isDirectorySync(existing)
      ? Directory(existing).resolveSymbolicLinksSync()
      : File(existing).resolveSymbolicLinksSync();
  for (final part in tail) {
    resolved = '$resolved${Platform.pathSeparator}$part';
  }
  if (!isInside(rootPath, resolved)) throw PathOutsideRoot(relative);
  return resolved;
}
