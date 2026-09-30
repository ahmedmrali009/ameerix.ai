import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../localization/locale_controller.dart';
import '../localization/supported_languages.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'pressable.dart';

/// Compact dropdown used in the navigation bar (desktop and tablet).
class LanguageDropdown extends StatelessWidget {
  const LanguageDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = LocaleScope.of(context);
    final l = AppLocalizations.of(context);
    final current = controller.language;

    return PopupMenuButton<String>(
      tooltip: l.a11ySelectLanguage,
      position: PopupMenuPosition.under,
      offset: const Offset(0, 10),
      initialValue: current.code,
      onSelected: controller.setLanguage,
      constraints: const BoxConstraints(minWidth: 200),
      padding: EdgeInsets.zero,
      itemBuilder: (context) => [
        for (final lang in supportedLanguages)
          PopupMenuItem<String>(
            value: lang.code,
            height: 44,
            child: Row(
              children: [
                SizedBox(
                  width: 22,
                  child: lang.code == current.code
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    lang.nativeName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontFamily: AppTypography.familyFor(AppTypography.scriptFor(lang.locale)),
                      fontFamilyFallback: AppTypography.fallbackFor(AppTypography.scriptFor(lang.locale)),
                      fontWeight: lang.code == current.code ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                Text(lang.code.toUpperCase(), style: const TextStyle(color: AppColors.grey500, fontSize: 12)),
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 10, 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: const Color(0x0D4F8CFF),
          border: Border.all(color: AppColors.lineDarkStrong),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, size: 16, color: AppColors.blueSoft),
            const SizedBox(width: 8),
            Text(
              current.shortLabel,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.expand_more, size: 18, color: AppColors.grey400),
          ],
        ),
      ),
    );
  }
}

/// Inline list "EN | 中文 | العربية | ES | IT | FR | DE | PT".
/// Used in the footer and the mobile menu.
class LanguageInlineList extends StatelessWidget {
  const LanguageInlineList({super.key, this.large = false, this.onChanged});

  final bool large;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final controller = LocaleScope.of(context);
    final l = AppLocalizations.of(context);
    return Semantics(
      label: l.a11ySelectLanguage,
      container: true,
      child: Wrap(
        spacing: large ? 8 : 4,
        runSpacing: large ? 8 : 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final lang in supportedLanguages)
            _LanguageChip(
              lang: lang,
              selected: lang.code == controller.language.code,
              large: large,
              onTap: () {
                controller.setLanguage(lang.code);
                onChanged?.call();
              },
            ),
        ],
      ),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({required this.lang, required this.selected, required this.large, required this.onTap});

  final SupportedLanguage lang;
  final bool selected;
  final bool large;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final script = AppTypography.scriptFor(lang.locale);
    return Semantics(
      selected: selected,
      child: Pressable(
        onTap: onTap,
        semanticLabel: lang.nativeName,
        excludeChildSemantics: true,
        builder: (context, s) => AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(horizontal: large ? 16 : 10, vertical: large ? 10 : 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.white : (s.active ? const Color(0x174F8CFF) : Colors.transparent),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? AppColors.white : (s.focused || s.hovered ? AppColors.electric : AppColors.lineDark)),
          ),
          child: Text(
            large ? lang.nativeName : lang.shortLabel,
            style: TextStyle(
              fontFamily: AppTypography.familyFor(script),
              fontFamilyFallback: AppTypography.fallbackFor(script),
              fontSize: large ? 15 : 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? AppColors.black : AppColors.grey300,
            ),
          ),
        ),
      ),
    );
  }
}
