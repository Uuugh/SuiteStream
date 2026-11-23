import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:suitestream/src/l10n/messages.dart';
import 'package:suitestream/src/theme/suite_icons.dart';
import 'package:suitestream/src/theme/suite_theme.dart';
import 'package:suitestream/src/theme/tokens.dart';
import 'package:suitestream/src/ui/popup_size_lock.dart';
import 'package:suitestream/src/ui/reset_button.dart';
import 'package:suitestream/src/ui/stepper_arrows.dart';
import 'package:suitestream/src/ui/suite_dialog.dart';
import 'package:suitestream/src/calendar/calendar_controller.dart';
import 'package:suitestream/src/calendar/local_calendars_dialog.dart';
import 'package:suitestream/src/calendar/settings_admin_pane.dart';
import 'package:suitestream/src/calendar/settings_calendar_pane.dart';
import 'package:suitestream/src/calendar/settings_theme_pane.dart';

/// Opens the user's settings (view settings, kept on the device). [prefs] holds the
/// settings that are not in the calendar controller (the calendar defaults); without it
/// the device's own preferences are used.
Future<void> openSettingsDialog(
  BuildContext context,
  CalendarController c, {
  SharedPreferences? prefs,
}) {
  final msgs = context.msg;
  final saved = prefs;
  return showSuiteDialog<void>(
    context: context,
    builder: (dialogContext) => MessagesScope(
      messages: msgs,
      child: Dialog(
        backgroundColor: dialogContext.tokens.card,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: PopupSizeLock(
            child: SettingsDialog(controller: c, prefs: saved),
          ),
        ),
      ),
    ),
  );
}

/// The panes of Settings, in menu order; Admin is last, at the bottom (SET-14).
enum SettingsSection {
  calendar,
  sources,
  feeds,
  rules,
  templates,
  history,
  general,
  theme,
  admin,
}

/// A labelled text field with the shared up and down arrows (UIC-41), used by the panes.
class SettingsField extends StatelessWidget {
  const SettingsField({
    super.key,
    required this.label,
    required this.fieldKey,
    required this.controller,
    required this.step,
    required this.onChanged,
    this.error,
    this.maxLength = 8,
  });

  final String label;
  final String fieldKey;
  final TextEditingController controller;
  final String? error;
  final void Function(int dir) step;
  final VoidCallback onChanged;
  final int maxLength;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: suiteLabelGap),
          child: Text(
            label,
            style: SuiteText.label(t).copyWith(color: t.muted),
          ),
        ),
        ArrowKeyStepper(
          onUp: () => step(1),
          onDown: () => step(-1),
          child: TextField(
            key: ValueKey(fieldKey),
            controller: controller,
            inputFormatters: [LengthLimitingTextInputFormatter(maxLength)],
            decoration: InputDecoration(
              suffixIcon: StepperArrows(
                upKey: ValueKey('$fieldKey-up'),
                downKey: ValueKey('$fieldKey-down'),
                onUp: () => step(1),
                onDown: () => step(-1),
              ),
              errorText: error,
              errorMaxLines: 2,
              filled: true,
              fillColor: t.bg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(suiteControlRadius),
                borderSide: BorderSide(color: t.line),
              ),
            ),
            onChanged: (_) => onChanged(),
          ),
        ),
      ],
    );
  }
}

/// UIC-45: how a pane that saves on its own is told Settings is being left (a page change,
/// the close button or the back button). The open pane registers its save here.
class SettingsLeaveHook {
  VoidCallback? _save;

  /// Called by the open pane; replaces any earlier one.
  void register(VoidCallback save) => _save = save;

  /// Called by a pane when it goes away, so a closed pane is never saved.
  void unregister(VoidCallback save) {
    if (_save == save) _save = null;
  }

  /// Saves the open pane's valid values; an invalid value is left unsaved.
  void run() => _save?.call();
}

/// SET-01.g: the open page's Reset, shown in the dialog's footer beside Close. A page that
/// has a Reset sets its action here and clears it when it goes away.
class SettingsResetHook extends ChangeNotifier {
  VoidCallback? _action;

  VoidCallback? get action => _action;

  /// Set from the page's `initState` (during a build), so listeners hear it after the frame.
  void set(VoidCallback action) {
    _action = action;
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
  }

  /// Clears [action] when the page goes away (only if it is still the registered one).
  void clear(VoidCallback action) {
    if (_action != action) return;
    _action = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) notifyListeners();
    });
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// The user's settings dialog: a menu of panes (General, Calendar, Theme, Sources, ...,
/// Admin) and the pane chosen. Each pane is its own file.
class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key, required this.controller, this.prefs});

  final CalendarController controller;
  final SharedPreferences? prefs;

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  SettingsSection _section = SettingsSection.general;
  final SettingsLeaveHook _leave = SettingsLeaveHook();
  final SettingsResetHook _reset = SettingsResetHook();

  @override
  void dispose() {
    _reset.dispose();
    super.dispose();
  }

  /// UIC-45: choosing another page saves the one being left.
  void _choose(SettingsSection section) {
    if (section == _section) return;
    _leave.run();
    setState(() => _section = section);
  }

  /// SET-01.e: the pages above the rule, in order.
  static const _topEntries = <(SettingsSection, String, String)>[
    (SettingsSection.calendar, 'settings-calendar', 'settingsCalendar'),
    (SettingsSection.sources, 'settings-sources', 'settingsSources'),
    (SettingsSection.feeds, 'settingsFeeds', 'settingsFeeds'),
    (SettingsSection.rules, 'settingsRules', 'settingsRules'),
    (SettingsSection.templates, 'settingsTemplates', 'settingsTemplates'),
    (SettingsSection.history, 'settingsHistory', 'settingsHistory'),
  ];

  /// SET-01.e, SET-14: the pages under the rule, at the bottom of the menu; Admin is last.
  static const _bottomEntries = <(SettingsSection, String, String)>[
    (SettingsSection.general, 'settings-general', 'settingsGeneral'),
    (SettingsSection.theme, 'settings-theme', 'settingsTheme'),
    (SettingsSection.admin, 'settings-admin', 'settingsAdmin'),
  ];

  Widget _menu(BuildContext context, {required bool vertical}) {
    final m = context.msg;
    final line = context.tokens.line;
    Widget tile((SettingsSection, String, String) e) => ListTile(
      key: ValueKey(e.$2),
      dense: true,
      selected: _section == e.$1,
      title: Text(m(e.$3)),
      onTap: () => _choose(e.$1),
    );
    final rule = Divider(key: const ValueKey('settings-menu-rule'), height: 2 * suitePartGap, color: line);
    if (vertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: ListView(children: [for (final e in _topEntries) tile(e)])),
          rule,
          for (final e in _bottomEntries) tile(e),
        ],
      );
    }
    // Narrow window: the entries wrap onto more rows, so every one stays in reach.
    Widget chips(List<(SettingsSection, String, String)> entries) => Wrap(
      spacing: suitePartGap,
      runSpacing: suitePartGap,
      children: [
        for (final (section, key, label) in entries)
          ChoiceChip(
            key: ValueKey(key),
            label: Text(m(label)),
            selected: _section == section,
            onSelected: (_) => _choose(section),
          ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [chips(_topEntries), rule, chips(_bottomEntries)],
    );
  }

  Widget _pane(BuildContext context) {
    final m = context.msg;
    switch (_section) {
      case SettingsSection.general:
        return const _GeneralPane();
      case SettingsSection.calendar:
        return SettingsCalendarPane(
          controller: widget.controller,
          prefs: widget.prefs,
          leave: _leave,
        );
      case SettingsSection.theme:
        return SettingsThemePane(controller: widget.controller, prefs: widget.prefs, resetHook: _reset);
      case SettingsSection.sources:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              m('manageLocalCalendars'),
              style: SuiteText.label(context.tokens),
            ),
            const SizedBox(height: suitePartGap),
            Expanded(child: LocalCalendarsPanel(controller: widget.controller)),
          ],
        );
      case SettingsSection.admin:
        return SettingsAdminPane(controller: widget.controller);
      case SettingsSection.feeds:
      case SettingsSection.rules:
      case SettingsSection.templates:
      case SettingsSection.history:
        return Center(
          child: Text(
            m('settingsUnavailable'),
            style: SuiteText.label(context.tokens),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final m = context.msg;
    final size = MediaQuery.sizeOf(context);
    final wide = size.width >= 640;
    final height = (size.height - 96).clamp(360.0, 600.0);
    // UIC-45: closing Settings (close button, back button or barrier) saves the open pane.
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _leave.run();
      },
      child: Padding(
        key: const ValueKey('settings-dialog'),
        padding: const EdgeInsets.all(suiteDialogPadding),
        child: SizedBox(
          height: height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // UIC-14, UIC-45: the back button sits in the left zone of the header and leaves Settings.
              Row(
                children: [
                  IconButton(
                    key: const ValueKey('settings-back'),
                    tooltip: m('settingsBack'),
                    icon: const Icon(SuiteIcons.arrowBack),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: suitePartGap),
                  Expanded(
                    child: Text(
                      m('settings'),
                      style: SuiteText.moduleKind(t, windowWidth: size.width),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: suitePartGap),
              Expanded(
                child: wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            width: 200,
                            child: _menu(context, vertical: true),
                          ),
                          VerticalDivider(
                            width: 2 * suiteDialogPadding,
                            color: t.line,
                          ),
                          Expanded(child: _pane(context)),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // The menu takes at most 40 % of the height and scrolls; the page keeps the rest.
                          ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: height * 0.4),
                            child: SingleChildScrollView(child: _menu(context, vertical: false)),
                          ),
                          const SizedBox(height: suitePartGap),
                          Expanded(child: _pane(context)),
                        ],
                      ),
              ),
              // SET-01.g, UIC-46: Reset (when the page has one) sits on the same line as Close.
              Row(
                children: [
                  ListenableBuilder(
                    listenable: _reset,
                    builder: (context, _) => _reset.action == null
                        ? const SizedBox.shrink()
                        : TextButton.icon(
                            key: const ValueKey('setting-theme-reset'),
                            style: suiteResetButtonStyle(context),
                            onPressed: _reset.action,
                            icon: const Icon(SuiteIcons.restartAlt),
                            label: Text(m('themeSettingsReset')),
                          ),
                  ),
                  const Spacer(),
                  TextButton(
                    key: const ValueKey('settings-close'),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(m('closeButton')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Settings > General: nothing is set here at present. The press-and-hold delay (SET-03.b)
/// moved to Settings > Theme; the page says so instead of staying blank.
class _GeneralPane extends StatelessWidget {
  const _GeneralPane();

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      context.msg('settingsGeneralEmpty'),
      style: SuiteText.label(context.tokens),
    ),
  );
}
