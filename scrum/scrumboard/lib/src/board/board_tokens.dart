import 'package:scrumboard/src/theme/scrum_theme.dart';

/// Board sizes, derived from the theme tokens. The block width is not a theme
/// token yet; it is asked for in handoffs.md (Ito section).
class BoardTokens {
  const BoardTokens._();

  /// Width of the Backlog block and of every top-level block (SCB-06.g).
  static const double blockWidth = 360;

  /// Gap between items inside a block.
  static const double nestGap = scrumPartGap;

  static const double gap = scrumPagePadding;
  static const double radius = scrumPanelRadius;
  static const double nestedRadius = scrumPanelRadius - scrumPartGap;
  static const double borderWidth = scrumPanelBorderWidth;
  static const double padding = scrumPagePadding;
}
