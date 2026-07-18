import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../enums/deity_kind.dart';
import '../taiyi/core/algorithm_enums.dart';
import '../taiyi/core/deity_definition.dart';
import '../taiyi/core/school_config.dart';
import '../taiyi/viewmodels/deity_view_model.dart';
import '../taiyi/viewmodels/school_view_model.dart';
import '../theme/taiyi_classic_theme.dart';
import '../widgets/ink_wash_widgets.dart';

/// Arguments passed into the deity editor route.
///
/// When [deity] is null, the editor opens in "new user deity" mode.
/// When [deity] is non-null and [deity.source == 'official'], the editor opens
/// in read-only mode with a banner explaining that official deities cannot be
/// modified in place; the user must use "Copy and edit".
class DeityEditorArgs {
  final DeityDefinition? deity;

  /// When true, after a successful save the editor will pop with the saved
  /// deity. The caller (e.g. dialog or list page) is expected to be a
  /// `ChangeNotifierProvider<DeityViewModel>` ancestor so save can route
  /// through the real ViewModel -> UseCase -> Drift Repository chain.
  final bool popOnSave;

  const DeityEditorArgs({this.deity, this.popOnSave = true});
}

class DeityEditorPage extends StatefulWidget {
  /// Optional [deity] to edit. If null, a new blank user deity will be created.
  final DeityDefinition? deity;

  /// Optional list of all schools used to populate the "applicable schools"
  /// chips. If null, the page will read [SchoolViewModel.schools] from the
  /// nearest Provider (which is the production wiring).
  final List<TaiYiSchool>? availableSchools;

  /// Override clock for tests so generated user deity ids are deterministic.
  final DateTime Function()? now;

  const DeityEditorPage({
    super.key,
    this.deity,
    this.availableSchools,
    this.now,
  });

  /// Route name expected by Master Agent. The Master Agent owns
  /// `lib/navigator.dart` and is responsible for wiring this name in the
  /// MaterialApp `onGenerateRoute`/`routes` table.
  static const String routeName = '/taiyishenshu/deity-editor';

  @override
  State<DeityEditorPage> createState() => _DeityEditorPageState();
}

class _DeityEditorPageState extends State<DeityEditorPage> {
  // --- form state ----------------------------------------------------------
  late TextEditingController _nameController;
  late TextEditingController _colorHexController;
  String? _displayStyle;
  late Set<String> _selectedSchoolIds;
  late Set<String> _selectedChartTypes;
  Color _pickedColor = const Color(0xFFC23B22); // cinnabar default
  bool _saving = false;

  /// The deity currently bound to the form. Mutated when the user taps
  /// "Copy and edit" on an official deity (replaces the read-only form with
  /// a freshly persisted user copy).
  DeityDefinition? _editing;

  // --- field metadata ------------------------------------------------------

  static const List<String> _displayStyleOptions = <String>[
    'classical',
    'modern',
    'ink_wash',
    'cinnabar_seal',
    'gold_leaf',
  ];

  static const Map<String, String> _displayStyleLabels = <String, String>{
    'classical': '古典',
    'modern': '现代',
    'ink_wash': '水墨',
    'cinnabar_seal': '朱印',
    'gold_leaf': '金箔',
  };

  /// Chart types selectable in this editor. `ke` is the only reserved
  /// placeholder allowed by the product spec.
  static const List<String> _chartTypeOptions = <String>[
    'year',
    'month',
    'day',
    'hour',
    'ke',
  ];

  static const Map<String, String> _chartTypeLabels = <String, String>{
    'year': '年家',
    'month': '月家',
    'day': '日家',
    'hour': '时家',
    'ke': '刻家（预留）',
  };

  // --- lifecycle -----------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _editing = widget.deity;
    _hydrateFromDeity(widget.deity);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _colorHexController.dispose();
    super.dispose();
  }

  /// Populate every form field from a deity (or sensible blank defaults).
  /// Called on init and after "Copy and edit" replaces the bound deity.
  void _hydrateFromDeity(DeityDefinition? deity) {
    _nameController = TextEditingController(text: deity?.name ?? '');
    final initialColor = deity?.color ?? '#C23B22';
    _colorHexController = TextEditingController(text: initialColor);
    _pickedColor = _parseHex(initialColor) ?? const Color(0xFFC23B22);
    _displayStyle = deity?.displayStyle;
    _selectedSchoolIds = <String>{...(deity?.schoolScopes ?? const <String>[])};
    _selectedChartTypes = <String>{...(deity?.chartTypes ?? const <String>[])};
  }

  // --- color helpers -------------------------------------------------------

  Color? _parseHex(String value) {
    final raw = value.replaceAll('#', '').trim();
    if (raw.length != 6 && raw.length != 8) return null;
    final hex = raw.length == 6 ? 'FF$raw' : raw;
    final parsed = int.tryParse(hex, radix: 16);
    if (parsed == null) return null;
    return Color(parsed);
  }

  String _formatHex(Color c) {
    final value = c.toARGB32() & 0x00FFFFFF;
    return '#${value.toRadixString(16).toUpperCase().padLeft(6, '0')}';
  }

  // --- derived helpers -----------------------------------------------------

  bool get _isOfficialReadOnly =>
      _editing != null && _editing!.source == 'official';

  bool get _isNew => _editing == null;

  String _generateUserDeityId() {
    final now = (widget.now ?? DateTime.now).call();
    return 'user_deity_${now.millisecondsSinceEpoch}';
  }

  List<TaiYiSchool> _resolveSchools() {
    if (widget.availableSchools != null) return widget.availableSchools!;
    final schoolVM = _readSchoolVM();
    return schoolVM?.schools ?? const <TaiYiSchool>[];
  }

  DeityViewModel? _readDeityVM() {
    try {
      return Provider.of<DeityViewModel>(context, listen: false);
    } on ProviderNotFoundException {
      return null;
    }
  }

  SchoolViewModel? _readSchoolVM() {
    try {
      return Provider.of<SchoolViewModel>(context, listen: false);
    } on ProviderNotFoundException {
      return null;
    }
  }

  // --- save / copy ---------------------------------------------------------

  /// Persist the in-memory form to a user deity through the real
  /// ViewModel -> UseCase -> Drift Repository chain. Never short-circuits
  /// to a SnackBar without a write.
  Future<void> _onSavePressed() async {
    if (_isOfficialReadOnly) {
      // Official deities are immutable from this editor. The Save button is
      // disabled in this mode, but guard defensively.
      return;
    }
    final vm = _readDeityVM();
    if (vm == null) {
      _showError('保存失败：未找到 DeityViewModel');
      return;
    }
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showError('请填写星神名称');
      return;
    }

    setState(() => _saving = true);
    try {
      final base = _editing ??
          DeityDefinition(
            id: _generateUserDeityId(),
            name: name,
            layer: _inferLayerForNew(),
            algorithm: const DeityAlgorithmSpec(
              templateId: _defaultTemplateForNew,
            ),
            source: 'user',
          );

      final updated = base.copyWith(
        name: name,
        source: 'user',
        color: _formatHex(_pickedColor),
        displayStyle: _displayStyle,
        schoolScopes: _selectedSchoolIds.toList(),
        chartTypes: _selectedChartTypes.toList(),
      );

      await vm.saveDeity(updated);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.saveSuccess)),
      );
      Navigator.of(context).pop(updated);
    } catch (e) {
      _showError('保存失败：$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Copy an official deity into a fresh user-owned derivative and replace
  /// the current form with the new editable record.
  Future<void> _onCopyAndEditPressed() async {
    final source = _editing;
    if (source == null) return;
    final vm = _readDeityVM();
    if (vm == null) {
      _showError('复制失败：未找到 DeityViewModel');
      return;
    }

    setState(() => _saving = true);
    try {
      final newId = _generateUserDeityId();
      await vm.copyDeity(
        sourceId: source.id,
        newId: newId,
        newName: '${source.name}副本',
      );

      // The UseCase has persisted the copy; pull it back through the
      // ViewModel-refreshed list to get the canonical record (with lineage).
      final copy = vm.deities.firstWhere(
        (d) => d.id == newId,
        orElse: () => source,
      );

      if (!mounted) return;
      setState(() {
        _editing = copy;
        _hydrateFromDeity(copy);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.copiedAsMyDeity(copy.name))),
      );
    } catch (e) {
      _showError('复制失败：$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // --- defaults for "new" mode --------------------------------------------

  /// When the editor is opened to create a brand-new user deity, we default
  /// the layer/algorithm to safe placeholders. Real algorithm editing lives
  /// in the algorithm sub-editor (out of scope for this task).
  EnumDeityLayer _inferLayerForNew() => EnumDeityLayer.tianPan;

  static const AlgorithmTemplateId _defaultTemplateForNew =
      AlgorithmTemplateId.fixedPosition;

  // --- build ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final readOnly = _isOfficialReadOnly;
    final schools = _resolveSchools();

    return Scaffold(
      backgroundColor: TaiYiClassicTheme.ricePaper,
      appBar: AppBar(
        backgroundColor: TaiYiClassicTheme.darkWood,
        foregroundColor: TaiYiClassicTheme.paleGold,
        title: Text(
          _isNew ? '新建星神' : '星神编辑器',
          style: TaiYiClassicTheme.getTitleStyle(fontSize: 22),
        ),
        actions: <Widget>[
          IconButton(
            key: const Key('deity_editor_save_button'),
            tooltip: AppLocalizations.of(context)!.save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        TaiYiClassicTheme.paleGold,
                      ),
                    ),
                  )
                : const Icon(Icons.save),
            onPressed: (_saving || readOnly) ? null : _onSavePressed,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (readOnly) _OfficialReadOnlyBanner(
              onCopyAndEdit: _saving ? null : _onCopyAndEditPressed,
            ),
            if (readOnly) const SizedBox(height: 16),
            const ChineseSectionHeader(title: '基础信息'),
            _BasicInfoSection(
              nameController: _nameController,
              readOnly: readOnly,
            ),
            const SizedBox(height: 24),
            const ChineseSectionHeader(title: '显示样式'),
            _DisplayStyleSection(
              colorHexController: _colorHexController,
              pickedColor: _pickedColor,
              onColorChanged: readOnly
                  ? null
                  : (c) => setState(() {
                        _pickedColor = c;
                        _colorHexController.text = _formatHex(c);
                      }),
              onHexCommitted: readOnly
                  ? null
                  : (hex) {
                      final parsed = _parseHex(hex);
                      if (parsed != null) {
                        setState(() => _pickedColor = parsed);
                      }
                    },
              displayStyle: _displayStyle,
              styleOptions: _displayStyleOptions,
              styleLabels: _displayStyleLabels,
              onStyleChanged: readOnly
                  ? null
                  : (v) => setState(() => _displayStyle = v),
              readOnly: readOnly,
            ),
            const SizedBox(height: 24),
            const ChineseSectionHeader(title: '适用流派'),
            _SchoolScopeSection(
              schools: schools,
              selected: _selectedSchoolIds,
              onToggle: readOnly
                  ? null
                  : (id) => setState(() {
                        if (_selectedSchoolIds.contains(id)) {
                          _selectedSchoolIds.remove(id);
                        } else {
                          _selectedSchoolIds.add(id);
                        }
                      }),
              readOnly: readOnly,
            ),
            const SizedBox(height: 24),
            const ChineseSectionHeader(title: '适用盘型'),
            _ChartTypeSection(
              options: _chartTypeOptions,
              labels: _chartTypeLabels,
              selected: _selectedChartTypes,
              onToggle: readOnly
                  ? null
                  : (id) => setState(() {
                        if (_selectedChartTypes.contains(id)) {
                          _selectedChartTypes.remove(id);
                        } else {
                          _selectedChartTypes.add(id);
                        }
                      }),
              readOnly: readOnly,
            ),
            const SizedBox(height: 24),
            const ChineseSectionHeader(title: '传承链'),
            _LineageSection(deity: _editing),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// Private subwidgets
// =====================================================================

class _OfficialReadOnlyBanner extends StatelessWidget {
  final VoidCallback? onCopyAndEdit;
  const _OfficialReadOnlyBanner({required this.onCopyAndEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('deity_editor_readonly_banner'),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TaiYiClassicTheme.paleGold.withValues(alpha: 0.25),
        border: Border.all(
          color: TaiYiClassicTheme.goldLeaf.withValues(alpha: 0.6),
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.lock_outline,
              size: 18, color: TaiYiClassicTheme.darkWood),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '这是官方星神，只能查看。',
                  style: TaiYiClassicTheme.getTitleStyle(
                    fontSize: 15,
                    color: TaiYiClassicTheme.darkWood,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '若需修改请先复制为我的星神。复制后会自动生成传承链。',
                  style: TextStyle(
                    fontSize: 13,
                    color: TaiYiClassicTheme.inkWash,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 36,
                  child: TextButton.icon(
                    key: const Key('deity_editor_copy_and_edit_button'),
                    style: TextButton.styleFrom(
                      backgroundColor: TaiYiClassicTheme.cinnabar,
                      foregroundColor: TaiYiClassicTheme.paleGold,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    onPressed: onCopyAndEdit,
                    icon: const Icon(Icons.copy, size: 16),
                    label: Text(AppLocalizations.of(context)!.copyAndEdit),
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

class _BasicInfoSection extends StatelessWidget {
  final TextEditingController nameController;
  final bool readOnly;
  const _BasicInfoSection({
    required this.nameController,
    required this.readOnly,
  });

  @override
  Widget build(BuildContext context) {
    return InkyBorder(
      padding: 16,
      child: TextField(
        key: const Key('deity_editor_name_field'),
        controller: nameController,
        readOnly: readOnly,
        enabled: !readOnly,
        decoration: const InputDecoration(
          labelText: '名称',
          labelStyle: TextStyle(color: TaiYiClassicTheme.inkBlack),
          border: InputBorder.none,
        ),
        style: TaiYiClassicTheme.getChineseStyle(fontSize: 20),
      ),
    );
  }
}

class _DisplayStyleSection extends StatelessWidget {
  final TextEditingController colorHexController;
  final Color pickedColor;
  final ValueChanged<Color>? onColorChanged;
  final ValueChanged<String>? onHexCommitted;
  final String? displayStyle;
  final List<String> styleOptions;
  final Map<String, String> styleLabels;
  final ValueChanged<String?>? onStyleChanged;
  final bool readOnly;

  const _DisplayStyleSection({
    required this.colorHexController,
    required this.pickedColor,
    required this.onColorChanged,
    required this.onHexCommitted,
    required this.displayStyle,
    required this.styleOptions,
    required this.styleLabels,
    required this.onStyleChanged,
    required this.readOnly,
  });

  // Curated palette aligned with the classical ink-wash theme so users land
  // on on-brand picks even without a full color picker.
  static const List<Color> _palette = <Color>[
    Color(0xFFC23B22), // cinnabar
    Color(0xFFD4A017), // gold leaf
    Color(0xFF1A1A1A), // ink black
    Color(0xFF4A4A4A), // ink wash
    Color(0xFF3E2723), // dark wood
    Color(0xFF2E7D32), // jade green
    Color(0xFF1565C0), // water blue
    Color(0xFFBF8C3E), // earth yellow
    Color(0xFF6A1B9A), // shen pan purple
  ];

  @override
  Widget build(BuildContext context) {
    return InkyBorder(
      padding: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ---- color row ---------------------------------------------------
          Row(
            children: <Widget>[
              Container(
                key: const Key('deity_editor_color_preview'),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: pickedColor,
                  border: Border.all(
                      color: TaiYiClassicTheme.inkBlack.withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  key: const Key('deity_editor_color_hex_field'),
                  controller: colorHexController,
                  readOnly: readOnly,
                  enabled: !readOnly,
                  inputFormatters: <TextInputFormatter>[
                    LengthLimitingTextInputFormatter(9),
                  ],
                  decoration: const InputDecoration(
                    labelText: '颜色 (HEX)',
                    hintText: '#C23B22',
                    isDense: true,
                  ),
                  onSubmitted: onHexCommitted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            key: const Key('deity_editor_color_swatches'),
            spacing: 8,
            runSpacing: 8,
            children: _palette
                .map((c) => _ColorSwatch(
                      color: c,
                      selected: c.toARGB32() == pickedColor.toARGB32(),
                      onTap: onColorChanged == null
                          ? null
                          : () => onColorChanged!(c),
                    ))
                .toList(),
          ),
          const SizedBox(height: 18),
          // ---- display style row ------------------------------------------
          DropdownButtonFormField<String>(
            key: const Key('deity_editor_display_style_dropdown'),
            initialValue: displayStyle,
            isDense: true,
            decoration: const InputDecoration(
              labelText: '显示样式',
              isDense: true,
            ),
            items: <DropdownMenuItem<String>>[
              const DropdownMenuItem<String>(
                value: null,
                child: Text('未指定', style: TextStyle(color: TaiYiClassicTheme.inkWash)),
              ),
              ...styleOptions.map(
                (s) => DropdownMenuItem<String>(
                  value: s,
                  child: Text(styleLabels[s] ?? s),
                ),
              ),
            ],
            onChanged: onStyleChanged,
          ),
        ],
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback? onTap;
  const _ColorSwatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: selected
                ? TaiYiClassicTheme.cinnabar
                : TaiYiClassicTheme.inkBlack.withValues(alpha: 0.3),
            width: selected ? 2 : 0.8,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: selected
            ? const Icon(Icons.check,
                size: 16, color: Colors.white)
            : null,
      ),
    );
  }
}

class _SchoolScopeSection extends StatelessWidget {
  final List<TaiYiSchool> schools;
  final Set<String> selected;
  final ValueChanged<String>? onToggle;
  final bool readOnly;

  const _SchoolScopeSection({
    required this.schools,
    required this.selected,
    required this.onToggle,
    required this.readOnly,
  });

  @override
  Widget build(BuildContext context) {
    if (schools.isEmpty) {
      return const InkyBorder(
        padding: 16,
        child: Text(
          '暂无可用流派',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: TaiYiClassicTheme.inkWash,
          ),
        ),
      );
    }
    return InkyBorder(
      padding: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(bottom: 8, left: 4),
            child: Text(
              '为空则适用所有流派',
              style: TextStyle(
                fontSize: 12,
                color: TaiYiClassicTheme.inkWash,
              ),
            ),
          ),
          Wrap(
            key: const Key('deity_editor_school_chips'),
            spacing: 8,
            runSpacing: 8,
            children: schools
                .map((s) => _SelectableChip(
                      keyValue: 'deity_editor_school_chip_${s.id}',
                      label: s.name,
                      selected: selected.contains(s.id),
                      onTap: onToggle == null ? null : () => onToggle!(s.id),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ChartTypeSection extends StatelessWidget {
  final List<String> options;
  final Map<String, String> labels;
  final Set<String> selected;
  final ValueChanged<String>? onToggle;
  final bool readOnly;

  const _ChartTypeSection({
    required this.options,
    required this.labels,
    required this.selected,
    required this.onToggle,
    required this.readOnly,
  });

  @override
  Widget build(BuildContext context) {
    return InkyBorder(
      padding: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(bottom: 8, left: 4),
            child: Text(
              '为空则适用所有盘型',
              style: TextStyle(
                fontSize: 12,
                color: TaiYiClassicTheme.inkWash,
              ),
            ),
          ),
          Wrap(
            key: const Key('deity_editor_chart_chips'),
            spacing: 8,
            runSpacing: 8,
            children: options
                .map((id) => _SelectableChip(
                      keyValue: 'deity_editor_chart_chip_$id',
                      label: labels[id] ?? id,
                      selected: selected.contains(id),
                      onTap: onToggle == null ? null : () => onToggle!(id),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SelectableChip extends StatelessWidget {
  final String keyValue;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _SelectableChip({
    required this.keyValue,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return InkWell(
      key: Key(keyValue),
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? TaiYiClassicTheme.cinnabar.withValues(alpha: 0.12)
              : Colors.transparent,
          border: Border.all(
            color: selected
                ? TaiYiClassicTheme.cinnabar
                : TaiYiClassicTheme.inkWash.withValues(alpha: 0.4),
            width: selected ? 1.2 : 0.8,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              selected ? Icons.check_box : Icons.check_box_outline_blank,
              size: 16,
              color: selected
                  ? TaiYiClassicTheme.cinnabar
                  : TaiYiClassicTheme.inkWash,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: disabled
                    ? TaiYiClassicTheme.inkWash.withValues(alpha: 0.6)
                    : TaiYiClassicTheme.inkBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LineageSection extends StatelessWidget {
  final DeityDefinition? deity;
  const _LineageSection({required this.deity});

  @override
  Widget build(BuildContext context) {
    final d = deity;
    if (d == null) {
      return const InkyBorder(
        padding: 16,
        child: Text(
          '新建星神尚无传承链',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: TaiYiClassicTheme.inkWash,
          ),
        ),
      );
    }

    final lineage = d.lineage;
    final sourceId = d.sourceId;
    final rootId = d.rootOfficialId;

    final hasAny = lineage != null || sourceId != null || rootId != null;
    if (!hasAny) {
      return const InkyBorder(
        key: Key('deity_editor_lineage_empty'),
        padding: 16,
        child: Text(
          '无传承链（根项）',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: TaiYiClassicTheme.inkWash,
          ),
        ),
      );
    }

    final chain = _parseLineageChain(lineage, d.id);

    return InkyBorder(
      key: const Key('deity_editor_lineage_section'),
      padding: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (rootId != null)
            _LineageRow(
              keyValue: 'deity_editor_lineage_root',
              label: '官方根',
              value: rootId,
            ),
          if (sourceId != null) ...<Widget>[
            const SizedBox(height: 6),
            _LineageRow(
              keyValue: 'deity_editor_lineage_source',
              label: '直接来源',
              value: sourceId,
            ),
          ],
          if (chain.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            const Text(
              '传承链',
              style: TextStyle(
                fontSize: 12,
                color: TaiYiClassicTheme.inkWash,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              key: const Key('deity_editor_lineage_chain'),
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: _interleaveArrows(chain),
            ),
          ],
        ],
      ),
    );
  }

  /// Lineage strings in this codebase are encoded by [CopyDeityUseCase] as
  /// `"official(<rootId>) -> <id1> -> <id2>"` or
  /// `"<previous lineage> -> <newId>"`. We split on " -> " and pass the raw
  /// segments through unchanged so the chain always reflects the real
  /// `lineage` field — no hand-crafted "派生自/演自" copy is injected.
  List<String> _parseLineageChain(String? lineage, String selfId) {
    if (lineage == null || lineage.isEmpty) return <String>[];
    return lineage
        .split('->')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  List<Widget> _interleaveArrows(List<String> chain) {
    final List<Widget> out = <Widget>[];
    for (int i = 0; i < chain.length; i++) {
      out.add(_LineageChip(label: chain[i]));
      if (i < chain.length - 1) {
        out.add(const Icon(
          Icons.arrow_forward,
          size: 14,
          color: TaiYiClassicTheme.inkWash,
        ));
      }
    }
    return out;
  }
}

class _LineageRow extends StatelessWidget {
  final String keyValue;
  final String label;
  final String value;
  const _LineageRow({
    required this.keyValue,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      key: Key(keyValue),
      children: <Widget>[
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: TaiYiClassicTheme.inkWash,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: TaiYiClassicTheme.inkBlack,
              fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}

class _LineageChip extends StatelessWidget {
  final String label;
  const _LineageChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: TaiYiClassicTheme.paleGold.withValues(alpha: 0.4),
        border: Border.all(
            color: TaiYiClassicTheme.goldLeaf.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: TaiYiClassicTheme.inkBlack,
        ),
      ),
    );
  }
}
