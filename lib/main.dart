import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/app/bootstrap.dart';
import 'src/calendar/calendar_controller.dart';
import 'src/calendar/calendar_page.dart';
import 'src/calendar/settings_dialog.dart';
import 'src/l10n/messages.dart';
import 'src/theme/suite_icons.dart';
import 'src/theme/suite_theme.dart';
import 'src/theme/tokens.dart';
import 'src/time/zones.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    initZones();
    await initializeDateFormatting();
    var zone = 'UTC';
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      if (isKnownZone(info)) zone = info;
    } catch (_) {
      // Falls back to UTC when the device zone cannot be read.
    }
    final prefs = await SharedPreferences.getInstance();
    // SHL-02.a: the page language follows the device language when it is offered, otherwise English.
    final deviceLanguage = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final messages = await Messages.load(deviceLanguage);
    final controller = await bootstrapCalendar(prefs: prefs, messages: messages, zone: zone);
    runApp(SuiteStreamApp(controller: controller, messages: messages));
  } catch (error, stack) {
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
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SuiteStream could not start',
                      key: ValueKey('startup-error-title'),
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    SelectableText('$error', key: const ValueKey('startup-error-text')),
                    const SizedBox(height: 12),
                    const Text('Reload the page. If it persists, clear the site data for this address.'),
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

class SuiteStreamApp extends StatelessWidget {
  const SuiteStreamApp({super.key, required this.controller, required this.messages});

  final CalendarController controller;
  final Messages messages;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SuiteStream',
      debugShowCheckedModeBanner: false,
      theme: buildSuiteTheme(Brightness.light),
      darkTheme: buildSuiteTheme(Brightness.dark),
      builder: (context, child) => ListenableBuilder(
        listenable: controller,
        child: child!,
        builder: (context, child) => SuiteAnimationScope(
          duration: controller.animationDuration,
          child: MessagesScope(messages: messages, child: child!),
        ),
      ),
      // The app bar does not depend on the controller, so no app-wide listener is needed.
      home: Builder(
        builder: (context) {
          final t = context.tokens;
          return Scaffold(
            appBar: AppBar(
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
    );
  }
}
