import 'package:flutter/material.dart';

import '../config/routes.dart';
import '../l10n/app_localizations.dart';
import '../sections/cinematic/distributor_scene.dart';
import '../sections/cinematic/finale_scene.dart';
import '../sections/cinematic/hero_scene.dart';
import '../sections/cinematic/market_score_scene.dart';
import '../sections/cinematic/platform_demo_scene.dart';
import '../sections/cinematic/statement_scene.dart';
import '../sections/cinematic/story_scene.dart';
import '../sections/cinematic/trade_graph_scene.dart';
import '../sections/home/home_sections.dart';
import '../sections/home/trust_section.dart';
import '../sections/shared/content_sections.dart';
import '../theme/app_colors.dart';
import '../widgets/page_scaffold.dart';

/// Cinematic homepage. Full-viewport, scroll-driven scenes alternate with
/// calmer information sections, and dark environments (deep space, midnight,
/// violet haze, opportunity blue) alternate with light credibility bands:
///
/// Hero → What we do (light) → Spain→GCC story → Problem (midnight) →
/// statement → Market Score → Platform modules (muted) → statement
/// (midnight) → Match network → Industries (light) → Trade Graph (haze) →
/// How it works (muted) → Product demo (midnight) → Market data → Technology
/// (light) → Spain + GCC strategy (midnight) → Trust & methodology (muted) →
/// cinematic final call to action (opportunity)
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      path: AppRoutes.home,
      metaTitle: (l) => l.metaTitleHome,
      metaDescription: (l) => l.metaDescHome,
      sections: const [
        HeroScene(),
        WhatWeDoSection(),
        SpainGccStory(),
        ProblemSection(),
        _KnowStatement(),
        MarketScoreVisualization(),
        ModulesSection(tone: SectionTone.muted),
        _PartnerStatement(),
        DistributorNetwork(),
        IndustriesSection(tone: SectionTone.light),
        TradeGraphVisualization(),
        HowItWorksSection(tone: SectionTone.muted),
        PlatformDemo(),
        StatsSection(tone: SectionTone.dark),
        TechTeaserSection(),
        InternationalSection(tone: SectionTone.midnight),
        TrustSection(tone: SectionTone.muted),
        FinaleCta(),
      ],
    );
  }
}

class _KnowStatement extends StatelessWidget {
  const _KnowStatement();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return RevealText(lines: [l.stmtKnow1, l.stmtKnow2, l.stmtKnow3], emphasis: const {0}, grid: true);
  }
}

class _PartnerStatement extends StatelessWidget {
  const _PartnerStatement();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return RevealText(
      lines: [l.stmtHalf, l.stmtPartner],
      mode: StatementMode.handOff,
      medium: true,
      emphasis: const {1},
      tone: SectionTone.midnight,
    );
  }
}
