import 'package:scrumboard/src/app/board_prefs.dart';

/// SCB-24: off the web (the Dart VM, tests) the theme and zoom are kept in
/// memory only; browser storage is never touched here.
BoardPrefsStore defaultBoardPrefs() => MemoryBoardPrefs();
