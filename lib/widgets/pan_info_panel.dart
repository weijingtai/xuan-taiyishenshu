import 'package:flutter/material.dart';

import '../../enums/gong.dart';
import '../../taiyi/pan_data_model.dart';
import '../../taiyi/pan_enums.dart';
import '../../theme/taiyi_classic_theme.dart';

class PanInfoPanel extends StatelessWidget {
  final PanDataModel panData;
  final EnumTaiYiGong? selectedGong;

  const PanInfoPanel({
    super.key,
    required this.panData,
    this.selectedGong,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const Divider(color: TaiYiClassicTheme.goldLeaf, height: 24),
          _buildBasicInfo(),
          const SizedBox(height: 12),
          _buildHostGuest(),
          const SizedBox(height: 8),
          _buildYinYangShu(),
          const SizedBox(height: 12),
          _buildEightDoors(),
          const SizedBox(height: 12),
          _buildGeJu(),
          const SizedBox(height: 12),
          _buildDiPan(),
          const SizedBox(height: 12),
          _buildRenPan(),
          const SizedBox(height: 12),
          _buildTianPan(),
          const SizedBox(height: 12),
        _buildShenPan(),
        if (panData.guiShen != null) ...[
          const SizedBox(height: 12),
          _buildGuiShen(),
        ],
        if (panData.warnings.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildWarnings(),
          ],
          if (selectedGong != null) ...[
            const SizedBox(height: 12),
            _buildGongDetail(selectedGong!),
          ],
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 18,
            color: color ?? TaiYiClassicTheme.cinnabar,
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: TaiYiClassicTheme.getTitleStyle(
              fontSize: 18,
              color: color ?? TaiYiClassicTheme.inkBlack,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '太乙神数',
          style: TaiYiClassicTheme.getTitleStyle(
            fontSize: 24,
            color: TaiYiClassicTheme.cinnabar,
            height: 1,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            border: Border.all(color: TaiYiClassicTheme.goldLeaf),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '${panData.input.schoolName}·${panData.input.chartType.label}',
            style: TaiYiClassicTheme.getChineseStyle(
              fontSize: 14,
              color: TaiYiClassicTheme.goldLeaf,
              height: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfo() {
    final dt = panData.input.dateTime;
    final chartType = panData.input.chartType;
    final seqLabel = switch (chartType) {
      TaiYiChartType.year => '积年',
      TaiYiChartType.month => '积月',
      TaiYiChartType.day => '积日',
      TaiYiChartType.hour => '积时',
      TaiYiChartType.ke => '积刻',
    };
    final items = [
      (seqLabel, '${panData.sequenceIndex}'),
      ('局数', '${panData.juNumber}局'),
      ('遁法', panData.dunType.label),
      ('太乙宫', panData.taiYiPalace.gua.name),
      ('文昌宫', panData.renPan.tianMuName ?? panData.renPan.tianMuGong.gua.name),
      ('计神宫', panData.renPan.jiShenName ?? panData.renPan.jiShenGong.gua.name),
      if (panData.schoolBase != null) ('基数', panData.schoolBase!),
      ('时间', '${dt.year}/${dt.month}/${dt.day} ${dt.hour}时'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('基础参数'),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: items.map((e) {
            return _infoChip(e.$1, e.$2);
          }).toList(),
        ),
        if (panData.yearJi != null) ...[
          const SizedBox(height: 8),
          _buildYearJiInfo(),
        ],
      ],
    );
  }

  Widget _buildYearJiInfo() {
    final yj = panData.yearJi!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('年计参数', color: TaiYiClassicTheme.cinnabar),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            _infoChip('纪数', '第${yj.ruJiJiShu}纪'),
            _infoChip('五子元局', '${yj.wuZiYuanJu}'),
            _infoChip('元数', '${yj.yuanShu}'),
            _infoChip('五元名称', yj.wuZiYuanName),
            _infoChip('入纪年数', '${yj.ruJiNianShu}'),
            _infoChip('年卦编号', '${yj.nianGuaBianHao}'),
            _infoChip('太乙行宫', '${yj.taiYiXingGongGongShu}宫'),
            _infoChip('入宫年书', '${yj.taiYiRuGongNianShuLabel}'),
          ],
        ),
      ],
    );
  }

  Widget _buildHostGuest() {
    final hg = panData.hostGuest;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('主客定算'),
        Row(
          children: [
            Expanded(child: _hostGuestCard('主', hg.hostCount, hg.hostPalace, hg.hostCountDetail)),
            const SizedBox(width: 6),
            Expanded(child: _hostGuestCard('客', hg.guestCount, hg.guestPalace, hg.guestCountDetail)),
            const SizedBox(width: 6),
            Expanded(child: _hostGuestCard('定', hg.dingCount, hg.dingPalace, hg.dingCountDetail)),
          ],
        ),
      ],
    );
  }

  // ── 太乙阴阳数 ────────────────────────────────────────────────

  static const _yangGongSet = {
    EnumTaiYiGong.Zhen,  // 三
    EnumTaiYiGong.Xun,   // 四
    EnumTaiYiGong.Gen,   // 八
    EnumTaiYiGong.Li,    // 九
  };

  bool _isYangGong(EnumTaiYiGong g) => _yangGongSet.contains(g);

  (String, Color, String) _yinYangCategory(int count, EnumTaiYiGong palace) {
    if (palace == EnumTaiYiGong.Center) return ('五宫', Colors.grey, '中宫不参与阴阳判断');
    final isYang = _isYangGong(palace);
    final yangLabel = isYang ? '阳宫' : '阴宫';
    final units = count % 10 == 0 ? 10 : count % 10;
    final isOdd = units % 2 == 1;

    if (isYang && (units == 3 || units == 9))
      return ('重阳', const Color(0xFFC23B22), '$yangLabel·算得$units·三九自临，重阳数');
    if (!isYang && (units == 2 || units == 6))
      return ('重阴', const Color(0xFF1565C0), '$yangLabel·算得$units·二六自临，重阴数');
    if (!isYang && (units == 1 || units == 7))
      return ('阴中重阳', const Color(0xFFBF5700), '$yangLabel·算得$units·一七自临，阴中重阳数');
    if (isYang && (units == 4 || units == 8))
      return ('阳中重阴', const Color(0xFF6A1B9A), '$yangLabel·算得$units·四八自临，阳中重阴数');
    if (!isYang && units == 1)
      return ('上和', const Color(0xFF2E7D32), '$yangLabel·算得$units·一配阴宫，上和之数');
    if (isYang && (units == 4 || units == 8))
      return ('上和', const Color(0xFF2E7D32), '$yangLabel·算得$units·四八配阳宫，上和之数');
    if (!isYang && (units == 2 || units == 6))
      return ('次和', const Color(0xFF388E3C), '$yangLabel·算得$units·二六配阴宫，次和之数');
    if (isYang && (units == 3 || units == 9))
      return ('次和', const Color(0xFF388E3C), '$yangLabel·算得$units·三九配阳宫，次和之数');
    const heNumbers = [12, 16, 21, 27, 34, 38];
    if (heNumbers.contains(count))
      return ('下和', const Color(0xFF4CAF50), '$yangLabel·算得$count·下和之数');
    if (isYang && isOdd)
      return ('不和', const Color(0xFF7B0000), '$yangLabel·算得$units奇数·阳宫不和');
    if (!isYang && !isOdd)
      return ('不和', const Color(0xFF7B0000), '$yangLabel·算得$units偶数·阴宫不和');
    return (isYang ? '阳和' : '阴和', const Color(0xFF2E7D32), '$yangLabel·奇偶阴阳相配，和数');
  }

  Widget _buildYinYangShu() {
    final hg = panData.hostGuest;
    final rows = [
      ('主', hg.hostCount, hg.hostPalace),
      ('客', hg.guestCount, hg.guestPalace),
      ('定', hg.dingCount, hg.dingPalace),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('太乙阴阳数', color: const Color(0xFF8B5E3C)),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8F0),
            border: Border.all(color: const Color(0xFF8B5E3C).withOpacity(0.3)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 宫位阴阳说明
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  _miniTag('阳宫·洛书三四八九', const Color(0xFFC23B22)),
                  _miniTag('阴宫·洛书一二六七', const Color(0xFF1565C0)),
                ],
              ),
              const SizedBox(height: 8),
              // 三算阴阳数判断
              ...rows.map((r) {
                final (label, count, palace) = r;
                if (palace == EnumTaiYiGong.Center) return const SizedBox.shrink();
                final (cat, color, desc) = _yinYangCategory(count, palace);
                final isYang = _isYangGong(palace);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 算标签
                      Container(
                        width: 28,
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color: label == '主'
                              ? TaiYiClassicTheme.cinnabar.withOpacity(0.1)
                              : label == '客'
                                  ? TaiYiClassicTheme.waterBlue.withOpacity(0.1)
                                  : TaiYiClassicTheme.jadeGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
        child: Center(
          child: Text(
            '${label}算',
            style: TaiYiClassicTheme.getTitleStyle(
              fontSize: 14,
              color: label == '主'
              ? TaiYiClassicTheme.cinnabar
              : label == '客'
              ? TaiYiClassicTheme.waterBlue
              : TaiYiClassicTheme.jadeGreen,
              height: 1.2,
            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // 宫名+阴阳
        Text(
          '${palace.gua.name}宫(${isYang ? "阳" : "阴"})',
          style: TaiYiClassicTheme.getSerifStyle(
            fontSize: 14,
            color: TaiYiClassicTheme.inkBlack,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
        const SizedBox(width: 4),
        // 数值
        Text(
          '= $count',
          style: TaiYiClassicTheme.getSerifStyle(
            fontSize: 15,
            color: TaiYiClassicTheme.inkBlack,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
                                ),
                                const SizedBox(width: 6),
                                // 分类标签
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.12),
                                    border: Border.all(color: color.withOpacity(0.5)),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
        child: Text(
          cat,
          style: TaiYiClassicTheme.getTitleStyle(
            fontSize: 14,
            color: color,
            height: 1.2,
          ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
      Text(
        desc,
        style: TaiYiClassicTheme.getSerifStyle(
          fontSize: 12,
          color: TaiYiClassicTheme.darkWood,
          height: 1.4,
        ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _hostGuestCard(String label, int count, EnumTaiYiGong palace, HostCountDetail? detail) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: TaiYiClassicTheme.paleGold.withOpacity(0.2),
        border: Border.all(color: TaiYiClassicTheme.goldLeaf.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
      Text(
        '${label}算',
        style: TaiYiClassicTheme.getTitleStyle(
          fontSize: 16,
          color: TaiYiClassicTheme.inkBlack,
        ),
      ),
      Text(
        '$count',
        style: TaiYiClassicTheme.getSerifStyle(
          fontSize: 20,
          color: label == '主'
              ? TaiYiClassicTheme.cinnabar
              : label == '客'
                  ? TaiYiClassicTheme.waterBlue
                  : TaiYiClassicTheme.jadeGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
    Text(
      '落${palace.gua.name}宫',
      style: TaiYiClassicTheme.getSerifStyle(
        fontSize: 13,
        color: TaiYiClassicTheme.darkWood,
      ),
    ),
          if (detail != null) ...[
            const SizedBox(height: 2),
            Wrap(
              spacing: 4,
              children: [
                if (detail.isZhengGong)
                  _miniTag('正宫', TaiYiClassicTheme.jadeGreen),
                if (!detail.isZhengGong)
                  _miniTag('间神起', TaiYiClassicTheme.cinnabar),
                if (detail.isChangShu == true)
                  _miniTag('长数', TaiYiClassicTheme.waterBlue),
                if (detail.isDuanShu == true)
                  _miniTag('短数', TaiYiClassicTheme.cinnabar),
                if (detail.isHe == true)
                  _miniTag('和', TaiYiClassicTheme.jadeGreen),
                if (detail.isBuHe == true)
                  _miniTag('不和', TaiYiClassicTheme.cinnabar),
              ],
            ),
            if (detail.detail != null) ...[
              const SizedBox(height: 2),
      Text(
        detail.detail!,
        style: TaiYiClassicTheme.getSerifStyle(
          fontSize: 12,
          color: TaiYiClassicTheme.darkWood,
          height: 1.3,
        ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildEightDoors() {
    final doors = panData.eightDoorsByPalace.entries.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('八门', color: TaiYiClassicTheme.jadeGreen),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: doors.map((e) {
            return _infoChip(e.value.singleName, e.key.gua.name);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGeJu() {
    if (panData.geJu.patterns.isEmpty) {
      return _sectionTitle('格局（无）');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('格局', color: TaiYiClassicTheme.cinnabar),
        ...panData.geJu.patterns.map((p) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    border: Border.all(color: TaiYiClassicTheme.cinnabar),
                    borderRadius: BorderRadius.circular(4),
                  ),
        child: Text(
          p.type.label,
          style: TaiYiClassicTheme.getTitleStyle(
            fontSize: 15,
            color: TaiYiClassicTheme.cinnabar,
          ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
        child: Text(
          p.description,
          style: TaiYiClassicTheme.getSerifStyle(
            fontSize: 13,
            color: TaiYiClassicTheme.darkWood,
          ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDiPan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('地盘·正间神', color: TaiYiClassicTheme.jadeGreen),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: panData.diPan.palaces.where((p) => p.zhengShen != null).map((p) {
            return _infoChip(
              '${p.gong.gua.name}',
              '${p.zhengShen}/${p.jianShen}',
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRenPan() {
    final ren = panData.renPan;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('人盘·十六神流转', color: TaiYiClassicTheme.waterBlue),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            _infoChip('天目', ren.tianMuName ?? ren.tianMuGong.gua.name),
            _infoChip('始击', ren.shiJiName ?? ren.shiJiGong.gua.name),
            _infoChip('计神', ren.jiShenName ?? ren.jiShenGong.gua.name),
          ],
        ),
        const SizedBox(height: 4),
    ...ren.sixteenGodsByPalace.entries.where((e) => e.value.isNotEmpty).map((e) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(
          '${e.key.gua.name}宫：${e.value.join('、')}',
          style: TaiYiClassicTheme.getSerifStyle(
            fontSize: 13,
            color: TaiYiClassicTheme.darkWood,
          ),
        ),
      );
    }),
      ],
    );
  }

  Widget _buildTianPan() {
    final tp = panData.tianPan;
    final items = [
      ('太乙', tp.taiYiGong.gua.name),
      ('主大将', tp.hostGeneralGong.gua.name),
      ('客大将', tp.guestGeneralGong.gua.name),
      ('主参将', tp.hostDeputyGeneralGong.gua.name),
      ('客参将', tp.guestDeputyGeneralGong.gua.name),
      if (tp.dingGeneralGong != null) ('定大将', tp.dingGeneralGong!.gua.name),
      if (tp.dingDeputyGeneralGong != null) ('定参将', tp.dingDeputyGeneralGong!.gua.name),
    if (tp.junJiGong != null)
      ('君基', '${tp.junJiGong!.gua.name}${tp.junJiRuGongNianShu != null ? " 入${tp.junJiRuGongNianShu}年" : ""}'),
    if (tp.chenJiGong != null)
      ('臣基', '${tp.chenJiGong!.gua.name}${tp.chenJiRuGongNianShu != null ? " 入${tp.chenJiRuGongNianShu}年" : ""}'),
    if (tp.minJiGong != null) ('民基', tp.minJiGong!.gua.name),
      if (tp.wuFuGong != null) ('五福', tp.wuFuGong!.gua.name),
      if (tp.daYouGong != null) ('大游', tp.daYouGong!.gua.name),
      if (tp.xiaoYouGong != null) ('小游', tp.xiaoYouGong!.gua.name),
      if (tp.feifFuGong != null) ('飞符', tp.feifFuGong!.gua.name),
      if (tp.siShenGong != null)
        ('四神', '${tp.siShenGong!.gua.name}${tp.siShenRuGongNianShu != null ? " 入${tp.siShenRuGongNianShu}年" : ""}'),
      if (tp.tianYiGong2 != null)
        ('天乙', '${tp.tianYiGong2!.gua.name}${tp.tianYiRuGongNianShu != null ? " 入${tp.tianYiRuGongNianShu}年" : ""}'),
      if (tp.diYiGong != null)
        ('地乙', '${tp.diYiGong!.gua.name}${tp.diYiRuGongNianShu != null ? " 入${tp.diYiRuGongNianShu}年" : ""}'),
      if (tp.zhiFuGong2 != null)
        ('值符', '${tp.zhiFuGong2!.gua.name}${tp.zhiFuRuGongNianShu != null ? " 入${tp.zhiFuRuGongNianShu}年" : ""}'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('天盘·星神', color: TaiYiClassicTheme.cinnabar),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: items.map((e) => _infoChip(e.$1, e.$2)).toList(),
        ),
      ],
    );
  }

  Widget _buildShenPan() {
    final sp = panData.shenPan;
    final items = [
      ('太岁', sp.taiSuiGong.gua.name),
      ('岁破', sp.suiPoGong.gua.name),
      ('直符', sp.zhiFuGong.gua.name),
      if (sp.qingLongGong != null) ('青龙', sp.qingLongGong!.gua.name),
      if (sp.zhuQueGong != null) ('朱雀', sp.zhuQueGong!.gua.name),
      if (sp.baiHuGong != null) ('白虎', sp.baiHuGong!.gua.name),
      if (sp.xuanWuGong != null) ('玄武', sp.xuanWuGong!.gua.name),
      if (sp.heShenGong != null) ('合神', sp.heShenGong!.gua.name),
      if (sp.fengBoGong != null) ('风伯', sp.fengBoGong!.gua.name),
      if (sp.yuShiGong != null) ('雨师', sp.yuShiGong!.gua.name),
      if (sp.qingLongQiGong != null) ('青龙旗', sp.qingLongQiGong!.gua.name),
      if (sp.heiQiGong != null)
        ('太阴黑旗', '${sp.heiQiGong!.gua.name}${sp.heiQiRuGongNianShu != null ? " 入${sp.heiQiRuGongNianShu}年" : ""}'),
      if (sp.chiQiGong != null) ('宫气赤旗', sp.chiQiGong!.gua.name),
      if (sp.guiShenZhiShiGong != null) ('贵神值事', sp.guiShenZhiShiGong!.gua.name),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('神盘·年神时神', color: TaiYiClassicTheme.deityLayerColor['神盘']!),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: items.map((e) => _infoChip(e.$1, e.$2)).toList(),
        ),
      ],
    );
  }

  static const _guiShenGridOrder = [
    EnumTaiYiGong.Xun, EnumTaiYiGong.Li, EnumTaiYiGong.Kun,
    EnumTaiYiGong.Zhen, EnumTaiYiGong.Center, EnumTaiYiGong.Dui,
    EnumTaiYiGong.Gen, EnumTaiYiGong.Kan, EnumTaiYiGong.Qian,
  ];

  Widget _buildGuiShen() {
    final gs = panData.guiShen!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('贵神·九宫排布', color: const Color(0xFF8B5E3C)),
    Text(
      '值事贵神：${gs.zhiShiGuiShen.label}（${gs.zhiShiGuiShen.meaning}）',
      style: TaiYiClassicTheme.getSerifStyle(
        fontSize: 14,
        color: TaiYiClassicTheme.inkBlack,
        fontWeight: FontWeight.w500,
      ),
        ),
        const SizedBox(height: 6),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.4,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          children: _guiShenGridOrder.map((gong) {
            final deity = gs.palaceMap[gong];
            final isCenter = gong == EnumTaiYiGong.Center;
            final isZhiShi = isCenter;
            return Container(
              decoration: BoxDecoration(
                color: isZhiShi
                    ? TaiYiClassicTheme.cinnabar.withOpacity(0.1)
                    : TaiYiClassicTheme.ricePaper,
                border: Border.all(
                  color: isZhiShi
                      ? TaiYiClassicTheme.cinnabar.withOpacity(0.6)
                      : TaiYiClassicTheme.goldLeaf.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    gong.gua.name,
                    style: TaiYiClassicTheme.getSerifStyle(
                      fontSize: 12,
                      color: TaiYiClassicTheme.mediumWood,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    deity?.shortLabel ?? '—',
                    style: TaiYiClassicTheme.getTitleStyle(
                      fontSize: 20,
                      color: isZhiShi
                          ? TaiYiClassicTheme.cinnabar
                          : TaiYiClassicTheme.inkBlack,
                      height: 1.2,
                    ),
                  ),
                  if (deity != null)
                    Text(
                      deity.label,
                      style: TaiYiClassicTheme.getSerifStyle(
                        fontSize: 11,
                        color: TaiYiClassicTheme.darkWood,
                        height: 1.2,
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWarnings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('提示', color: Colors.orange),
        ...panData.warnings.map((w) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        '· $w',
        style: TaiYiClassicTheme.getSerifStyle(
          fontSize: 13,
          color: Colors.orange.shade700,
        ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildGongDetail(EnumTaiYiGong gong) {
    final palace = panData.palaces.firstWhere((p) => p.gong == gong);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      _sectionTitle('${gong.gua.name}宫详情'),
      if (palace.stars.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            '星神：${palace.stars.join('、')}',
            style: TaiYiClassicTheme.getSerifStyle(fontSize: 14, color: TaiYiClassicTheme.darkWood),
          ),
        ),
      if (palace.doors.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            '八门：${palace.doors.join('、')}',
            style: TaiYiClassicTheme.getSerifStyle(fontSize: 14, color: TaiYiClassicTheme.darkWood),
          ),
        ),
      if (palace.note != null)
        Text(
          palace.note!,
          style: TaiYiClassicTheme.getSerifStyle(fontSize: 13, color: TaiYiClassicTheme.goldLeaf),
        ),
      ],
    );
  }

  Widget _infoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: TaiYiClassicTheme.ricePaper,
        border: Border.all(color: TaiYiClassicTheme.goldLeaf.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TaiYiClassicTheme.getSerifStyle(
              fontSize: 13,
              color: TaiYiClassicTheme.mediumWood,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TaiYiClassicTheme.getSerifStyle(
              fontSize: 14,
              color: TaiYiClassicTheme.inkBlack,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        text,
        style: TaiYiClassicTheme.getSerifStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600, height: 1.2),
      ),
    );
  }
}
