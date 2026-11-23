import 'package:flutter/material.dart';

import '../app/test_data.dart';
import '../l10n/messages.dart';
import '../theme/theme_mode_controller.dart';
import '../theme/suite_theme.dart';
import '../ui/confirm.dart';
import 'calendar_controller.dart';

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
    setState(() => _status = ok ? m.orElse('adminAdded', 'Test calendars added.') : m.orElse('adminFailed', 'Could not save. Try again.'));
  }

  Future<void> _remove() async {
    final m = context.msg;
    final question = m.orElse(
      'adminRemoveConfirm',
      'Remove the test calendars and their events? Your own calendars and events are not changed.',
    );
    if (!await confirmYesNo(context, question) || !mounted) return;
    final ok = await widget.controller.removeCalendarData({for (final c in testCalendars) c.id}, isRemovedEvent: isTestEvent);
    if (!mounted) return;
    setState(() => _status = ok ? m.orElse('adminRemoved', 'Test data removed.') : m.orElse('adminFailed', 'Could not save. Try again.'));
  }

  @override
  Widget build(BuildContext context) {
    final m = context.msg;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(m.orElse('adminTestDataHelp', 'Test calendars Work, Family and Travel with sample events across November 2026, for trying the app.')),
        const SizedBox(height: suitePartGap),
        Wrap(
          spacing: suitePartGap,
          runSpacing: suitePartGap,
          children: [
            FilledButton(
              key: const ValueKey('admin-add-test-data'),
              onPressed: _add,
              child: Text(m.orElse('adminAddTestCalendars', 'Add test calendars')),
            ),
            OutlinedButton(
              key: const ValueKey('admin-remove-test-data'),
              onPressed: _remove,
              child: Text(m.orElse('adminRemoveTestData', 'Remove test data')),
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
