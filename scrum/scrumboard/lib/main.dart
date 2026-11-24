import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:scrumboard/src/api/scrumboard_api.dart';
import 'package:scrumboard/src/app/scrumboard_page.dart';
import 'package:scrumboard/src/board/backlog_timeline.dart';
import 'package:scrumboard/src/features/features_column.dart';
import 'package:scrumboard/src/l10n/messages.dart';
import 'package:scrumboard/src/theme/scrum_theme.dart';

/// The ScrumBoard app: the theme, the messages and the page with its panes.
class ScrumBoardApp extends StatefulWidget {
  const ScrumBoardApp({super.key, required this.api, required this.messages});

  final ScrumBoardApi api;
  final Messages messages;

  @override
  State<ScrumBoardApp> createState() => _ScrumBoardAppState();
}

class _ScrumBoardAppState extends State<ScrumBoardApp> {
  ThemeMode _mode = ThemeMode.light;
  int _zoom = scrumZoomDefault;

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
          onZoomChanged: (z) => setState(() => _zoom = z.clamp(scrumZoomMin, scrumZoomMax)),
          onToggleTheme: () =>
              setState(() => _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark),
          board: BacklogTimeline(api: api),
          features: FeaturesColumn(api: api),
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
