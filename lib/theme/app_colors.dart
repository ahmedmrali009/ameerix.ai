import 'package:flutter/widgets.dart';

/// Cinematic enterprise-AI palette.
///
/// Neutral tokens keep their historical names (`black`, `ink`, `grey400`…)
/// so every existing widget moves to the navy system automatically; the
/// accents carry fixed meaning across the whole site:
///
/// * [blue] / [electric] — data, market intelligence, analysis
/// * [violet]            — AI processing, the Ameerix intelligence engine
/// * [cyan]              — connections, live data, network relationships
/// * [gold]              — commercial opportunity, priority, valuable signals
/// * [magenta]           — very sparing AI energy / depth
/// * [green]             — validated / positive product states only
/// * [error]             — warnings and errors only
///
/// All text/background pairs used by the site meet WCAG AA.
class AppColors {
  const AppColors._();

  // --- environments -------------------------------------------------------
  static const Color deepSpace = Color(0xFF030712); // AI / intelligence scenes
  static const Color midnight = Color(0xFF071426); // product sections
  static const Color navy = Color(0xFF0A1A3D); // opportunity / CTA
  static const Color hazeBlack = Color(0xFF05040E); // Trade Graph (violet haze)

  // --- neutrals (dark side) ----------------------------------------------
  static const Color black = deepSpace;
  static const Color ink = Color(0xFF0B1528); // raised surface on dark
  static const Color ink2 = Color(0xFF111D35);
  static const Color lineDark = Color(0xFF1A2742);
  static const Color lineDarkStrong = Color(0xFF2A3A5C);

  /// Translucent intelligence panel (use sparingly, over complex visuals).
  static const Color glass = Color(0x8C0A142D); // rgba(10,20,45,.55)
  static const Color glassEdge = Color(0x3394B4FF);

  // --- neutral text -------------------------------------------------------
  static const Color grey700 = Color(0xFF334155);
  static const Color grey600 = Color(0xFF475569); // body on light (7.2:1)
  static const Color grey500 = Color(0xFF7C8BA5); // subtle on dark (5.3:1)
  static const Color grey400 = Color(0xFF94A3B8); // body on dark (7.8:1)
  static const Color grey300 = Color(0xFFCBD5E1);
  static const Color slate = Color(0xFF5A6A83); // subtle on light (≥4.9:1)

  // --- light side ---------------------------------------------------------
  static const Color navyInk = Color(0xFF0B1B3A); // headings on light
  static const Color lineLight = Color(0xFFE2E8F0);
  static const Color lineLightStrong = Color(0xFFCBD5E1);
  static const Color mist = Color(0xFFEEF2F8); // very light blue-grey
  static const Color white = Color(0xFFF8FAFC); // soft white
  static const Color pureWhite = Color(0xFFFFFFFF);

  // --- semantic accents ---------------------------------------------------
  static const Color blue = Color(0xFF3B82F6);
  static const Color blueDeep = Color(0xFF2563EB);
  static const Color blueInk = Color(0xFF1D4ED8); // blue text on light
  static const Color electric = Color(0xFF4F8CFF);
  static const Color blueSoft = Color(0xFF93B4FF);
  static const Color violet = Color(0xFF8B5CF6);
  static const Color violetDeep = Color(0xFF7C3AED);
  static const Color violetSoft = Color(0xFFA78BFA);
  static const Color cyan = Color(0xFF22D3EE);
  static const Color magenta = Color(0xFFD946EF);
  static const Color gold = Color(0xFFF4C76B);
  static const Color goldDeep = Color(0xFF8A6417); // gold text on light
  static const Color green = Color(0xFF34D399);
  static const Color error = Color(0xFFB42318);
  static const Color errorOnDark = Color(0xFFF97066);

  /// Blue→violet treatment for one or two strategic words.
  static const LinearGradient intelligence = LinearGradient(
    colors: [Color(0xFF6EA8FF), Color(0xFF8B7CF8), Color(0xFFB79CFF)],
  );

  /// Gold treatment reserved for "opportunity".
  static const LinearGradient opportunity = LinearGradient(
    colors: [Color(0xFFFFE3A3), gold, Color(0xFFE0A84A)],
  );
}

/// Visual environment of a section. Widgets read it through [Tone.of].
///
/// * [dark]        deep-space navy — AI / intelligence scenes
/// * [midnight]    midnight blue — product sections
/// * [haze]        near black + violet haze — Trade Graph family
/// * [light]       soft white — corporate credibility
/// * [muted]       very light blue-grey — methodology, industries
/// * [opportunity] deep blue + a trace of gold — final CTA
enum SectionTone { dark, light, muted, midnight, haze, opportunity }

@immutable
class TonePalette {
  const TonePalette({
    required this.isDark,
    required this.background,
    required this.surface,
    required this.surfaceHover,
    required this.border,
    required this.borderStrong,
    required this.heading,
    required this.body,
    required this.subtle,
    required this.inverse,
    this.accent = AppColors.blue,
    this.lighting = const [],
  });

  final bool isDark;
  final Color background;
  final Color surface;
  final Color surfaceHover;
  final Color border;
  final Color borderStrong;
  final Color heading;
  final Color body;
  final Color subtle;
  final Color inverse;

  /// Accent for eyebrows, icons and focus in this environment.
  final Color accent;

  /// Soft radial light sources painted behind the content (cinematic
  /// "volumetric" illumination). Kept subtle; empty for flat bands.
  final List<RadialGradient> lighting;

  static const TonePalette dark = TonePalette(
    isDark: true,
    background: AppColors.deepSpace,
    surface: AppColors.ink,
    surfaceHover: AppColors.ink2,
    border: AppColors.lineDark,
    borderStrong: AppColors.lineDarkStrong,
    heading: AppColors.white,
    body: AppColors.grey400,
    subtle: AppColors.grey500,
    inverse: AppColors.deepSpace,
    accent: AppColors.electric,
    lighting: [
      RadialGradient(center: Alignment(.8, -1.1), radius: 1.1, colors: [Color(0x1F2563EB), Color(0x002563EB)]),
      RadialGradient(center: Alignment(-1, 1.2), radius: .9, colors: [Color(0x147C3AED), Color(0x007C3AED)]),
    ],
  );

  static const TonePalette midnight = TonePalette(
    isDark: true,
    background: AppColors.midnight,
    surface: Color(0xFF0C1D36),
    surfaceHover: Color(0xFF10233F),
    border: Color(0xFF1B2D4B),
    borderStrong: Color(0xFF2B4068),
    heading: AppColors.white,
    body: AppColors.grey400,
    subtle: AppColors.grey500,
    inverse: AppColors.midnight,
    accent: AppColors.electric,
    lighting: [
      RadialGradient(center: Alignment(0, -1.3), radius: 1.2, colors: [Color(0x2E3B82F6), Color(0x003B82F6)]),
    ],
  );

  static const TonePalette haze = TonePalette(
    isDark: true,
    background: AppColors.hazeBlack,
    surface: Color(0xFF0E0B1F),
    surfaceHover: Color(0xFF151029),
    border: Color(0xFF221B3D),
    borderStrong: Color(0xFF33295A),
    heading: AppColors.white,
    body: AppColors.grey400,
    subtle: AppColors.grey500,
    inverse: AppColors.hazeBlack,
    accent: AppColors.violetSoft,
    lighting: [
      RadialGradient(center: Alignment(.4, 0), radius: 1.0, colors: [Color(0x2E7C3AED), Color(0x007C3AED)]),
      RadialGradient(center: Alignment(-.9, -.9), radius: .7, colors: [Color(0x14D946EF), Color(0x00D946EF)]),
    ],
  );

  static const TonePalette opportunity = TonePalette(
    isDark: true,
    background: Color(0xFF040C22),
    surface: Color(0xFF0A1734),
    surfaceHover: Color(0xFF0E1D40),
    border: Color(0xFF1B2C52),
    borderStrong: Color(0xFF2C4274),
    heading: AppColors.white,
    body: AppColors.grey400,
    subtle: AppColors.grey500,
    inverse: AppColors.navy,
    accent: AppColors.gold,
    lighting: [
      RadialGradient(center: Alignment(0, 1.2), radius: 1.1, colors: [Color(0x332563EB), Color(0x002563EB)]),
      RadialGradient(center: Alignment(.7, -.2), radius: .5, colors: [Color(0x14F4C76B), Color(0x00F4C76B)]),
    ],
  );

  static const TonePalette light = TonePalette(
    isDark: false,
    background: AppColors.white,
    surface: AppColors.pureWhite,
    surfaceHover: AppColors.pureWhite,
    border: AppColors.lineLight,
    borderStrong: AppColors.lineLightStrong,
    heading: AppColors.navyInk,
    body: AppColors.grey600,
    subtle: AppColors.slate,
    inverse: AppColors.white,
    accent: AppColors.blueInk,
  );

  static const TonePalette muted = TonePalette(
    isDark: false,
    background: AppColors.mist,
    surface: AppColors.pureWhite,
    surfaceHover: AppColors.pureWhite,
    border: AppColors.lineLight,
    borderStrong: AppColors.lineLightStrong,
    heading: AppColors.navyInk,
    body: AppColors.grey600,
    subtle: AppColors.slate,
    inverse: AppColors.white,
    accent: AppColors.blueInk,
    lighting: [
      RadialGradient(center: Alignment(.9, -1), radius: 1.0, colors: [Color(0x1A3B82F6), Color(0x003B82F6)]),
    ],
  );

  static TonePalette forTone(SectionTone tone) => switch (tone) {
        SectionTone.dark => dark,
        SectionTone.light => light,
        SectionTone.muted => muted,
        SectionTone.midnight => midnight,
        SectionTone.haze => haze,
        SectionTone.opportunity => opportunity,
      };
}

class Tone extends InheritedWidget {
  const Tone({super.key, required this.palette, required super.child});

  final TonePalette palette;

  static TonePalette of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<Tone>()?.palette ?? TonePalette.light;

  @override
  bool updateShouldNotify(Tone oldWidget) => oldWidget.palette != palette;
}

/// Paints a palette's soft light sources. Cheap: a few gradient fills,
/// repainted only when the section is laid out.
class AmbientLighting extends StatelessWidget {
  const AmbientLighting({super.key, required this.palette});
  final TonePalette palette;

  @override
  Widget build(BuildContext context) {
    if (palette.lighting.isEmpty) return const SizedBox.shrink();
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [for (final g in palette.lighting) DecoratedBox(decoration: BoxDecoration(gradient: g))],
      ),
    );
  }
}
