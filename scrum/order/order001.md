## Request

Build the Flutter/Dart foundation of SuiteStream and show a themed calendar.

## Context

The old Python app (the CalendarStream repository) is retired and will not be used. SuiteStream is recreated in Dart with Flutter from `requirements/`, which is the spec. On 2026-11-21 the Product Owner approved all requirements: every former `proposed` row is now `backlog` (1,433 rows). Nothing new is added during the transition freeze.

## Scope

- Language and framework: Dart with Flutter only. No Python or other languages. Nothing is ported from the old app; build from the requirements.

- Time model (TIM-01 to TIM-06, TIM-10), theme tokens and fonts (THM-01.a-d, THM-02.a-l), shared dropdown and instant-apply (UIC-12, UIC-13), Month and Week calendar views (CAL-01.a-d, h, i).
- Exclusions: connections/sync, events dialog, rules, print, settings screens, any `proposed` row.

## Priority

A runnable app that renders events in the correct time zone with the agreed theme.
