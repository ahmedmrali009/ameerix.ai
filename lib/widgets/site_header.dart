import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../config/routes.dart';
import '../core/breakpoints.dart';
import '../core/navigation.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'buttons.dart';
import 'language_selector.dart';
import 'logo.dart';
import 'pressable.dart';

class NavEntry {
  const NavEntry(this.route, this.label);
  final String route;
  final String label;
}

List<NavEntry> primaryNav(AppLocalizations l) => [
      NavEntry(AppRoutes.platform, l.navPlatform),
      NavEntry(AppRoutes.solutions, l.navSolutions),
      NavEntry(AppRoutes.industries, l.navIndustries),
      NavEntry(AppRoutes.howItWorks, l.navHowItWorks),
      NavEntry(AppRoutes.technology, l.navTechnology),
      NavEntry(AppRoutes.about, l.navAbout),
      NavEntry(AppRoutes.insights, l.navInsights),
    ];

/// Sticky, translucent header. Shows full navigation when it fits (measured
/// per language), otherwise a menu button that opens a full-screen menu.
class SiteHeader extends StatelessWidget {
  const SiteHeader({super.key, required this.scrolled});

  final bool scrolled;

  static double heightOf(BuildContext context) => Breakpoints.isMobile(context) ? 64 : 76;

  static const double _navItemPadding = 13;
  static const double _navFontSize = 14.5;

  /// Decides, per language and width, how much of the header fits.
  /// Measuring real label widths keeps long translations (e.g. German,
  /// French, Portuguese) from overflowing.
  _HeaderLayout _layoutFor(BuildContext context, double available, List<NavEntry> items, String ctaLabel) {
    final t = AppTypography.of(context);
    final style = t.label.copyWith(fontSize: _navFontSize);
    final direction = Directionality.of(context);
    final scaler = MediaQuery.textScalerOf(context);
    double measure(String text, TextStyle s) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: s),
        textDirection: direction,
        maxLines: 1,
        textScaler: scaler,
      )..layout();
      final w = painter.width;
      painter.dispose();
      return w;
    }

    // Item = text + horizontal padding + outer spacing + border.
    var navWidth = 0.0;
    for (final item in items) {
      navWidth += measure(item.label, style) + _navItemPadding * 2 + 4 + 2;
    }
    // CTA = text + padding + border + focus ring.
    final ctaWidth = measure(ctaLabel, t.button) + 18 * 2 + 2 + 8;
    const logoWidth = 175.0;
    const languageWidth = 125.0;
    const menuWidth = 44.0;

    if (logoWidth + 24 + navWidth + 16 + languageWidth + 16 + ctaWidth <= available) {
      return _HeaderLayout.full;
    }
    if (logoWidth + 24 + languageWidth + 12 + ctaWidth + 8 + menuWidth <= available) {
      return _HeaderLayout.compactWithCta;
    }
    return _HeaderLayout.compact;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final items = primaryNav(l);
    final current = AppNavigator.currentPath(context);
    final height = heightOf(context);
    final gutter = Breakpoints.gutter(context);

    return Tone(
      palette: TonePalette.dark,
      child: ClipRect(
      child: BackdropFilter(
        enabled: scrolled,
        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: height,
          decoration: BoxDecoration(
            // Transparent over the hero; dark translucent navy glass with a
            // faint blue edge light once the page scrolls.
            color: const Color(0xFF071426).withValues(alpha: scrolled ? 0.72 : 0.0),
            border: Border(
              bottom: BorderSide(color: scrolled ? const Color(0x404F8CFF) : const Color(0x00000000)),
            ),
            boxShadow: scrolled ? const [BoxShadow(color: Color(0x33030712), blurRadius: 24, offset: Offset(0, 8))] : const [],
          ),
          padding: EdgeInsets.symmetric(horizontal: gutter),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppConfig.maxContentWidth + 80),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final layout = _layoutFor(context, constraints.maxWidth, items, l.ctaRequestDemo);
                  final full = layout == _HeaderLayout.full;
                  return Row(
                    children: [
                      const AmeerixLogo(),
                      const SizedBox(width: 24),
                      if (full)
                        Expanded(
                          child: Semantics(
                            container: true,
                            explicitChildNodes: true,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (final item in items)
                                  _NavLink(entry: item, active: current == item.route),
                              ],
                            ),
                          ),
                        )
                      else
                        const Spacer(),
                      if (full) ...[
                        const LanguageDropdown(),
                        const SizedBox(width: 16),
                        AppButton(label: l.ctaRequestDemo, route: AppRoutes.contact, compact: true),
                      ] else ...[
                        if (layout == _HeaderLayout.compactWithCta) ...[
                          const LanguageDropdown(),
                          const SizedBox(width: 12),
                          AppButton(label: l.ctaRequestDemo, route: AppRoutes.contact, compact: true),
                          const SizedBox(width: 8),
                        ],
                        _MenuButton(label: l.a11yOpenMenu, onTap: () => showMobileMenu(context)),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}

enum _HeaderLayout { full, compactWithCta, compact }

class _NavLink extends StatelessWidget {
  const _NavLink({required this.entry, required this.active});

  final NavEntry entry;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final t = AppTypography.of(context);
    return Pressable(
      route: entry.route,
      semanticLabel: entry.label,
      excludeChildSemantics: true,
      builder: (context, s) {
        final highlighted = active || s.active;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: SiteHeader._navItemPadding, vertical: 8),
            decoration: BoxDecoration(
              color: s.hovered ? const Color(0x174F8CFF) : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: s.focused ? AppColors.electric : Colors.transparent),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Text(
                  entry.label,
                  maxLines: 1,
                  softWrap: false,
                  style: t.label.copyWith(
                    fontSize: SiteHeader._navFontSize,
                    color: highlighted ? AppColors.white : AppColors.grey400,
                  ),
                ),
                // Active page: a short illuminated line under the label.
                Positioned(
                  bottom: -7,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: active ? 16 : 0,
                    height: 1.5,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [AppColors.electric, AppColors.violet]),
                      boxShadow: [BoxShadow(color: Color(0x994F8CFF), blurRadius: 6)],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      excludeChildSemantics: true,
      builder: (context, s) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: s.active ? const Color(0x174F8CFF) : Colors.transparent,
          border: Border.all(color: s.focused || s.hovered ? AppColors.electric : AppColors.lineDarkStrong),
        ),
        child: const Icon(Icons.menu, color: Colors.white, size: 20),
      ),
    );
  }
}

/// Full-screen navigation for tablet / mobile.
Future<void> showMobileMenu(BuildContext context) {
  final l = AppLocalizations.of(context);
  final current = AppNavigator.currentPath(context);
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: l.a11yCloseMenu,
    barrierColor: const Color(0x99000000),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (dialogContext, _, _) => _MobileMenu(currentRoute: current),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, -0.02), end: Offset.zero).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _MobileMenu extends StatelessWidget {
  const _MobileMenu({required this.currentRoute});

  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);
    final gutter = Breakpoints.gutter(context);
    final items = [NavEntry(AppRoutes.home, l.navHome), ...primaryNav(l), NavEntry(AppRoutes.contact, l.navContact)];

    void goTo(String route) {
      final navigator = Navigator.of(context);
      navigator.pop();
      if (AppRoutes.normalise(route) != currentRoute) navigator.pushNamed(route);
    }

    return Tone(
      palette: TonePalette.dark,
      child: Material(
      color: AppColors.black,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: SiteHeader.heightOf(context),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: gutter),
                child: Row(
                  children: [
                    const AmeerixLogo(linked: false),
                    const Spacer(),
                    Pressable(
                      onTap: () => Navigator.of(context).pop(),
                      semanticLabel: l.a11yCloseMenu,
                      excludeChildSemantics: true,
                      builder: (context, s) => Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: s.active ? AppColors.ink2 : Colors.transparent,
                          border: Border.all(color: s.focused ? AppColors.grey400 : AppColors.lineDarkStrong),
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, thickness: 1, color: AppColors.lineDark),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(gutter, 16, gutter, 32),
                children: [
                  for (final item in items)
                    Pressable(
                      onTap: () => goTo(item.route),
                      semanticLabel: item.label,
                      excludeChildSemantics: true,
                      builder: (context, s) {
                        final active = item.route == currentRoute;
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: const BorderSide(color: AppColors.lineDark),
                              top: s.focused ? const BorderSide(color: AppColors.grey400) : BorderSide.none,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: t.h3.copyWith(
                                    fontSize: 22,
                                    color: active || s.active ? Colors.white : AppColors.grey300,
                                  ),
                                ),
                              ),
                              Icon(Icons.arrow_forward, size: 18, color: active ? Colors.white : AppColors.grey500),
                            ],
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 32),
                  Text(
                    l.footerLanguage,
                    style: t.eyebrow.copyWith(color: AppColors.grey500),
                  ),
                  const SizedBox(height: 14),
                  LanguageInlineList(large: true, onChanged: () {}),
                  const SizedBox(height: 32),
                  AppButton(
                    label: l.ctaRequestDemo,
                    onPressed: () => goTo(AppRoutes.contact),
                    expand: true,
                    showArrow: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
