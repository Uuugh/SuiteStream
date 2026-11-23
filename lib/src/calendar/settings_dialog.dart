import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:suitestream/src/l10n/messages.dart';
import 'package:suitestream/src/theme/suite_icons.dart';
import 'package:suitestream/src/theme/suite_theme.dart';
import 'package:suitestream/src/theme/tokens.dart';
import 'package:suitestream/src/ui/popup_size_lock.dart';
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
  general,
  calendar,
  theme,
  sources,
  feeds,
  rules,
  templates,
  history,
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

  /// UIC-45: choosing another page saves the one being left.
  void _choose(SettingsSection section) {
    if (section == _section) return;
    _leave.run();
    setState(() => _section = section);
  }

  static const _entries = <(SettingsSection, String, String)>[
    (SettingsSection.general, 'settings-general', 'settingsGeneral'),
    (SettingsSection.calendar, 'settings-calendar', 'settingsCalendar'),
    (SettingsSection.theme, 'settings-theme', 'settingsTheme'),
    (SettingsSection.sources, 'settings-sources', 'settingsSources'),
    (SettingsSection.feeds, 'settingsFeeds', 'settingsFeeds'),
    (SettingsSection.rules, 'settingsRules', 'settingsRules'),
    (SettingsSection.templates, 'settingsTemplates', 'settingsTemplates'),
    (SettingsSection.history, 'settingsHistory', 'settingsHistory'),
    (SettingsSection.admin, 'settings-admin', 'settingsAdmin'),
  ];

  Widget _menu(BuildContext context, {required bool vertical}) {
    final m = context.msg;
    if (vertical) {
      return ListView(
        children: [
          for (final (section, key, label) in _entries)
            ListTile(
              key: ValueKey(key),
              dense: true,
              selected: _section == section,
              title: Text(m(label)),
              onTap: () => _choose(section),
            ),
        ],
      );
    }
    // Narrow window: the entries wrap onto more rows, so every one stays in reach.
    return Wrap(
      spacing: suitePartGap,
      runSpacing: suitePartGap,
      children: [
        for (final (section, key, label) in _entries)
          ChoiceChip(
            key: ValueKey(key),
            label: Text(m(label)),
            selected: _section == section,
            onSelected: (_) => _choose(section),
          ),
      ],
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
        return SettingsThemePane(controller: widget.controller);
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
                          _menu(context, vertical: false),
                          const SizedBox(height: suitePartGap),
                          Expanded(child: _pane(context)),
                        ],
                      ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  key: const ValueKey('settings-close'),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(m('closeButton')),
                ),
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
