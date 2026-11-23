import 'package:flutter/material.dart';

import 'theme_settings.dart';
import 'tokens.dart';

/// THM-01.a: IBM Plex Sans is the font for everything.
const String sansFamily = 'IBM Plex Sans';

/// THM-01.b: IBM Plex Mono is only for what is typed or copied exactly
/// (links, IDs, the Username, the client ID, the stream name).
const String monoFamily = 'IBM Plex Mono';

/// DEF-01: phone-width window, 700 px wide or narrower.
const double phoneMaxWidth = 700;

/// THM-06.c, SET-03.c: the one animation time (DEF-01), which the user can change
/// in Settings. Cancel | Save slide, word change, pulse and hover all use it.
const Duration defaultAnimationDuration = Duration(milliseconds: 500);
const Duration maxAnimationDuration = Duration(seconds: 2);

/// Offers the user's animation time to every widget below it. Without one, the
/// default applies. Reduced motion (MediaQuery.disableAnimations) always wins.
class SuiteAnimationScope extends InheritedWidget {
  const SuiteAnimationScope({super.key, required this.duration, required super.child});

  final Duration duration;

  /// The animation time in effect for [context]: zero when reduced motion is requested.
  static Duration of(BuildContext context) {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return Duration.zero;
    return context.dependOnInheritedWidgetOfExactType<SuiteAnimationScope>()?.duration ?? defaultAnimationDuration;
  }

  @override
  bool updateShouldNotify(SuiteAnimationScope old) => duration != old.duration;
}

const double suiteControlRadius = 8;
const double suitePanelRadius = 12;
const double suiteControlHeight = 34;
const double suiteCompactControlHeight = 28;
const double suitePartGap = 5;
const double suiteStackedZoneGap = 6;
/// Spacing: all layout padding and gaps come from these, so the app keeps one rhythm.
/// Literal values elsewhere are only for alignment fixes or component geometry.
const double suiteDialogPadding = 12;
const double suitePagePadding = suiteDialogPadding;
const double suiteLabelGap = 3;
const double suiteChipRadius = 6;
/// Vertical padding inside a text field, so a field with one line is [suiteControlHeight] tall.
const double suiteFieldVerticalPadding = 6.5;
/// Vertical padding of a dropdown field: its 24 px arrow, not the text, sets the content
/// height, so the field is still [suiteControlHeight] tall.
const double suiteDropdownVerticalPadding = (suiteControlHeight - 24) / 2;
/// Height of the label line over a field (12 px bold text and the small checkbox beside it).
const double suiteLabelHeight = 17;
/// Gap between two side-by-side fields, and between the two dialog columns.
const double suiteColumnGap = 10;
/// UIC-43, THM-10.d: the shadow depth of every popup (dialog, menu, picker, popover, opened
/// event) at the default Popup shadow setting (100 %). SET-03.e scales it.
const double suitePopupElevation = 8;

/// Color picker geometry (UIC-10): swatch size, selected check size, gap between swatches.
const double suiteSwatchSize = 30;
const double suiteSwatchCheckSize = 18;
const double suiteSwatchGap = 8;

/// Sizes that were literals (Kobayashi findings 6 and 7).
const double suiteColorPickerWidth = 7 * suiteSwatchSize + 6 * suiteSwatchGap;
const double suiteLocalCalendarsDialogWidth = 440;
const double suiteDefaultAvatarRadius = 6;
const Size suiteResizeBarSize = Size(29, 8);
const double suiteListColorBarWidth = 4;
const double suiteListColorBarHeight = 18;
const double suiteListColorBarGap = 8;
const double suiteStartupMaxWidth = 640;
const double suiteStartupPadding = 24;
const double suiteStartupGap = 12;
const double suiteStartupTitleSize = 20;

/// The popup shadow depth for [context]: [suitePopupElevation] scaled by the user's Popup
/// shadow setting (0 means no shadow).
double popupElevationOf(BuildContext context) =>
    suitePopupElevation * ThemeSettingsScope.of(context).popupShadow / 100;

/// A [DialogThemeData] with the popup shadow applied, for dialogs under [context].
DialogThemeData popupDialogTheme(BuildContext context, DialogThemeData base) =>
    base.copyWith(elevation: popupElevationOf(context), shadowColor: Theme.of(context).colorScheme.shadow);

const Alignment suiteBadgeAnchor = Alignment.bottomRight;
const Offset suiteBadgeOffset = Offset(1 / 4, 1 / 6);

ButtonStyle suiteIconButtonStyle({bool compact = false}) {
  final size = Size.square(
    compact ? suiteCompactControlHeight : suiteControlHeight,
  );
  return IconButton.styleFrom(
    minimumSize: size,
    fixedSize: size,
    padding: EdgeInsets.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(suiteControlRadius)),
    ),
  );
}

/// THM-01.c: the module kind is 17 px at weight 700 (15 px in a phone-width window).
double moduleKindSize({required double windowWidth}) =>
    windowWidth <= phoneMaxWidth ? 15 : 17;

/// THM-01.d text styles. Default text is 14 px; labels are weight 600; notes are
/// 13 px in the muted color.
class SuiteText {
  const SuiteText._();

  static const double bodySize = 14;
  static const double noteSize = 13;

  static TextStyle body(SuiteTokens t) => TextStyle(
    fontFamily: sansFamily,
    fontSize: bodySize,
    fontWeight: FontWeight.w400,
    color: t.text,
  );
  static TextStyle label(SuiteTokens t) =>
      body(t).copyWith(fontWeight: FontWeight.w600);
  static TextStyle note(SuiteTokens t) =>
      body(t).copyWith(fontSize: noteSize, color: t.muted);
  static TextStyle moduleKind(SuiteTokens t, {required double windowWidth}) =>
      body(t).copyWith(
        fontSize: moduleKindSize(windowWidth: windowWidth),
        fontWeight: FontWeight.w700,
      );
  static TextStyle mono(SuiteTokens t) =>
      body(t).copyWith(fontFamily: monoFamily);
}

/// Builds the app theme for a palette. Every component uses it by default.
ThemeData buildSuiteTheme(Brightness brightness) {
  final t = brightness == Brightness.dark
      ? SuiteTokens.dark
      : SuiteTokens.light;
  final base = SuiteText.body(t);
  final textTheme = TextTheme(
    displayLarge: base,
    displayMedium: base,
    displaySmall: base,
    headlineLarge: base,
    headlineMedium: base,
    headlineSmall: base,
    titleLarge: base.copyWith(fontSize: 17, fontWeight: FontWeight.w700),
    titleMedium: SuiteText.label(t),
    titleSmall: SuiteText.label(t),
    bodyLarge: base,
    bodyMedium: base,
    bodySmall: SuiteText.note(t),
    labelLarge: SuiteText.label(t),
    labelMedium: SuiteText.label(t),
    labelSmall: SuiteText.note(t),
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: t.scheme,
    scaffoldBackgroundColor: t.bg,
    canvasColor: t.card,
    dividerColor: t.line,
    fontFamily: sansFamily,
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    dialogTheme: DialogThemeData(
      elevation: suitePopupElevation,
      shadowColor: t.scheme.shadow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(suitePanelRadius)),
      ),
    ),
    menuTheme: MenuThemeData(
      style: MenuStyle(
        elevation: const WidgetStatePropertyAll(suitePopupElevation),
        shadowColor: WidgetStatePropertyAll(t.scheme.shadow),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(elevation: suitePopupElevation, shadowColor: t.scheme.shadow),
    // One height for every single-line text box and dropdown on the site. A multi-line
    // box overrides it with `constraints: const BoxConstraints()`.
    inputDecorationTheme: const InputDecorationThemeData(
      isDense: true,
      constraints: BoxConstraints.tightFor(height: suiteControlHeight),
      contentPadding: EdgeInsets.symmetric(horizontal: suiteDialogPadding, vertical: suiteFieldVerticalPadding),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(suiteControlRadius)),
      ),
    ),
    extensions: <ThemeExtension<dynamic>>[t],
  );
}
