import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:suitestream/src/app/bootstrap.dart';
import 'package:suitestream/src/app/settings_sync.dart';
import 'package:suitestream/src/calendar/calendar_controller.dart';
import 'package:suitestream/src/calendar/calendar_defaults.dart';
import 'package:suitestream/src/calendar/calendar_page.dart';
import 'package:suitestream/src/calendar/settings_dialog.dart';
import 'package:suitestream/src/l10n/messages.dart';
import 'package:suitestream/src/theme/suite_icons.dart';
import 'package:suitestream/src/theme/suite_theme.dart';
import 'package:suitestream/src/theme/theme_mode_controller.dart';
import 'package:suitestream/src/theme/theme_settings.dart';
import 'package:suitestream/src/theme/tokens.dart';
import 'package:suitestream/src/time/zones.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    initZones();
    await initializeDateFormatting();
    var zone = 'UTC';
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      if (isKnownZone(info)) zone = info;
    } on Exception catch (_) {
      // Falls back to UTC when the device zone cannot be read.
    }
    final prefs = await SharedPreferences.getInstance();
    // PBI-037: the server copy of the Settings is loaded before any model reads the preferences.
    final sync = SettingsSync.forPlatform(
      prefs: prefs,
      keys: {
        ...settingsSyncBaseKeys,
        ...themeSettingsPrefsKeys,
      },
    );
    await sync.pull();
    // SHL-02.a: the page language follows the device language when it is offered, otherwise English.
    final deviceLanguage =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final messages = await Messages.load(deviceLanguage);
    final controller = await bootstrapCalendar(
      prefs: prefs,
      messages: messages,
      zone: zone,
    );
    runApp(
      SuiteStreamApp(
        controller: controller,
        messages: messages,
        themeMode: ThemeModeController(prefs: prefs),
        themeSettings: ThemeSettings(prefs: prefs),
        timingSettings: TimingSettings(prefs: prefs),
        settingsSync: sync,
      ),
    );
  } on Object catch (error, stack) {
    debugPrint('SuiteStream startup failed: $error\n$stack');
    runApp(StartupErrorApp(error: error));
  }
}

/// Shown instead of a blank page when startup fails.
class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SuiteStream',
      debugShowCheckedModeBanner: false,
      theme: buildSuiteTheme(Brightness.light),
      darkTheme: buildSuiteTheme(Brightness.dark),
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(suiteStartupPadding),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: suiteStartupMaxWidth,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Builder(
                      builder: (context) => Text(
                        'SuiteStream could not start',
                        key: const ValueKey('startup-error-title'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: suiteStartupGap),
                    SelectableText(
                      '$error',
                      key: const ValueKey('startup-error-text'),
                    ),
                    const SizedBox(height: suiteStartupGap),
                    const Text(
                      'Reload the page. If it persists, clear the site data for this address.',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SuiteStreamApp extends StatefulWidget {
  const SuiteStreamApp({
    super.key,
    required this.controller,
    required this.messages,
    required this.themeMode,
    this.themeSettings,
    this.timingSettings,
    this.settingsSync,
  });

  final CalendarController controller;
  final Messages messages;
  final ThemeModeController themeMode;

  /// UIC-44: the Theme pane settings, one instance for the whole app (null = defaults).
  final ThemeSettings? themeSettings;

  /// SET-03.m: the Saved or Cancelled shown time, one instance for the whole app (null = default).
  final TimingSettings? timingSettings;

  /// PBI-037: the Settings copy in the database (null = device only).
  final SettingsSync? settingsSync;

  @override
  State<SuiteStreamApp> createState() => _SuiteStreamAppState();
}

class _SuiteStreamAppState extends State<SuiteStreamApp> {
  late final ThemeSettings settings = widget.themeSettings ?? ThemeSettings();
  late final TimingSettings timing = widget.timingSettings ?? TimingSettings();

  Widget _syncScope(Widget child) {
    final sync = widget.settingsSync;
    return sync == null ? child : SettingsSyncScope(sync: sync, child: child);
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final messages = widget.messages;
    final themeMode = widget.themeMode;
    return ListenableBuilder(
      listenable: themeMode,
      builder: (context, _) => MaterialApp(
        title: 'SuiteStream',
        debugShowCheckedModeBanner: false,
        theme: buildSuiteTheme(Brightness.light),
        darkTheme: buildSuiteTheme(Brightness.dark),
        themeMode: themeMode.mode,
        builder: (context, child) => _syncScope(
          ListenableBuilder(
            listenable: controller,
            child: child!,
            builder: (context, child) => SuiteAnimationScope(
              duration: controller.animationDuration,
              child: ThemeModeScope(
                controller: themeMode,
                child: ThemeSettingsScope(
                  settings: settings,
                  child: TimingSettingsScope(
                    settings: timing,
                    // The status word time reaches every Cancel | Save pair live.
                    child: ListenableBuilder(
                      listenable: timing,
                      child: child!,
                      builder: (context, child) => SuiteStatusWordScope(
                        duration: timing.statusWordTime,
                        child: MessagesScope(messages: messages, child: child!),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // The app bar does not depend on the controller, so no app-wide listener is needed.
        home: Builder(
          builder: (context) {
            final t = context.tokens;
            return Scaffold(
              appBar: AppBar(
                // SHL-01.h: no background of its own; the page color shows through.
                backgroundColor: t.bg,
                surfaceTintColor: Colors.transparent,
                scrolledUnderElevation: 0,
                titleSpacing: suitePartGap,
                toolbarHeight: 44,
                actions: [
                  IconButton(
                    key: const ValueKey('settings-button'),
                    tooltip: context.msg('settings'),
                    style: suiteIconButtonStyle(),
                    icon: const Icon(SuiteIcons.settings),
                    onPressed: () => openSettingsDialog(context, controller),
                  ),
                ],
                title: Row(
                  children: [
                    Image.asset(
                      t.scheme.brightness == Brightness.dark
                          ? 'assets/images/logo/mark-dark-72.png'
                          : 'assets/images/logo/mark-light-72.png',
                      width: 26,
                      height: 26,
                      excludeFromSemantics: true,
                    ),
                    const SizedBox(width: suitePartGap),
                    const Text('SuiteStream'),
                  ],
                ),
              ),
              body: CalendarPage(controller: controller),
            );
          },
        ),
      ),
    );
  }
}
