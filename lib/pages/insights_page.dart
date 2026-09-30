import 'package:flutter/material.dart';

import '../config/routes.dart';
import '../l10n/app_localizations.dart';
import '../models/site_content.dart';
import '../sections/shared/page_hero.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/buttons.dart';
import '../widgets/cards.dart';
import '../widgets/page_scaffold.dart';
import '../widgets/pressable.dart';
import '../widgets/responsive_grid.dart';
import '../widgets/reveal.dart';
import '../widgets/section.dart';
import '../widgets/text_blocks.dart';

/// Insights hub. Until real content exists, it shows clearly labelled layout
/// placeholders — never fabricated articles, dates, authors or figures.
///
/// To publish content later, replace [_placeholderItems] with data loaded
/// from a CMS or a JSON file and render real titles/excerpts/links.
class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PageScaffold(
      path: AppRoutes.insights,
      metaTitle: (l) => l.metaTitleInsights,
      metaDescription: (l) => l.metaDescInsights,
      sections: [
        PageHero(eyebrow: l.insightsEyebrow, title: l.insightsTitle, body: l.insightsBody),
        const _InsightsGrid(),
        const _SubscribeBand(),
      ],
    );
  }
}

/// Category index into [SiteContent.insightCategories] for each placeholder.
const List<int> _placeholderItems = [0, 1, 2, 3, 4, 0];

class _InsightsGrid extends StatefulWidget {
  const _InsightsGrid();

  @override
  State<_InsightsGrid> createState() => _InsightsGridState();
}

class _InsightsGridState extends State<_InsightsGrid> {
  int? _category; // null = all

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final categories = SiteContent(l).insightCategories;
    final visible = [
      for (final c in _placeholderItems)
        if (_category == null || _category == c) c,
    ];

    return Section(
      tone: SectionTone.light,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChip(label: l.catAll, selected: _category == null, onTap: () => setState(() => _category = null)),
              for (var i = 0; i < categories.length; i++)
                _FilterChip(label: categories[i], selected: _category == i, onTap: () => setState(() => _category = i)),
            ],
          ),
          const Gap(28),
          NoteBox(l.insightsPlaceholderNotice, icon: Icons.construction_outlined),
          const Gap(28),
          ResponsiveGrid(
            key: ValueKey(_category),
            minItemWidth: 290,
            maxColumns: 3,
            children: [for (final c in visible) _PlaceholderCard(category: categories[c])],
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppTypography.of(context);
    return Semantics(
      selected: selected,
      child: Pressable(
        onTap: onTap,
        semanticLabel: label,
        excludeChildSemantics: true,
        builder: (context, s) => AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? AppColors.black : (s.hovered ? AppColors.mist : AppColors.white),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected || s.focused ? AppColors.black : AppColors.lineLightStrong),
          ),
          child: Text(
            label,
            style: t.label.copyWith(fontSize: 14, color: selected ? AppColors.white : AppColors.black),
          ),
        ),
      ),
    );
  }
}

class _PlaceholderCard extends StatelessWidget {
  const _PlaceholderCard({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);
    return HoverCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Neutral image placeholder (no stock imagery).
          ExcludeSemantics(
            child: Container(
              height: 160,
              decoration: const BoxDecoration(
                color: AppColors.mist,
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: const Center(child: Icon(Icons.article_outlined, size: 32, color: AppColors.grey300)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [Pill(category), Pill(l.placeholderBadge, icon: Icons.edit_note)],
                ),
                const Gap(18),
                Heading(l.placeholderTitle(category), style: t.h3, level: 3, color: AppColors.grey600),
                const Gap(10),
                Text(l.placeholderExcerpt(category), style: t.bodySmall.copyWith(color: AppColors.grey500)),
                const Gap(18),
                Text(l.comingSoon, style: t.label.copyWith(color: AppColors.grey500, fontSize: 13.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscribeBand extends StatelessWidget {
  const _SubscribeBand();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Section(
      tone: SectionTone.dark,
      child: SplitLayout(
        breakpoint: 860,
        gap: 48,
        crossAxisAlignment: CrossAxisAlignment.center,
        start: Reveal(child: SectionHeading(title: l.insightsSubscribeTitle, body: l.insightsSubscribeBody)),
        end: Reveal(
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: AppButton(label: l.ctaGetInTouch, route: AppRoutes.contact, showArrow: true),
          ),
        ),
      ),
    );
  }
}
