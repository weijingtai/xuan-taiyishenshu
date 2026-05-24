import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/taiyi_pan_controller.dart';
import '../theme/taiyi_classic_theme.dart';
import '../taiyi/core/deity_definition.dart';
import 'ink_wash_widgets.dart';
import '../pages/entity_editor_page.dart';

class DeityManagementDialog extends StatelessWidget {
  const DeityManagementDialog({super.key});

  static const Map<String, String> _tierLabels = {
    'core': '核心枢轴',
    'generals': '主客将领',
    'jiShen': '岁时三基',
    'auspicious': '吉庆神煞',
    'spiritual': '九天外层',
    'chronos': '地盘岁君',
    'weather': '天文气象',
  };

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TaiYiPanController>();
    final officialDeities = controller.officialDeities;

    // Group deities by tier
    final Map<String, List<DeityDefinition>> grouped = {};
    for (final deity in officialDeities) {
      final tier = deity.tier;
      grouped.putIfAbsent(tier, () => []).add(deity);
    }

    // Sort tiers according to _tierLabels order
    final sortedTiers = _tierLabels.keys.where((t) => grouped.containsKey(t)).toList();
    // Add any remaining tiers not in _tierLabels
    sortedTiers.addAll(grouped.keys.where((t) => !_tierLabels.containsKey(t)));

    return AlertDialog(
      backgroundColor: TaiYiClassicTheme.ricePaper,
      surfaceTintColor: Colors.transparent,
      title: Column(
        children: [
          Text(
            '星神管理',
            style: GoogleFonts.maShanZheng(
              fontSize: 24,
              color: TaiYiClassicTheme.darkWood,
            ),
          ),
          const Divider(color: TaiYiClassicTheme.goldLeaf, thickness: 1),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ChineseSectionHeader(title: '系统内置'),
              ...sortedTiers.map((tier) => _buildTierSection(context, controller, tier, grouped[tier]!)),
              const SizedBox(height: 24),
              const ChineseSectionHeader(title: '我的'),
              InkyBorder(
                color: TaiYiClassicTheme.goldLeaf,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text('暂无自定义星神', style: TextStyle(fontStyle: FontStyle.italic, color: TaiYiClassicTheme.inkWash)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const ChineseSectionHeader(title: 'Marketplace'),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Opacity(
                  opacity: 0.5,
                  child: Text('即将上线', style: TextStyle(fontStyle: FontStyle.italic, color: TaiYiClassicTheme.inkWash)),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (controller.showHiddenWarning)
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.warning, color: TaiYiClassicTheme.cinnabar, size: 14),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '部分基础星神已隐藏，盘面解释可能不完整。',
                    style: TextStyle(color: TaiYiClassicTheme.cinnabar, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
      ],
    );
  }

  Widget _buildTierSection(BuildContext context, TaiYiPanController controller, String tier, List<DeityDefinition> deities) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              _tierLabels[tier] ?? '其他星神',
              style: GoogleFonts.maShanZheng(fontSize: 16, color: TaiYiClassicTheme.inkBlack.withValues(alpha: 0.7)),
            ),
          ),
          InkyBorder(
            padding: 12,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: deities.map((deity) => _buildDeityChip(context, controller, deity)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeityChip(BuildContext context, TaiYiPanController controller, DeityDefinition deity) {
    final isVisible = controller.isDeityVisible(deity.id);
    // Real logic: check chartType restriction
    final bool available = deity.chartTypes.isEmpty || 
                           deity.chartTypes.contains(controller.panData?.input.chartType.name);

    return Opacity(
      opacity: available ? 1.0 : 0.4,
      child: InkWell(
        onTap: available ? () => controller.setDeityVisibility(deity.id, !isVisible) : null,
        onLongPress: available ? () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => EntityEditorPage(
                type: EntityType.deity,
                entityId: deity.id,
                initialName: deity.name,
                lineage: deity.source == 'official' ? '官方系统' : '自定义派生',
                controller: controller,
              ),
            ),
          );
        } : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isVisible ? TaiYiClassicTheme.cinnabar.withValues(alpha: 0.1) : Colors.transparent,
            border: Border.all(
              color: isVisible ? TaiYiClassicTheme.cinnabar : TaiYiClassicTheme.inkWash.withValues(alpha: 0.3),
              width: 0.8,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isVisible ? Icons.check_box : Icons.check_box_outline_blank,
                size: 14,
                color: isVisible ? TaiYiClassicTheme.cinnabar : TaiYiClassicTheme.inkWash,
              ),
              const SizedBox(width: 6),
              Text(
                deity.name,
                style: GoogleFonts.longCang(
                  color: isVisible ? TaiYiClassicTheme.inkBlack : TaiYiClassicTheme.inkWash.withValues(alpha: 0.6),
                  fontSize: 16,
                ),
              ),
              if (!available)
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(Icons.lock_outline, size: 12, color: TaiYiClassicTheme.inkWash),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
