import 'package:flutter/widgets.dart';

/// Metadata for each language offered by the website.
///
/// To add a language:
///  1. Add `lib/l10n/app_<code>.arb` (copy `app_en.arb` and translate values).
///  2. Add an entry below.
///  3. Run `flutter gen-l10n` (or any `flutter run/build`).
///  4. Re-run `python3 tool/generate_sitemap.py` to add hreflang entries.
@immutable
class SupportedLanguage {
  const SupportedLanguage({
    required this.code,
    required this.nativeName,
    required this.shortLabel,
    required this.ogLocale,
    this.isRtl = false,
  });

  /// ISO 639-1 language code (matches the ARB file suffix).
  final String code;

  /// Name of the language written in that language.
  final String nativeName;

  /// Compact label used in the navigation bar.
  final String shortLabel;

  /// Open Graph locale (e.g. `es_ES`).
  final String ogLocale;

  /// Whether the language is written right-to-left.
  final bool isRtl;

  Locale get locale => Locale(code);
}

/// Display order follows the navigation bar: EN | 中文 | العربية | ES | IT | FR | DE | PT
const List<SupportedLanguage> supportedLanguages = <SupportedLanguage>[
  SupportedLanguage(code: 'en', nativeName: 'English', shortLabel: 'EN', ogLocale: 'en_GB'),
  SupportedLanguage(code: 'zh', nativeName: '中文', shortLabel: '中文', ogLocale: 'zh_CN'),
  SupportedLanguage(code: 'ar', nativeName: 'العربية', shortLabel: 'العربية', ogLocale: 'ar_AE', isRtl: true),
  SupportedLanguage(code: 'es', nativeName: 'Español', shortLabel: 'ES', ogLocale: 'es_ES'),
  SupportedLanguage(code: 'it', nativeName: 'Italiano', shortLabel: 'IT', ogLocale: 'it_IT'),
  SupportedLanguage(code: 'fr', nativeName: 'Français', shortLabel: 'FR', ogLocale: 'fr_FR'),
  SupportedLanguage(code: 'de', nativeName: 'Deutsch', shortLabel: 'DE', ogLocale: 'de_DE'),
  SupportedLanguage(code: 'pt', nativeName: 'Português', shortLabel: 'PT', ogLocale: 'pt_PT'),
];

const SupportedLanguage defaultLanguage = SupportedLanguage(
  code: 'en',
  nativeName: 'English',
  shortLabel: 'EN',
  ogLocale: 'en_GB',
);

SupportedLanguage languageFor(String? code) {
  if (code == null) return defaultLanguage;
  final normalised = code.toLowerCase().split(RegExp('[-_]')).first;
  for (final lang in supportedLanguages) {
    if (lang.code == normalised) return lang;
  }
  return defaultLanguage;
}

bool isSupportedCode(String? code) {
  if (code == null) return false;
  final normalised = code.toLowerCase().split(RegExp('[-_]')).first;
  return supportedLanguages.any((l) => l.code == normalised);
}
