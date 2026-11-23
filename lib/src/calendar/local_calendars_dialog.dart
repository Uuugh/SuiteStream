import 'package:flutter/material.dart';

import '../theme/suite_icons.dart';
import '../l10n/messages.dart';
import '../ui/suite_dialog.dart';
import 'calendar_controller.dart';

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

class _LocalCalendarsDialog extends StatefulWidget {
  const _LocalCalendarsDialog({required this.controller});

  final CalendarController controller;

  @override
  State<_LocalCalendarsDialog> createState() => _LocalCalendarsDialogState();
}

class _LocalCalendarsDialogState extends State<_LocalCalendarsDialog> {
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

  Future<void> _edit({String? id, String? name}) async {
    final messages = context.msg;
    final result = await showSuiteDialog<String>(
      context: context,
      builder: (context) => _CalendarNameDialog(messages: messages, initialName: name),
    );
    if (mounted && result != null) {
      await _apply(() => widget.controller.saveCalendar(result.isEmpty ? messages('local') : result, id: id));
    }
  }

  Future<void> _delete(String id, String name, {required bool clear}) async {
    final m = context.msg;
    final action = m(clear ? 'clearLocalCalendar' : 'deleteLocalCalendar');
    final confirmed = await showSuiteDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(action),
        content: Text(clear ? m('confirmClearLocalCalendar', {'calendar': name}) : name),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(m('cancel'))),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(action)),
        ],
      ),
    );
    if (mounted && confirmed == true) {
      await _apply(() => clear ? widget.controller.clearLastCalendar(id) : widget.controller.deleteCalendar(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = context.msg;
    final controller = widget.controller;
    return AlertDialog(
      title: Text(m('manageLocalCalendars')),
      content: SizedBox(
        width: 440,
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) => ListView(
            shrinkWrap: true,
            children: [
              for (final calendar in controller.calendars)
                ListTile(
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
                        onPressed: _busy ? null : () => _edit(id: calendar.id, name: calendar.name),
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
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.pop(context), child: Text(m('closeButton'))),
        FilledButton.icon(
          onPressed: _busy ? null : _edit,
          icon: const Icon(SuiteIcons.add),
          label: Text(m('addLocalCalendar')),
        ),
      ],
    );
  }
}

class _CalendarNameDialog extends StatefulWidget {
  const _CalendarNameDialog({required this.messages, required this.initialName});

  final Messages messages;
  final String? initialName;

  @override
  State<_CalendarNameDialog> createState() => _CalendarNameDialogState();
}

class _CalendarNameDialogState extends State<_CalendarNameDialog> {
  late final _name = TextEditingController(text: widget.initialName);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.messages;
    final canSave = widget.initialName == null || _name.text.trim().isNotEmpty;
    return AlertDialog(
      title: Text(m(widget.initialName == null ? 'addLocalCalendar' : 'renameLocalCalendar')),
      content: TextField(
        controller: _name,
        autofocus: true,
        decoration: InputDecoration(labelText: m('calendarName')),
        onChanged: (_) => setState(() {}),
        onSubmitted: (name) {
          if (canSave) Navigator.pop(context, name.trim());
        },
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(m('cancel'))),
        FilledButton(
          onPressed: canSave ? () => Navigator.pop(context, _name.text.trim()) : null,
          child: Text(m('save')),
        ),
      ],
    );
  }
}
