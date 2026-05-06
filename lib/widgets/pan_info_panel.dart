import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
            height: 16,
            color: color ?? TaiYiClassicTheme.cinnabar,
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: GoogleFonts.maShanZheng(
              fontSize: 16,
              color: color ?? TaiYiClassicTheme.inkBlack,
              height: 1,
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
          style: GoogleFonts.maShanZheng(
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
            '${panData.input.school.label}·${panData.input.chartType.label}',
            style: GoogleFonts.longCang(
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
                style: GoogleFonts.maShanZheng(
                  fontSize: 14,
                  color: TaiYiClassicTheme.inkBlack,
                ),
              ),
              Text(
                '$count',
                style: GoogleFonts.notoSerif(
                  fontSize: 18,
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
            style: GoogleFonts.longCang(
              fontSize: 12,
              color: TaiYiClassicTheme.inkWash,
            ),
          ),
          if (detail != null) ...[
            const SizedBox(height: 2),
            Wrap(
              spacing: 4,
              children: [
                if (detail.isZhengGong)
                  _miniTag('正宫', TaiYiClassicTheme.jadeGreen),
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
                    style: GoogleFonts.maShanZheng(
                      fontSize: 13,
                      color: TaiYiClassicTheme.cinnabar,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    p.description,
                    style: GoogleFonts.longCang(
                      fontSize: 12,
                      color: TaiYiClassicTheme.inkWash,
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
              style: GoogleFonts.longCang(
                fontSize: 11,
                color: TaiYiClassicTheme.inkWash,
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
      if (tp.junJiGong != null) ('君基', tp.junJiGong!.gua.name),
      if (tp.chenJiGong != null) ('臣基', tp.chenJiGong!.gua.name),
      if (tp.minJiGong != null) ('民基', tp.minJiGong!.gua.name),
      if (tp.wuFuGong != null) ('五福', tp.wuFuGong!.gua.name),
      if (tp.daYouGong != null) ('大游', tp.daYouGong!.gua.name),
      if (tp.xiaoYouGong != null) ('小游', tp.xiaoYouGong!.gua.name),
      if (tp.feifFuGong != null) ('飞符', tp.feifFuGong!.gua.name),
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
      if (sp.heShenGong != null) ('河神', sp.heShenGong!.gua.name),
      if (sp.fengBoGong != null) ('风伯', sp.fengBoGong!.gua.name),
      if (sp.yuShiGong != null) ('雨师', sp.yuShiGong!.gua.name),
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
              style: GoogleFonts.longCang(
                fontSize: 11,
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
              style: GoogleFonts.longCang(fontSize: 12, color: TaiYiClassicTheme.inkWash),
            ),
          ),
        if (palace.doors.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '八门：${palace.doors.join('、')}',
              style: GoogleFonts.longCang(fontSize: 12, color: TaiYiClassicTheme.inkWash),
            ),
          ),
        if (palace.note != null)
          Text(
            palace.note!,
            style: GoogleFonts.longCang(fontSize: 11, color: TaiYiClassicTheme.goldLeaf),
          ),
      ],
    );
  }

  Widget _infoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
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
            style: GoogleFonts.longCang(
              fontSize: 11,
              color: TaiYiClassicTheme.inkWash,
              height: 1,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            value,
            style: GoogleFonts.notoSerif(
              fontSize: 12,
              color: TaiYiClassicTheme.inkBlack,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        text,
        style: GoogleFonts.longCang(fontSize: 10, color: color, height: 1),
      ),
    );
  }
}
