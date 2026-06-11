import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:repository_interface_taiyishenshu/repository_interface_taiyishenshu.dart';
import '../minggua/viewmodels/ming_gua_view_model.dart';

/// 太乙命卦 MVP 展示页面。
class MingGuaSamplePage extends StatefulWidget {
  const MingGuaSamplePage({super.key});

  @override
  State<MingGuaSamplePage> createState() => _MingGuaSamplePageState();
}

class _MingGuaSamplePageState extends State<MingGuaSamplePage> {
  late TextEditingController _yearController;

  @override
  void initState() {
    super.initState();
    _yearController = TextEditingController(
      text: DateTime.now().year.toString(),
    );
  }

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('太乙命卦')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 年份输入
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _yearController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '年份',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _onCalculate,
                  child: const Text('起卦'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 结果区
            Expanded(
              child: Consumer<MingGuaViewModel>(
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
                    return const Center(child: Text('输入年份后点击"起卦"'));
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

  void _onCalculate() {
    final year = int.tryParse(_yearController.text);
    if (year == null) return;
    context.read<MingGuaViewModel>().calculate(year: year);
  }

  Widget _buildResult(MingGuaResultContract r) {
    return ListView(
      children: [
        _infoTile('积年', '${r.accumulatedYear}'),
        _infoTile('余数', '${r.remainder}'),
        _infoTile('卦序编号', '${r.guaIndex}'),
        const Divider(),
        _guaDisplay('本卦', r.benGuaName, r.benGuaYao, r.dongYaoPosition),
        const Divider(),
        _infoTile('动爻', '第 ${r.dongYaoPosition} 爻'),
        _infoTile('阴阳辰', r.isYangChen ? '阳辰' : '阴辰'),
        const Divider(),
        _guaDisplay('变卦', r.bianGuaName, r.bianGuaYao, null),
      ],
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

  Widget _guaDisplay(
    String label,
    String name,
    List<bool> yao,
    int? highlightPosition,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: $name', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        // 六爻从上到下显示(上爻→初爻)
        for (int i = 5; i >= 0; i--)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    _yaoLabel(i),
                    style: TextStyle(
                      color: (highlightPosition != null && i == highlightPosition - 1)
                          ? Colors.red
                          : null,
                    ),
                  ),
                ),
                Text(
                  yao[i] ? '━━━━' : '━ ━',
                  style: TextStyle(
                    fontSize: 20,
                    color: (highlightPosition != null && i == highlightPosition - 1)
                        ? Colors.red
                        : null,
                    fontWeight: (highlightPosition != null && i == highlightPosition - 1)
                        ? FontWeight.bold
                        : null,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _yaoLabel(int index) {
    const labels = ['初爻', '二爻', '三爻', '四爻', '五爻', '上爻'];
    return labels[index];
  }
}
