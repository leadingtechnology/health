import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppGaps {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

TextTheme _withLineHeights(TextTheme base) {
  // Titles ~1.2, body ~1.4 for readability across languages
  return base.copyWith(
    displaySmall: base.displaySmall?.copyWith(height: 1.2),
    headlineMedium: base.headlineMedium?.copyWith(height: 1.2),
    headlineSmall: base.headlineSmall?.copyWith(height: 1.2),
    titleLarge: base.titleLarge?.copyWith(height: 1.2),
    titleMedium: base.titleMedium?.copyWith(height: 1.2, fontWeight: FontWeight.w600),
    titleSmall: base.titleSmall?.copyWith(height: 1.2),
    bodyLarge: base.bodyLarge?.copyWith(height: 1.4),
    bodyMedium: base.bodyMedium?.copyWith(height: 1.4),
    bodySmall: base.bodySmall?.copyWith(height: 1.4),
    labelLarge: base.labelLarge?.copyWith(height: 1.2),
  );
}

ThemeData buildAppTheme({
  required Color seed,
  required Brightness brightness,
  List<String>? fontFallback,
  bool elderMode = false,
}) {
  final isDark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
  final baseTypography = Typography.material2021(platform: defaultTargetPlatform);
  final baseText = brightness == Brightness.dark ? baseTypography.white : baseTypography.black;
  final textTheme = _withLineHeights(baseText);

  final fillAlpha = isDark ? 0.12 : 0.06;

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    visualDensity: elderMode ? VisualDensity.comfortable : VisualDensity.standard,
    fontFamilyFallback: fontFallback,
    textTheme: textTheme,
  ).copyWith(
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: scheme.primary, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: scheme.surface.withValues(alpha: fillAlpha),
      isDense: true,
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 64,
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      indicatorColor: scheme.secondaryContainer,
      backgroundColor: scheme.surface,
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant, thickness: 1),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    ),
  );
}

