import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/suite_icons.dart';
import '../l10n/messages.dart';
import '../theme/suite_theme.dart';
import '../theme/tokens.dart';
import '../time/suite_event.dart';
import '../time/time_format.dart';
import '../time/zones.dart';
import '../ui/confirm.dart';
import '../ui/popup_size_lock.dart';
import 'calendar_controller.dart';
import 'event_dialog.dart';

/// EVT-07.b: the range text is "day, start–end" for one day and
/// "day start – day end" across days; an all-day event shows its day, or its
/// first and last days, followed by msg:allDay3.
String eventRangeText(Messages m, SuiteEvent e, Location zone, TimeFormat format) {
  final s = e.startIn(zone);
  var en = e.endIn(zone);
  String day(TZDateTime d) => DateFormat.MMMEd(m.locale).format(d);
  String time(TZDateTime d) => formatTimeOfDay(d.hour, d.minute, format);
  if (e.allDay) {
    final last = en.subtract(const Duration(days: 1));
    final sameDay = last.year == s.year && last.month == s.month && last.day == s.day;
    final days = sameDay ? day(s) : '${day(s)} – ${day(last)}';
    return '$days ${m('allDay3')}';
  }
  final sameDay = s.year == en.year && s.month == en.month && s.day == en.day;
  if (sameDay) return '${day(s)}, ${time(s)}–${time(en)}';
  return '${day(s)} ${time(s)} – ${day(en)} ${time(en)}';
}

/// EVT-07: clicking an event opens its details in place. They stay open when the
/// calendar is redrawn until Close (msg:closeButton).
class EventDetails extends StatelessWidget {
  const EventDetails({super.key, required this.controller, required this.event});

  final CalendarController controller;
  final SuiteEvent event;

  Future<void> _openEditor(
    BuildContext context,
    CalendarController controller,
    SuiteEvent event, {
    required bool duplicate,
  }) async {
    await openEventDialog(
      context,
      controller,
      event: duplicate ? null : event,
      duplicateOf: duplicate ? event : null,
    );
    if (context.mounted) controller.selectEvent(null);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final m = context.msg;
    final c = controller;
    final e = event;
    final calendar = c.calendars.where((x) => x.id == e.calendarId).firstOrNull;
    final lines = <String>[
      if (e.hiddenFromGoogle) m('hiddenFromGoogleCalendar'), // EVT-07.d
      if (e.edited) m('editedHere'),
      if (e.deleted) m('deletedInSuitestream'),
    ];
    return Container(
      key: const ValueKey('event-details'),
      width: double.infinity,
      padding: const EdgeInsets.all(suiteDialogPadding),
      decoration: BoxDecoration(
        color: t.soft,
        border: Border(top: BorderSide(color: t.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(e.title, key: const ValueKey('details-title'), style: SuiteText.label(t).copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(eventRangeText(m, e, c.localZone.location, c.timeFormat), key: const ValueKey('details-range'), style: SuiteText.note(t)),
          if (e.location.isNotEmpty)
            Row(children: [
              const Icon(SuiteIcons.locationOn, size: 16),
              const SizedBox(width: 4),
              Expanded(child: Text(e.location, key: const ValueKey('details-location'), style: SuiteText.body(t))),
            ]),
          if (e.notes.isNotEmpty) Text(e.notes, key: const ValueKey('details-notes'), style: SuiteText.body(t), maxLines: 6, overflow: TextOverflow.ellipsis),
          for (final l in lines) Text(l, style: SuiteText.note(t)),
          // EVT-07.h: the calendar is named when there is more than one.
          if (c.calendars.length > 1 && calendar != null)
            Text(calendar.name, key: const ValueKey('details-calendar'), style: SuiteText.note(t)),
          const SizedBox(height: 4),
          Row(
            children: [
              TextButton(key: const ValueKey('details-close'), onPressed: () => c.selectEvent(null), child: Text(m('closeButton'))),
              const Spacer(),
              IconButton(
                key: const ValueKey('details-edit'),
                tooltip: m('edit'),
                icon: const Icon(SuiteIcons.edit),
                onPressed: () =>
                    _openEditor(context, c, e, duplicate: false),
              ),
              IconButton(
                key: const ValueKey('details-duplicate'),
                tooltip: m('duplicateEvent'),
                icon: const Icon(SuiteIcons.contentCopy),
                onPressed: () => _openEditor(context, c, e, duplicate: true),
              ),
              IconButton(
                key: const ValueKey('details-delete'),
                tooltip: e.custom ? m('deleteEvent') : (e.hiddenFromGoogle ? m('showButton') : m('hideButton')),
                icon: Icon(e.custom ? SuiteIcons.delete : (e.hiddenFromGoogle ? SuiteIcons.visibility : SuiteIcons.visibilityOff)),
                onPressed: () async {
                  // EVT-07.k: Delete asks msg:deleteEventAsk and hide asks msg:hideEventAsk (UIC-06).
                  if (e.custom) {
                    if (await confirmYesNo(context, m('deleteEventAsk'))) c.deleteEvent(e.id);
                  } else if (e.hiddenFromGoogle) {
                    c.setHidden(e.id, false);
                  } else if (await confirmYesNo(context, m('hideEventAsk'))) {
                    c.setHidden(e.id, true);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// EVT-07: shows the details of the clicked event in a popup over the calendar,
/// so the calendar itself is never resized. The popup stays open when the
/// calendar is redrawn until Close, and closing it clears the choice.
class EventDetailsHost extends StatefulWidget {
  const EventDetailsHost({super.key, required this.controller, required this.child});

  final CalendarController controller;
  final Widget child;

  @override
  State<EventDetailsHost> createState() => _EventDetailsHostState();
}

class _EventDetailsHostState extends State<EventDetailsHost> {
  bool _open = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_sync);
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  @override
  void dispose() {
    widget.controller.removeListener(_sync);
    super.dispose();
  }

  void _sync() {
    if (!mounted) return;
    final selected = widget.controller.selectedEvent;
    if (selected != null && !_open) {
      _open = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _show());
    }
  }

  Future<void> _show() async {
    if (!mounted) return;
    final c = widget.controller;
    final msgs = context.msg;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => MessagesScope(
        messages: msgs,
        child: ListenableBuilder(
          listenable: c,
          builder: (context, _) {
            final e = c.selectedEvent;
            if (e == null) {
              // The editor can open another route while it closes. Dismiss
              // this details route even when another popup is on top of it.
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!dialogContext.mounted) return;
                final route = ModalRoute.of(dialogContext);
                if (route == null || !route.isActive) return;
                if (route.isCurrent) {
                  route.navigator?.pop();
                } else {
                  route.navigator?.removeRoute(route);
                }
              });
              return const SizedBox.shrink();
            }
            return Dialog(
              backgroundColor: context.tokens.card,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: PopupSizeLock(child: Padding(padding: const EdgeInsets.all(4), child: EventDetails(controller: c, event: e))),
              ),
            );
          },
        ),
      ),
    );
    _open = false;
    c.selectEvent(null); // dismissing the popup clears the choice
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
