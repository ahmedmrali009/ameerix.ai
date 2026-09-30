import 'package:flutter/widgets.dart';

/// Responsive breakpoints (logical pixels).
///
///   mobile  < 600       (tested at 390)
///   tablet  600 – 1023  (tested at 768)
///   laptop  1024 – 1279 (tested at 1024)
///   desktop ≥ 1280      (tested at 1440)
enum ScreenSize { mobile, tablet, laptop, desktop }

class Breakpoints {
  const Breakpoints._();

  static const double tablet = 600;
  static const double laptop = 1024;
  static const double desktop = 1280;

  static ScreenSize of(BuildContext context) => fromWidth(MediaQuery.sizeOf(context).width);

  static ScreenSize fromWidth(double width) {
    if (width >= desktop) return ScreenSize.desktop;
    if (width >= laptop) return ScreenSize.laptop;
    if (width >= tablet) return ScreenSize.tablet;
    return ScreenSize.mobile;
  }

  static bool isMobile(BuildContext context) => of(context) == ScreenSize.mobile;

  static bool isCompact(BuildContext context) {
    final s = of(context);
    return s == ScreenSize.mobile || s == ScreenSize.tablet;
  }

  /// Horizontal page gutter.
  static double gutter(BuildContext context) => switch (of(context)) {
        ScreenSize.mobile => 20,
        ScreenSize.tablet => 32,
        ScreenSize.laptop => 40,
        ScreenSize.desktop => 48,
      };

  /// Vertical padding of a standard section.
  static double sectionSpacing(BuildContext context) => switch (of(context)) {
        ScreenSize.mobile => 72,
        ScreenSize.tablet => 88,
        ScreenSize.laptop => 104,
        ScreenSize.desktop => 120,
      };

  /// Picks a value for the current screen size, falling back to smaller sizes.
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? laptop,
    T? desktop,
  }) {
    switch (of(context)) {
      case ScreenSize.desktop:
        return desktop ?? laptop ?? tablet ?? mobile;
      case ScreenSize.laptop:
        return laptop ?? tablet ?? mobile;
      case ScreenSize.tablet:
        return tablet ?? mobile;
      case ScreenSize.mobile:
        return mobile;
    }
  }
}
