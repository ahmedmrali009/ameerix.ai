import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// Simple content records. All strings come from the ARB files; this file
/// only groups them and pairs them with icons, so sections stay declarative.

@immutable
class TextItem {
  const TextItem(this.title, this.body, [this.icon]);
  final String title;
  final String body;
  final IconData? icon;
}

@immutable
class ModuleItem {
  const ModuleItem({required this.name, required this.description, required this.output, required this.icon});
  final String name;
  final String description;
  final String output;
  final IconData icon;
}

@immutable
class IndustryItem {
  const IndustryItem({
    required this.name,
    required this.description,
    required this.useCases,
    required this.benefits,
    required this.icon,
  });
  final String name;
  final String description;
  final List<String> useCases;
  final List<String> benefits;
  final IconData icon;
}

@immutable
class SegmentItem {
  const SegmentItem({required this.title, required this.need, required this.modules, required this.icon});
  final String title;
  final String need;
  final String modules;
  final IconData icon;
}

@immutable
class VariableItem {
  const VariableItem(this.title, this.examples, this.use);
  final String title;
  final String examples;
  final String use;
}

/// A statistic that counts up; [format] receives the locale-formatted number.
@immutable
class StatItem {
  const StatItem({required this.value, required this.decimals, required this.format, required this.label});
  final double value;
  final int decimals;
  final String Function(String number) format;
  final String label;
}

class SiteContent {
  SiteContent(this.l);
  final AppLocalizations l;

  List<TextItem> get pillars => [
        TextItem(l.pillar1Title, l.pillar1Body, Icons.fact_check_outlined),
        TextItem(l.pillar2Title, l.pillar2Body, Icons.leaderboard_outlined),
        TextItem(l.pillar3Title, l.pillar3Body, Icons.hub_outlined),
      ];

  List<String> get problems => [l.problem1, l.problem2, l.problem3, l.problem4, l.problem5];

  List<String> get solutionPoints => [l.solutionPoint1, l.solutionPoint2, l.solutionPoint3];

  List<ModuleItem> get modules => [
        ModuleItem(name: l.modReadinessName, description: l.modReadinessDesc, output: l.modReadinessOutput, icon: Icons.fact_check_outlined),
        ModuleItem(name: l.modScoreName, description: l.modScoreDesc, output: l.modScoreOutput, icon: Icons.leaderboard_outlined),
        ModuleItem(name: l.modMatchName, description: l.modMatchDesc, output: l.modMatchOutput, icon: Icons.join_inner_outlined),
        ModuleItem(name: l.modGraphName, description: l.modGraphDesc, output: l.modGraphOutput, icon: Icons.hub_outlined),
        ModuleItem(name: l.modLocaliseName, description: l.modLocaliseDesc, output: l.modLocaliseOutput, icon: Icons.translate_outlined),
        ModuleItem(name: l.modCrmName, description: l.modCrmDesc, output: l.modCrmOutput, icon: Icons.view_kanban_outlined),
        ModuleItem(name: l.modIntelName, description: l.modIntelDesc, output: l.modIntelOutput, icon: Icons.insights_outlined),
      ];

  List<TextItem> get steps => [
        TextItem(l.step1Title, l.step1Body, Icons.fact_check_outlined),
        TextItem(l.step2Title, l.step2Body, Icons.leaderboard_outlined),
        TextItem(l.step3Title, l.step3Body, Icons.join_inner_outlined),
        TextItem(l.step4Title, l.step4Body, Icons.translate_outlined),
        TextItem(l.step5Title, l.step5Body, Icons.view_kanban_outlined),
        TextItem(l.step6Title, l.step6Body, Icons.autorenew_outlined),
      ];

  List<IndustryItem> get industries => [
        IndustryItem(
          name: l.indFoodName,
          description: l.indFoodDesc,
          useCases: [l.indFoodUse1, l.indFoodUse2, l.indFoodUse3],
          benefits: [l.indFoodBen1, l.indFoodBen2],
          icon: Icons.restaurant_outlined,
        ),
        IndustryItem(
          name: l.indCosmeticsName,
          description: l.indCosmeticsDesc,
          useCases: [l.indCosmeticsUse1, l.indCosmeticsUse2, l.indCosmeticsUse3],
          benefits: [l.indCosmeticsBen1, l.indCosmeticsBen2],
          icon: Icons.spa_outlined,
        ),
        IndustryItem(
          name: l.indFurnitureName,
          description: l.indFurnitureDesc,
          useCases: [l.indFurnitureUse1, l.indFurnitureUse2, l.indFurnitureUse3],
          benefits: [l.indFurnitureBen1, l.indFurnitureBen2],
          icon: Icons.chair_outlined,
        ),
        IndustryItem(
          name: l.indHospitalityName,
          description: l.indHospitalityDesc,
          useCases: [l.indHospitalityUse1, l.indHospitalityUse2, l.indHospitalityUse3],
          benefits: [l.indHospitalityBen1, l.indHospitalityBen2],
          icon: Icons.apartment_outlined,
        ),
      ];

  List<TextItem> get buyerSegments => [
        TextItem(l.buyerSeg1, '', Icons.inventory_2_outlined),
        TextItem(l.buyerSeg2, '', Icons.spa_outlined),
        TextItem(l.buyerSeg3, '', Icons.memory_outlined),
        TextItem(l.buyerSeg4, '', Icons.precision_manufacturing_outlined),
        TextItem(l.buyerSeg5, '', Icons.local_shipping_outlined),
      ];

  List<StatItem> get stats => [
        _stat(l.statSmesNumber, (n) => l.statSmesValue(n), l.statSmesLabel),
        _stat(l.statExportsNumber, (n) => l.statExportsValue(n), l.statExportsLabel),
        _stat(l.statExportersNumber, (n) => l.statExportersValue(n), l.statExportersLabel),
        _stat(l.statEuGccNumber, (n) => l.statEuGccValue(n), l.statEuGccLabel),
        _stat(l.statEuUaeNumber, (n) => l.statEuUaeValue(n), l.statEuUaeLabel),
        _stat(l.statGccNumber, (n) => l.statGccValue(n), l.statGccLabel),
      ];

  /// Numbers live in the ARB files so each language can express magnitude
  /// naturally (e.g. "2.96 M" vs "296 万").
  static StatItem _stat(String number, String Function(String) format, String label) {
    final raw = number.trim();
    final dot = raw.indexOf('.');
    return StatItem(
      value: double.tryParse(raw) ?? 0,
      decimals: dot < 0 ? 0 : raw.length - dot - 1,
      format: format,
      label: label,
    );
  }

  List<TextItem> get benefits => [
        TextItem(l.benefit1Title, l.benefit1Body, Icons.visibility_outlined),
        TextItem(l.benefit2Title, l.benefit2Body, Icons.filter_alt_outlined),
        TextItem(l.benefit3Title, l.benefit3Body, Icons.timeline_outlined),
        TextItem(l.benefit4Title, l.benefit4Body, Icons.schedule_outlined),
        TextItem(l.benefit5Title, l.benefit5Body, Icons.verified_outlined),
        TextItem(l.benefit6Title, l.benefit6Body, Icons.query_stats_outlined),
      ];

  List<String> get techChips => [l.techChip1, l.techChip2, l.techChip3, l.techChip4, l.techChip5, l.techChip6];

  List<TextItem> get differentiators => [
        TextItem(l.diff1Title, l.diff1Body, Icons.rule_outlined),
        TextItem(l.diff2Title, l.diff2Body, Icons.join_inner_outlined),
        TextItem(l.diff3Title, l.diff3Body, Icons.hub_outlined),
        TextItem(l.diff4Title, l.diff4Body, Icons.autorenew_outlined),
        TextItem(l.diff5Title, l.diff5Body, Icons.account_tree_outlined),
        TextItem(l.diff6Title, l.diff6Body, Icons.layers_outlined),
        TextItem(l.diff7Title, l.diff7Body, Icons.person_search_outlined),
      ];

  List<TextItem> get intlPhases => [
        TextItem(l.intlPhase1Title, l.intlPhase1Body, Icons.looks_one_outlined),
        TextItem(l.intlPhase2Title, l.intlPhase2Body, Icons.looks_two_outlined),
        TextItem(l.intlPhase3Title, l.intlPhase3Body, Icons.looks_3_outlined),
      ];

  List<String> get catalysts => [l.catalyst1, l.catalyst2, l.catalyst3, l.catalyst4];

  List<TextItem> get readinessDimensions => [
        TextItem(l.dim1Title, l.dim1Body, Icons.factory_outlined),
        TextItem(l.dim2Title, l.dim2Body, Icons.sell_outlined),
        TextItem(l.dim3Title, l.dim3Body, Icons.description_outlined),
        TextItem(l.dim4Title, l.dim4Body, Icons.public_outlined),
        TextItem(l.dim5Title, l.dim5Body, Icons.inventory_2_outlined),
        TextItem(l.dim6Title, l.dim6Body, Icons.account_balance_wallet_outlined),
      ];

  List<VariableItem> get scoreVariables => [
        VariableItem(l.var1Title, l.var1Body, l.var1Use),
        VariableItem(l.var2Title, l.var2Body, l.var2Use),
        VariableItem(l.var3Title, l.var3Body, l.var3Use),
        VariableItem(l.var4Title, l.var4Body, l.var4Use),
        VariableItem(l.var5Title, l.var5Body, l.var5Use),
        VariableItem(l.var6Title, l.var6Body, l.var6Use),
      ];

  List<String> get matchCriteria => [l.crit1, l.crit2, l.crit3, l.crit4, l.crit5, l.crit6, l.crit7, l.crit8];

  List<TextItem> get dataSources => [
        TextItem(l.src1Title, l.src1Body, Icons.account_balance_outlined),
        TextItem(l.src2Title, l.src2Body, Icons.library_books_outlined),
        TextItem(l.src3Title, l.src3Body, Icons.business_outlined),
        TextItem(l.src4Title, l.src4Body, Icons.touch_app_outlined),
        TextItem(l.src5Title, l.src5Body, Icons.fact_check_outlined),
      ];

  List<String> get pipelineStages =>
      [l.stage1, l.stage2, l.stage3, l.stage4, l.stage5, l.stage6, l.stage7, l.stage8, l.stage9];

  List<String> get intelExamples => [l.intelEx1, l.intelEx2, l.intelEx3];

  List<TextItem> get engagementOptions => [
        TextItem(l.engage1Title, l.engage1Body, Icons.flag_outlined),
        TextItem(l.engage2Title, l.engage2Body, Icons.play_arrow_outlined),
        TextItem(l.engage3Title, l.engage3Body, Icons.workspace_premium_outlined),
        TextItem(l.engage4Title, l.engage4Body, Icons.domain_outlined),
        TextItem(l.engage5Title, l.engage5Body, Icons.handshake_outlined),
      ];

  List<SegmentItem> get segments => [
        SegmentItem(title: l.seg1Title, need: l.seg1Need, modules: l.seg1Modules, icon: Icons.explore_outlined),
        SegmentItem(title: l.seg2Title, need: l.seg2Need, modules: l.seg2Modules, icon: Icons.flight_takeoff_outlined),
        SegmentItem(title: l.seg3Title, need: l.seg3Need, modules: l.seg3Modules, icon: Icons.trending_up_outlined),
        SegmentItem(title: l.seg4Title, need: l.seg4Need, modules: l.seg4Modules, icon: Icons.groups_outlined),
        SegmentItem(title: l.seg5Title, need: l.seg5Need, modules: l.seg5Modules, icon: Icons.work_outline),
        SegmentItem(title: l.seg6Title, need: l.seg6Need, modules: l.seg6Modules, icon: Icons.precision_manufacturing_outlined),
      ];

  List<String> get roles => [l.role1, l.role2, l.role3, l.role4];

  List<TextItem> get partnerTypes => [
        TextItem(l.pt1Title, l.pt1Body, Icons.groups_outlined),
        TextItem(l.pt2Title, l.pt2Body, Icons.account_balance_outlined),
        TextItem(l.pt3Title, l.pt3Body, Icons.work_outline),
        TextItem(l.pt4Title, l.pt4Body, Icons.local_shipping_outlined),
        TextItem(l.pt5Title, l.pt5Body, Icons.directions_boat_outlined),
        TextItem(l.pt6Title, l.pt6Body, Icons.gavel_outlined),
      ];

  List<String> get partnerPrinciples => [l.pp1, l.pp2, l.pp3, l.pp4, l.pp5];

  List<TextItem> get processSteps => [
        TextItem(l.proc1Title, l.proc1Body, Icons.forum_outlined),
        TextItem(l.proc2Title, l.proc2Body, Icons.inventory_2_outlined),
        TextItem(l.proc3Title, l.proc3Body, Icons.slideshow_outlined),
        TextItem(l.proc4Title, l.proc4Body, Icons.flag_outlined),
        TextItem(l.proc5Title, l.proc5Body, Icons.task_alt_outlined),
      ];

  List<String> get metrics => [l.metric1, l.metric2, l.metric3, l.metric4, l.metric5, l.metric6];

  List<String> get aiPoints => [l.aiPoint1, l.aiPoint2, l.aiPoint3, l.aiPoint4, l.aiPoint5];

  List<TextItem> get dataPrinciples => [
        TextItem(l.dp1Title, l.dp1Body, Icons.compress_outlined),
        TextItem(l.dp2Title, l.dp2Body, Icons.history_outlined),
        TextItem(l.dp3Title, l.dp3Body, Icons.view_column_outlined),
        TextItem(l.dp4Title, l.dp4Body, Icons.auto_delete_outlined),
        TextItem(l.dp5Title, l.dp5Body, Icons.admin_panel_settings_outlined),
      ];

  List<String> get securityPoints => [l.sec1, l.sec2, l.sec3, l.sec4, l.sec5];

  List<String> get spainPoints => [l.spainPoint1, l.spainPoint2, l.spainPoint3, l.spainPoint4];

  List<String> get culture => [l.cult1, l.cult2, l.cult3, l.cult4, l.cult5];

  List<TextItem> get roadmap => [
        TextItem(l.rm1Title, l.rm1Body),
        TextItem(l.rm2Title, l.rm2Body),
        TextItem(l.rm3Title, l.rm3Body),
        TextItem(l.rm4Title, l.rm4Body),
      ];

  List<String> get insightCategories =>
      [l.catReports, l.catIndustry, l.catArticles, l.catResearch, l.catNews];
}
