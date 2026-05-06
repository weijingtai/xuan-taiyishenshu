import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/taiyi_pan_controller.dart';
import '../enums/gong.dart';
import '../taiyi/pan_data_model.dart';
import '../taiyi/pan_enums.dart';
import '../theme/taiyi_classic_theme.dart';
import '../widgets/taiyi_pan_grid.dart';
import '../widgets/pan_info_panel.dart';

class TaiYiPanPage extends StatefulWidget {
  const TaiYiPanPage({super.key});

  @override
  State<TaiYiPanPage> createState() => _TaiYiPanPageState();
}

class _TaiYiPanPageState extends State<TaiYiPanPage> {
  final _controller = TaiYiPanController();
  EnumTaiYiGong? _selectedGong;

  late DateTime _selectedDate;
  late TaiYiSchool _selectedSchool;
  late TaiYiChartType _selectedChartType;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    _selectedSchool = TaiYiSchool.jingMirror;
    _selectedChartType = TaiYiChartType.year;
    _controller.addListener(_onPanDataChanged);
    _calculate();
  }

  @override
  void dispose() {
    _controller.removeListener(_onPanDataChanged);
    _controller.dispose();
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
      school: _selectedSchool,
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
          icon: const Icon(Icons.settings, color: TaiYiClassicTheme.goldLeaf),
          onPressed: _showSettingsDialog,
          tooltip: '起盘参数',
        ),
      ],
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
    final grid = TaiYiPanGrid(
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

    if (isWide) {
      return Column(
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
      );
    } else {
      return SingleChildScrollView(
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
      );
    }
  }

  Widget _buildSelectorBar() {
    final dateStr = '${_selectedDate.year}年${_selectedDate.month}月${_selectedDate.day}日';
    final timeStr = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: TaiYiClassicTheme.paleGold.withValues(alpha: 0.15),
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
          ...TaiYiSchool.values.map((s) {
            return ChoiceChip(
              label: Text(s.label),
              selected: _selectedSchool == s,
              onSelected: (_) {
                setState(() => _selectedSchool = s);
                _calculate();
              },
              selectedColor: TaiYiClassicTheme.darkWood,
              labelStyle: TextStyle(
                fontSize: 12,
                color: _selectedSchool == s
                    ? TaiYiClassicTheme.paleGold
                    : TaiYiClassicTheme.inkBlack,
              ),
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 4),
            );
          }),
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
                      children: TaiYiSchool.values.map((s) {
                        return ChoiceChip(
                          label: Text(s.label),
                          selected: _selectedSchool == s,
                          onSelected: (_) {
                            setDialogState(() => _selectedSchool = s);
                          },
                          selectedColor: TaiYiClassicTheme.darkWood,
                          labelStyle: TextStyle(
                            color: _selectedSchool == s
                                ? TaiYiClassicTheme.paleGold
                                : TaiYiClassicTheme.inkBlack,
                          ),
                        );
                      }).toList(),
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
