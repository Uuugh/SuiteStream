import 'package:flutter/material.dart';
import 'package:scrumboard/src/theme/scrum_theme.dart';

export 'package:scrumboard/src/app/board_prefs_default.dart'
    if (dart.library.js_interop) 'package:scrumboard/src/app/board_prefs_web.dart' show defaultBoardPrefs;

/// SCB-24: where the page keeps the theme and the zoom step between starts.
/// Only these two are kept; the filters and the outline state are not.
abstract interface class BoardPrefsStore {
  /// The stored theme and zoom; null for a value that is not stored or cannot
  /// be read. May throw when the store cannot be read at all.
  ({ThemeMode? theme, int? zoom}) load();

  /// Stores the theme and the zoom; a null value is left as it is.
  void save({ThemeMode? theme, int? zoom});
}

/// Storage keys (browser local storage, `board_prefs_web.dart`).
const String boardPrefsThemeKey = 'scrumboard.theme';
const String boardPrefsZoomKey = 'scrumboard.zoom';

/// [zoom] when it is within the limits and on a step of SCB-20.a, else null.
int? checkedZoom(int? zoom) {
  if (zoom == null) return null;
  if (zoom < scrumZoomMin || zoom > scrumZoomMax) return null;
  if ((zoom - scrumZoomMin) % scrumZoomStep != 0) return null;
  return zoom;
}

/// The theme for a stored name (`light` or `dark`), else null.
ThemeMode? themeFromName(String? name) => switch (name) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => null,
    };

/// The stored name of [mode]: `dark` or `light`.
String themeName(ThemeMode mode) => mode == ThemeMode.dark ? 'dark' : 'light';

/// Keeps the values in memory: the default off the web (and in tests), where
/// a new app built on the same store sees what the last one saved.
class MemoryBoardPrefs implements BoardPrefsStore {
  MemoryBoardPrefs({this.theme, this.zoom});

  ThemeMode? theme;
  int? zoom;

  @override
  ({ThemeMode? theme, int? zoom}) load() => (theme: theme, zoom: zoom);

  @override
  void save({ThemeMode? theme, int? zoom}) {
    if (theme != null) this.theme = theme;
    if (zoom != null) this.zoom = zoom;
  }
}
