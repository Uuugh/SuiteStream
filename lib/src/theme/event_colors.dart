import 'package:flutter/material.dart';

/// Event color choices come from the active Material theme.
Map<String, Color> eventColors(ColorScheme scheme) => {
  'primary': scheme.primary,
  'secondary': scheme.secondary,
  'tertiary': scheme.tertiary,
  'primaryContainer': scheme.primaryContainer,
  'secondaryContainer': scheme.secondaryContainer,
  'tertiaryContainer': scheme.tertiaryContainer,
  'outline': scheme.outline,
};
