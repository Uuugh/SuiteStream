import 'package:scrumboard/src/theme/scrum_theme.dart';

/// Board sizes. Shared ones come from the theme tokens; the two the theme does
/// not have yet are asked for in handoffs.md (Ito section) and kept here.
class BoardTokens {
  const BoardTokens._();

  /// Width of the Backlog block and of every top-level block (SCB-06.g).
  static const double blockWidth = 360;

  /// Gap between items inside a block.
  static const double nestGap = 8;

  static const double gap = scrumPagePadding;
  static const double radius = scrumPanelRadius;
  static const double nestedRadius = scrumPanelRadius - 4;
  static const double borderWidth = scrumPanelBorderWidth;
  static const double padding = scrumPagePadding;
}
