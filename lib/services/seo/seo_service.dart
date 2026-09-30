import 'package:flutter/foundation.dart';

import '../../config/app_config.dart';
import '../../localization/supported_languages.dart';
import 'seo_dom_stub.dart' if (dart.library.js_interop) 'seo_dom_web.dart' as dom;

/// Per-page metadata written into the HTML document.
@immutable
class PageMeta {
  const PageMeta({
    required this.path,
    required this.title,
    required this.description,
    required this.language,
    this.indexable = true,
  });

  final String path;
  final String title;
  final String description;
  final SupportedLanguage language;
  final bool indexable;

  /// Canonical URL: language-specific (matches the hreflang alternates in
  /// sitemap.xml); English is the x-default without a query string.
  String get canonicalUrl {
    final base = AppConfig.siteUrl.endsWith('/')
        ? AppConfig.siteUrl.substring(0, AppConfig.siteUrl.length - 1)
        : AppConfig.siteUrl;
    final url = '$base$path';
    return language.code == 'en' ? url : '$url?lang=${language.code}';
  }
}

/// Updates `<title>`, meta description, Open Graph/Twitter tags, canonical
/// link and `<html lang dir>` on the web. No-op on other platforms/tests.
class SeoService {
  const SeoService._();

  static void apply(PageMeta meta) {
    if (!kIsWeb) return;
    try {
      dom.applyMeta(
        title: meta.title,
        description: meta.description,
        canonicalUrl: meta.canonicalUrl,
        langCode: meta.language.code,
        ogLocale: meta.language.ogLocale,
        rtl: meta.language.isRtl,
        indexable: meta.indexable,
      );
    } catch (_) {
      // SEO updates must never break rendering.
    }
  }
}
