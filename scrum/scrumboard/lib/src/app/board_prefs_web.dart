import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:scrumboard/src/app/board_prefs.dart';

/// The browser's `window.localStorage`, through `dart:js_interop` (an SDK
/// library: no package). The only file that imports `dart:js_interop`.
@JS('localStorage')
external _Storage get _localStorage;

extension type _Storage._(JSObject _) implements JSObject {
  external String? getItem(String key);
  external void setItem(String key, String value);
}

/// SCB-24: on the web the theme and zoom are kept in the browser's local
/// storage under [boardPrefsThemeKey] and [boardPrefsZoomKey].
BoardPrefsStore defaultBoardPrefs() => BrowserBoardPrefs();

class BrowserBoardPrefs implements BoardPrefsStore {
  @override
  ({ThemeMode? theme, int? zoom}) load() {
    final storage = _localStorage;
    return (
      theme: themeFromName(storage.getItem(boardPrefsThemeKey)),
      zoom: checkedZoom(int.tryParse(storage.getItem(boardPrefsZoomKey) ?? '')),
    );
  }

  @override
  void save({ThemeMode? theme, int? zoom}) {
    try {
      final storage = _localStorage;
      if (theme != null) storage.setItem(boardPrefsThemeKey, themeName(theme));
      if (zoom != null) storage.setItem(boardPrefsZoomKey, '$zoom');
    } on Object {
      // Storage refused (private window, blocked site data): the page keeps
      // working with the values in memory.
    }
  }
}
