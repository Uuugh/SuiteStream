import 'package:flutter/material.dart';

import 'package:scrumboard/src/l10n/messages.dart';

/// One choice of a [ScbFilter].
class ScbFilterChoice {
  const ScbFilterChoice(this.value, this.label);
  final String value;
  final String label;
}

/// The shared filter (UIC-21) in the ScrumBoard package, in the same look as
/// the app's: one control that opens a menu where the user selects one,
/// several, all or none of the choices, shown in the accent color while it is
/// active, and a change applies at once. The owner keeps what is hidden (so
/// choices that appear later are shown); this widget only draws it.
class ScbFilter extends StatelessWidget {
  const ScbFilter({
    super.key,
    required this.label,
    required this.choices,
    required this.hidden,
    required this.onChanged,
  });

  /// The filter's name, already a message (for example msg:scbFilterFeature).
  final String label;
  final List<ScbFilterChoice> choices;

  /// The values the user chose to hide.
  final Set<String> hidden;
  final ValueChanged<Set<String>> onChanged;

  /// UIC-21: the filter shows when it is active (anything is hidden).
  bool get active => choices.any((c) => hidden.contains(c.value));

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final m = context.msg;
    final color = active ? scheme.primary : null;
    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          closeOnActivate: false,
          onPressed: () => onChanged({}),
          child: Text(m('selectAll'), key: ValueKey('scb-filter-all-$label'), style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w600)),
        ),
        MenuItemButton(
          closeOnActivate: false,
          onPressed: () => onChanged({for (final c in choices) c.value}),
          child: Text(m('selectNone'), key: ValueKey('scb-filter-none-$label'), style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w600)),
        ),
        for (final c in choices)
          CheckboxMenuButton(
            closeOnActivate: false,
            value: !hidden.contains(c.value),
            onChanged: (on) => onChanged(on == true ? ({...hidden}..remove(c.value)) : {...hidden, c.value}),
            child: Text(c.label, key: ValueKey('scb-filter-${c.value}')),
          ),
      ],
      builder: (context, controller, _) => TextButton.icon(
        key: ValueKey('scb-filter-button-$label'),
        style: TextButton.styleFrom(foregroundColor: color ?? scheme.onSurface),
        onPressed: () => controller.isOpen ? controller.close() : controller.open(),
        icon: const Icon(Icons.filter_list),
        label: Text(label),
      ),
    );
  }
}
