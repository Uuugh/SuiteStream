import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:scrumboard/src/api/scrumboard_api.dart';
import 'package:scrumboard/src/app/board_prefs.dart';
import 'package:scrumboard/src/app/scrumboard_page.dart';
import 'package:scrumboard/src/board/backlog_timeline.dart';
import 'package:scrumboard/src/features/features_column.dart';
import 'package:scrumboard/src/l10n/messages.dart';
import 'package:scrumboard/src/questions/questions_column.dart';
import 'package:scrumboard/src/theme/scrum_theme.dart';

/// The ScrumBoard app: the theme, the messages and the page with its panes.
class ScrumBoardApp extends StatefulWidget {
  const ScrumBoardApp({super.key, required this.api, required this.messages, this.prefs});

  final ScrumBoardApi api;
  final Messages messages;

  /// SCB-24: where the theme and zoom are kept; null uses
  /// [defaultBoardPrefs] (browser local storage on the web, memory elsewhere).
  final BoardPrefsStore? prefs;

  @override
  State<ScrumBoardApp> createState() => _ScrumBoardAppState();
}

class _ScrumBoardAppState extends State<ScrumBoardApp> {
  ThemeMode _mode = ThemeMode.light;
  int _zoom = scrumZoomDefault;
  late final BoardPrefsStore _prefs = widget.prefs ?? defaultBoardPrefs();

  @override
  void initState() {
    super.initState();
    // SCB-24: a store that cannot be read, or a value that is not valid,
    // leaves the default.
    try {
      final saved = _prefs.load();
      _mode = saved.theme ?? _mode;
      _zoom = checkedZoom(saved.zoom) ?? _zoom;
    } on Object {
      // Defaults stay.
    }
  }

  void _save() {
    try {
      _prefs.save(theme: _mode, zoom: _zoom);
    } on Object {
      // Not kept; the page keeps working.
    }
  }

  @override
  Widget build(BuildContext context) {
    final api = widget.api;
    return MessagesScope(
      messages: widget.messages,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildScrumTheme(Brightness.light),
        darkTheme: buildScrumTheme(Brightness.dark),
        themeMode: _mode,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(_zoom / 100)),
          child: child!,
        ),
        home: ScrumBoardPage(
          api: api,
          zoomPercent: _zoom,
          onZoomChanged: (z) {
            setState(() => _zoom = z.clamp(scrumZoomMin, scrumZoomMax));
            _save();
          },
          onToggleTheme: () {
            setState(() => _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
            _save();
          },
          board: BacklogTimeline(api: api),
          features: FeaturesColumn(api: api),
          questions: QuestionsColumn(api: api),
        ),
      ),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final messages =
      await Messages.load(ui.PlatformDispatcher.instance.locale.languageCode);
  runApp(
    ScrumBoardApp(
      api: HttpScrumBoardApi(baseUri: Uri.base),
      messages: messages,
    ),
  );
}
