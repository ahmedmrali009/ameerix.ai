import 'package:web/web.dart' as web;

/// Browser implementation: writes metadata into the live document so that
/// crawlers that execute JavaScript, link previews and assistive technology
/// see page-specific information.
void applyMeta({
  required String title,
  required String description,
  required String canonicalUrl,
  required String langCode,
  required String ogLocale,
  required bool rtl,
  required bool indexable,
}) {
  final document = web.document;
  document.title = title;

  final root = document.documentElement;
  root?.setAttribute('lang', langCode);
  root?.setAttribute('dir', rtl ? 'rtl' : 'ltr');

  _meta('name', 'description', description);
  _meta('name', 'robots', indexable ? 'index, follow' : 'noindex, follow');
  _meta('property', 'og:title', title);
  _meta('property', 'og:description', description);
  _meta('property', 'og:url', canonicalUrl);
  _meta('property', 'og:locale', ogLocale);
  _meta('name', 'twitter:title', title);
  _meta('name', 'twitter:description', description);
  _canonical(canonicalUrl);
}

void _meta(String attribute, String key, String content) {
  var element = web.document.querySelector('meta[$attribute="$key"]');
  if (element == null) {
    element = web.document.createElement('meta');
    element.setAttribute(attribute, key);
    web.document.head?.appendChild(element);
  }
  element.setAttribute('content', content);
}

void _canonical(String href) {
  var element = web.document.querySelector('link[rel="canonical"]');
  if (element == null) {
    element = web.document.createElement('link');
    element.setAttribute('rel', 'canonical');
    web.document.head?.appendChild(element);
  }
  element.setAttribute('href', href);
}
