import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../controllers/taiyi_pan_controller.dart';
import '../enums/gong.dart';
import '../taiyi/pan_data_model.dart';
import '../taiyi/pan_enums.dart';
import '../theme/taiyi_classic_theme.dart';
import '../widgets/taiyi_pan_grid.dart';
import '../widgets/taiyi_pan_grid_v2.dart';
import '../widgets/pan_info_panel.dart';
import '../widgets/deity_management_dialog.dart';
import '../widgets/ink_wash_widgets.dart';
import 'entity_editor_page.dart';

import '../taiyi/taiyi_assembly.dart';

class TaiYiPanPage extends StatefulWidget {
  final TaiYiPanController? controller;
  const TaiYiPanPage({super.key, this.controller});

  @override
  State<TaiYiPanPage> createState() => _TaiYiPanPageState();
}

class _TaiYiPanPageState extends State<TaiYiPanPage> {
  late final TaiYiPanController _controller;
  EnumTaiYiGong? _selectedGong;
  bool _useV2 = false;

  late DateTime _selectedDate;
  late String _selectedSchoolId;
  late TaiYiChartType _selectedChartType;
  late TimeOfDay _selectedTime;

  List<(String, String)> get _defaultSchoolOptions {
    if (_controller.availableSchools.isNotEmpty) {
      return _controller.availableSchools
          .map((s) => (s.id, s.name))
          .toList();
    }
    return const [
      ('jingMirror', '金镜派'),
      ('tongZong', '统宗派'),
      ('jiCheng', '集成派'),
    ];
  }

  @override
  void initState() {

    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      final assembly = TaiYiDataAssembly();
      _controller = TaiYiPanController(assembly: assembly);
    }
    _selectedDate = DateTime.now();

    _selectedTime = TimeOfDay.now();
    _selectedSchoolId = 'jingMirror';
    _selectedChartType = TaiYiChartType.year;
    _controller.addListener(_onPanDataChanged);
    _controller.loadSchools();
    _calculate();
  }

  @override
  void dispose() {
    _controller.removeListener(_onPanDataChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onPanDataChanged() {
    if (mounted) setState(() {});
  }

  void _calculate() {
    final dt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    _controller.calculate(
      dateTime: dt,
      schoolId: _selectedSchoolId,
      chartType: _selectedChartType,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: TaiYiClassicTheme.ricePaper,
      appBar: _buildAppBar(),
      body: _controller.isCalculating
          ? const Center(child: CircularProgressIndicator(color: TaiYiClassicTheme.cinnabar))
          : _controller.error != null
              ? _buildError()
              : _controller.panData != null
                  ? _buildContent(isWide, _controller.panData!)
                  : const Center(child: Text('尚未起盘')),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: TaiYiClassicTheme.darkWood,
      foregroundColor: TaiYiClassicTheme.paleGold,
      title: Text(
        '太乙神数',
        style: GoogleFonts.maShanZheng(fontSize: 22, color: TaiYiClassicTheme.paleGold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.auto_awesome, color: TaiYiClassicTheme.goldLeaf),
          onPressed: _showDeityManagementDialog,
          tooltip: '星神管理',
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: TaiYiClassicTheme.goldLeaf),
          onPressed: _showSettingsDialog,
          tooltip: '起盘参数',
        ),
      ],
    );
  }

  void _showDeityManagementDialog() {
    showDialog(
      context: context,
      builder: (ctx) => ChangeNotifierProvider.value(
        value: _controller,
        child: const DeityManagementDialog(),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: TaiYiClassicTheme.cinnabar),
            const SizedBox(height: 12),
            Text(
              '起盘失败',
              style: GoogleFonts.maShanZheng(fontSize: 20, color: TaiYiClassicTheme.cinnabar),
            ),
            const SizedBox(height: 8),
            Text(
              _controller.error ?? '未知错误',
              style: GoogleFonts.longCang(fontSize: 14, color: TaiYiClassicTheme.inkWash),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showSettingsDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: TaiYiClassicTheme.darkWood,
                foregroundColor: TaiYiClassicTheme.paleGold,
              ),
              child: const Text('修改参数'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(bool isWide, PanDataModel panData) {
    final screenWidth = MediaQuery.of(context).size.width;
    final gridWidth = isWide ? screenWidth * 0.6 : screenWidth - 24;
    final grid = _useV2
        ? TaiYiPanGridV2(
            panData: panData,
            totalWidth: gridWidth.clamp(320.0, 900.0),
            onGongTap: (gong) {
              setState(() {
                _selectedGong = _selectedGong == gong ? null : gong;
              });
            },
          )
        : TaiYiPanGrid(
            panData: panData,
            totalWidth: gridWidth.clamp(320.0, 900.0),
            onGongTap: (gong) {
              setState(() {
                _selectedGong = _selectedGong == gong ? null : gong;
              });
            },
          );
    final info = PanInfoPanel(
      panData: panData,
      selectedGong: _selectedGong,
    );

    final selectorBar = _buildSelectorBar();

    return Column(
      children: [
        if (_controller.showHiddenWarning)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: TaiYiClassicTheme.cinnabar.withValues(alpha: 0.08),
              border: const Border(bottom: BorderSide(color: TaiYiClassicTheme.cinnabar, width: 0.5)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning_amber_rounded, color: TaiYiClassicTheme.cinnabar, size: 16),
                const SizedBox(width: 8),
                Text(
                  '部分基础星神或关键计算项已隐藏，盘面解释可能不完整。',
                  style: GoogleFonts.longCang(color: TaiYiClassicTheme.cinnabar, fontSize: 14),
                ),
              ],
            ),
          ),
        Expanded(
          child: PaperBackground(
            child: isWide
                ? Column(
                    children: [
                      selectorBar,
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(16),
                                child: Center(child: grid),
                              ),
                            ),
                            Container(width: 1, color: TaiYiClassicTheme.goldLeaf.withValues(alpha: 0.3)),
                            Expanded(
                              flex: 3,
                              child: info,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        selectorBar,
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Center(child: grid),
                        ),
                        Container(
                          height: 1,
                          color: TaiYiClassicTheme.goldLeaf.withValues(alpha: 0.3),
                        ),
                        info,
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectorBar() {
    final dateStr = '${_selectedDate.year}年${_selectedDate.month}月${_selectedDate.day}日';
    final timeStr = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: TaiYiClassicTheme.paleGold.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(color: TaiYiClassicTheme.goldLeaf.withValues(alpha: 0.3), width: 1),
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _buildDateTimeSelector(dateStr, timeStr),
          const SizedBox(width: 4),
          const VerticalDivider(width: 1, thickness: 1, color: TaiYiClassicTheme.goldLeaf),
          const SizedBox(width: 4),
          Text(
            '盘型',
            style: GoogleFonts.maShanZheng(fontSize: 14, color: TaiYiClassicTheme.darkWood),
          ),
          ...TaiYiChartType.values.where((t) => t != TaiYiChartType.ke).map((t) {
            return ChoiceChip(
              label: Text(t.label),
              selected: _selectedChartType == t,
              onSelected: (_) {
                setState(() => _selectedChartType = t);
                _calculate();
              },
              selectedColor: TaiYiClassicTheme.cinnabar,
              labelStyle: TextStyle(
                fontSize: 12,
                color: _selectedChartType == t
                    ? Colors.white
                    : TaiYiClassicTheme.inkBlack,
              ),
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 4),
            );
          }),
          const SizedBox(width: 4),
          Text(
            '流派',
            style: GoogleFonts.maShanZheng(fontSize: 14, color: TaiYiClassicTheme.darkWood),
          ),
          ..._defaultSchoolOptions.map((s) {
            return ChoiceChip(
              label: Text(s.$2),
              selected: _selectedSchoolId == s.$1,
              onSelected: (_) {
                setState(() => _selectedSchoolId = s.$1);
                _calculate();
              },
              selectedColor: TaiYiClassicTheme.darkWood,
              labelStyle: TextStyle(
                fontSize: 12,
                color: _selectedSchoolId == s.$1
                    ? TaiYiClassicTheme.paleGold
                    : TaiYiClassicTheme.inkBlack,
              ),
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 4),
            );
          }),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 20, color: TaiYiClassicTheme.darkWood),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => EntityEditorPage(
                    type: EntityType.school,
                    initialName: '新流派',
                    controller: _controller,
                  ),
                ),
              );
            },
            tooltip: '新建流派',
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: 4),
          const VerticalDivider(width: 1, thickness: 1, color: TaiYiClassicTheme.goldLeaf),
          const SizedBox(width: 4),
          Text(
            '样式',
            style: GoogleFonts.maShanZheng(fontSize: 14, color: TaiYiClassicTheme.darkWood),
          ),
          ChoiceChip(
            label: const Text('经典'),
            selected: !_useV2,
            onSelected: (val) {
              if (val) setState(() => _useV2 = false);
            },
            selectedColor: TaiYiClassicTheme.darkWood,
            labelStyle: TextStyle(
              fontSize: 12,
              color: !_useV2 ? TaiYiClassicTheme.paleGold : TaiYiClassicTheme.inkBlack,
            ),
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          ChoiceChip(
            label: const Text('罗盘'),
            selected: _useV2,
            onSelected: (val) {
              if (val) setState(() => _useV2 = true);
            },
            selectedColor: TaiYiClassicTheme.darkWood,
            labelStyle: TextStyle(
              fontSize: 12,
              color: _useV2 ? TaiYiClassicTheme.paleGold : TaiYiClassicTheme.inkBlack,
            ),
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSelector(String dateStr, String timeStr) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _selectorButton(
          icon: Icons.calendar_today,
          label: dateStr,
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(-1000),
              lastDate: DateTime(3000),
              builder: (_, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: TaiYiClassicTheme.cinnabar,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setState(() => _selectedDate = picked);
              _calculate();
            }
          },
        ),
        const SizedBox(width: 4),
        _selectorButton(
          icon: Icons.access_time,
          label: timeStr,
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: _selectedTime,
              builder: (_, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: TaiYiClassicTheme.cinnabar,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setState(() => _selectedTime = picked);
              _calculate();
            }
          },
        ),
        const SizedBox(width: 4),
        _selectorButton(
          icon: Icons.refresh,
          label: '现在',
          onTap: () {
            final now = DateTime.now();
            setState(() {
              _selectedDate = now;
              _selectedTime = TimeOfDay(hour: now.hour, minute: now.minute);
            });
            _calculate();
          },
        ),
      ],
    );
  }

  Widget _selectorButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: TaiYiClassicTheme.goldLeaf.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(6),
          color: TaiYiClassicTheme.ricePaper.withValues(alpha: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: TaiYiClassicTheme.cinnabar),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.longCang(fontSize: 13, color: TaiYiClassicTheme.darkWood),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: TaiYiClassicTheme.ricePaper,
              title: Text(
                '起盘参数',
                style: GoogleFonts.maShanZheng(
                  fontSize: 20,
                  color: TaiYiClassicTheme.darkWood,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _dialogSection('日期'),
                    ListTile(
                      leading: const Icon(Icons.calendar_today, color: TaiYiClassicTheme.darkWood),
                      title: Text(
                        '${_selectedDate.year}年${_selectedDate.month}月${_selectedDate.day}日',
                        style: GoogleFonts.longCang(color: TaiYiClassicTheme.inkBlack),
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(-1000),
                          lastDate: DateTime(3000),
                          builder: (_, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: TaiYiClassicTheme.darkWood,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setDialogState(() => _selectedDate = picked);
                        }
                      },
                    ),
                    _dialogSection('时辰'),
                    ListTile(
                      leading: const Icon(Icons.access_time, color: TaiYiClassicTheme.darkWood),
                      title: Text(
                        '${_selectedTime.hour}时${_selectedTime.minute}分',
                        style: GoogleFonts.longCang(color: TaiYiClassicTheme.inkBlack),
                      ),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime,
                          builder: (_, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: TaiYiClassicTheme.darkWood,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setDialogState(() => _selectedTime = picked);
                        }
                      },
                    ),
                    _dialogSection('流派'),
                    Wrap(
                      spacing: 8,
                      children: [
                        ..._defaultSchoolOptions.map((s) {
                          return ChoiceChip(
                            label: Text(s.$2),
                            selected: _selectedSchoolId == s.$1,
                            onSelected: (_) {
                              setDialogState(() => _selectedSchoolId = s.$1);
                            },
                            selectedColor: TaiYiClassicTheme.darkWood,
                            labelStyle: TextStyle(
                              color: _selectedSchoolId == s.$1
                                  ? TaiYiClassicTheme.paleGold
                                  : TaiYiClassicTheme.inkBlack,
                            ),
                          );
                        }).toList(),
                        ActionChip(
                          avatar: const Icon(Icons.edit, size: 16),
                          label: const Text('管理'),
                          onPressed: () {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('管理流派功能即将上线')),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _dialogSection('盘类型'),
                    Wrap(
                      spacing: 8,
                      children: TaiYiChartType.values.where((t) => t != TaiYiChartType.ke).map((t) {
                        return ChoiceChip(
                          label: Text(t.label),
                          selected: _selectedChartType == t,
                          onSelected: (_) {
                            setDialogState(() => _selectedChartType = t);
                          },
                          selectedColor: TaiYiClassicTheme.darkWood,
                          labelStyle: TextStyle(
                            color: _selectedChartType == t
                                ? TaiYiClassicTheme.paleGold
                                : TaiYiClassicTheme.inkBlack,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text('取消', style: TextStyle(color: TaiYiClassicTheme.inkWash)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _calculate();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TaiYiClassicTheme.cinnabar,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('起盘'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _dialogSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        title,
        style: GoogleFonts.maShanZheng(
          fontSize: 14,
          color: TaiYiClassicTheme.inkBlack,
        ),
      ),
    );
  }
}
