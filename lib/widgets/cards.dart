import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'pressable.dart';
import 'section.dart';
import 'text_blocks.dart';

/// Bordered surface with a subtle lift on hover. When [route] is provided the
/// whole card becomes a link.
class HoverCard extends StatefulWidget {
  const HoverCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(28),
    this.route,
    this.semanticLabel,
    this.hoverable = true,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final String? route;
  final String? semanticLabel;
  final bool hoverable;
  final Color? color;

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _hovered = false;

  Widget _surface(BuildContext context, bool active, bool focused) {
    final palette = Tone.of(context);
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final lift = active && widget.hoverable && !reduce;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      transform: Matrix4.translationValues(0, lift ? -4 : 0, 0),
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.color ?? (active && widget.hoverable ? palette.surfaceHover : palette.surface),
        borderRadius: BorderRadius.circular(16),
        // Border illumination: the edge picks up the environment accent.
        border: Border.all(
          color: focused
              ? palette.accent
              : (active && widget.hoverable
                  ? (palette.isDark ? palette.accent.withValues(alpha: .55) : const Color(0x662563EB))
                  : palette.border),
          width: focused ? 1.5 : 1,
        ),
        boxShadow: !lift
            ? const []
            : palette.isDark
                ? [BoxShadow(color: palette.accent.withValues(alpha: .16), blurRadius: 36, spreadRadius: -10)]
                : const [BoxShadow(color: Color(0x142563EB), blurRadius: 28, offset: Offset(0, 14))],
      ),
      child: widget.child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.route != null) {
      return Pressable(
        route: widget.route,
        semanticLabel: widget.semanticLabel,
        builder: (context, s) => _surface(context, s.hovered, s.focused),
      );
    }
    if (!widget.hoverable) return _surface(context, false, false);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: _surface(context, _hovered, false),
    );
  }
}

/// Square outlined icon container.
class IconBadge extends StatelessWidget {
  const IconBadge(this.icon, {super.key, this.size = 44, this.filled = false});

  final IconData icon;
  final double size;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final palette = Tone.of(context);
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: filled ? palette.heading : (palette.isDark ? AppColors.ink2 : const Color(0xFFEAF1FE)),
          gradient: filled || !palette.isDark
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [palette.accent.withValues(alpha: .16), palette.surfaceHover],
                ),
          borderRadius: BorderRadius.circular(size * 0.27),
          border: Border.all(color: filled ? palette.heading : (palette.isDark ? palette.accent.withValues(alpha: .28) : const Color(0xFFD4E2FB))),
        ),
        child: Icon(icon, size: size * 0.48, color: filled ? palette.inverse : palette.accent),
      ),
    );
  }
}

/// Icon + title + body card used across many sections.
class FeatureCard extends StatelessWidget {
  const FeatureCard({
    super.key,
    required this.title,
    required this.body,
    this.icon,
    this.index,
    this.footer,
    this.route,
    this.compact = false,
  });

  final String title;
  final String body;
  final IconData? icon;

  /// Shows a small "01" style counter instead of / in addition to the icon.
  final int? index;
  final Widget? footer;
  final String? route;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = AppTypography.of(context);
    final palette = Tone.of(context);
    return HoverCard(
      route: route,
      padding: EdgeInsets.all(compact ? 22 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null || index != null)
            Row(
              children: [
                if (icon != null) IconBadge(icon!, size: compact ? 40 : 44),
                const Spacer(),
                if (index != null)
                  ExcludeSemantics(
                    child: Text(
                      (index! + 1).toString().padLeft(2, '0'),
                      style: t.caption.copyWith(
                        color: palette.subtle,
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
              ],
            ),
          if (icon != null || index != null) Gap(compact ? 18 : 24),
          Heading(title, style: t.h3, level: 3),
          if (body.isNotEmpty) ...[
            const Gap(10),
            Text(body, style: t.body.copyWith(color: palette.body)),
          ],
          if (footer != null) ...[const Gap(20), footer!],
        ],
      ),
    );
  }
}
