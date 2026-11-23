import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/messages.dart';
import '../theme/suite_theme.dart';
import '../theme/tokens.dart';
import '../time/length_input.dart';
import '../ui/cancel_save_pair.dart';
import '../ui/popup_size_lock.dart';
import '../ui/stepper_arrows.dart';
import '../ui/suite_dialog.dart';
import 'calendar_controller.dart';
import 'event_drag.dart';
import 'local_calendars_dialog.dart';
import 'settings_admin_pane.dart';
import 'settings_calendar_pane.dart';
import 'settings_theme_pane.dart';

/// Opens the user's settings (view settings, kept on the device). [prefs] holds the
/// settings that are not in the calendar controller (the calendar defaults); without it
/// the device's own preferences are used.
Future<void> openSettingsDialog(BuildContext context, CalendarController c, {SharedPreferences? prefs}) {
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
          child: PopupSizeLock(child: SettingsDialog(controller: c, prefs: saved)),
        ),
      ),
    ),
  );
}

/// The panes of Settings, in menu order; Admin is last, at the bottom (SET-14).
enum SettingsSection { general, calendar, theme, sources, feeds, rules, templates, history, admin }

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
          child: Text(label, style: SuiteText.label(t).copyWith(color: t.muted)),
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

/// The Cancel | Save pair every pane with a Save carries (SET-01.d, UIC-27).
class SettingsSavePair extends StatelessWidget {
  const SettingsSavePair({super.key, required this.enabled, required this.onSave});

  final bool enabled;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final m = context.msg;
    return Align(
      alignment: Alignment.centerRight,
      // UIC-27: Save is available once something has changed.
      child: CancelSavePair(
        cancelKey: const ValueKey('settings-cancel'),
        saveKey: const ValueKey('settings-save'),
        cancelLabel: m('cancel'),
        saveLabel: m('save'),
        onCancel: () => Navigator.of(context).pop(),
        saveEnabled: enabled,
        onSave: onSave,
      ),
    );
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
              onTap: () => setState(() => _section = section),
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
            onSelected: (_) => setState(() => _section = section),
          ),
      ],
    );
  }

  Widget _pane(BuildContext context) {
    final m = context.msg;
    switch (_section) {
      case SettingsSection.general:
        return _GeneralPane(controller: widget.controller);
      case SettingsSection.calendar:
        return SettingsCalendarPane(controller: widget.controller, prefs: widget.prefs);
      case SettingsSection.theme:
        return SettingsThemePane(controller: widget.controller);
      case SettingsSection.sources:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(m('manageLocalCalendars'), style: SuiteText.label(context.tokens)),
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
        return Center(child: Text(m('settingsUnavailable'), style: SuiteText.label(context.tokens)));
    }
  }

  /// General and Calendar have their own Cancel | Save; Theme applies at once and has Reset.
  bool get _ownButtons => _section == SettingsSection.general || _section == SettingsSection.calendar;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final m = context.msg;
    final size = MediaQuery.sizeOf(context);
    final wide = size.width >= 640;
    final height = (size.height - 96).clamp(360.0, 600.0);
    return Padding(
      key: const ValueKey('settings-dialog'),
      padding: const EdgeInsets.all(suiteDialogPadding),
      child: SizedBox(
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(m('settings'), style: SuiteText.moduleKind(t, windowWidth: size.width)),
            const SizedBox(height: suitePartGap),
            Expanded(
              child: wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(width: 200, child: _menu(context, vertical: true)),
                        VerticalDivider(width: 2 * suiteDialogPadding, color: t.line),
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
            if (!_ownButtons)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(m('closeButton'))),
              ),
          ],
        ),
      ),
    );
  }
}

/// SET-09: Settings > General: the press-and-hold delay before an event can be dragged.
class _GeneralPane extends StatefulWidget {
  const _GeneralPane({required this.controller});

  final CalendarController controller;

  @override
  State<_GeneralPane> createState() => _GeneralPaneState();
}

class _GeneralPaneState extends State<_GeneralPane> {
  late final TextEditingController _press = TextEditingController(text: formatPressDelay(widget.controller.longPress));
  late final String _initialPress = _press.text;
  String? _pressError;

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  bool get _changed => _press.text.trim() != _initialPress;

  void _save() {
    final press = parsePressDelayInput(_press.text);
    if (press == null) {
      setState(() => _pressError = context.msg('pressDelayInvalid'));
      return;
    }
    widget.controller.longPress = press;
    Navigator.of(context).pop();
  }

  /// The arrows step the press-and-hold delay by 0.1 seconds.
  void _stepPress(int dir) {
    final d = parsePressDelayInput(_press.text) ?? widget.controller.longPress;
    _press.text = formatPressDelay(clampLongPress(d + Duration(milliseconds: 100 * dir)));
    setState(() => _pressError = null);
  }

  @override
  Widget build(BuildContext context) {
    final m = context.msg;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: SettingsField(
              label: m('pressDelay'),
              fieldKey: 'setting-press-delay',
              controller: _press,
              error: _pressError,
              step: _stepPress,
              onChanged: () => setState(() => _pressError = null),
            ),
          ),
        ),
        const SizedBox(height: suitePartGap),
        SettingsSavePair(enabled: _changed, onSave: _save),
      ],
    );
  }
}
