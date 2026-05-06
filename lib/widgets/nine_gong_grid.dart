import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  static const _yangGong = {
    EnumTaiYiGong.Qian,
    EnumTaiYiGong.Gen,
    EnumTaiYiGong.Zhen,
    EnumTaiYiGong.Kan,
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
              style: GoogleFonts.maShanZheng(
                fontSize: cellSize * 0.22,
                color: TaiYiClassicTheme.cinnabar,
                height: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              panData.dunType.label,
              style: GoogleFonts.maShanZheng(
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
                style: GoogleFonts.maShanZheng(
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
                style: GoogleFonts.longCang(
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
              style: GoogleFonts.longCang(
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
                style: GoogleFonts.longCang(
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
              style: GoogleFonts.longCang(
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
                style: GoogleFonts.longCang(
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

  Widget _buildCenterContent(EnumTaiYiGong gong) {
    final guaName = gong.gua.name;
    final guaSymbol = TaiYiClassicTheme.eightGuaSymbol[guaName] ?? '';
    final gongNumber = TaiYiClassicTheme.toChineseNumber(gong.order);
    final isTaiYiHere = gong == panData.taiYiPalace;
    final status = gong.status;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          status,
          style: GoogleFonts.zhiMangXing(
            fontSize: cellSize * 0.07,
            color: TaiYiClassicTheme.inkWash.withOpacity(0.6),
            height: 1,
          ),
        ),
        SizedBox(height: cellSize * 0.01),
        Stack(
          alignment: Alignment.center,
          children: [
            Text(
              guaName,
              style: GoogleFonts.maShanZheng(
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
              style: GoogleFonts.notoSerif(
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

  Widget _buildBottomRow(
    EnumTaiYiGong gong,
    List<DeityPlacement> tianPlacements,
    List<DeityPlacement> shenPlacements,
  ) {
    final bottomDiZhi = _bottomDiZhi(gong);
    final tianNames = tianPlacements.map((p) => p.kind.label).toList();
    final shenNames = shenPlacements.map((p) => p.kind.label).toList();

    return SizedBox(
      height: cellSize * 0.16,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (tianNames.isNotEmpty)
            Wrap(
              spacing: cellSize * 0.01,
              runSpacing: 1,
              alignment: WrapAlignment.center,
              children: tianNames.map((name) {
                return Text(
                  name,
                  style: GoogleFonts.longCang(
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
                  style: GoogleFonts.longCang(
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
              style: GoogleFonts.longCang(
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
      style: GoogleFonts.zhiMangXing(
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
