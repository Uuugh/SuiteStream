import 'package:flutter/material.dart';

import 'package:suitestream/src/app/test_data.dart';
import 'package:suitestream/src/l10n/messages.dart';
import 'package:suitestream/src/theme/suite_theme.dart';
import 'package:suitestream/src/ui/confirm.dart';
import 'package:suitestream/src/calendar/calendar_controller.dart';

/// Settings > Admin (PBI-041): adds and removes the test calendars.
class SettingsAdminPane extends StatefulWidget {
  const SettingsAdminPane({super.key, required this.controller});

  final CalendarController controller;

  @override
  State<SettingsAdminPane> createState() => _SettingsAdminPaneState();
}

class _SettingsAdminPaneState extends State<SettingsAdminPane> {
  String? _status;

  Future<void> _add() async {
    final m = context.msg;
    final c = widget.controller;
    final ok = await c.addCalendarData(testCalendars, buildTestEvents(c.baseZone.name));
    if (!mounted) return;
    setState(() => _status = ok ? m('adminAdded') : m('adminFailed'));
  }

  Future<void> _remove() async {
    final m = context.msg;
    if (!await confirmYesNo(context, m('adminRemoveConfirm')) || !mounted) return;
    final ok = await widget.controller.removeCalendarData({for (final c in testCalendars) c.id}, isRemovedEvent: isTestEvent);
    if (!mounted) return;
    setState(() => _status = ok ? m('adminRemoved') : m('adminFailed'));
  }

  @override
  Widget build(BuildContext context) {
    final m = context.msg;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(m('adminTestDataHelp')),
        const SizedBox(height: suitePartGap),
        Wrap(
          spacing: suitePartGap,
          runSpacing: suitePartGap,
          children: [
            FilledButton(
              key: const ValueKey('admin-add-test-data'),
              onPressed: _add,
              child: Text(m('adminAddTestCalendars')),
            ),
            OutlinedButton(
              key: const ValueKey('admin-remove-test-data'),
              onPressed: _remove,
              child: Text(m('adminRemoveTestData')),
            ),
          ],
        ),
        if (_status != null) ...[
          const SizedBox(height: suitePartGap),
          Text(_status!, key: const ValueKey('admin-status')),
        ],
      ],
    );
  }
}
