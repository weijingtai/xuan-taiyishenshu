import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/taiyi_classic_theme.dart';
import '../../taiyi/core/chart_config.dart';
import '../../taiyi/core/deity_override.dart';
import '../ink_wash_widgets.dart';
import '../../l10n/app_localizations.dart';

/// Read-only banner shown when an official school is opened in view mode.
class OfficialReadOnlyBanner extends StatelessWidget {
  final VoidCallback onCopyAndEdit;
  const OfficialReadOnlyBanner({super.key, required this.onCopyAndEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('official_readonly_banner'),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TaiYiClassicTheme.paleGold.withOpacity(0.4),
        border: Border.all(color: TaiYiClassicTheme.goldLeaf, width: 1.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, color: TaiYiClassicTheme.cinnabar),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '这是官方流派,只能查看。若需修改请先复制为我的流派。',
              style: TaiYiClassicTheme.getChineseStyle(
                fontSize: 14,
                color: TaiYiClassicTheme.darkWood,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            key: const Key('copy_and_edit_button'),
            onPressed: onCopyAndEdit,
            icon: const Icon(Icons.copy, size: 18),
            label: Text(AppLocalizations.of(context)!.copyAndEdit),
            style: ElevatedButton.styleFrom(
              backgroundColor: TaiYiClassicTheme.cinnabar,
              foregroundColor: Colors.white,
              minimumSize: const Size(120, 44),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section: Identity (id / name / source / sourceId / rootOfficialId / lineage)
class IdentitySection extends StatelessWidget {
  final TextEditingController nameController;
  final String id;
  final String source;
  final String? sourceId;
  final String? rootOfficialId;
  final String? lineage;
  final bool readOnly;
  const IdentitySection({
    super.key,
    required this.nameController,
    required this.id,
    required this.source,
    required this.sourceId,
    required this.rootOfficialId,
    required this.lineage,
    required this.readOnly,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ChineseSectionHeader(title: '基础信息'),
        InkyBorder(
          padding: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _KeyValueRow(label: 'ID', value: id),
              const SizedBox(height: 8),
              TextFormField(
                key: const Key('school_name_input'),
                controller: nameController,
                enabled: !readOnly,
                decoration: const InputDecoration(
                  labelText: '名称',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? '名称不能为空' : null,
              ),
              const SizedBox(height: 12),
              _SourceBadge(source: source),
              if (sourceId != null) ...[
                const SizedBox(height: 8),
                _KeyValueRow(label: 'sourceId', value: sourceId!),
              ],
              if (rootOfficialId != null) ...[
                const SizedBox(height: 4),
                _KeyValueRow(label: 'rootOfficialId', value: rootOfficialId!),
              ],
              if (lineage != null) ...[
                const SizedBox(height: 4),
                _KeyValueRow(label: 'lineage', value: lineage!),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SourceBadge extends StatelessWidget {
  final String source;
  const _SourceBadge({required this.source});
  @override
  Widget build(BuildContext context) {
    final isOfficial = source == 'official';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOfficial
            ? TaiYiClassicTheme.cinnabar.withOpacity(0.15)
            : TaiYiClassicTheme.jadeGreen.withOpacity(0.15),
        border: Border.all(
          color: isOfficial
              ? TaiYiClassicTheme.cinnabar
              : TaiYiClassicTheme.jadeGreen,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isOfficial ? '官方流派' : '我的流派',
        style: TextStyle(
          color: isOfficial
              ? TaiYiClassicTheme.cinnabar
              : TaiYiClassicTheme.jadeGreen,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  final String label;
  final String value;
  const _KeyValueRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: TaiYiClassicTheme.inkWash,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(
                color: TaiYiClassicTheme.inkBlack,
                fontSize: 13,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section: Epoch (积年/积月/积日/积时 + zhangSui/zhangYue + dayOffset/hourOffset)
class EpochSection extends StatelessWidget {
  /// Map of field name -> controller for all numeric epoch fields.
  final Map<String, TextEditingController> controllers;
  final TextEditingController tropicalYearController;
  final bool readOnly;

  static const orderedFields = <_EpochFieldSpec>[
    _EpochFieldSpec('ancientBase', '积年基数 (ancientBase)', '积年累计起点'),
    _EpochFieldSpec('epochYear', '积年纪元年 (epochYear)', '基准公历年'),
    _EpochFieldSpec('correction', '积年校正 (correction)', '入纪偏移'),
    _EpochFieldSpec('ancientMonthBase', '积月基数 (ancientMonthBase)', '月家累计起点'),
    _EpochFieldSpec('ancientDayBase', '积日基数 (ancientDayBase)', '日家累计起点'),
    _EpochFieldSpec('ancientHourBase', '积时基数 (ancientHourBase)', '时家累计起点'),
    _EpochFieldSpec('zhangSui', 'zhangSui (章岁)', '章岁周期'),
    _EpochFieldSpec('zhangYue', 'zhangYue (章月)', '章月周期'),
    _EpochFieldSpec('dayOffset', 'dayOffset (日偏移)', '日家局数偏移'),
    _EpochFieldSpec('hourOffset', 'hourOffset (时偏移)', '时家局数偏移'),
  ];

  const EpochSection({
    super.key,
    required this.controllers,
    required this.tropicalYearController,
    required this.readOnly,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ChineseSectionHeader(title: '积年 / 积月 / 积日 / 积时'),
        InkyBorder(
          padding: 16,
          child: Column(
            children: [
              for (final spec in orderedFields)
                _intRow(spec),
              _doubleRow(
                key: 'tropicalYear',
                label: '回归年长度 (tropicalYear)',
                helper: '默认 365.2425',
                controller: tropicalYearController,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _intRow(_EpochFieldSpec spec) {
    final c = controllers[spec.field]!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        key: Key('epoch_${spec.field}_input'),
        controller: c,
        enabled: !readOnly,
        keyboardType: const TextInputType.numberWithOptions(signed: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
        ],
        decoration: InputDecoration(
          labelText: spec.label,
          helperText: spec.helper,
          border: const OutlineInputBorder(),
        ),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return '不能为空';
          if (int.tryParse(v.trim()) == null) return '必须为整数';
          return null;
        },
      ),
    );
  }

  Widget _doubleRow({
    required String key,
    required String label,
    required String helper,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: TextFormField(
        key: Key('epoch_${key}_input'),
        controller: controller,
        enabled: !readOnly,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
        ],
        decoration: InputDecoration(
          labelText: label,
          helperText: helper,
          border: const OutlineInputBorder(),
        ),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return '不能为空';
          if (double.tryParse(v.trim()) == null) return '必须为数字';
          return null;
        },
      ),
    );
  }
}

class _EpochFieldSpec {
  final String field;
  final String label;
  final String helper;
  const _EpochFieldSpec(this.field, this.label, this.helper);
}

/// Section: Algorithm rules - palace formula (主算/客算/定算 base), wenChang, jiShen, eight door
class AlgorithmSection extends StatelessWidget {
  final String palaceFormula;
  final bool wenChangStayRule;
  final bool useTwelveJiShen;
  final String eightDoorMode;
  final ValueChanged<String> onPalaceFormulaChanged;
  final ValueChanged<bool> onWenChangChanged;
  final ValueChanged<bool> onJiShenChanged;
  final ValueChanged<String> onEightDoorChanged;
  final bool readOnly;

  static const palaceFormulaOptions = <String>['jingMirror', 'tongZong', 'jiCheng', 'custom'];
  static const eightDoorOptions = <String>['dynamic', 'static', 'fixed'];

  const AlgorithmSection({
    super.key,
    required this.palaceFormula,
    required this.wenChangStayRule,
    required this.useTwelveJiShen,
    required this.eightDoorMode,
    required this.onPalaceFormulaChanged,
    required this.onWenChangChanged,
    required this.onJiShenChanged,
    required this.onEightDoorChanged,
    required this.readOnly,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ChineseSectionHeader(title: '主算 / 客算 / 定算 + 文昌 / 计神 / 八门'),
        InkyBorder(
          padding: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // palaceFormula -> drives 主算/客算/定算 base
              DropdownButtonFormField<String>(
                key: const Key('palace_formula_dropdown'),
                value: palaceFormulaOptions.contains(palaceFormula)
                    ? palaceFormula
                    : 'custom',
                items: [
                  for (final v in palaceFormulaOptions)
                    DropdownMenuItem(value: v, child: Text(_palaceLabel(v))),
                ],
                onChanged:
                    readOnly ? null : (v) => onPalaceFormulaChanged(v ?? 'jingMirror'),
                decoration: const InputDecoration(
                  labelText: 'palaceFormula (主/客/定算基准)',
                  helperText: '决定主算/客算/定算的宫位起点公式',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // 文昌规则
              SwitchListTile(
                key: const Key('wenchang_switch'),
                title: const Text('文昌停留规则 (wenChangStayRule)'),
                subtitle: const Text('启用文昌在本宫停留 / 关闭则按通用规则推进'),
                value: wenChangStayRule,
                onChanged: readOnly ? null : onWenChangChanged,
              ),
              const Divider(),
              // 计神规则
              SwitchListTile(
                key: const Key('jishen_switch'),
                title: const Text('计神十二将 (useTwelveJiShen)'),
                subtitle: const Text('启用十二计神 / 关闭则用经典计神'),
                value: useTwelveJiShen,
                onChanged: readOnly ? null : onJiShenChanged,
              ),
              const Divider(),
              // 八门模式
              DropdownButtonFormField<String>(
                key: const Key('eight_door_dropdown'),
                value: eightDoorOptions.contains(eightDoorMode)
                    ? eightDoorMode
                    : eightDoorMode,
                items: [
                  for (final v in eightDoorOptions)
                    DropdownMenuItem(value: v, child: Text(_eightDoorLabel(v))),
                  if (!eightDoorOptions.contains(eightDoorMode))
                    DropdownMenuItem(
                      value: eightDoorMode,
                      child: Text('自定义: $eightDoorMode'),
                    ),
                ],
                onChanged: readOnly
                    ? null
                    : (v) => onEightDoorChanged(v ?? 'dynamic'),
                decoration: const InputDecoration(
                  labelText: 'eightDoorMode (八门模式)',
                  helperText: 'dynamic = 跟随太乙宫;static = 固定;fixed = 按局数',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _palaceLabel(String v) {
    switch (v) {
      case 'jingMirror':
        return 'jingMirror (金镜派 主客算)';
      case 'tongZong':
        return 'tongZong (统宗派 主客算)';
      case 'jiCheng':
        return 'jiCheng (集成派 主客算)';
      case 'custom':
        return 'custom (自定义)';
      default:
        return v;
    }
  }

  String _eightDoorLabel(String v) {
    switch (v) {
      case 'dynamic':
        return 'dynamic (动态八门)';
      case 'static':
        return 'static (静态八门)';
      case 'fixed':
        return 'fixed (固定八门)';
      default:
        return v;
    }
  }
}

/// Section: Preserved metadata (read-only summary — must NOT be lost on save)
/// Shows chartConfigs / deityIds / deityConfigs / privateDeities / overrides
class PreservedMetadataSection extends StatelessWidget {
  final List<String> deityIds;
  final Map<String, ChartConfig> chartConfigs;
  final Map<String, DeityOverride> deityConfigs;
  final List<String> privateDeities;
  final Map<String, dynamic>? overrides;

  const PreservedMetadataSection({
    super.key,
    required this.deityIds,
    required this.chartConfigs,
    required this.deityConfigs,
    required this.privateDeities,
    required this.overrides,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChineseSectionHeader(title: AppLocalizations.of(context)!.keepMetadata),
        InkyBorder(
          padding: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _summaryTile(
                key: 'deity_ids_summary',
                icon: Icons.star_outline,
                label: 'deityIds',
                value: '${deityIds.length} 个星神',
                detail: deityIds.isEmpty
                    ? '(无)'
                    : deityIds.take(8).join(', ') +
                        (deityIds.length > 8 ? ' …' : ''),
              ),
              _summaryTile(
                key: 'chart_configs_summary',
                icon: Icons.grid_view,
                label: 'chartConfigs',
                value: '${chartConfigs.length} 项盘别配置',
                detail: chartConfigs.keys.isEmpty
                    ? '(无)'
                    : chartConfigs.keys.join(', '),
              ),
              _summaryTile(
                key: 'deity_configs_summary',
                icon: Icons.tune,
                label: 'deityConfigs',
                value: '${deityConfigs.length} 项星神覆盖',
                detail: deityConfigs.keys.isEmpty
                    ? '(无)'
                    : deityConfigs.keys.take(6).join(', ') +
                        (deityConfigs.length > 6 ? ' …' : ''),
              ),
              _summaryTile(
                key: 'private_deities_summary',
                icon: Icons.lock_outline,
                label: 'privateDeities',
                value: '${privateDeities.length} 个私有星神',
                detail: privateDeities.isEmpty
                    ? '(无)'
                    : privateDeities.join(', '),
              ),
              _summaryTile(
                key: 'overrides_summary',
                icon: Icons.layers_outlined,
                label: 'overrides',
                value: overrides == null
                    ? '(无)'
                    : '${overrides!.length} 项覆盖',
                detail: overrides == null || overrides!.isEmpty
                    ? '(无)'
                    : overrides!.keys.take(6).join(', ') +
                        (overrides!.length > 6 ? ' …' : ''),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: TaiYiClassicTheme.paleGold.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline,
                        size: 18, color: TaiYiClassicTheme.darkWood),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '提示:此页面只编辑流派元数据。'
                        '星神配置请前往「我的星神」编辑器。'
                        '保存时这些字段会被原样保留,不会丢失。',
                        style: TextStyle(
                          fontSize: 12,
                          color: TaiYiClassicTheme.darkWood,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryTile({
    required String key,
    required IconData icon,
    required String label,
    required String value,
    required String detail,
  }) {
    return Padding(
      key: Key(key),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: TaiYiClassicTheme.inkWash),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: TaiYiClassicTheme.inkBlack,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 12,
                        color: TaiYiClassicTheme.inkWash,
                      ),
                    ),
                  ],
                ),
                if (detail.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      detail,
                      style: const TextStyle(
                        fontSize: 11,
                        color: TaiYiClassicTheme.mediumWood,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
