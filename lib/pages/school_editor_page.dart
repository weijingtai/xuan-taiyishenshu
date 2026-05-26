import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../taiyi/core/school_config.dart';
import '../taiyi/viewmodels/school_view_model.dart';
import '../theme/taiyi_classic_theme.dart';
import '../widgets/school_editor/school_editor_sections.dart';

/// Arguments for the school editor route.
class SchoolEditorArgs {
  /// id of the school to edit. If null, an empty editor opens (not currently used).
  final String schoolId;

  /// 'view' (read-only) or 'edit' (writable).
  /// Official schools always open in 'view' mode regardless.
  final String mode;

  const SchoolEditorArgs({required this.schoolId, this.mode = 'edit'});
}

/// School editor page. Covers full TaiYiSchool metadata. Saves via
/// SchoolViewModel.saveSchool (-> SaveUserSchoolUseCase -> Drift).
///
/// Save strategy: builds the next school via [TaiYiSchool.copyWith] on the
/// original loaded object so that ALL non-edited fields (deityIds,
/// chartConfigs, deityConfigs, privateDeities, overrides, sourceId,
/// rootOfficialId, lineage, …) are preserved verbatim.
class SchoolEditorPage extends StatefulWidget {
  final SchoolEditorArgs args;

  /// Optional: directly pass the school (used by tests / from list page).
  final TaiYiSchool? initialSchool;

  const SchoolEditorPage({
    super.key,
    required this.args,
    this.initialSchool,
  });

  @override
  State<SchoolEditorPage> createState() => _SchoolEditorPageState();
}

class _SchoolEditorPageState extends State<SchoolEditorPage> {
  final _formKey = GlobalKey<FormState>();
  late TaiYiSchool _original;
  bool _loaded = false;
  String? _loadError;

  // Identity
  late TextEditingController _nameController;

  // Epoch fields
  late Map<String, TextEditingController> _epochControllers;
  late TextEditingController _tropicalYearController;

  // Algorithm state
  late String _palaceFormula;
  late bool _wenChangStayRule;
  late bool _useTwelveJiShen;
  late String _eightDoorMode;

  bool _saving = false;
  String? _saveError;

  bool get _isOfficial => _original.source == 'official';
  bool get _readOnly => _isOfficial || widget.args.mode == 'view';

  @override
  void initState() {
    super.initState();
    if (widget.initialSchool != null) {
      _bootstrap(widget.initialSchool!);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadFromViewModel());
    }
  }

  Future<void> _loadFromViewModel() async {
    final vm = context.read<SchoolViewModel>();
    if (vm.schools.isEmpty) {
      await vm.loadSchools();
    }
    if (!mounted) return;
    try {
      final school =
          vm.schools.firstWhere((s) => s.id == widget.args.schoolId);
      _bootstrap(school);
    } catch (_) {
      setState(() {
        _loadError = '未找到流派: ${widget.args.schoolId}';
        _loaded = true;
      });
    }
  }

  void _bootstrap(TaiYiSchool school) {
    _original = school;
    _nameController = TextEditingController(text: school.name);
    _epochControllers = {
      'ancientBase':
          TextEditingController(text: school.epoch.ancientBase.toString()),
      'epochYear':
          TextEditingController(text: school.epoch.epochYear.toString()),
      'correction':
          TextEditingController(text: school.epoch.correction.toString()),
      'ancientMonthBase':
          TextEditingController(text: school.epoch.ancientMonthBase.toString()),
      'ancientDayBase':
          TextEditingController(text: school.epoch.ancientDayBase.toString()),
      'ancientHourBase':
          TextEditingController(text: school.epoch.ancientHourBase.toString()),
      'zhangSui': TextEditingController(text: school.epoch.zhangSui.toString()),
      'zhangYue': TextEditingController(text: school.epoch.zhangYue.toString()),
      'dayOffset':
          TextEditingController(text: school.epoch.dayOffset.toString()),
      'hourOffset':
          TextEditingController(text: school.epoch.hourOffset.toString()),
    };
    _tropicalYearController =
        TextEditingController(text: school.epoch.tropicalYear.toString());
    _palaceFormula = school.palaceFormula;
    _wenChangStayRule = school.wenChangStayRule;
    _useTwelveJiShen = school.useTwelveJiShen;
    _eightDoorMode = school.eightDoorMode;
    setState(() {
      _loaded = true;
    });
  }

  @override
  void dispose() {
    if (_loaded && _loadError == null) {
      _nameController.dispose();
      for (final c in _epochControllers.values) {
        c.dispose();
      }
      _tropicalYearController.dispose();
    }
    super.dispose();
  }

  /// Build the updated TaiYiSchool via copyWith on the original — this is the
  /// key reason metadata is not lost: ALL fields that the editor does not
  /// touch are preserved by copyWith returning `field ?? this.field`.
  TaiYiSchool _buildUpdatedSchool() {
    final updatedEpoch = _original.epoch.copyWith(
      ancientBase: int.parse(_epochControllers['ancientBase']!.text.trim()),
      epochYear: int.parse(_epochControllers['epochYear']!.text.trim()),
      correction: int.parse(_epochControllers['correction']!.text.trim()),
      tropicalYear: double.parse(_tropicalYearController.text.trim()),
      ancientMonthBase:
          int.parse(_epochControllers['ancientMonthBase']!.text.trim()),
      ancientDayBase:
          int.parse(_epochControllers['ancientDayBase']!.text.trim()),
      ancientHourBase:
          int.parse(_epochControllers['ancientHourBase']!.text.trim()),
      zhangSui: int.parse(_epochControllers['zhangSui']!.text.trim()),
      zhangYue: int.parse(_epochControllers['zhangYue']!.text.trim()),
      dayOffset: int.parse(_epochControllers['dayOffset']!.text.trim()),
      hourOffset: int.parse(_epochControllers['hourOffset']!.text.trim()),
    );

    // Preserve EVERY non-edited field by relying on copyWith semantics.
    // deityIds / chartConfigs / deityConfigs / privateDeities / overrides /
    // sourceId / rootOfficialId / lineage are intentionally NOT passed.
    return _original.copyWith(
      name: _nameController.text.trim(),
      epoch: updatedEpoch,
      palaceFormula: _palaceFormula,
      wenChangStayRule: _wenChangStayRule,
      useTwelveJiShen: _useTwelveJiShen,
      eightDoorMode: _eightDoorMode,
    );
  }

  Future<void> _onSavePressed() async {
    if (_readOnly) return;
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    setState(() {
      _saving = true;
      _saveError = null;
    });
    try {
      final updated = _buildUpdatedSchool();
      await context.read<SchoolViewModel>().saveSchool(updated);
      // After successful save, refresh original snapshot so further edits
      // continue to preserve fields.
      _original = updated;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存成功')),
      );
    } catch (e) {
      setState(() => _saveError = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _onCopyAndEdit() async {
    final vm = context.read<SchoolViewModel>();
    final sourceId = _original.id;
    final ts = DateTime.now().millisecondsSinceEpoch;
    final newId = 'user_${sourceId}_$ts';
    final newName = '${_original.name}副本';

    setState(() => _saving = true);
    try {
      await vm.copySchool(
          sourceId: sourceId, newId: newId, newName: newName);
      // Switch editor to the new copy in edit mode.
      final copy = vm.schools.firstWhere((s) => s.id == newId);
      // Dispose old controllers and rebuild from new school.
      _nameController.dispose();
      for (final c in _epochControllers.values) {
        c.dispose();
      }
      _tropicalYearController.dispose();
      _bootstrap(copy);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已复制为「$newName」,可以开始编辑')),
      );
    } catch (e) {
      setState(() => _saveError = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return Scaffold(
        backgroundColor: TaiYiClassicTheme.ricePaper,
        appBar: AppBar(
          backgroundColor: TaiYiClassicTheme.darkWood,
          foregroundColor: TaiYiClassicTheme.paleGold,
          title: const Text('流派编辑器'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        backgroundColor: TaiYiClassicTheme.ricePaper,
        appBar: AppBar(
          backgroundColor: TaiYiClassicTheme.darkWood,
          foregroundColor: TaiYiClassicTheme.paleGold,
          title: const Text('流派编辑器'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _loadError!,
              key: const Key('load_error'),
              style: const TextStyle(color: TaiYiClassicTheme.cinnabar),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: TaiYiClassicTheme.ricePaper,
      appBar: AppBar(
        backgroundColor: TaiYiClassicTheme.darkWood,
        foregroundColor: TaiYiClassicTheme.paleGold,
        title: Text(
          _readOnly ? '查看流派 · ${_original.name}' : '编辑流派 · ${_original.name}',
        ),
        actions: [
          if (!_readOnly)
            IconButton(
              key: const Key('save_button'),
              icon: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation(TaiYiClassicTheme.paleGold),
                      ),
                    )
                  : const Icon(Icons.save),
              onPressed: _saving ? null : _onSavePressed,
              tooltip: '保存',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            if (_isOfficial)
              OfficialReadOnlyBanner(onCopyAndEdit: _onCopyAndEdit),
            if (_saveError != null)
              Container(
                key: const Key('save_error_banner'),
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: TaiYiClassicTheme.cinnabar.withOpacity(0.1),
                  border: Border.all(color: TaiYiClassicTheme.cinnabar),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '保存失败: $_saveError',
                  style: const TextStyle(color: TaiYiClassicTheme.cinnabar),
                ),
              ),
            IdentitySection(
              nameController: _nameController,
              id: _original.id,
              source: _original.source,
              sourceId: _original.sourceId,
              rootOfficialId: _original.rootOfficialId,
              lineage: _original.lineage,
              readOnly: _readOnly,
            ),
            const SizedBox(height: 16),
            EpochSection(
              controllers: _epochControllers,
              tropicalYearController: _tropicalYearController,
              readOnly: _readOnly,
            ),
            const SizedBox(height: 16),
            AlgorithmSection(
              palaceFormula: _palaceFormula,
              wenChangStayRule: _wenChangStayRule,
              useTwelveJiShen: _useTwelveJiShen,
              eightDoorMode: _eightDoorMode,
              onPalaceFormulaChanged: (v) =>
                  setState(() => _palaceFormula = v),
              onWenChangChanged: (v) => setState(() => _wenChangStayRule = v),
              onJiShenChanged: (v) => setState(() => _useTwelveJiShen = v),
              onEightDoorChanged: (v) => setState(() => _eightDoorMode = v),
              readOnly: _readOnly,
            ),
            const SizedBox(height: 16),
            PreservedMetadataSection(
              deityIds: _original.deityIds,
              chartConfigs: _original.chartConfigs,
              deityConfigs: _original.deityConfigs,
              privateDeities: _original.privateDeities,
              overrides: _original.overrides,
            ),
            const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
