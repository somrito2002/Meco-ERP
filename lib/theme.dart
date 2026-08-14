import 'package:flutter/material.dart';

/// Raw palette values shared by both themes.
///
/// Widgets should generally NOT reference these directly; use
/// `Theme.of(context).colorScheme` or `AppColors` instead.
abstract final class AppPalette {
  /// Brand navy, used as the primary color (buttons, focused borders, accents).
  static const Color navy = Color(0xFF0E2438);

  /// Primary color for dark mode (lighter navy so it stands out on black).
  static const Color navyLight = Color(0xFF3D74C0);

  /// Near-black text color used on light surfaces.
  static const Color ink = Color(0xFF1B2430);

  /// Pure black application background for dark mode.
  static const Color black = Color(0xFF000000);

  /// Light application background.
  static const Color lightBackground = Color(0xFFF7F8FA);

  /// Surface color for cards / inputs / menus in dark mode.
  static const Color darkSurface = Color(0xFF14161A);

  /// Elevated surface for dropdown menus in dark mode.
  static const Color darkSurfaceHigh = Color(0xFF1F242B);

  /// Subtle input border in light mode.
  static const Color lightBorder = Color(0xFFE0E3E8);

  /// Input border in dark mode (visible against black).
  static const Color darkBorder = Color(0xFF3D424C);

  /// Medium gray hint / secondary text in light mode.
  static const Color lightHint = Color(0xFF9AA1AC);

  /// Muted light gray hint / secondary text in dark mode.
  static const Color darkHint = Color(0xFFA0A6AF);
}

/// App-specific semantic colors that are not part of `ColorScheme`.
///
/// Access via `Theme.of(context).extension<AppColors>()`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.link,
    required this.inputFill,
    required this.divider,
  });

  /// Color used for interactive links (e.g. support email).
  final Color link;

  /// Fill color of text inputs.
  final Color inputFill;

  /// Center color of the gradient divider.
  final Color divider;

  static const AppColors light = AppColors(
    link: Color(0xFF2563EB),
    inputFill: Colors.white,
    divider: Color(0xFFD1D5DB),
  );

  static const AppColors dark = AppColors(
    link: Color(0xFF6FA8F5),
    inputFill: AppPalette.darkSurface,
    divider: Color(0xFF333945),
  );

  @override
  AppColors copyWith({Color? link, Color? inputFill, Color? divider}) {
    return AppColors(
      link: link ?? this.link,
      inputFill: inputFill ?? this.inputFill,
      divider: divider ?? this.divider,
    );
  }

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      link: Color.lerp(link, other.link, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
    );
  }
}

/// Centralized application themes.
abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final ColorScheme scheme = isDark ? _darkScheme() : _lightScheme();
    final AppColors appColors = isDark ? AppColors.dark : AppColors.light;

    final ThemeData base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Roboto',
      colorScheme: scheme,
    );

    const Radius radius = Radius.circular(12);
    final OutlineInputBorder border = OutlineInputBorder(
      borderRadius: const BorderRadius.all(radius),
      borderSide: BorderSide(color: scheme.outline),
    );

    return base.copyWith(
      scaffoldBackgroundColor:
          isDark ? AppPalette.black : AppPalette.lightBackground,
      extensions: <ThemeExtension<dynamic>>[appColors],

      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? AppPalette.black : AppPalette.lightBackground,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
      ),

      iconTheme: IconThemeData(color: scheme.onSurfaceVariant),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: appColors.inputFill,
        hintStyle: TextStyle(color: scheme.onSurfaceVariant, fontSize: 15),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        enabledBorder: border,
        disabledBorder: border,
        border: border,
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(radius),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(radius),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: scheme.primary),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.outline),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(radius),
          ),
        ),
      ),

      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(radius),
        ),
        margin: EdgeInsets.zero,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? AppPalette.darkSurfaceHigh : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(radius),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? AppPalette.darkSurfaceHigh : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: radius),
        ),
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: isDark ? AppPalette.darkSurfaceHigh : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(radius),
        ),
        textStyle: TextStyle(color: scheme.onSurface, fontSize: 15),
      ),

      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: appColors.inputFill,
          hintStyle: TextStyle(color: scheme.onSurfaceVariant),
          border: border,
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(radius),
            borderSide: BorderSide(color: scheme.primary, width: 1.5),
          ),
        ),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(
            isDark ? AppPalette.darkSurfaceHigh : Colors.white,
          ),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(radius),
            ),
          ),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 16,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            isDark ? AppPalette.darkSurfaceHigh : AppPalette.ink,
        contentTextStyle: TextStyle(
          color: isDark ? scheme.onSurface : Colors.white,
        ),
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? AppPalette.darkSurfaceHigh : AppPalette.ink,
          borderRadius: const BorderRadius.all(Radius.circular(6)),
        ),
        textStyle: TextStyle(
          color: isDark ? Colors.white : Colors.white,
          fontSize: 13,
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? AppPalette.darkSurface : Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        iconTheme: WidgetStatePropertyAll(
          IconThemeData(color: scheme.onSurfaceVariant),
        ),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(color: scheme.onSurface, fontSize: 12),
        ),
      ),
    );
  }

  static ColorScheme _lightScheme() {
    return ColorScheme.fromSeed(seedColor: AppPalette.navy).copyWith(
      brightness: Brightness.light,
      primary: AppPalette.navy,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFE3EAF2),
      onPrimaryContainer: AppPalette.navy,
      surface: Colors.white,
      onSurface: AppPalette.ink,
      onSurfaceVariant: AppPalette.lightHint,
      outline: AppPalette.lightBorder,
      outlineVariant: const Color(0xFFE6E9EE),
    );
  }

  static ColorScheme _darkScheme() {
    return ColorScheme.fromSeed(
      seedColor: AppPalette.navy,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppPalette.navyLight,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFF1E2F4A),
      onPrimaryContainer: const Color(0xFFCFE0F8),
      surface: AppPalette.darkSurface,
      onSurface: Colors.white,
      onSurfaceVariant: AppPalette.darkHint,
      outline: AppPalette.darkBorder,
      outlineVariant: const Color(0xFF2A2F37),
      surfaceContainerHighest: AppPalette.darkSurfaceHigh,
    );
  }
}
