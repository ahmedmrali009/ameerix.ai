import 'package:flutter/widgets.dart';

import '../config/routes.dart';

/// Global route observer, used by pages to refresh SEO metadata when they
/// become visible again after a pop (browser "back").
final RouteObserver<ModalRoute<void>> appRouteObserver = RouteObserver<ModalRoute<void>>();

class AppNavigator {
  const AppNavigator._();

  static String currentPath(BuildContext context) =>
      AppRoutes.normalise(ModalRoute.of(context)?.settings.name);

  /// Navigates to [route] unless it is already the current page.
  static void go(BuildContext context, String route) {
    final target = AppRoutes.normalise(route);
    if (currentPath(context) == target) {
      PrimaryScrollHelper.scrollToTop(context);
      return;
    }
    Navigator.of(context).pushNamed(target);
  }
}

/// Lets widgets ask the current page to scroll back to the top.
class PrimaryScrollHelper extends InheritedWidget {
  const PrimaryScrollHelper({super.key, required this.controller, required super.child});

  final ScrollController controller;

  /// The page's scroll controller, used by scroll-driven motion sections.
  static ScrollController? maybeControllerOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<PrimaryScrollHelper>()?.controller;

  static void scrollToTop(BuildContext context) {
    final helper = context.getInheritedWidgetOfExactType<PrimaryScrollHelper>();
    final controller = helper?.controller;
    if (controller == null || !controller.hasClients) return;
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce) {
      controller.jumpTo(0);
    } else {
      controller.animateTo(0, duration: const Duration(milliseconds: 600), curve: Curves.easeOutCubic);
    }
  }

  @override
  bool updateShouldNotify(PrimaryScrollHelper oldWidget) => oldWidget.controller != controller;
}
