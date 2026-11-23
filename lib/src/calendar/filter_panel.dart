import 'package:flutter/material.dart';

import 'package:suitestream/src/theme/suite_icons.dart';
import 'package:suitestream/src/l10n/messages.dart';
import 'package:suitestream/src/ui/suite_dropdown.dart';
import 'package:suitestream/src/calendar/calendar_controller.dart';
import 'package:suitestream/src/calendar/event_filter.dart';

String _stateLabel(Messages m, EventState s) => switch (s) {
      EventState.edited => m('stateEdited'),
      EventState.changedBySource => m('stateChangedBySource'),
      EventState.hiddenFromGoogle => m('stateHiddenFromGoogle'),
      EventState.deleted => m('stateDeleted'),
    };

/// FLT-01.a: the Calendar filter: one filter icon with a dropdown (UIC-12) that
/// lists every calendar with its color and the event states. Choosing items
/// shows only those events; nothing outside the calendar changes.
class CalendarFilterButton extends StatelessWidget {
  const CalendarFilterButton({super.key, required this.controller});

  final CalendarController controller;

  static String calendarValue(String id) => 'cal:$id';
  static String stateValue(EventState s) => 'state:${s.name}';

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final f = c.filter;
    final m = context.msg;
    final ids = [for (final cal in c.calendars) cal.id];
    final items = <DropdownItem<String>>[
      for (final cal in c.calendars)
        DropdownItem(
          value: calendarValue(cal.id),
          label: cal.name,
          leading: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: cal.color == null ? Theme.of(context).colorScheme.primary : Color(cal.color!),
              shape: BoxShape.circle,
            ),
          ),
        ),
      for (final s in EventState.values) DropdownItem(value: stateValue(s), label: _stateLabel(m, s)),
    ];
    final selected = <String>{
      for (final id in ids)
        if (f.calendarShown(id)) calendarValue(id),
      for (final s in EventState.values)
        if (f.stateShown(s)) stateValue(s),
    };
    return SuiteDropdown<String>(
      icon: SuiteIcons.filterList,
      tooltip: m('calendarFilter'),
      multi: true,
      active: f.active,
      items: items,
      selected: selected,
      actions: [
        DropdownAction(label: m('selectAll'), onPressed: f.selectAll),
        DropdownAction(label: m('selectNone'), onPressed: () => f.selectNone(ids)),
      ],
      onChanged: (shown) => f.setShown(
        calendarIds: ids,
        shownCalendars: {for (final id in ids) if (shown.contains(calendarValue(id))) id},
        shownStates: {for (final s in EventState.values) if (shown.contains(stateValue(s))) s},
      ),
    );
  }
}

