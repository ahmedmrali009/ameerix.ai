import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Layered architecture diagram built from widgets (text stays selectable,
/// translatable and accessible).
class ArchitectureDiagram extends StatelessWidget {
  const ArchitectureDiagram({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Semantics(
      container: true,
      label: l.a11yArchitectureVisual,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.mist,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.lineLight),
        ),
        child: LayoutBuilder(
          builder: (context, c) {
            final narrow = c.maxWidth < 520;
            final middle = [
              _Box(label: l.archLayer3, icon: Icons.rule_outlined),
              _Box(label: l.archLayer4, icon: Icons.search),
              _Box(label: l.archLayer6, icon: Icons.auto_awesome_outlined),
            ];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Box(label: l.archLayer1, icon: Icons.web_outlined, strong: true),
                const _Connector(),
                _Box(label: l.archLayer2, icon: Icons.api_outlined, strong: true),
                const _Connector(),
                if (narrow)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      middle[0],
                      const SizedBox(height: 10),
                      middle[1],
                      const SizedBox(height: 10),
                      middle[2],
                    ],
                  )
                else
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: middle[0]),
                        const SizedBox(width: 10),
                        Expanded(child: middle[1]),
                        const SizedBox(width: 10),
                        Expanded(child: middle[2]),
                      ],
                    ),
                  ),
                const _Connector(),
                _Box(label: l.archLayer5, icon: Icons.hub_outlined, strong: true, inverted: true),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.label, required this.icon, this.strong = false, this.inverted = false});

  final String label;
  final IconData icon;
  final bool strong;
  final bool inverted;

  @override
  Widget build(BuildContext context) {
    final t = AppTypography.of(context);
    final fg = inverted ? AppColors.white : AppColors.black;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: inverted ? AppColors.black : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: inverted ? AppColors.black : (strong ? AppColors.lineLightStrong : AppColors.lineLight)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: t.label.copyWith(color: fg, fontSize: 14))),
        ],
      ),
    );
  }
}

class _Connector extends StatelessWidget {
  const _Connector();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 26,
      child: Center(child: Icon(Icons.south, size: 16, color: AppColors.grey500)),
    );
  }
}
