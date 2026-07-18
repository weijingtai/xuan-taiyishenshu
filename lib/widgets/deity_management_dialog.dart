import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../controllers/taiyi_pan_controller.dart';
import '../theme/taiyi_classic_theme.dart';
import '../taiyi/core/deity_definition.dart';
import '../taiyi/core/school_config.dart';
import '../pages/entity_editor_page.dart';
import 'ink_wash_widgets.dart';

/// 星神管理 Dialog
///
/// 三区结构 (系统内置 / 我的星神 / Marketplace 预留),
/// 复制官方 → 我的, 我的可编辑可删除, Checkbox 偏好走 Repository。
/// 不可用项置灰 + 文字原因 (反 lock-only) + checkbox.onChanged==null。
/// 隐藏关键项时, Dialog 顶部显示警告 Banner。
class DeityManagementDialog extends StatefulWidget {
  const DeityManagementDialog({super.key});

  @override
  State<DeityManagementDialog> createState() => _DeityManagementDialogState();
}

class _DeityManagementDialogState extends State<DeityManagementDialog> {
  /// tier code -> 中文分组标签
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
    final theme = Theme.of(context);

    // 区分官方/用户:用 source 字段, 不依赖 id 前缀。
    final allDeities = controller.allDeities;
    final officialDeities =
        allDeities.where((d) => d.source == 'official').toList()
          ..sort((a, b) => a.priority.compareTo(b.priority));
    final userDeities = allDeities.where((d) => d.source == 'user').toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    // Group official deities by tier
    final Map<String, List<DeityDefinition>> grouped = {};
    for (final deity in officialDeities) {
      grouped.putIfAbsent(deity.tier, () => []).add(deity);
    }
    final sortedTiers = _tierLabels.keys
        .where((t) => grouped.containsKey(t))
        .toList();
    sortedTiers.addAll(grouped.keys.where((t) => !_tierLabels.containsKey(t)));

    return AlertDialog(
      backgroundColor: TaiYiClassicTheme.ricePaper,
      surfaceTintColor: Colors.transparent,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '星神管理',
            style: TextStyle(fontSize: 22, color: TaiYiClassicTheme.darkWood),
          ),
          const SizedBox(height: 4),
          const Divider(
            color: TaiYiClassicTheme.goldLeaf,
            thickness: 1,
            height: 4,
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Semantics(
          identifier: 'deity-management-dialog',
          container: true,
          label: '星神管理对话框',
          child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部隐藏关键项警告 Banner (AC13)
              if (controller.showHiddenWarning)
                _HiddenCoreWarning(theme: theme),

              // === Section 1: 系统内置 ===
              Semantics(
                identifier: 'deity-section-official',
                child: const ChineseSectionHeader(title: '系统内置'),
              ),
              if (officialDeities.isEmpty)
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(AppLocalizations.of(context)!.noOfficialDeityLoaded),
                )
              else
                ...sortedTiers.map(
                  (tier) => _OfficialTierSection(
                    tier: tier,
                    label: _tierLabels[tier] ?? '其他',
                    deities: grouped[tier]!,
                    controller: controller,
                  ),
                ),

              const SizedBox(height: 16),

              // === Section 2: 我的星神 ===
              Semantics(
                identifier: 'deity-section-user',
                child: const ChineseSectionHeader(title: '我的星神'),
              ),
              _MyDeitiesSection(
                userDeities: userDeities,
                controller: controller,
              ),

              const SizedBox(height: 16),

              // === Section 3: Marketplace (产品占位, 唯一一处 "即将开放") ===
              Semantics(
                identifier: 'deity-section-marketplace',
                child: const ChineseSectionHeader(title: 'Marketplace'),
              ),
              const _MarketplacePlaceholder(),
              const SizedBox(height: 8),
            ],
          ),
        ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(8, 0, 16, 8),
      actions: [
        Semantics(
          identifier: 'deity-dialog-close',
          button: true,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ),
      ],
    );
  }
}

/// 隐藏核心星神警告 Banner (AC13)
class _HiddenCoreWarning extends StatelessWidget {
  final ThemeData theme;
  const _HiddenCoreWarning({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: 'deity-dialog-hidden-warning',
      label: '隐藏关键星神警告',
      container: true,
      child: Container(
      margin: const EdgeInsets.fromLTRB(0, 4, 0, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: TaiYiClassicTheme.cinnabar.withValues(alpha: 0.08),
        border: Border.all(
          color: TaiYiClassicTheme.cinnabar.withValues(alpha: 0.4),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber,
            color: TaiYiClassicTheme.cinnabar,
            size: 18,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              '部分基础星神或关键计算项已隐藏，盘面解释可能不完整。',
              style: TextStyle(
                color: TaiYiClassicTheme.cinnabar,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}

/// 官方星神按 tier 分组的小节
class _OfficialTierSection extends StatelessWidget {
  final String tier;
  final String label;
  final List<DeityDefinition> deities;
  final TaiYiPanController controller;

  const _OfficialTierSection({
    required this.tier,
    required this.label,
    required this.deities,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: TaiYiClassicTheme.inkBlack.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          InkyBorder(
            padding: 4,
            child: Column(
              children: deities
                  .map(
                    (deity) => _OfficialDeityTile(
                      deity: deity,
                      controller: controller,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// 单条官方星神:Checkbox + 名称 + 不可用原因 + "复制到我的" 按钮
class _OfficialDeityTile extends StatelessWidget {
  final DeityDefinition deity;
  final TaiYiPanController controller;

  const _OfficialDeityTile({required this.deity, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isVisible = controller.isDeityVisible(deity.id);
    final unavailableReason = _resolveUnavailableReason(deity, controller);
    final available = unavailableReason == null;

    return Opacity(
      opacity: available ? 1.0 : 0.55,
      child: Semantics(
        identifier: 'deity-tile-${deity.id}',
        container: true,
        child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        leading: Semantics(
          identifier: 'deity-checkbox-${deity.id}',
          checked: available && isVisible,
          enabled: available,
          label: '${deity.name} 显示开关',
          child: Checkbox(
          value: available && isVisible,
          // 反 fake completion: 不可用必须 onChanged==null,使 checkbox 真的禁用
          onChanged: available
              ? (v) => controller.setDeityVisibility(deity.id, v ?? false)
              : null,
          activeColor: TaiYiClassicTheme.cinnabar,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        ),
        title: GestureDetector(
          onTap: available
              ? () => controller.setDeityVisibility(deity.id, !isVisible)
              : null,
          // 长按官方项打开只读 Editor (查看 lineage / 配置, 不可改)。
          // 与 “复制到我的” 按钮分工:复制后才能编辑;长按只是查看。
          onLongPress: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => EntityEditorPage(
                  type: EntityType.deity,
                  entityId: deity.id,
                  initialName: deity.name,
                  lineage: '官方系统',
                  controller: controller,
                ),
              ),
            );
          },
          child: Semantics(
            identifier: 'deity-name-${deity.id}',
            label: deity.name,
            child: Text(
              deity.name,
              style: TextStyle(
                fontSize: 15,
                color: available
                    ? TaiYiClassicTheme.inkBlack
                    : TaiYiClassicTheme.inkWash,
              ),
            ),
          ),
        ),
        subtitle: unavailableReason == null
            ? null
            : Semantics(
                identifier: 'deity-reason-${deity.id}',
                label: unavailableReason,
                child: Text(
                  // 反 lock-only: 必须有文字原因
                  unavailableReason,
                  key: const ValueKey('deity-unavailable-reason'),
                  style: const TextStyle(
                    fontSize: 11,
                    color: TaiYiClassicTheme.inkWash,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
        trailing: Tooltip(
          message: '复制到我的星神',
          child: Semantics(
            identifier: 'deity-copy-${deity.id}',
            button: true,
            label: AppLocalizations.of(context)!.copyDeityToMyDeities(deity.name),
            child: IconButton(
              icon: const Icon(Icons.copy, size: 16),
              color: TaiYiClassicTheme.goldLeaf,
              tooltip: AppLocalizations.of(context)!.copyToMyDeities,
              onPressed: () => _onCopy(context),
            ),
          ),
        ),
      ),
      ),
    );
  }

  Future<void> _onCopy(BuildContext context) async {
    final newId = 'user_${deity.id}_${DateTime.now().millisecondsSinceEpoch}';
    final newName = '${deity.name}副本';

    await controller.deityViewModel.copyDeity(
      sourceId: deity.id,
      newId: newId,
      newName: newName,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.copiedToMyDeities(newName)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

/// "我的星神" 区:用户副本列表 + 编辑/删除入口
class _MyDeitiesSection extends StatelessWidget {
  final List<DeityDefinition> userDeities;
  final TaiYiPanController controller;

  const _MyDeitiesSection({
    required this.userDeities,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (userDeities.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: InkyBorder(
          padding: 12,
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: TaiYiClassicTheme.inkWash.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '暂无自定义星神,可从系统内置星神点 “复制” 按钮派生。',
                  key: ValueKey('my-deities-empty'),
                  style: TextStyle(
                    color: TaiYiClassicTheme.inkWash,
                    fontStyle: FontStyle.italic,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InkyBorder(
        padding: 4,
        child: Column(
          children: userDeities
              .map(
                (deity) =>
                    _UserDeityTile(deity: deity, controller: controller),
              )
              .toList(),
        ),
      ),
    );
  }
}

/// 单条用户星神:Checkbox + 名称 + 不可用原因 + 编辑 + 删除
class _UserDeityTile extends StatelessWidget {
  final DeityDefinition deity;
  final TaiYiPanController controller;

  const _UserDeityTile({required this.deity, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isVisible = controller.isDeityVisible(deity.id);
    final unavailableReason = _resolveUnavailableReason(deity, controller);
    final available = unavailableReason == null;

    return Opacity(
      opacity: available ? 1.0 : 0.55,
      child: Semantics(
        identifier: 'deity-tile-${deity.id}',
        container: true,
        child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        leading: Semantics(
          identifier: 'deity-checkbox-${deity.id}',
          checked: available && isVisible,
          enabled: available,
          label: '${deity.name} 显示开关',
          child: Checkbox(
            value: available && isVisible,
            onChanged: available
                ? (v) => controller.setDeityVisibility(deity.id, v ?? false)
                : null,
            activeColor: TaiYiClassicTheme.cinnabar,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        title: GestureDetector(
          onTap: available
              ? () => controller.setDeityVisibility(deity.id, !isVisible)
              : null,
          child: Semantics(
            identifier: 'deity-name-${deity.id}',
            label: deity.name,
            child: Text(
              deity.name,
              style: TextStyle(
                fontSize: 15,
                color: available
                    ? TaiYiClassicTheme.inkBlack
                    : TaiYiClassicTheme.inkWash,
              ),
            ),
          ),
        ),
        subtitle: Semantics(
          identifier: 'deity-lineage-${deity.id}',
          label: '${deity.name} 传承',
          child: Text(
            unavailableReason ?? '派生自: ${deity.lineage ?? deity.sourceId ?? "(未知)"}',
            style: TextStyle(
              fontSize: 11,
              color: TaiYiClassicTheme.inkWash,
              fontStyle: unavailableReason == null
                  ? FontStyle.normal
                  : FontStyle.italic,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tooltip(
              message: '编辑',
              child: Semantics(
                identifier: 'deity-edit-${deity.id}',
                button: true,
                label: AppLocalizations.of(context)!.editDeity(deity.name),
                child: IconButton(
                  icon: const Icon(Icons.edit, size: 16),
                  color: TaiYiClassicTheme.darkWood,
                  tooltip: AppLocalizations.of(context)!.edit,
                  onPressed: () => _onEdit(context),
                ),
              ),
            ),
            Tooltip(
              message: '删除',
              child: Semantics(
                identifier: 'deity-delete-${deity.id}',
                button: true,
              label: AppLocalizations.of(context)!.deleteDeityLabel(deity.name),
              child: IconButton(
                key: ValueKey('delete-user-deity-${deity.id}'),
                icon: const Icon(Icons.delete_outline, size: 16),
                color: TaiYiClassicTheme.cinnabar,
                tooltip: AppLocalizations.of(context)!.delete,
                  onPressed: () => _onDelete(context),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  void _onEdit(BuildContext context) {
    // 期望路由 /taiyishenshu/deity-editor (Task 31 创建)。
    // Master 后续 wire 路由表。这里走临时 MaterialPageRoute 兜底。
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => EntityEditorPage(
          type: EntityType.deity,
          entityId: deity.id,
          initialName: deity.name,
          lineage: deity.lineage ?? deity.sourceId ?? '(未知)',
          controller: controller,
        ),
      ),
    );
  }

  Future<void> _onDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: TaiYiClassicTheme.ricePaper,
        title: Text(AppLocalizations.of(context)!.deleteDeity),
        content: Text(AppLocalizations.of(context)!.confirmDeleteDeity(deity.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: TaiYiClassicTheme.cinnabar,
            ),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await controller.deityViewModel.deleteDeity(deity.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.deletedDeity(deity.name))),
        );
      }
    }
  }
}

/// Marketplace 预留区 (产品占位, 唯一一处 "即将开放")
class _MarketplacePlaceholder extends StatelessWidget {
  const _MarketplacePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Semantics(
        identifier: 'marketplace-placeholder-container',
        label: 'Marketplace 预留区，即将开放',
        container: true,
        child: InkyBorder(
        padding: 12,
        // 整体灰阶 + 不可交互:placeholder 不能被勾选
        child: AbsorbPointer(
          absorbing: true,
          child: Opacity(
            opacity: 0.45,
            child: Row(
              children: [
                Icon(
                  Icons.storefront,
                  size: 18,
                  color: TaiYiClassicTheme.inkWash.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Marketplace 即将开放 (产品占位)',
                    key: ValueKey('marketplace-placeholder'),
                    style: TextStyle(
                      color: TaiYiClassicTheme.inkWash,
                      fontStyle: FontStyle.italic,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}

/// 同时考虑当前流派 (deityIds 白名单 + schoolScopes) 和当前盘型 (chartTypes)。
/// 返回 null 表示可用,否则返回中文原因字符串。
String? _resolveUnavailableReason(
  DeityDefinition deity,
  TaiYiPanController controller,
) {
  final input = controller.panData?.input;
  final schoolId = input?.schoolId;
  final chartType = input?.chartType.name;

  // 当前盘型限制
  if (chartType != null &&
      deity.chartTypes.isNotEmpty &&
      !deity.chartTypes.contains(chartType)) {
    return '不适用于当前盘型 ($chartType)';
  }

  // schoolScopes 显式限制
  if (schoolId != null &&
      deity.schoolScopes.isNotEmpty &&
      !deity.schoolScopes.contains(schoolId)) {
    return '不适用于当前流派 ($schoolId)';
  }

  // 当前流派 deityIds 白名单
  if (schoolId != null) {
    final school = _findSchool(controller, schoolId);
    if (school != null &&
        school.deityIds.isNotEmpty &&
        !school.deityIds.contains(deity.id)) {
      return '当前流派 ($schoolId) 未启用该项';
    }
  }

  return null;
}

TaiYiSchool? _findSchool(TaiYiPanController controller, String schoolId) {
  for (final s in controller.availableSchools) {
    if (s.id == schoolId) return s;
  }
  return null;
}
