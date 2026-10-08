/// Build-time configuration.
///
/// Values can be overridden without code changes using `--dart-define`, e.g.
///
/// ```sh
/// flutter build web --release \
///   --dart-define=SITE_URL=https://www.your-domain.com \
///   --dart-define=CONTACT_ENDPOINT=https://api.your-domain.com/v1/leads
/// ```
class AppConfig {
  const AppConfig._();

  /// Public origin used for canonical URLs and Open Graph tags.
  /// Replace with the production domain before launch.
  static const String siteUrl = String.fromEnvironment(
    'SITE_URL',
    defaultValue: 'https://amhilo.com',
  );

  /// HTTPS endpoint that receives contact / demo requests as JSON (POST).
  /// Empty = not configured: the form validates but tells the visitor that
  /// online submissions are not enabled yet. No fake backend is simulated.
  static const String contactEndpoint = String.fromEnvironment('CONTACT_ENDPOINT');

  /// Maximum content width for all sections.
  static const double maxContentWidth = 1200;

  /// Key used to persist the visitor's language choice.
  static const String localeStorageKey = 'amhilo.locale';
}
