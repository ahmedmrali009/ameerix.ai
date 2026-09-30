/// Public URL paths of the website.
///
/// Keep in sync with `tool/generate_sitemap.py` and `web/index.html`.
class AppRoutes {
  const AppRoutes._();

  static const String home = '/';
  static const String platform = '/platform';
  static const String solutions = '/solutions';
  static const String industries = '/industries';
  static const String howItWorks = '/how-it-works';
  static const String technology = '/technology';
  static const String about = '/about';
  static const String insights = '/insights';
  static const String contact = '/contact';

  static const List<String> all = <String>[
    home,
    platform,
    solutions,
    industries,
    howItWorks,
    technology,
    about,
    insights,
    contact,
  ];

  /// Normalises a raw route name (which may contain a query string or a
  /// trailing slash) to one of the known paths, or returns it unchanged.
  static String normalise(String? raw) {
    if (raw == null || raw.isEmpty) return home;
    var path = Uri.tryParse(raw)?.path ?? raw;
    if (path.isEmpty) return home;
    if (path.length > 1 && path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }
    return path.toLowerCase();
  }
}
