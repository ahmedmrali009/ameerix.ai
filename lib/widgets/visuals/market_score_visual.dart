import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../reveal.dart';

/// Illustrative Market Score card (hero + platform page).
///
/// The 82 / 74 figures are the illustrative example used in the business
/// plan to explain score explainability; the card is labelled accordingly.
class MarketScoreVisual extends StatelessWidget {
  const MarketScoreVisual({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);

    return Semantics(
      container: true,
      label: l.a11yHeroVisual,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.lineDark),
          boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 60, offset: Offset(0, 30))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.visualTitle, style: t.h4.copyWith(color: AppColors.white)),
                      const SizedBox(height: 4),
                      Text(l.visualSubtitle, style: t.caption.copyWith(color: AppColors.grey500)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.lineDarkStrong),
                    ),
                    child: Text(
                      l.labelIllustrative,
                      style: t.caption.copyWith(color: AppColors.grey400, fontSize: 11.5),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            _ScoreRow(country: l.countryUae, score: 82, delay: 0),
            const SizedBox(height: 18),
            _ScoreRow(country: l.countryKsa, score: 74, delay: 150),
            const SizedBox(height: 24),
            const Divider(height: 1, thickness: 1, color: AppColors.lineDark),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _FactorList(
                    title: l.visualRaises,
                    icon: Icons.north_east,
                    items: [l.visualDriverDemand, l.visualDriverNetwork],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _FactorList(
                    title: l.visualLowers,
                    icon: Icons.south_east,
                    items: [l.visualDriverAccess],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(l.visualFooter, style: t.caption.copyWith(color: AppColors.grey500)),
          ],
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({required this.country, required this.score, required this.delay});

  final String country;
  final int score;
  final int delay;

  @override
  Widget build(BuildContext context) {
    final t = AppTypography.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: Text(country, style: t.label.copyWith(color: AppColors.grey300))),
            const SizedBox(width: 12),
            Text.rich(
              TextSpan(children: [
                TextSpan(
                  text: '$score',
                  style: t.h3.copyWith(color: AppColors.white, fontFeatures: const [FontFeature.tabularFigures()]),
                ),
                TextSpan(text: ' /100', style: t.caption.copyWith(color: AppColors.grey500)),
              ]),
              textDirection: TextDirection.ltr,
            ),
          ],
        ),
        const SizedBox(height: 10),
        OnVisible(
          builder: (context, visible) => TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: visible ? score / 100 : 0),
            duration: Duration(milliseconds: visible ? 1200 + delay : 0),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: SizedBox(
                height: 6,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const ColoredBox(color: AppColors.lineDark),
                    FractionallySizedBox(
                      alignment: AlignmentDirectional.centerStart,
                      widthFactor: v.clamp(0.0, 1.0),
                      heightFactor: 1,
                      child: const ColoredBox(color: AppColors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FactorList extends StatelessWidget {
  const _FactorList({required this.title, required this.icon, required this.items});

  final String title;
  final IconData icon;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final t = AppTypography.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: t.caption.copyWith(color: AppColors.grey500, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(icon, size: 14, color: AppColors.grey300),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(item, style: t.caption.copyWith(color: AppColors.grey300))),
              ],
            ),
          ),
      ],
    );
  }
}
