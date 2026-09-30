import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'pressable.dart';

enum ButtonVariant { primary, secondary, text }

/// Site button. Colours adapt to the surrounding [Tone]:
/// primary is a soft-white pill with a faint blue glow on dark sections and
/// an intelligence-blue pill on light ones; secondary buttons light their
/// border on hover (border illumination rather than colour fills).
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.route,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.showArrow = false,
    this.icon,
    this.compact = false,
    this.expand = false,
    this.loading = false,
  });

  final String label;
  final String? route;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool showArrow;
  final IconData? icon;
  final bool compact;
  final bool expand;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final palette = Tone.of(context);
    final t = AppTypography.of(context);
    final disabled = route == null && onPressed == null;

    Widget content(PressableState s) {
      late Color bg;
      late Color fg;
      late Color border;
      switch (variant) {
        case ButtonVariant.primary:
          if (palette.isDark) {
            bg = s.hovered ? AppColors.pureWhite : AppColors.white;
            fg = AppColors.navyInk;
            border = bg;
          } else {
            bg = s.hovered ? AppColors.blueDeep : AppColors.navyInk;
            fg = AppColors.pureWhite;
            border = bg;
          }
        case ButtonVariant.secondary:
          bg = s.hovered ? (palette.isDark ? const Color(0x1A4F8CFF) : const Color(0x0F2563EB)) : Colors.transparent;
          fg = palette.heading;
          border = s.hovered ? (palette.isDark ? AppColors.electric : AppColors.blueDeep) : palette.borderStrong;
        case ButtonVariant.text:
          bg = Colors.transparent;
          fg = palette.heading;
          border = Colors.transparent;
      }
      if (disabled) {
        bg = bg.withValues(alpha: 0.5);
        fg = fg.withValues(alpha: 0.6);
      }

      final isText = variant == ButtonVariant.text;
      final padding = isText
          ? const EdgeInsets.symmetric(vertical: 6)
          : EdgeInsets.symmetric(horizontal: compact ? 18 : 24, vertical: compact ? 11 : 15);

      final labelText = Text(
        label,
        textAlign: TextAlign.center,
        style: t.button.copyWith(
          color: fg,
          decoration: isText && s.hovered ? TextDecoration.underline : TextDecoration.none,
          decorationColor: fg,
        ),
      );

      final row = Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (loading) ...[
            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: fg)),
            const SizedBox(width: 10),
          ] else if (icon != null) ...[
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 10),
          ],
          Flexible(child: labelText),
          if (showArrow) ...[
            const SizedBox(width: 10),
            AnimatedSlide(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              // Positive dx moves toward the reading direction after mirroring.
              offset: Offset(s.hovered ? (Directionality.of(context) == TextDirection.rtl ? -0.25 : 0.25) : 0, 0),
              child: Icon(Icons.arrow_forward, size: 17, color: fg),
            ),
          ],
        ],
      );

      return FocusRing(
        visible: s.focused,
        color: palette.accent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: padding,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: border),
            boxShadow: variant == ButtonVariant.primary && palette.isDark
                ? [BoxShadow(color: AppColors.electric.withValues(alpha: s.hovered ? .45 : .18), blurRadius: s.hovered ? 32 : 20, spreadRadius: -6)]
                : null,
          ),
          child: row,
        ),
      );
    }

    if (disabled) {
      return Semantics(
        button: true,
        enabled: false,
        child: content(const PressableState(hovered: false, focused: false)),
      );
    }

    return Pressable(
      route: route,
      onTap: onPressed,
      semanticLabel: label,
      excludeChildSemantics: true,
      builder: (context, s) => content(s),
    );
  }
}
