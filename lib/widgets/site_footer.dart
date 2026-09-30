import 'package:flutter/material.dart';

import '../config/routes.dart';
import '../core/breakpoints.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'language_selector.dart';
import 'logo.dart';
import 'pressable.dart';
import 'section.dart';

class SiteFooter extends StatelessWidget {
  const SiteFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);
    final size = Breakpoints.of(context);
    final year = DateTime.now().year.toString();

    final brand = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AmeerixLogo(showTagline: true),
        const Gap(20),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Text(l.footerTagline, style: t.bodySmall.copyWith(color: AppColors.grey400)),
        ),
        const Gap(24),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on_outlined, size: 16, color: AppColors.grey500),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '${l.cityBarcelona}, ${l.countrySpain}',
                style: t.caption.copyWith(color: AppColors.grey400),
              ),
            ),
          ],
        ),
      ],
    );

    final platformLinks = _LinkColumn(title: l.footerPlatform, links: [
      (AppRoutes.platform, l.navPlatform),
      (AppRoutes.howItWorks, l.navHowItWorks),
      (AppRoutes.technology, l.navTechnology),
      (AppRoutes.industries, l.navIndustries),
    ]);
    final companyLinks = _LinkColumn(title: l.footerCompany, links: [
      (AppRoutes.about, l.navAbout),
      (AppRoutes.solutions, l.navSolutions),
      (AppRoutes.contact, l.navContact),
    ]);
    final resourceLinks = _LinkColumn(title: l.footerResources, links: [
      (AppRoutes.insights, l.navInsights),
      (AppRoutes.contact, l.ctaRequestDemo),
    ]);
    final language = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ColumnTitle(l.footerLanguage),
        const Gap(16),
        const LanguageInlineList(),
      ],
    );

    Widget top;
    if (size == ScreenSize.mobile) {
      top = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          brand,
          const Gap(40),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Expanded(child: platformLinks), const SizedBox(width: 24), Expanded(child: companyLinks)],
          ),
          const Gap(32),
          resourceLinks,
          const Gap(32),
          language,
        ],
      );
    } else if (size == ScreenSize.tablet) {
      top = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          brand,
          const Gap(48),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: platformLinks),
              const SizedBox(width: 24),
              Expanded(child: companyLinks),
              const SizedBox(width: 24),
              Expanded(child: resourceLinks),
            ],
          ),
          const Gap(40),
          language,
        ],
      );
    } else {
      top = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 4, child: brand),
          const SizedBox(width: 32),
          Expanded(flex: 2, child: platformLinks),
          const SizedBox(width: 24),
          Expanded(flex: 2, child: companyLinks),
          const SizedBox(width: 24),
          Expanded(flex: 2, child: resourceLinks),
          const SizedBox(width: 24),
          Expanded(flex: 3, child: language),
        ],
      );
    }

    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Tone(
        palette: TonePalette.dark,
        child: Container(
          color: AppColors.black,
          child: Column(
            children: [
              const Divider(height: 1, thickness: 1, color: AppColors.lineDark),
              Padding(
                padding: EdgeInsets.only(top: size == ScreenSize.mobile ? 56 : 80, bottom: 32),
                child: ContentWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      top,
                      Gap(size == ScreenSize.mobile ? 48 : 72),
                      const Divider(height: 1, thickness: 1, color: AppColors.lineDark),
                      const Gap(24),
                      Text(l.footerDisclaimer, style: t.caption.copyWith(color: AppColors.grey500)),
                      const Gap(8),
                      Text(l.footerRights(year), style: t.caption.copyWith(color: AppColors.grey500)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColumnTitle extends StatelessWidget {
  const _ColumnTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = AppTypography.of(context);
    return Text(
      t.usesUppercase ? text.toUpperCase() : text,
      style: t.eyebrow.copyWith(color: AppColors.grey500),
    );
  }
}

class _LinkColumn extends StatelessWidget {
  const _LinkColumn({required this.title, required this.links});

  final String title;
  final List<(String, String)> links;

  @override
  Widget build(BuildContext context) {
    final t = AppTypography.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ColumnTitle(title),
        const Gap(16),
        for (final (route, label) in links)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Pressable(
              route: route,
              semanticLabel: label,
              excludeChildSemantics: true,
              builder: (context, s) => Text(
                label,
                style: t.bodySmall.copyWith(
                  color: s.active ? AppColors.white : AppColors.grey400,
                  decoration: s.active ? TextDecoration.underline : TextDecoration.none,
                  decorationColor: AppColors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
