import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taiyishenshu/theme/taiyi_classic_theme.dart';
import 'package:taiyishenshu/widgets/ink_wash_widgets.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: DeityDialogDemo(),
  ));
}

class DeityDialogDemo extends StatelessWidget {
  const DeityDialogDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TaiYiClassicTheme.ricePaper,
      appBar: AppBar(
        backgroundColor: TaiYiClassicTheme.darkWood,
        title: Text('星神管理 Demo', style: GoogleFonts.maShanZheng(color: TaiYiClassicTheme.paleGold)),
      ),
      body: Center(
        child: PaperBackground(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '点击按钮查看分类隔离的星神管理弹窗',
                style: GoogleFonts.longCang(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _showDemoDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TaiYiClassicTheme.cinnabar,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text('打开管理弹窗', style: GoogleFonts.maShanZheng(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDemoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const DemoDeityManagementDialog(),
    );
  }
}

class DemoDeityManagementDialog extends StatefulWidget {
  const DemoDeityManagementDialog({super.key});

  @override
  State<DemoDeityManagementDialog> createState() => _DemoDeityManagementDialogState();
}

class _DemoDeityManagementDialogState extends State<DemoDeityManagementDialog> {
  static const Map<String, String> _tierLabels = {
    'core': '核心枢轴',
    'generals': '主客将领',
    'jiShen': '岁时三基',
    'auspicious': '吉庆神煞',
    'spiritual': '九天外层',
    'chronos': '地盘岁君',
    'weather': '天文气象',
  };

  // Real categorized mock data
  final List<Map<String, dynamic>> _officialDeities = [
    {'id': 'taiYi', 'name': '太乙', 'visible': true, 'available': true, 'tier': 'core'},
    {'id': 'wenChang', 'name': '文昌', 'visible': true, 'available': true, 'tier': 'core'},
    {'id': 'shiJi', 'name': '始击', 'visible': true, 'available': true, 'tier': 'core'},
    {'id': 'jiShen', 'name': '计神', 'visible': true, 'available': true, 'tier': 'core'},
    
    {'id': 'zhuDaJiang', 'name': '主大将', 'visible': true, 'available': true, 'tier': 'generals'},
    {'id': 'keDaJiang', 'name': '客大将', 'visible': true, 'available': true, 'tier': 'generals'},
    {'id': 'zhuCanJiang', 'name': '主参将', 'visible': true, 'available': true, 'tier': 'generals'},
    {'id': 'keCanJiang', 'name': '客参将', 'visible': true, 'available': true, 'tier': 'generals'},
    
    {'id': 'junJi', 'name': '君基', 'visible': true, 'available': true, 'tier': 'jiShen'},
    {'id': 'chenJi', 'name': '臣基', 'visible': true, 'available': true, 'tier': 'jiShen'},
    {'id': 'minJi', 'name': '民基', 'visible': true, 'available': true, 'tier': 'jiShen'},
    
    {'id': 'wuFu', 'name': '五福', 'visible': true, 'available': true, 'tier': 'auspicious'},
    {'id': 'daYou', 'name': '大游', 'visible': true, 'available': true, 'tier': 'auspicious'},
    {'id': 'siShen', 'name': '四神', 'visible': true, 'available': true, 'tier': 'auspicious'},
    
    {'id': 'yangJiu', 'name': '阳九', 'visible': false, 'available': true, 'tier': 'spiritual'},
    {'id': 'baiLiu', 'name': '百六', 'visible': false, 'available': true, 'tier': 'spiritual'}, // Fixed Bai Liu!
    
    {'id': 'taiSui', 'name': '太岁', 'visible': true, 'available': true, 'tier': 'chronos'},
    {'id': 'suiPo', 'name': '岁破', 'visible': true, 'available': true, 'tier': 'chronos'},
    
    {'id': 'qingLong', 'name': '青龙', 'visible': true, 'available': true, 'tier': 'weather'},
    {'id': 'zhuQue', 'name': '朱雀', 'visible': true, 'available': true, 'tier': 'weather'},
  ];

  final List<Map<String, dynamic>> _myDeities = [
    {'id': 'my_taiYi', 'name': '我的太乙', 'visible': true, 'available': true},
  ];

  @override
  Widget build(BuildContext context) {
    final showWarning = _officialDeities.any((d) => (d['id'] == 'taiYi' || d['id'] == 'wenChang') && d['visible'] == false);

    // Group deities by tier
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final deity in _officialDeities) {
      final tier = deity['tier'] ?? 'core';
      grouped.putIfAbsent(tier, () => []).add(deity);
    }

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
              ...grouped.entries.map((entry) => _buildTierSection(entry.key, entry.value)),
              const SizedBox(height: 24),
              const ChineseSectionHeader(title: '我的'),
              InkyBorder(
                color: TaiYiClassicTheme.goldLeaf,
                padding: 12,
                child: Column(
                  children: [
                    if (_myDeities.isEmpty)
                      const Padding(padding: EdgeInsets.all(12), child: Text('暂无自定义星神', style: TextStyle(fontStyle: FontStyle.italic)))
                    else
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _myDeities.map((deity) => _buildDeityChip(deity, isOfficial: false)).toList(),
                      ),
                  ],
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
        if (showWarning)
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

  Widget _buildTierSection(String tier, List<Map<String, dynamic>> deities) {
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
              children: deities.map((deity) => _buildDeityChip(deity, isOfficial: true)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeityChip(Map<String, dynamic> deity, {required bool isOfficial}) {
    final bool available = deity['available'] ?? true;
    final bool isVisible = deity['visible'] ?? true;
    
    return Opacity(
      opacity: available ? 1.0 : 0.4,
      child: InkWell(
        onTap: available ? () {
          setState(() {
            deity['visible'] = !isVisible;
          });
        } : null,
        onLongPress: available ? () {
          if (isOfficial) {
            setState(() {
              _myDeities.add({
                'id': 'my_${deity['id']}_${_myDeities.length}',
                'name': '副本:${deity['name']}',
                'visible': true,
                'available': true,
              });
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('已复制 ${deity['name']} 到“我的”')),
            );
          } else {
            setState(() {
              _myDeities.removeWhere((d) => d['id'] == deity['id']);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('已删除 ${deity['name']}')),
            );
          }
        } : null,
        child: Tooltip(
          message: available ? (isOfficial ? '点按切换，长按复制' : '点按切换，长按删除') : (deity['reason'] ?? '不可用'),
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
                  deity['name'],
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
      ),
    );
  }
}
