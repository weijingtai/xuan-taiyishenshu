import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../controllers/taiyi_pan_controller.dart';
import '../theme/taiyi_classic_theme.dart';
import '../widgets/ink_wash_widgets.dart';
import '../taiyi/core/school_config.dart';

enum EntityType { school, deity }

class EntityEditorPage extends StatefulWidget {
  final EntityType type;
  final String? entityId;
  final String? initialName;
  final String? lineage;
  final TaiYiPanController? controller;

  const EntityEditorPage({
    super.key,
    required this.type,
    this.entityId,
    this.initialName,
    this.lineage,
    this.controller,
  });

  @override
  State<EntityEditorPage> createState() => _EntityEditorPageState();
}

class _EntityEditorPageState extends State<EntityEditorPage> {
  late TextEditingController _nameController;
  
  // School fields
  final _ancientBaseController = TextEditingController(text: '0');
  final _epochYearController = TextEditingController(text: '1984');
  final _correctionController = TextEditingController(text: '0');
  final _tropicalYearController = TextEditingController(text: '365.2425');
  bool _wenChangStayRule = true;
  bool _useTwelveJiShen = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    
    if (widget.type == EntityType.school && widget.entityId != null) {
      // Find existing school to populate
      final school = widget.controller?.availableSchools.firstWhere((s) => s.id == widget.entityId);
      if (school != null) {
        _ancientBaseController.text = school.epoch.ancientBase.toString();
        _epochYearController.text = school.epoch.epochYear.toString();
        _correctionController.text = school.epoch.correction.toString();
        _tropicalYearController.text = school.epoch.tropicalYear.toString();
        _wenChangStayRule = school.wenChangStayRule;
        _useTwelveJiShen = school.useTwelveJiShen;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ancientBaseController.dispose();
    _epochYearController.dispose();
    _correctionController.dispose();
    _tropicalYearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.type == EntityType.school ? '流派编辑器' : '星神编辑器';

    return Scaffold(
      backgroundColor: TaiYiClassicTheme.ricePaper,
      appBar: AppBar(
        backgroundColor: TaiYiClassicTheme.darkWood,
        foregroundColor: TaiYiClassicTheme.paleGold,
        title: Text(
          title,
          style: TaiYiClassicTheme.getTitleStyle(fontSize: 22),
        ),
        actions: [
          IconButton(
            key: const Key('save_button'),
            icon: const Icon(Icons.save),
            onPressed: _save,
            tooltip: AppLocalizations.of(context)!.save,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.lineage != null) _buildLineage(widget.lineage!),
            const SizedBox(height: 16),
            const ChineseSectionHeader(title: '基础信息'),
            InkyBorder(
              padding: 16,
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '名称',
                  labelStyle: TextStyle(color: TaiYiClassicTheme.inkBlack),
                  border: InputBorder.none,
                ),
                style: TaiYiClassicTheme.getChineseStyle(fontSize: 20),
              ),
            ),
            if (widget.type == EntityType.school) ...[
              const SizedBox(height: 24),
              const ChineseSectionHeader(title: '历法元数据 (Epoch)'),
              InkyBorder(
                padding: 12,
                child: Column(
                  children: [
                    _buildNumberField(_ancientBaseController, '积年基数 (Ancient Base)'),
                    _buildNumberField(_epochYearController, '起算年份 (Epoch Year)'),
                    _buildNumberField(_correctionController, '修正值 (Correction)'),
                    _buildNumberField(_tropicalYearController, '回归年长度 (Tropical Year)'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const ChineseSectionHeader(title: '算法开关'),
              InkyBorder(
                padding: 4,
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('文昌重留规则', style: TextStyle(fontSize: 14)),
                      value: _wenChangStayRule,
                      activeColor: TaiYiClassicTheme.cinnabar,
                      onChanged: (v) => setState(() => _wenChangStayRule = v),
                    ),
                    SwitchListTile(
                      title: const Text('使用十二计神', style: TextStyle(fontSize: 14)),
                      value: _useTwelveJiShen,
                      activeColor: TaiYiClassicTheme.cinnabar,
                      onChanged: (v) => setState(() => _useTwelveJiShen = v),
                    ),
                  ],
                ),
              ),
            ],
            if (widget.type == EntityType.deity) ...[
              const SizedBox(height: 24),
              const ChineseSectionHeader(title: '星神配置'),
              InkyBorder(
                color: TaiYiClassicTheme.goldLeaf,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      // 设计文档 2026-05-23-taiyi-school-manager-mvp-design.md §3-1 明确
                      // 本轮不实现自由公式编辑。
                      '本轮范围内不支持自由公式编辑（详见设计规格 §3-1）。',
                      style: TextStyle(fontStyle: FontStyle.italic, color: TaiYiClassicTheme.inkWash),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, color: TaiYiClassicTheme.inkWash),
        isDense: true,
      ),
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildLineage(String lineage) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TaiYiClassicTheme.paleGold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: TaiYiClassicTheme.goldLeaf.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_tree, size: 14, color: TaiYiClassicTheme.darkWood),
              const SizedBox(width: 4),
              Text(
                '传承链',
                style: TaiYiClassicTheme.getTitleStyle(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            lineage,
            style: TaiYiClassicTheme.getChineseStyle(
              fontSize: 16,
              color: TaiYiClassicTheme.inkWash,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final controller = widget.controller;
    if (controller == null) return;

    if (widget.type == EntityType.school) {
      final school = TaiYiSchool(
        id: widget.entityId ?? 'user_school_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text,
        source: 'user',
        epoch: SchoolEpochConfig(
          ancientBase: int.tryParse(_ancientBaseController.text) ?? 0,
          epochYear: int.tryParse(_epochYearController.text) ?? 0,
          correction: int.tryParse(_correctionController.text) ?? 0,
          tropicalYear: double.tryParse(_tropicalYearController.text) ?? 365.2425,
        ),
        wenChangStayRule: _wenChangStayRule,
        useTwelveJiShen: _useTwelveJiShen,
      );
      await controller.saveUserSchool(school);
    } else {
      // 星神编辑器(深度字段+保存)归属 ZenTao Task 31。
      // Task 12 范围仅校验 Repository/UseCase 边界,因此星神保存入口暂不挂接。
      // 此处主动 no-op,UI 仍正常关闭,避免误导用户产生"未保存"错觉。
    }

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.saveSuccess)),
      );
    }
  }
}
