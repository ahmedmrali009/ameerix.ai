import 'package:flutter/material.dart';

import '../config/routes.dart';
import '../pages/about_page.dart';
import '../pages/contact_page.dart';
import '../pages/home_page.dart';
import '../pages/how_it_works_page.dart';
import '../pages/industries_page.dart';
import '../pages/insights_page.dart';
import '../pages/not_found_page.dart';
import '../pages/platform_page.dart';
import '../pages/solutions_page.dart';
import '../pages/technology_page.dart';

/// Path-based routing (e.g. /platform) using the built-in Navigator.
/// Each page is created lazily when first visited.
class AppRouter {
  const AppRouter._();

  static Widget pageFor(String path) => switch (path) {
        AppRoutes.home => const HomePage(),
        AppRoutes.platform => const PlatformPage(),
        AppRoutes.solutions => const SolutionsPage(),
        AppRoutes.industries => const IndustriesPage(),
        AppRoutes.howItWorks => const HowItWorksPage(),
        AppRoutes.technology => const TechnologyPage(),
        AppRoutes.about => const AboutPage(),
        AppRoutes.insights => const InsightsPage(),
        AppRoutes.contact => const ContactPage(),
        _ => NotFoundPage(path: path),
      };

  static Route<void> onGenerateRoute(RouteSettings settings) {
    final path = AppRoutes.normalise(settings.name);
    return FadePageRoute(
      settings: RouteSettings(name: path, arguments: settings.arguments),
      child: pageFor(path),
    );
  }

  /// Deep links open directly on the requested page (no hidden home page
  /// underneath), which keeps first load light.
  static List<Route<dynamic>> onGenerateInitialRoutes(String initialRoute) =>
      [onGenerateRoute(RouteSettings(name: initialRoute))];
}

/// Subtle fade + rise page transition. Disabled when the OS requests
/// reduced motion.
class FadePageRoute extends PageRouteBuilder<void> {
  FadePageRoute({required Widget child, super.settings})
      : super(
          transitionDuration: const Duration(milliseconds: 380),
          reverseTransitionDuration: const Duration(milliseconds: 240),
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, page) {
            if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return page;
            final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.015), end: Offset.zero).animate(curved),
                child: page,
              ),
            );
          },
        );
}
