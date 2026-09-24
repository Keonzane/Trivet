import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum Pillar { work, health, leisure }

class AppSpacing {
  static const double xs = 4; // inside components only
  static const double sm = 8; // base unit, list gaps
  static const double md = 16; // screen edge padding
  static const double lg = 24; // between sections
}

@immutable
class PillarColors extends ThemeExtension<PillarColors> {
  final Color work;
  final Color health;
  final Color leisure;
  final Color onPillar;

  const PillarColors({
    required this.work,
    required this.health,
    required this.leisure,
    required this.onPillar,
  });

  Color of(Pillar pillar) {
    switch (pillar) {
      case Pillar.work:
        return work;
      case Pillar.health:
        return health;
      case Pillar.leisure:
        return leisure;
    }
  }

  static const light = PillarColors(
    work: Color(0xFF3D5A73), // Slate
    health: Color(0xFF4F7942), // Moss
    leisure: Color(0xFFB4531F), // Ember
    onPillar: Colors.white,
  );

  static const dark = PillarColors(
    work: Color(0xFF7FA3C4), // Slate (dark)
    health: Color(0xFF7FB36F), // Moss (dark)
    leisure: Color(0xFFE58A5A), // Ember (dark)
    onPillar: Color(0xFF1C1E1F), // Ink — pillar fills are light in dark mode
  );

  @override
  PillarColors copyWith({
    Color? work,
    Color? health,
    Color? leisure,
    Color? onPillar,
  }) {
    return PillarColors(
      work: work ?? this.work,
      health: health ?? this.health,
      leisure: leisure ?? this.leisure,
      onPillar: onPillar ?? this.onPillar,
    );
  }

  @override
  PillarColors lerp(ThemeExtension<PillarColors>? other, double t) {
    if (other is! PillarColors) return this;
    return PillarColors(
      work: Color.lerp(work, other.work, t)!,
      health: Color.lerp(health, other.health, t)!,
      leisure: Color.lerp(leisure, other.leisure, t)!,
      onPillar: Color.lerp(onPillar, other.onPillar, t)!,
    );
  }
}

extension PillarColorsContext on BuildContext {
  PillarColors get pillars => Theme.of(this).extension<PillarColors>()!;
}

const _paper = Color(0xFFF5F3EE);
const _ink = Color(0xFF1C1E1F);
const _line = Color(0xFFE4E1D8);
const _secondaryGrey = Color(0xFF5C5F61);
const _error = Color(0xFFB3261E);

const _night = Color(0xFF1C1E1F);
const _bone = Color(0xFFF5F3EE);
const _lineDark = Color(0xFF3F4345);
const _secondaryGreyDark = Color(0xFFA6AAAC);
const _errorDark = Color(0xFFF0847C);

TextTheme _textTheme(Color onSurface) {
  final headline = GoogleFonts.spaceGrotesk(color: onSurface);
  final body = GoogleFonts.ibmPlexSans(color: onSurface);
  return TextTheme(
    headlineLarge: headline.copyWith(fontSize: 32, fontWeight: FontWeight.w700),
    headlineSmall: headline.copyWith(fontSize: 24, fontWeight: FontWeight.w700),
    bodyMedium: body.copyWith(fontSize: 16, fontWeight: FontWeight.w400),
    labelLarge: body.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      fontFeatures: const [FontFeature.tabularFigures()],
    ),
    labelSmall: body.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.8,
    ),
  );
}

final ThemeData appTheme = _buildTheme(
  brightness: Brightness.light,
  surface: _paper,
  onSurface: _ink,
  outline: _secondaryGrey,
  outlineVariant: _line,
  error: _error,
  pillarColors: PillarColors.light,
);

final ThemeData appDarkTheme = _buildTheme(
  brightness: Brightness.dark,
  surface: _night,
  onSurface: _bone,
  outline: _secondaryGreyDark,
  outlineVariant: _lineDark,
  error: _errorDark,
  pillarColors: PillarColors.dark,
);

ThemeData _buildTheme({
  required Brightness brightness,
  required Color surface,
  required Color onSurface,
  required Color outline,
  required Color outlineVariant,
  required Color error,
  required PillarColors pillarColors,
}) {
  final colorScheme = ColorScheme(
    brightness: brightness,
    primary: onSurface,
    onPrimary: surface,
    secondary: outline,
    onSecondary: surface,
    surface: surface,
    onSurface: onSurface,
    error: error,
    onError: surface,
    outline: outline,
    outlineVariant: outlineVariant,
  );

  final textTheme = _textTheme(onSurface);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: surface,
    textTheme: textTheme,
    extensions: [pillarColors],
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: outlineVariant),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        minimumSize: const Size.fromHeight(48),
        textStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: onSurface,
        side: BorderSide(color: outline),
        minimumSize: const Size.fromHeight(48),
        textStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      labelStyle: textTheme.labelSmall,
      hintStyle: textTheme.bodyMedium?.copyWith(color: outline),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + AppSpacing.xs,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: onSurface),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: error),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      indicatorColor: outlineVariant,
      labelTextStyle: WidgetStatePropertyAll(textTheme.labelSmall),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: surface,
      selectedLabelTextStyle: textTheme.labelSmall,
      unselectedLabelTextStyle: textTheme.labelSmall,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surface,
      selectedColor: onSurface,
      labelStyle: textTheme.labelLarge,
      secondaryLabelStyle: textTheme.labelLarge?.copyWith(color: surface),
      side: BorderSide(color: outlineVariant),
      shape: const StadiumBorder(),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        backgroundColor: surface,
        selectedBackgroundColor: onSurface,
        selectedForegroundColor: surface,
        foregroundColor: onSurface,
        side: BorderSide(color: outlineVariant),
        textStyle: textTheme.labelLarge,
      ),
    ),
    dividerColor: outlineVariant,
  );
}
