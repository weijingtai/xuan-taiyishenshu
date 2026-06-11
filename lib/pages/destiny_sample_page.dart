import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../destiny/viewmodels/destiny_view_model.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';

/// 太乙人道命法 MVP 展示页面。
class DestinySamplePage extends StatefulWidget {
  const DestinySamplePage({super.key});

  @override
  State<DestinySamplePage> createState() => _DestinySamplePageState();
}

class _DestinySamplePageState extends State<DestinySamplePage> {
  DateTime _selectedDate = DateTime(1990, 6, 15);
  int _selectedHour = 14; // 14:00 = 未时

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('太乙命法')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 日期时间输入
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<int>(
                  value: _selectedHour,
                  items: List.generate(24, (i) {
                    final branch = _hourToBranch(i);
                    return DropdownMenuItem(
                      value: i,
                      child: Text('$i:00 ($branch)'),
                    );
                  }),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedHour = v);
                  },
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _onCalculate,
                  child: const Text('排盘'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 结果区
            Expanded(
              child: Consumer<DestinyViewModel>(
                builder: (context, vm, _) {
                  if (vm.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (vm.error != null) {
                    return Text(
                      '错误: ${vm.error}',
                      style: const TextStyle(color: Colors.red),
                    );
                  }
                  if (vm.result == null) {
                    return const Center(child: Text('选择出生时间后点击"排盘"'));
                  }
                  return _buildResult(vm.result!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _onCalculate() {
    final birthTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedHour,
    );
    // 使用默认统宗配置(实际应从 Repository 加载)
    final config = DestinyConfigContract(
      id: 'tongZong',
      name: '统宗命法',
      epoch: const SchoolEpochConfigContract(
        ancientBase: 10155219,
        epochYear: 1303,
        correction: 1,
      ),
      palaceMappings: List.generate(
        12,
        (i) => DestinyPalaceMappingContract(
          index: i + 1,
          name: _kTwelvePalaceNames[i],
          mappingRule: i == 0 ? 'birthBranchPalace' : 'sequentialNext($i)',
        ),
      ),
    );
    context.read<DestinyViewModel>().calculate(
          birthTime: birthTime,
          config: config,
        );
  }

  Widget _buildResult(DestinyResultContract r) {
    return ListView(
      children: [
        _sectionTitle('时局信息'),
        _infoTile('局数', '${r.juNumber}'),
        _infoTile('阴阳遁', r.dunType == 'yang' ? '阳遁' : '阴遁'),
        const Divider(),
        _sectionTitle('天盘核心'),
        _infoTile('太乙', r.taiYiPalace),
        _infoTile('文昌', r.wenChangPalace),
        _infoTile('始击', r.shiJiPalace),
        const Divider(),
        _sectionTitle('主客算'),
        _infoTile('主算', '${r.hostCount}'),
        _infoTile('客算', '${r.guestCount}'),
        const Divider(),
        _sectionTitle('十二宫'),
        ...r.twelvePalaces.map((p) => ListTile(
              dense: true,
              title: Text('${p.index}. ${p.name}'),
              subtitle: Text(
                p.deities.isEmpty ? '—' : p.deities.join(', '),
              ),
            )),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  String _hourToBranch(int hour) {
    const branches = [
      '子', '丑', '寅', '卯', '辰', '巳',
      '午', '未', '申', '酉', '戌', '亥',
    ];
    return branches[((hour + 1) % 24) ~/ 2];
  }
}

const List<String> _kTwelvePalaceNames = [
  '命宫', '相貌', '父母', '兄弟', '妻妾', '子孙',
  '财帛', '田宅', '官禄', '奴仆', '疾厄', '福德',
];
