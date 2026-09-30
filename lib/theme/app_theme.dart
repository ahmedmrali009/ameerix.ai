import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Material theme used for framework widgets (inputs, menus, dialogs,
/// scrollbars). Most site components style themselves via [Tone] and
/// [AppTypography].
class AppTheme {
  const AppTheme._();

  static ThemeData forLocale(Locale locale) {
    final script = AppTypography.scriptFor(locale);
    final family = AppTypography.familyFor(script);
    final fallback = AppTypography.fallbackFor(script);

    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.blueDeep,
      onPrimary: AppColors.pureWhite,
      secondary: AppColors.violetDeep,
      onSecondary: AppColors.white,
      error: Color(0xFFB42318),
      onError: AppColors.white,
      surface: AppColors.white,
      onSurface: AppColors.navyInk,
      outline: AppColors.lineLightStrong,
      outlineVariant: AppColors.lineLight,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: family,
      fontFamilyFallback: fallback,
      scaffoldBackgroundColor: AppColors.black,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: const Color(0x0A2563EB),
      focusColor: const Color(0x292563EB),
      visualDensity: VisualDensity.standard,
    );

    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c, width: w),
        );

    return base.copyWith(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.pureWhite,
        isDense: false,
        contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
        labelStyle: const TextStyle(color: AppColors.grey600, fontSize: 15),
        floatingLabelStyle: const TextStyle(color: AppColors.blueInk, fontWeight: FontWeight.w500),
        hintStyle: const TextStyle(color: AppColors.grey500, fontSize: 15),
        errorStyle: const TextStyle(color: Color(0xFFB42318), fontSize: 13, height: 1.3),
        errorMaxLines: 3,
        border: border(AppColors.lineLightStrong),
        enabledBorder: border(AppColors.lineLightStrong),
        focusedBorder: border(AppColors.blueDeep, 1.6),
        errorBorder: border(const Color(0xFFB42318)),
        focusedErrorBorder: border(const Color(0xFFB42318), 1.6),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.lineDark),
        ),
        textStyle: const TextStyle(color: AppColors.white, fontSize: 15),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(const Color(0x6694A3B8)),
        thickness: WidgetStateProperty.all(6),
        radius: const Radius.circular(8),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.blueDeep,
        selectionColor: Color(0x403B82F6),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? AppColors.blueDeep : Colors.transparent,
        ),
        side: const BorderSide(color: AppColors.grey500, width: 1.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      dropdownMenuTheme: const DropdownMenuThemeData(
        menuStyle: MenuStyle(backgroundColor: WidgetStatePropertyAll(AppColors.pureWhite)),
      ),
      tooltipTheme: const TooltipThemeData(
        decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.all(Radius.circular(6))),
        textStyle: TextStyle(color: AppColors.white, fontSize: 13),
      ),
    );
  }
}
