import 'package:flutter/material.dart';

import '../theme/event_colors.dart';
import '../theme/suite_icons.dart';
import '../theme/suite_theme.dart';
import '../l10n/messages.dart';
import '../ui/cancel_save_pair.dart';
import '../ui/color_picker.dart';
import '../ui/confirm.dart';
import '../ui/suite_dialog.dart';
import 'calendar_controller.dart';

/// Dot radius: no token exists, so it is the swatch gap (8), the same value.
const double _dotRadius = suiteSwatchGap;


Future<void> openLocalCalendars(BuildContext context, CalendarController controller) {
  final messages = context.msg;
  return showSuiteDialog<void>(
    context: context,
    builder: (context) => MessagesScope(
      messages: messages,
      child: _LocalCalendarsDialog(controller: controller),
    ),
  );
}

/// The local calendar list with its Add button; used by the dialog and the Settings Sources pane.
class LocalCalendarsPanel extends StatefulWidget {
  const LocalCalendarsPanel({super.key, required this.controller});

  final CalendarController controller;

  @override
  State<LocalCalendarsPanel> createState() => _LocalCalendarsPanelState();
}

class _LocalCalendarsPanelState extends State<LocalCalendarsPanel> {
  bool _busy = false;
  bool _error = false;

  Future<void> _apply(Future<bool> Function() operation) async {
    setState(() {
      _busy = true;
      _error = false;
    });
    final saved = await operation();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = !saved;
    });
  }

  Future<void> _edit({String? id, String? name, int? color}) async {
    final messages = context.msg;
    // A new calendar offers the next unused calendar color (UIC-10, EVT-03.i).
    final start = color ?? nextCalendarColor(widget.controller.calendars.map((c) => c.color));
    final result = await showSuiteDialog<({String name, int color})>(
      context: context,
      builder: (context) => _CalendarNameDialog(messages: messages, initialName: name, initialColor: start),
    );
    if (mounted && result != null) {
      await _apply(
        () => widget.controller.saveCalendar(
          result.name.isEmpty ? messages('local') : result.name,
          id: id,
          color: result.color,
        ),
      );
    }
  }

  Future<void> _delete(String id, String name, {required bool clear}) async {
    final m = context.msg;
    final action = m(clear ? 'clearLocalCalendar' : 'deleteLocalCalendar');
    // UIC-06, UIC-27.d: a question is answered with the shared No | Yes pair.
    final confirmed = await confirmYesNo(
      context,
      clear ? m('confirmClearLocalCalendar', {'calendar': name}) : '$action: $name?',
    );
    if (mounted && confirmed) {
      await _apply(() => clear ? widget.controller.clearLastCalendar(id) : widget.controller.deleteCalendar(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = context.msg;
    final controller = widget.controller;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) => ListView(
              shrinkWrap: true,
              children: [
                for (final calendar in controller.calendars)
                  ListTile(
                    leading: CircleAvatar(
                      key: ValueKey('calendar-dot-${calendar.id}'),
                      radius: _dotRadius,
                      backgroundColor: Color(nearestCalendarColor(calendar.color ?? defaultEventColor)),
                    ),
                    title: Text(calendar.name),
                    subtitle: calendar.id == controller.defaultCalendarId
                        ? Text(m('defaultLocalCalendar'))
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: m('setDefaultLocalCalendar'),
                          onPressed: _busy || calendar.id == controller.defaultCalendarId
                              ? null
                              : () => _apply(() => controller.setDefaultCalendar(calendar.id)),
                          icon: Icon(SuiteIcons.star, fill: calendar.id == controller.defaultCalendarId ? 1 : 0),
                        ),
                        IconButton(
                          tooltip: m('renameLocalCalendar'),
                          onPressed: _busy ? null : () => _edit(id: calendar.id, name: calendar.name, color: calendar.color),
                          icon: const Icon(SuiteIcons.edit),
                        ),
                        IconButton(
                          tooltip: m(controller.calendars.length == 1 ? 'clearLocalCalendar' : 'deleteLocalCalendar'),
                          onPressed: _busy || !(controller.canDeleteCalendar(calendar.id) || controller.canClearLastCalendar(calendar.id))
                              ? null
                              : () => _delete(calendar.id, calendar.name, clear: controller.calendars.length == 1),
                          icon: const Icon(SuiteIcons.delete),
                        ),
                      ],
                    ),
                  ),
                if (_error)
                  Text(m('saveLocalCalendarFailed'), style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: _busy ? null : _edit,
            icon: const Icon(SuiteIcons.add),
            label: Text(m('addLocalCalendar')),
          ),
        ),
      ],
    );
  }
}

class _LocalCalendarsDialog extends StatelessWidget {
  const _LocalCalendarsDialog({required this.controller});

  final CalendarController controller;

  @override
  Widget build(BuildContext context) {
    final m = context.msg;
    return SuiteAlertDialog(
      title: Text(m('manageLocalCalendars')),
      content: SizedBox(width: suiteLocalCalendarsDialogWidth, child: LocalCalendarsPanel(controller: controller)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(m('closeButton'))),
      ],
    );
  }
}

class _CalendarNameDialog extends StatefulWidget {
  const _CalendarNameDialog({required this.messages, required this.initialName, required this.initialColor});

  final Messages messages;
  final String? initialName;
  final int initialColor;

  @override
  State<_CalendarNameDialog> createState() => _CalendarNameDialogState();
}

class _CalendarNameDialogState extends State<_CalendarNameDialog> {
  late final _name = TextEditingController(text: widget.initialName);
  late int _color = nearestCalendarColor(widget.initialColor);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.messages;
    final canSave = widget.initialName == null || _name.text.trim().isNotEmpty;
    return SuiteAlertDialog(
      title: Text(m(widget.initialName == null ? 'addLocalCalendar' : 'renameLocalCalendar')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _name,
            autofocus: true,
            decoration: InputDecoration(labelText: m('calendarName')),
            onChanged: (_) => setState(() {}),
            onSubmitted: (name) {
              if (canSave) Navigator.pop(context, (name: name.trim(), color: _color));
            },
          ),
          const SizedBox(height: suitePartGap),
          // UIC-10: the shared picker, here with the 24 calendar colors.
          InkWell(
            key: const ValueKey('calendar-color-button'),
            borderRadius: BorderRadius.circular(suiteControlRadius),
            onTap: () async {
              final picked = await showColorPicker(context, palette: calendarPalette, current: _color);
              if (mounted && picked != null) setState(() => _color = picked);
            },
            child: InputDecorator(
              decoration: InputDecoration(labelText: m.has('calendarColor') ? m('calendarColor') : 'Calendar color'),
              child: Row(
                children: [
                  CircleAvatar(key: const ValueKey('calendar-color-swatch'), radius: _dotRadius, backgroundColor: Color(_color)),
                  const SizedBox(width: suitePartGap),
                  Expanded(child: Text(paletteColorName(m, nearestPaletteColor(_color, calendarPalette)))),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        CancelSavePair(
          cancelLabel: m('cancel'),
          saveLabel: m('save'),
          onCancel: () => Navigator.pop(context),
          saveEnabled: canSave,
          onSave: () => Navigator.pop(context, (name: _name.text.trim(), color: _color)),
        ),
      ],
    );
  }
}
