import 'package:flutter/material.dart';

// Colors ported verbatim from the prototype design tokens.
const _lightBg = Color(0xFFFDF3EA);
const _lightSurface = Color(0xFFFFFFFF);
const _lightText = Color(0xFF4A2F22);
const _lightAccent = Color(0xFFC46A3A);

const _darkBg = Color(0xFF2A1810);
const _darkSurface = Color(0xFF3D2416);
const _darkText = Color(0xFFF5ECE2);
const _darkAccent = Color(0xFFE08A5C);

ThemeData _build({
  required Brightness brightness,
  required Color bg,
  required Color surface,
  required Color text,
  required Color accent,
}) {
  final divider = text.withValues(alpha: 0.12);
  final base = ThemeData(
      brightness: brightness, useMaterial3: true, fontFamily: 'Comfortaa');
  return base.copyWith(
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: accent,
      brightness: brightness,
    ).copyWith(
      primary: accent,
      surface: surface,
      onSurface: text,
    ),
    dividerColor: divider,
    dividerTheme: DividerThemeData(color: divider, thickness: 1, space: 1),
    cardColor: surface,
    textTheme: base.textTheme.apply(bodyColor: text, displayColor: text),
    iconTheme: IconThemeData(color: text),
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      foregroundColor: text,
      elevation: 0,
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: accent, width: 2),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: bg,
      indicatorColor: accent.withValues(alpha: 0.16),
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: text),
      ),
    ),
  );
}

final ThemeData lightTheme = _build(
  brightness: Brightness.light,
  bg: _lightBg,
  surface: _lightSurface,
  text: _lightText,
  accent: _lightAccent,
);

final ThemeData darkTheme = _build(
  brightness: Brightness.dark,
  bg: _darkBg,
  surface: _darkSurface,
  text: _darkText,
  accent: _darkAccent,
);

// Accent helper for widgets that need the credit color directly.
Color accentOf(BuildContext context) => Theme.of(context).colorScheme.primary;
