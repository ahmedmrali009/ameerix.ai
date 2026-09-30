import 'package:flutter/material.dart';

import '../../config/routes.dart';
import '../../core/breakpoints.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/buttons.dart';
import '../../widgets/reveal.dart';
import '../../widgets/section.dart';
import '../../widgets/text_blocks.dart';
import '../../widgets/visuals/dot_grid_background.dart';

/// Closing call-to-action on inner pages: a deep-blue "opportunity" panel
/// (soft blue light, a trace of gold) on a light band.
class CtaSection extends StatelessWidget {
  const CtaSection({super.key, this.title, this.body, this.secondaryRoute, this.secondaryLabel});

  final String? title;
  final String? body;
  final String? secondaryRoute;
  final String? secondaryLabel;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);
    final pad = Breakpoints.value<double>(context, mobile: 32, tablet: 48, laptop: 64, desktop: 72);

    return Section(
      tone: SectionTone.light,
      child: Reveal(
        child: Tone(
          palette: TonePalette.opportunity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                const Positioned.fill(child: ColoredBox(color: Color(0xFF040C22))),
                const Positioned.fill(child: AmbientLighting(palette: TonePalette.opportunity)),
                const Positioned.fill(
                  child: ExcludeSemantics(
                    child: DotGridBackground(focal: Alignment(1, -1), maxOpacity: 0.16),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(pad),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Heading(title ?? l.ctaTitle, style: t.h2, textAlign: TextAlign.center),
                      ),
                      const Gap(20),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 620),
                        child: Text(
                          body ?? l.ctaBody,
                          textAlign: TextAlign.center,
                          style: t.lead.copyWith(color: AppColors.grey400),
                        ),
                      ),
                      const Gap(36),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          AppButton(label: l.ctaRequestDemo, route: AppRoutes.contact, showArrow: true),
                          AppButton(
                            label: secondaryLabel ?? l.ctaExplorePlatform,
                            route: secondaryRoute ?? AppRoutes.platform,
                            variant: ButtonVariant.secondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
