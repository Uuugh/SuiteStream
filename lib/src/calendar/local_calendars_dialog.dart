import 'package:flutter/material.dart';

import '../theme/suite_icons.dart';
import '../l10n/messages.dart';
import '../ui/cancel_save_pair.dart';
import '../ui/confirm.dart';
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
      content: SizedBox(width: 440, child: LocalCalendarsPanel(controller: controller)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(m('closeButton'))),
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
    return SuiteAlertDialog(
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
        CancelSavePair(
          cancelLabel: m('cancel'),
          saveLabel: m('save'),
          onCancel: () => Navigator.pop(context),
          saveEnabled: canSave,
          onSave: () => Navigator.pop(context, _name.text.trim()),
        ),
      ],
    );
  }
}
