import 'package:flutter/widgets.dart';

import '../core/breakpoints.dart';

enum ScriptKind { latin, arabic, cjk }

/// Script-aware, responsive type scale.
///
/// * Latin: Inter with tight tracking on large headings.
/// * Arabic: IBM Plex Sans Arabic, **no letter-spacing** (it breaks joining)
///   and taller line height.
/// * Chinese: Inter for Latin glyphs; CJK glyphs fall back to Noto Sans SC,
///   which Flutter Web loads automatically on demand. No letter-spacing.
class AppTypography {
  AppTypography._(this.script, this._size);

  final ScriptKind script;
  final ScreenSize _size;

  static const String latinFamily = 'Inter';
  static const String arabicFamily = 'IBMPlexSansArabic';

  static ScriptKind scriptFor(Locale locale) => switch (locale.languageCode) {
        'ar' => ScriptKind.arabic,
        'zh' => ScriptKind.cjk,
        _ => ScriptKind.latin,
      };

  static String familyFor(ScriptKind script) =>
      script == ScriptKind.arabic ? arabicFamily : latinFamily;

  static List<String> fallbackFor(ScriptKind script) => switch (script) {
        ScriptKind.arabic => const <String>[latinFamily],
        ScriptKind.cjk => const <String>['Noto Sans SC', 'PingFang SC', 'Microsoft YaHei'],
        ScriptKind.latin => const <String>[arabicFamily],
      };

  static AppTypography of(BuildContext context) =>
      AppTypography._(scriptFor(Localizations.localeOf(context)), Breakpoints.of(context));

  bool get _isLatin => script == ScriptKind.latin;

  double _track(double latin) => _isLatin ? latin : 0;
  double _height(double latin) => switch (script) {
        ScriptKind.latin => latin,
        ScriptKind.arabic => latin + 0.28,
        ScriptKind.cjk => latin + 0.2,
      };

  double _pick(double mobile, double tablet, double laptop, double desktop) => switch (_size) {
        ScreenSize.mobile => mobile,
        ScreenSize.tablet => tablet,
        ScreenSize.laptop => laptop,
        ScreenSize.desktop => desktop,
      };

  TextStyle _base(double size, FontWeight weight, double height, double tracking) => TextStyle(
        fontFamily: familyFor(script),
        fontFamilyFallback: fallbackFor(script),
        fontSize: size,
        fontWeight: weight,
        height: _height(height),
        letterSpacing: _track(tracking),
      );

  /// Hero headline.
  TextStyle get display => _base(_pick(38, 50, 58, 68), FontWeight.w600, 1.06, -1.6);

  /// Page / section title (h2).
  TextStyle get h1 => _base(_pick(32, 40, 44, 52), FontWeight.w600, 1.1, -1.2);

  TextStyle get h2 => _base(_pick(28, 34, 38, 42), FontWeight.w600, 1.14, -0.9);

  TextStyle get h3 => _base(_pick(19, 20, 21, 22), FontWeight.w600, 1.3, -0.3);

  TextStyle get h4 => _base(17, FontWeight.w600, 1.35, -0.1);

  TextStyle get lead => _base(_pick(17, 18, 19, 20), FontWeight.w400, 1.6, -0.1);

  TextStyle get body => _base(16, FontWeight.w400, 1.62, 0);

  TextStyle get bodySmall => _base(14.5, FontWeight.w400, 1.55, 0);

  TextStyle get caption => _base(13, FontWeight.w400, 1.5, 0);

  TextStyle get label => _base(14.5, FontWeight.w500, 1.3, 0);

  TextStyle get button => _base(15, FontWeight.w600, 1.2, 0);

  /// Small uppercase kicker above headings. Uppercase is applied in the widget
  /// only for Latin scripts.
  TextStyle get eyebrow => _base(12.5, FontWeight.w600, 1.3, 1.6);

  TextStyle get stat => _base(_pick(38, 44, 48, 56), FontWeight.w600, 1.0, -1.5);

  bool get usesUppercase => _isLatin;
}
