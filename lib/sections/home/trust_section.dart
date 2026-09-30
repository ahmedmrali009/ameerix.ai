import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/cards.dart';
import '../../widgets/responsive_grid.dart';
import '../../widgets/reveal.dart';
import '../../widgets/section.dart';
import '../../widgets/text_blocks.dart';

/// Trust & methodology: how scores are built, human review, ethics and the
/// "not legal/financial advice" note. Content comes from the business plan.
class TrustSection extends StatelessWidget {
  const TrustSection({super.key, this.tone = SectionTone.light});

  final SectionTone tone;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);
    return Section(
      tone: tone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Reveal(child: SectionHeading(eyebrow: l.trustEyebrow, title: l.trustTitle)),
          const Gap(56),
          ResponsiveGrid(
            minItemWidth: 260,
            maxColumns: 4,
            children: [
              FeatureCard(icon: Icons.rule_outlined, title: l.scoringTitle, body: l.scoringBody, compact: true),
              FeatureCard(icon: Icons.person_search_outlined, title: l.benefit5Title, body: l.benefit5Body, compact: true),
              FeatureCard(icon: Icons.verified_outlined, title: l.diff7Title, body: l.diff7Body, compact: true),
              FeatureCard(icon: Icons.policy_outlined, title: l.ethicsTitle, body: l.ethicsBody, compact: true),
            ],
          ),
          const Gap(32),
          Reveal(
            child: Text(l.adviceNote, style: t.caption.copyWith(color: Tone.of(context).subtle)),
          ),
        ],
      ),
    );
  }
}
