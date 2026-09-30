import 'package:flutter/material.dart';

import '../config/routes.dart';
import '../l10n/app_localizations.dart';
import '../models/site_content.dart';
import '../sections/shared/content_sections.dart';
import '../sections/shared/cta_section.dart';
import '../sections/shared/page_hero.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/buttons.dart';
import '../widgets/cards.dart';
import '../widgets/page_scaffold.dart';
import '../widgets/responsive_grid.dart';
import '../widgets/reveal.dart';
import '../widgets/section.dart';
import '../widgets/text_blocks.dart';
import '../widgets/visuals/market_score_visual.dart';

class PlatformPage extends StatelessWidget {
  const PlatformPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PageScaffold(
      path: AppRoutes.platform,
      metaTitle: (l) => l.metaTitlePlatform,
      metaDescription: (l) => l.metaDescPlatform,
      sections: [
        PageHero(
          eyebrow: l.platformEyebrow,
          title: l.platformTitle,
          body: l.platformBody,
          actions: [
            AppButton(label: l.ctaRequestDemo, route: AppRoutes.contact, showArrow: true),
            AppButton(label: l.ctaSeeHowItWorks, route: AppRoutes.howItWorks, variant: ButtonVariant.secondary),
          ],
          footer: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: NoteBox(l.platformStatusNote),
          ),
        ),
        const ModulesSection(tone: SectionTone.light, showLink: false),
        const _ReadinessSection(),
        const _MarketScoreSection(),
        const _MatchGraphSection(),
        const _LocaliseCrmSection(),
        const _IntelligenceSection(),
        const _EngagementSection(),
        CtaSection(secondaryLabel: l.ctaSeeHowItWorks, secondaryRoute: AppRoutes.howItWorks),
      ],
    );
  }
}

/// Numbered module title block.
class _ModuleHeader extends StatelessWidget {
  const _ModuleHeader({required this.module, required this.index, this.extra});

  final ModuleItem module;
  final int index;
  final String? extra;

  @override
  Widget build(BuildContext context) {
    final t = AppTypography.of(context);
    final palette = Tone.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconBadge(module.icon, size: 48, filled: true),
            const SizedBox(width: 16),
            ExcludeSemantics(
              child: Text(
                (index + 1).toString().padLeft(2, '0'),
                style: t.label.copyWith(color: palette.subtle),
              ),
            ),
          ],
        ),
        const Gap(24),
        Heading(module.name, style: t.h2, level: 2),
        const Gap(16),
        Text(module.description, style: t.lead.copyWith(color: palette.body)),
        if (extra != null) ...[
          const Gap(16),
          Text(extra!, style: t.body.copyWith(color: palette.body)),
        ],
      ],
    );
  }
}

class _SubTitle extends StatelessWidget {
  const _SubTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = AppTypography.of(context);
    return Text(
      t.usesUppercase ? text.toUpperCase() : text,
      style: t.eyebrow.copyWith(color: Tone.of(context).subtle),
    );
  }
}

class _ReadinessSection extends StatelessWidget {
  const _ReadinessSection();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final content = SiteContent(l);
    return Section(
      tone: SectionTone.muted,
      child: SplitLayout(
        breakpoint: 980,
        gap: 64,
        startFlex: 4,
        endFlex: 6,
        start: Reveal(child: _ModuleHeader(module: content.modules[0], index: 0, extra: l.readinessOutputBody)),
        end: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Reveal(child: _SubTitle(l.readinessDimsTitle)),
            const Gap(20),
            ResponsiveGrid(
              minItemWidth: 220,
              maxColumns: 2,
              spacing: 16,
              children: [
                for (final d in content.readinessDimensions)
                  FeatureCard(icon: d.icon, title: d.title, body: d.body, compact: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MarketScoreSection extends StatelessWidget {
  const _MarketScoreSection();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);
    final content = SiteContent(l);
    return Section(
      tone: SectionTone.dark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SplitLayout(
            breakpoint: 980,
            gap: 64,
            crossAxisAlignment: CrossAxisAlignment.center,
            start: Reveal(child: _ModuleHeader(module: content.modules[1], index: 1, extra: l.scoreExplainBody)),
            end: const Reveal(delay: Duration(milliseconds: 120), child: Center(child: MarketScoreVisual())),
          ),
          const Gap(64),
          Reveal(child: _SubTitle(l.scoreVarsTitle)),
          const Gap(20),
          ResponsiveGrid(
            minItemWidth: 300,
            maxColumns: 3,
            spacing: 16,
            children: [
              for (final v in content.scoreVariables)
                HoverCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Heading(v.title, style: t.h3, level: 3),
                      const Gap(8),
                      Text(v.examples, style: t.bodySmall.copyWith(color: AppColors.grey400)),
                      const Gap(18),
                      Pill(v.use, icon: Icons.adjust),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MatchGraphSection extends StatelessWidget {
  const _MatchGraphSection();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final content = SiteContent(l);
    return Section(
      tone: SectionTone.light,
      child: SplitLayout(
        breakpoint: 980,
        gap: 72,
        start: Reveal(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ModuleHeader(module: content.modules[2], index: 2),
              const Gap(32),
              _SubTitle(l.matchCriteriaTitle),
              const Gap(16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [for (final c in content.matchCriteria) Pill(c)],
              ),
              const Gap(28),
              NoteBox(l.matchNote, icon: Icons.filter_alt_outlined),
            ],
          ),
        ),
        end: Reveal(
          delay: const Duration(milliseconds: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ModuleHeader(module: content.modules[3], index: 3),
              const Gap(32),
              _SubTitle(l.graphSourcesTitle),
              const Gap(8),
              const DataSourcesBlock(),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocaliseCrmSection extends StatelessWidget {
  const _LocaliseCrmSection();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final content = SiteContent(l);
    return Section(
      tone: SectionTone.muted,
      child: SplitLayout(
        breakpoint: 980,
        gap: 72,
        startFlex: 4,
        endFlex: 6,
        start: Reveal(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ModuleHeader(module: content.modules[4], index: 4),
              const Gap(24),
              NoteBox(l.localiseNote, icon: Icons.person_search_outlined),
            ],
          ),
        ),
        end: Reveal(
          delay: const Duration(milliseconds: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ModuleHeader(module: content.modules[5], index: 5),
              const Gap(32),
              _SubTitle(l.crmStagesTitle),
              const Gap(16),
              _PipelineStages(stages: content.pipelineStages),
            ],
          ),
        ),
      ),
    );
  }
}

class _PipelineStages extends StatelessWidget {
  const _PipelineStages({required this.stages});
  final List<String> stages;

  @override
  Widget build(BuildContext context) {
    final t = AppTypography.of(context);
    final palette = Tone.of(context);
    return Wrap(
      spacing: 6,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var i = 0; i < stages.length; i++) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: i == stages.length - 1 ? AppColors.black : AppColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: i == stages.length - 1 ? AppColors.black : palette.border),
            ),
            child: Text(
              stages[i],
              style: t.caption.copyWith(
                fontWeight: FontWeight.w500,
                color: i == stages.length - 1 ? AppColors.white : palette.heading,
              ),
            ),
          ),
          if (i < stages.length - 1)
            ExcludeSemantics(child: Icon(Icons.arrow_forward, size: 14, color: palette.subtle)),
        ],
      ],
    );
  }
}

class _IntelligenceSection extends StatelessWidget {
  const _IntelligenceSection();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);
    final content = SiteContent(l);
    return Section(
      tone: SectionTone.dark,
      child: SplitLayout(
        breakpoint: 980,
        gap: 72,
        crossAxisAlignment: CrossAxisAlignment.center,
        start: Reveal(child: _ModuleHeader(module: content.modules[6], index: 6, extra: l.intelNote)),
        end: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Reveal(child: _SubTitle(l.intelExamplesTitle)),
            const Gap(16),
            for (var i = 0; i < content.intelExamples.length; i++) ...[
              if (i > 0) const Gap(12),
              Reveal(
                delay: Duration(milliseconds: 80 * i),
                child: HoverCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const IconBadge(Icons.notifications_none, size: 36),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            content.intelExamples[i],
                            style: t.body.copyWith(color: AppColors.white),
                          ),
                        ),
                      ),
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

class _EngagementSection extends StatelessWidget {
  const _EngagementSection();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final options = SiteContent(l).engagementOptions;
    return Section(
      tone: SectionTone.light,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Reveal(child: SectionHeading(eyebrow: l.engageEyebrow, title: l.engageTitle)),
          const Gap(48),
          ResponsiveGrid(
            minItemWidth: 200,
            maxColumns: 5,
            spacing: 16,
            children: [
              for (final o in options) FeatureCard(icon: o.icon, title: o.title, body: o.body, compact: true),
            ],
          ),
          const Gap(28),
          Reveal(child: NoteBox(l.engageNote)),
        ],
      ),
    );
  }
}
