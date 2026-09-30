import 'package:flutter/material.dart';

import '../../config/routes.dart';
import '../../core/breakpoints.dart';
import '../../l10n/app_localizations.dart';
import '../../models/site_content.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/buttons.dart';
import '../../widgets/cards.dart';
import '../../widgets/responsive_grid.dart';
import '../../widgets/reveal.dart';
import '../../widgets/section.dart';
import '../../widgets/text_blocks.dart';
import '../../widgets/visuals/corridor_visual.dart';

// ---------------------------------------------------------------------------
// Platform modules
// ---------------------------------------------------------------------------

class ModulesSection extends StatelessWidget {
  const ModulesSection({super.key, this.tone = SectionTone.muted, this.showLink = true});

  final SectionTone tone;
  final bool showLink;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final content = SiteContent(l);
    return Section(
      tone: tone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Reveal(
            child: SectionHeading(
              eyebrow: l.capabilitiesEyebrow,
              title: l.capabilitiesTitle,
              body: l.capabilitiesBody,
            ),
          ),
          const Gap(56),
          ResponsiveGrid(
            minItemWidth: 250,
            maxColumns: 4,
            children: [
              for (var i = 0; i < content.modules.length; i++) ModuleCard(module: content.modules[i], index: i),
            ],
          ),
          if (showLink) ...[
            const Gap(40),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: AppButton(
                label: l.ctaExplorePlatform,
                route: AppRoutes.platform,
                variant: ButtonVariant.secondary,
                showArrow: true,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ModuleCard extends StatelessWidget {
  const ModuleCard({super.key, required this.module, required this.index});

  final ModuleItem module;
  final int index;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);
    final palette = Tone.of(context);
    return FeatureCard(
      icon: module.icon,
      index: index,
      title: module.name,
      body: module.description,
      compact: true,
      footer: Container(
        padding: const EdgeInsets.only(top: 14),
        decoration: BoxDecoration(border: Border(top: BorderSide(color: palette.border))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.usesUppercase ? l.labelOutput.toUpperCase() : l.labelOutput,
              style: t.eyebrow.copyWith(color: palette.subtle, fontSize: 11),
            ),
            const Gap(6),
            Text(module.output, style: t.bodySmall.copyWith(color: palette.heading, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// How it works
// ---------------------------------------------------------------------------

class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key, this.tone = SectionTone.dark, this.showLink = true, this.showHeading = true});

  final SectionTone tone;
  final bool showLink;
  final bool showHeading;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final steps = SiteContent(l).steps;
    return Section(
      tone: tone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showHeading) ...[
            Reveal(child: SectionHeading(eyebrow: l.howEyebrow, title: l.howTitle, body: l.howBody)),
            const Gap(64),
          ],
          StepsTimeline(steps: steps),
          if (showLink) ...[
            const Gap(48),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: AppButton(
                label: l.ctaSeeHowItWorks,
                route: AppRoutes.howItWorks,
                variant: ButtonVariant.secondary,
                showArrow: true,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Horizontal timeline on wide screens; vertical on narrow ones.
class StepsTimeline extends StatelessWidget {
  const StepsTimeline({super.key, required this.steps, this.forceVertical = false});

  final List<TextItem> steps;
  final bool forceVertical;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final horizontal = !forceVertical && c.maxWidth >= 1000;
        if (horizontal) {
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < steps.length; i++)
                  Expanded(
                    child: Reveal(
                      delay: Duration(milliseconds: 90 * i),
                      child: _HorizontalStep(item: steps[i], index: i, last: i == steps.length - 1),
                    ),
                  ),
              ],
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < steps.length; i++)
              Reveal(child: _VerticalStep(item: steps[i], index: i, last: i == steps.length - 1)),
          ],
        );
      },
    );
  }
}

class _StepNumber extends StatelessWidget {
  const _StepNumber(this.index);
  final int index;

  @override
  Widget build(BuildContext context) {
    final palette = Tone.of(context);
    final t = AppTypography.of(context);
    return ExcludeSemantics(
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: palette.background,
          border: Border.all(color: palette.borderStrong),
        ),
        child: Text(
          '${index + 1}',
          style: t.label.copyWith(color: palette.heading, fontFeatures: const [FontFeature.tabularFigures()]),
        ),
      ),
    );
  }
}

class _HorizontalStep extends StatelessWidget {
  const _HorizontalStep({required this.item, required this.index, required this.last});

  final TextItem item;
  final int index;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final t = AppTypography.of(context);
    final palette = Tone.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StepNumber(index),
              if (!last) ...[
                const SizedBox(width: 12),
                Expanded(child: Container(height: 1, color: palette.border)),
              ],
            ],
          ),
          const Gap(24),
          Heading(item.title, style: t.h3, level: 3),
          const Gap(10),
          Text(item.body, style: t.bodySmall.copyWith(color: palette.body)),
        ],
      ),
    );
  }
}

class _VerticalStep extends StatelessWidget {
  const _VerticalStep({required this.item, required this.index, required this.last});

  final TextItem item;
  final int index;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final t = AppTypography.of(context);
    final palette = Tone.of(context);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              _StepNumber(index),
              if (!last) Expanded(child: Container(width: 1, color: palette.border)),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 8, bottom: last ? 0 : 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Heading(item.title, style: t.h3, level: 3),
                  const Gap(8),
                  Text(item.body, style: t.body.copyWith(color: palette.body)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Industries
// ---------------------------------------------------------------------------

class IndustriesSection extends StatelessWidget {
  const IndustriesSection({super.key, this.tone = SectionTone.light, this.showLink = true});

  final SectionTone tone;
  final bool showLink;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final industries = SiteContent(l).industries;
    return Section(
      tone: tone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Reveal(
            child: SectionHeading(eyebrow: l.industriesEyebrow, title: l.industriesTitle, body: l.industriesBody),
          ),
          const Gap(56),
          ResponsiveGrid(
            minItemWidth: 250,
            maxColumns: 4,
            children: [
              for (final item in industries)
                FeatureCard(
                  icon: item.icon,
                  title: item.name,
                  body: item.description,
                  route: AppRoutes.industries,
                ),
            ],
          ),
          if (showLink) ...[
            const Gap(40),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: AppButton(
                label: l.ctaViewIndustries,
                route: AppRoutes.industries,
                variant: ButtonVariant.secondary,
                showArrow: true,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Full industry card with use cases and benefits (Industries page).
class IndustryDetailCard extends StatelessWidget {
  const IndustryDetailCard({super.key, required this.item, required this.index});

  final IndustryItem item;
  final int index;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);
    final palette = Tone.of(context);

    Widget listBlock(String title, List<String> items, ListMarker marker) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.usesUppercase ? title.toUpperCase() : title,
              style: t.eyebrow.copyWith(color: palette.subtle),
            ),
            const Gap(16),
            MarkerList(items: items, marker: marker, small: true, spacing: 12),
          ],
        );

    return HoverCard(
      hoverable: false,
      padding: EdgeInsets.all(Breakpoints.value<double>(context, mobile: 24, tablet: 32, laptop: 40)),
      child: SplitLayout(
        breakpoint: 760,
        gap: 48,
        stackGap: 32,
        startFlex: 5,
        endFlex: 7,
        start: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconBadge(item.icon, size: 48, filled: true),
                const Spacer(),
                ExcludeSemantics(
                  child: Text(
                    (index + 1).toString().padLeft(2, '0'),
                    style: t.caption.copyWith(color: palette.subtle, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const Gap(24),
            Heading(item.name, style: t.h2.copyWith(fontSize: t.h3.fontSize! + 6), level: 2),
            const Gap(14),
            Text(item.description, style: t.body.copyWith(color: palette.body)),
          ],
        ),
        end: SplitLayout(
          breakpoint: 520,
          gap: 32,
          stackGap: 28,
          start: listBlock(l.labelUseCases, item.useCases, ListMarker.dash),
          end: listBlock(l.labelBenefits, item.benefits, ListMarker.check),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Market figures
// ---------------------------------------------------------------------------

class StatsSection extends StatelessWidget {
  const StatsSection({super.key, this.tone = SectionTone.dark});

  final SectionTone tone;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);
    final stats = SiteContent(l).stats;
    return Section(
      tone: tone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Reveal(child: SectionHeading(eyebrow: l.dataEyebrow, title: l.dataTitle, body: l.dataBody)),
          const Gap(56),
          ResponsiveGrid(
            minItemWidth: 220,
            maxColumns: 3,
            spacing: 32,
            runSpacing: 44,
            children: [for (final s in stats) _StatTile(stat: s, style: t.stat)],
          ),
          const Gap(48),
          Reveal(child: BodyText(l.dataSources, small: true, color: Tone.of(context).subtle)),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.stat, required this.style});

  final StatItem stat;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final t = AppTypography.of(context);
    final palette = Tone.of(context);
    return Container(
      padding: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: palette.borderStrong))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedCounter(
            value: stat.value,
            decimals: stat.decimals,
            format: stat.format,
            style: style.copyWith(color: palette.heading),
          ),
          const Gap(12),
          Text(stat.label, style: t.bodySmall.copyWith(color: palette.body)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Benefits / differentiators
// ---------------------------------------------------------------------------

class BenefitsSection extends StatelessWidget {
  const BenefitsSection({super.key, this.tone = SectionTone.light});

  final SectionTone tone;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final items = SiteContent(l).benefits;
    return Section(
      tone: tone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Reveal(child: SectionHeading(eyebrow: l.benefitsEyebrow, title: l.benefitsTitle)),
          const Gap(56),
          ResponsiveGrid(
            minItemWidth: 280,
            maxColumns: 3,
            children: [for (final b in items) FeatureCard(icon: b.icon, title: b.title, body: b.body)],
          ),
        ],
      ),
    );
  }
}

class DifferentiatorsSection extends StatelessWidget {
  const DifferentiatorsSection({super.key, this.tone = SectionTone.muted});

  final SectionTone tone;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final items = SiteContent(l).differentiators;
    return Section(
      tone: tone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Reveal(child: SectionHeading(eyebrow: l.whyEyebrow, title: l.whyTitle, body: l.whyBody)),
          const Gap(56),
          ResponsiveGrid(
            minItemWidth: 250,
            maxColumns: 4,
            children: [
              for (var i = 0; i < items.length; i++)
                FeatureCard(icon: items[i].icon, title: items[i].title, body: items[i].body, compact: true),
              // Eighth tile completes the 4×2 grid with a call to action.
              const _WhyCtaTile(),
            ],
          ),
        ],
      ),
    );
  }
}

class _WhyCtaTile extends StatelessWidget {
  const _WhyCtaTile();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);
    return Tone(
      palette: TonePalette.dark,
      child: HoverCard(
        route: AppRoutes.technology,
        color: AppColors.black,
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const IconBadge(Icons.north_east, size: 40),
            const Gap(24),
            Text(l.ctaReadTechnology, style: t.h3.copyWith(color: AppColors.white)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// International strategy
// ---------------------------------------------------------------------------

class InternationalSection extends StatelessWidget {
  const InternationalSection({super.key, this.tone = SectionTone.dark, this.showCatalysts = true});

  final SectionTone tone;
  final bool showCatalysts;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);
    final content = SiteContent(l);
    final palette = TonePalette.forTone(tone);

    return Section(
      tone: tone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SplitLayout(
            breakpoint: 960,
            gap: 64,
            crossAxisAlignment: CrossAxisAlignment.center,
            start: Reveal(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeading(eyebrow: l.intlEyebrow, title: l.intlTitle, body: l.intlBody),
                  const Gap(36),
                  for (var i = 0; i < content.intlPhases.length; i++) ...[
                    if (i > 0) const Gap(20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i < 2 ? palette.heading : Colors.transparent,
                            border: Border.all(color: i < 2 ? palette.heading : palette.borderStrong),
                          ),
                          child: ExcludeSemantics(
                            child: Text(
                              '${i + 1}',
                              style: t.caption.copyWith(
                                color: i < 2 ? palette.inverse : palette.body,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Heading(content.intlPhases[i].title, style: t.h4, level: 3),
                              const Gap(4),
                              Text(content.intlPhases[i].body, style: t.bodySmall.copyWith(color: palette.body)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            end: const Reveal(delay: Duration(milliseconds: 150), child: CorridorVisual()),
          ),
          if (showCatalysts) ...[
            const Gap(72),
            Reveal(
              child: Text(
                t.usesUppercase ? l.catalystsTitle.toUpperCase() : l.catalystsTitle,
                style: t.eyebrow.copyWith(color: palette.subtle),
              ),
            ),
            const Gap(20),
            ResponsiveGrid(
              minItemWidth: 230,
              maxColumns: 4,
              spacing: 16,
              children: [
                for (final c in content.catalysts)
                  HoverCard(
                    padding: const EdgeInsets.all(22),
                    child: Text(c, style: t.bodySmall.copyWith(color: palette.heading)),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// GCC buyers (pilot use cases)
// ---------------------------------------------------------------------------

class GccBuyersSection extends StatelessWidget {
  const GccBuyersSection({super.key, this.tone = SectionTone.dark});

  final SectionTone tone;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);
    final segments = SiteContent(l).buyerSegments;
    return Section(
      tone: tone,
      child: SplitLayout(
        breakpoint: 900,
        gap: 64,
        start: Reveal(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeading(eyebrow: l.buyersEyebrow, title: l.buyersTitle, body: l.buyersBody),
              const Gap(28),
              NoteBox(l.buyersNote),
            ],
          ),
        ),
        end: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < segments.length; i++) ...[
              if (i > 0) const Gap(12),
              Reveal(
                delay: Duration(milliseconds: 60 * i),
                child: HoverCard(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Row(
                    children: [
                      IconBadge(segments[i].icon!, size: 40),
                      const SizedBox(width: 16),
                      Expanded(child: Text(segments[i].title, style: t.h4.copyWith(color: Tone.of(context).heading))),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Trade Graph data sources (Platform + Technology)
// ---------------------------------------------------------------------------

class DataSourcesBlock extends StatelessWidget {
  const DataSourcesBlock({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);
    final palette = Tone.of(context);
    final sources = SiteContent(l).dataSources;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < sources.length; i++)
          Reveal(
            delay: Duration(milliseconds: 50 * i),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: palette.border))),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconBadge(sources[i].icon!, size: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Heading(sources[i].title, style: t.h4, level: 4),
                        const Gap(4),
                        Text(sources[i].body, style: t.bodySmall.copyWith(color: palette.body)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        Container(height: 1, color: palette.border),
        const Gap(20),
        NoteBox(l.graphNote, icon: Icons.policy_outlined),
      ],
    );
  }
}
