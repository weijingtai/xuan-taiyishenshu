import 'package:flutter/material.dart';

import '../../enums/eight_door.dart';
import '../../enums/gong.dart';
import '../../models/tian_pan_model.dart';
import '../../taiyi/pan_data_model.dart';
import '../../taiyi/pan_enums.dart';
import '../../theme/taiyi_classic_theme.dart';

class NineGongGrid extends StatelessWidget {
  final PanDataModel panData;
  final double cellSize;
  final ValueChanged<EnumTaiYiGong>? onGongTap;

  const NineGongGrid({
    super.key,
    required this.panData,
    this.cellSize = 200,
    this.onGongTap,
  });

  static const _gongLayout = [
    [EnumTaiYiGong.Li, EnumTaiYiGong.Kun, EnumTaiYiGong.Dui],
    [EnumTaiYiGong.Xun, EnumTaiYiGong.Center, EnumTaiYiGong.Qian],
    [EnumTaiYiGong.Zhen, EnumTaiYiGong.Gen, EnumTaiYiGong.Kan],
  ];

  static const _nearGong = {
    EnumTaiYiGong.Zhen,
    EnumTaiYiGong.Gen,
    EnumTaiYiGong.Kan,
  };

  // 太乙阴阳数：以洛书三(震)四(巽)八(艮)九(离)为阳宫，
  //           一(坎)二(坤)六(乾)七(兑)为阴宫，五宫除外。
  static const _yangGong = {
    EnumTaiYiGong.Zhen,  // 三
    EnumTaiYiGong.Xun,   // 四
    EnumTaiYiGong.Gen,   // 八
    EnumTaiYiGong.Li,    // 九
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _gongLayout.map((row) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: row.map((gong) {
            if (gong == EnumTaiYiGong.Center) {
              return _buildCenterCell();
            }
            return _buildGongCell(gong);
          }).toList(),
        );
      }).toList(),
    );
  }

  Widget _buildCenterCell() {
    return Container(
      width: cellSize,
      height: cellSize,
      decoration: TaiYiClassicTheme.centerDecoration(),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${panData.juNumber}局',
              style: TaiYiClassicTheme.getTitleStyle(
                fontSize: cellSize * 0.22,
                color: TaiYiClassicTheme.cinnabar,
                height: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              panData.dunType.label,
              style: TaiYiClassicTheme.getTitleStyle(
                fontSize: cellSize * 0.10,
                color: TaiYiClassicTheme.inkWash,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGongCell(EnumTaiYiGong gong) {
    final isYang = _yangGong.contains(gong);
    final isNear = _nearGong.contains(gong);
    final door = panData.eightDoorsByPalace[gong];
    final diPalace = panData.diPan.of(gong);
    final renGods = panData.renPan.sixteenGodsByPalace[gong] ?? [];

    final tianPlacements = <DeityPlacement>[];
    for (final p in panData.tianPan.toPlacements()) {
      if (p.gong == gong) tianPlacements.add(p);
    }
    final shenPlacements = <DeityPlacement>[];
    for (final p in panData.shenPan.toPlacements()) {
      if (p.gong == gong) shenPlacements.add(p);
    }

    return GestureDetector(
      onTap: () => onGongTap?.call(gong),
      child: Container(
        width: cellSize,
        height: cellSize,
        padding: EdgeInsets.all(cellSize * 0.03),
        decoration: TaiYiClassicTheme.gongDecoration(
          isYangYin: isYang,
          isNear: isNear,
        ),
        child: Column(
          children: [
            _buildTopRow(gong, door, diPalace.zhengShen),
            Expanded(
              child: Row(
                children: [
                  _buildLeftColumn(gong, diPalace.jianShen, renGods),
                  Expanded(child: _buildCenterContent(gong)),
                  _buildRightColumn(gong, renGods),
                ],
              ),
            ),
            _buildBottomRow(gong, tianPlacements, shenPlacements),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRow(EnumTaiYiGong gong, EnumEightDoor? door, String? zhengShen) {
    final isCorner = _cornerInfo(gong);
    return SizedBox(
      height: cellSize * 0.18,
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.topLeft,
              child: isCorner != null && isCorner.$1 == Alignment.topLeft
                  ? _cornerLabel(isCorner.$2)
                  : const SizedBox.shrink(),
            ),
          ),
          if (door != null)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: cellSize * 0.03,
                vertical: cellSize * 0.01,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: TaiYiClassicTheme.jadeGreen,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(4),
                color: TaiYiClassicTheme.jadeGreen.withOpacity(0.1),
              ),
              child: Text(
                door.singleName,
                style: TaiYiClassicTheme.getTitleStyle(
                  fontSize: cellSize * 0.08,
                  color: TaiYiClassicTheme.jadeGreen,
                  height: 1,
                ),
              ),
            ),
          if (zhengShen != null)
            Padding(
              padding: EdgeInsets.only(left: cellSize * 0.02),
              child: Text(
                zhengShen,
                style: TaiYiClassicTheme.getChineseStyle(
                  fontSize: cellSize * 0.07,
                  color: TaiYiClassicTheme.earthYellow.withOpacity(0.8),
                  height: 1,
                ),
              ),
            ),
          Expanded(
            child: Align(
              alignment: Alignment.topRight,
              child: isCorner != null && isCorner.$1 == Alignment.topRight
                  ? _cornerLabel(isCorner.$2)
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftColumn(EnumTaiYiGong gong, String? jianShen, List<String> renGods) {
    final leftDiZhi = _leftDiZhi(gong);
    return SizedBox(
      width: cellSize * 0.18,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leftDiZhi != null)
            Text(
              leftDiZhi,
              style: TaiYiClassicTheme.getChineseStyle(
                fontSize: cellSize * 0.12,
                color: (TaiYiClassicTheme.zodiacColors[leftDiZhi] ?? Colors.grey)
                    .withOpacity(0.7),
                height: 1,
              ),
            ),
          if (jianShen != null)
            Padding(
              padding: EdgeInsets.only(top: cellSize * 0.01),
              child: Text(
                jianShen,
                style: TaiYiClassicTheme.getChineseStyle(
                  fontSize: cellSize * 0.06,
                  color: TaiYiClassicTheme.earthYellow.withOpacity(0.6),
                  height: 1,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRightColumn(EnumTaiYiGong gong, List<String> renGods) {
    final rightDiZhi = _rightDiZhi(gong);
    return SizedBox(
      width: cellSize * 0.18,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (rightDiZhi != null)
            Text(
              rightDiZhi,
              style: TaiYiClassicTheme.getChineseStyle(
                fontSize: cellSize * 0.12,
                color: (TaiYiClassicTheme.zodiacColors[rightDiZhi] ?? Colors.grey)
                    .withOpacity(0.7),
                height: 1,
              ),
            ),
          if (renGods.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: cellSize * 0.01),
              child: Text(
                renGods.join(' '),
                style: TaiYiClassicTheme.getChineseStyle(
                  fontSize: cellSize * 0.05,
                  color: TaiYiClassicTheme.waterBlue.withOpacity(0.6),
                  height: 1.2,
                ),
                textAlign: TextAlign.right,
              ),
            ),
        ],
      ),
    );
  }

  // ── 太乙阴阳数辅助 ─────────────────────────────────────────

  /// 判断某宫是否为阳宫（洛书三四八九）。
  bool _isYangGong(EnumTaiYiGong gong) => _yangGong.contains(gong);

  /// 按「太乙阴阳数」规则判断一个算数+落宫的分类。
  /// 返回 (分类名, 颜色, 是否和)。
  (String, Color, bool?) _yinYangNumberCategory(int count, EnumTaiYiGong palace) {
    if (palace == EnumTaiYiGong.Center) return ('五宫', Colors.grey, null);
    final isYang = _isYangGong(palace);
    final units = count % 10 == 0 ? 10 : count % 10;
    final isOdd = units % 2 == 1; // 奇数

    // 1. 重阳：三九自临（宫数奇，算数3或9）
    if (isYang && (units == 3 || units == 9)) return ('重阳', const Color(0xFFC23B22), true);
    // 2. 重阴：二六自临
    if (!isYang && (units == 2 || units == 6)) return ('重阴', const Color(0xFF1565C0), true);
    // 3. 阴中重阳：一七自临于阴宫
    if (!isYang && (units == 1 || units == 7)) return ('阴中重阳', const Color(0xFFBF5700), null);
    // 4. 阳中重阴：四八自临于阳宫
    if (isYang && (units == 4 || units == 8)) return ('阳中重阴', const Color(0xFF6A1B9A), null);
    // 5. 上和：一配阴宫，四八配阳宫
    if (!isYang && units == 1) return ('上和', const Color(0xFF2E7D32), true);
    if (isYang && (units == 4 || units == 8)) return ('上和', const Color(0xFF2E7D32), true);
    // 6. 次和：二六配阴宫，三九配阳宫
    if (!isYang && (units == 2 || units == 6)) return ('次和', const Color(0xFF388E3C), true);
    if (isYang && (units == 3 || units == 9)) return ('次和', const Color(0xFF388E3C), true);
    // 7. 下和数
    const heNumbers = [12, 16, 21, 27, 34, 38];
    if (heNumbers.contains(count)) return ('下和', const Color(0xFF4CAF50), true);
    // 8. 不和：阳宫得奇 或 阴宫得偶（与宫阴阳不匹配）
    if (isYang && isOdd) return ('不和', const Color(0xFF7B0000), false);
    if (!isYang && !isOdd) return ('不和', const Color(0xFF7B0000), false);
    // 9. 阴阳相配（和）
    return (isYang ? '阳和' : '阴和', const Color(0xFF2E7D32), true);
  }

  Widget _yinYangBadge(EnumTaiYiGong gong) {
    if (gong == EnumTaiYiGong.Center) return const SizedBox.shrink();
    final isYang = _isYangGong(gong);
    final label = isYang ? '阳宫' : '阴宫';
    final color = isYang ? const Color(0xFFC23B22) : const Color(0xFF1565C0);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: cellSize * 0.025, vertical: cellSize * 0.005),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.5), width: 0.5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        label,
        style: TaiYiClassicTheme.getSerifStyle(
          fontSize: cellSize * 0.055,
          color: color,
          height: 1,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCenterContent(EnumTaiYiGong gong) {
    final guaName = gong.gua.name;
    final guaSymbol = TaiYiClassicTheme.eightGuaSymbol[guaName] ?? '';
    final gongNumber = TaiYiClassicTheme.toChineseNumber(gong.order);
    final isTaiYiHere = gong == panData.taiYiPalace;
    final status = gong.status;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              status,
              style: TextStyle(
                fontSize: cellSize * 0.065,
                color: TaiYiClassicTheme.inkWash.withOpacity(0.6),
                height: 1,
              ),
            ),
            SizedBox(width: cellSize * 0.02),
            _yinYangBadge(gong),
          ],
        ),
        SizedBox(height: cellSize * 0.01),
        Stack(
          alignment: Alignment.center,
          children: [
            Text(
              guaName,
              style: TaiYiClassicTheme.getTitleStyle(
                fontSize: cellSize * 0.28,
                color: isTaiYiHere
                    ? TaiYiClassicTheme.cinnabar
                    : TaiYiClassicTheme.inkBlack,
                height: 1,
              ),
            ),
            if (isTaiYiHere)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: cellSize * 0.06,
                  height: cellSize * 0.06,
                  decoration: const BoxDecoration(
                    color: TaiYiClassicTheme.cinnabar,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '帝',
                      style: TextStyle(
                        fontSize: cellSize * 0.04,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              gongNumber,
              style: TaiYiClassicTheme.getSerifStyle(
                fontSize: cellSize * 0.07,
                color: TaiYiClassicTheme.inkWash,
                height: 1,
              ),
            ),
            SizedBox(width: cellSize * 0.04),
            Text(
              guaSymbol,
              style: TextStyle(
                fontSize: cellSize * 0.09,
                color: (TaiYiClassicTheme.eightGuaColor[guaName] ?? Colors.grey)
                    .withOpacity(0.7),
                height: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 生成阴阳数标签小chip
  Widget _numberCategoryChip(int count, EnumTaiYiGong palace, String prefix) {
    final (cat, color, _) = _yinYangNumberCategory(count, palace);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: cellSize * 0.02, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        border: Border.all(color: color.withOpacity(0.4), width: 0.5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        '$prefix$count·$cat',
        style: TaiYiClassicTheme.getSerifStyle(
          fontSize: cellSize * 0.048,
          color: color,
          height: 1,
        ),
      ),
    );
  }

  Widget _buildBottomRow(
    EnumTaiYiGong gong,
    List<DeityPlacement> tianPlacements,
    List<DeityPlacement> shenPlacements,
  ) {
    final bottomDiZhi = _bottomDiZhi(gong);
    final tianNames = tianPlacements.map((p) => p.kind.label).toList();
    final shenNames = shenPlacements.map((p) => p.kind.label).toList();

    // 阴阳数判断：主算、客算、定算 落在此宫时显示
    final hg = panData.hostGuest;
    final showHost  = hg.hostPalace  == gong;
    final showGuest = hg.guestPalace == gong;
    final showDing  = hg.dingPalace  == gong;

    return SizedBox(
      height: cellSize * 0.22,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 阴阳数标签行
          if (showHost || showGuest || showDing)
            Padding(
              padding: EdgeInsets.only(bottom: cellSize * 0.01),
              child: Wrap(
                spacing: cellSize * 0.01,
                runSpacing: 1,
                alignment: WrapAlignment.center,
                children: [
                  if (showHost)  _numberCategoryChip(hg.hostCount,  gong, '主'),
                  if (showGuest) _numberCategoryChip(hg.guestCount, gong, '客'),
                  if (showDing)  _numberCategoryChip(hg.dingCount,  gong, '定'),
                ],
              ),
            ),
          if (tianNames.isNotEmpty)
            Wrap(
              spacing: cellSize * 0.01,
              runSpacing: 1,
              alignment: WrapAlignment.center,
              children: tianNames.map((name) {
                return Text(
                  name,
                  style: TaiYiClassicTheme.getChineseStyle(
                    fontSize: cellSize * 0.055,
                    color: TaiYiClassicTheme.cinnabar.withOpacity(0.9),
                    height: 1.2,
                  ),
                );
              }).toList(),
            ),
          if (shenNames.isNotEmpty)
            Wrap(
              spacing: cellSize * 0.01,
              runSpacing: 1,
              alignment: WrapAlignment.center,
              children: shenNames.map((name) {
                return Text(
                  name,
                  style: TaiYiClassicTheme.getChineseStyle(
                    fontSize: cellSize * 0.05,
                    color: TaiYiClassicTheme.deityLayerColor['神盘']!
                        .withOpacity(0.8),
                    height: 1.2,
                  ),
                );
              }).toList(),
            ),
          if (bottomDiZhi != null)
            Text(
              bottomDiZhi,
              style: TaiYiClassicTheme.getChineseStyle(
                fontSize: cellSize * 0.10,
                color: (TaiYiClassicTheme.zodiacColors[bottomDiZhi] ?? Colors.grey)
                    .withOpacity(0.7),
                height: 1,
              ),
            ),
        ],
      ),
    );
  }

  Widget _cornerLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: cellSize * 0.07,
        color: TaiYiClassicTheme.goldLeaf,
        height: 1,
      ),
    );
  }

  (Alignment, String)? _cornerInfo(EnumTaiYiGong gong) {
    return switch (gong) {
      EnumTaiYiGong.Li => (Alignment.topLeft, '南离'),
      EnumTaiYiGong.Dui => (Alignment.topRight, '西兑'),
      EnumTaiYiGong.Zhen => (Alignment.bottomLeft, '东震'),
      EnumTaiYiGong.Kan => (Alignment.bottomRight, '北坎'),
      _ => null,
    };
  }

  String? _leftDiZhi(EnumTaiYiGong gong) {
    return switch (gong) {
      EnumTaiYiGong.Xun => '辰',
      EnumTaiYiGong.Zhen => '卯',
      EnumTaiYiGong.Gen => '寅',
      _ => null,
    };
  }

  String? _rightDiZhi(EnumTaiYiGong gong) {
    return switch (gong) {
      EnumTaiYiGong.Kun => '未',
      EnumTaiYiGong.Qian => '戌',
      EnumTaiYiGong.Gen => '丑',
      _ => null,
    };
  }

  String? _bottomDiZhi(EnumTaiYiGong gong) {
    return switch (gong) {
      EnumTaiYiGong.Zhen => '卯',
      EnumTaiYiGong.Gen => '寅',
      EnumTaiYiGong.Kan => '子',
      _ => null,
    };
  }
}
