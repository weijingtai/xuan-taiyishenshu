/// 太乙八宫顺行序(剔除中五宫)。索引 0..7。
const List<String> kTaiYiPalaceOrder = ['乾', '离', '艮', '震', '兑', '坤', '坎', '巽'];

/// 八宫宫本数(中=5 不入,故映射中跳过 5)。
const Map<String, int> kGongBenShu = {
  '乾': 1,
  '离': 2,
  '艮': 3,
  '震': 4,
  '兑': 6,
  '坤': 7,
  '坎': 8,
  '巽': 9,
};

/// 十六神地理序(1-indexed 位置对应旧代码 _sixteenGodSequence)。
const List<String> kSixteenGodSequence = [
  '子', '丑', '艮', '寅', '卯', '辰', '巽', '巳',
  '午', '未', '坤', '申', '酉', '戌', '乾', '亥',
];

/// 正神位置集合(1-indexed)。
const Set<int> kZhengDeityPositions = {1, 3, 5, 7, 9, 11, 13, 15};

/// 地支/卦名 → 太乙宫 映射。
const Map<String, String> kBranchToPalace = {
  '子': '坎', '丑': '艮', '艮': '艮', '寅': '艮',
  '卯': '震', '辰': '巽', '巽': '巽', '巳': '巽',
  '午': '离', '未': '坤', '坤': '坤', '申': '坤',
  '酉': '兑', '戌': '乾', '乾': '乾', '亥': '乾',
};

/// 太乙宫 → 十六神正位(1-indexed) 映射。
const Map<String, int> kPalaceToZhengDeityPosition = {
  '坎': 1, '艮': 3, '震': 5, '巽': 7,
  '离': 9, '坤': 11, '兑': 13, '乾': 15,
};

/// 宫本数(兼容旧代码 _hostGuestPalaceNumber: order>=5 则 +1)。
int gongBenShuOf(String palace) => kGongBenShu[palace] ?? 0;

/// 十六神位置 → 宫名。
String sixteenGodPalace(int position) {
  final god = kSixteenGodSequence[(position - 1) % 16];
  return kBranchToPalace[god] ?? '中';
}

/// 满十去十:((sum-1) % 10) + 1,且结果 10 归 9;sum==0(无算)返 0。
int formatCount(int sum) {
  if (sum == 0) return 0;
  final r = ((sum - 1) % 10) + 1;
  return r == 10 ? 9 : r;
}

/// 太乙前一宫(在 kTaiYiPalaceOrder 上 -1,mod 8)。
String prevPalace(String taiYiPalace) {
  final idx = kTaiYiPalaceOrder.indexOf(taiYiPalace);
  if (idx == -1) throw ArgumentError('未知宫位: $taiYiPalace');
  return kTaiYiPalaceOrder[(idx - 1 + 8) % 8];
}

/// 太乙后一宫(在 kTaiYiPalaceOrder 上 +1,mod 8)。
String nextPalace(String taiYiPalace) {
  final idx = kTaiYiPalaceOrder.indexOf(taiYiPalace);
  if (idx == -1) throw ArgumentError('未知宫位: $taiYiPalace');
  return kTaiYiPalaceOrder[(idx + 1) % 8];
}

/// 顺行从 [start] 累加宫本数至 [endPalace](默认 prevPalace(taiYiPalace);终点本身不计入)后 formatCount。
/// 无算返 0:start==taiYiPalace;或 start 顺行一步即抵 taiYiPalace;或 start==endPalace。
/// 入参宫名须属于 kTaiYiPalaceOrder。
int walkAndSum(String start, String taiYiPalace, {String? endPalace}) {
  if (!kTaiYiPalaceOrder.contains(start)) {
    throw ArgumentError('非法起点宫位: $start');
  }
  if (!kTaiYiPalaceOrder.contains(taiYiPalace)) {
    throw ArgumentError('非法太乙宫位: $taiYiPalace');
  }

  if (start == taiYiPalace) return 0; // 无算①: 起点同太乙宫

  final si = kTaiYiPalaceOrder.indexOf(start);
  if (kTaiYiPalaceOrder[(si + 1) % 8] == taiYiPalace) return 0; // 无算②: 一步即到太乙

  final actualEnd = endPalace ?? prevPalace(taiYiPalace);
  if (!kTaiYiPalaceOrder.contains(actualEnd)) {
    throw ArgumentError('非法终点宫位: $actualEnd');
  }

  if (start == actualEnd) return 0; // 无算延伸

  final ei = kTaiYiPalaceOrder.indexOf(actualEnd);
  int sum = 0;
  int ci = si;
  while (ci != ei) {
    sum += kGongBenShu[kTaiYiPalaceOrder[ci]]!;
    ci = (ci + 1) % 8;
  }
  return formatCount(sum);
}

/// 地支对冲表。
const Map<String, String> kBranchComplement = {
  '子': '丑', '丑': '子', '寅': '亥', '亥': '寅',
  '卯': '戌', '戌': '卯', '辰': '酉', '酉': '辰',
  '巳': '申', '申': '巳', '午': '未', '未': '午',
};

/// 16 神位置(1-indexed) → 神名。
String sixteenGodAt(int position) {
  return kSixteenGodSequence[(position - 1) % 16];
}

/// 神名 → 16 神位置(1-indexed)。
int sixteenGodPosition(String name) {
  final idx = kSixteenGodSequence.indexOf(name);
  return idx >= 0 ? idx + 1 : 1;
}

/// 定目位置计算(旧算法 _calculateDingMuPosition)。
/// 基于 currentBranch(年支)、wenChangDeity(文昌神名)、合神偏移。
String calculateDingMu({
  required String currentBranch,
  required String wenChangDeity,
}) {
  final heShenBranch = kBranchComplement[currentBranch] ?? currentBranch;
  final taiSuiPos = sixteenGodPosition(currentBranch);
  final heShenPos = sixteenGodPosition(heShenBranch);
  final wenChangPos = sixteenGodPosition(wenChangDeity);
  final shift = taiSuiPos - heShenPos;
  final dingMuPos = ((wenChangPos + shift - 1) % 16 + 16) % 16 + 1;
  return sixteenGodAt(dingMuPos);
}

/// 十六神地理序走盘累加(旧算法兼容)。
///
/// 与旧代码 `_walkAndSumWithDetail` 完全一致:
/// - 正神(奇数位): 累加宫本数
/// - 间神(偶数位): 累加 1
/// - 不做满十去十(raw sum)
/// - 同位: 返回太乙宫本数
/// - 同宫(chartType=year): 返回 10
int walkAndSum16(int startPos, int taiYiPos, {String chartType = 'year'}) {
  final startPalace = sixteenGodPalace(startPos);
  final taiYiPalace = sixteenGodPalace(taiYiPos);

  // 同位
  if (startPos == taiYiPos) {
    return gongBenShuOf(taiYiPalace);
  }

  // 同宫
  if (startPalace == taiYiPalace) {
    return chartType == 'year' ? 10 : 1;
  }

  // 正常累加
  int sum = 0;
  if (kZhengDeityPositions.contains(startPos)) {
    sum += gongBenShuOf(startPalace);
  } else {
    sum += 1;
  }

  int cur = startPos % 16 + 1;
  for (var i = 0; i < 16; i++) {
    if (cur == taiYiPos) break;
    if (kZhengDeityPositions.contains(cur)) {
      final palace = sixteenGodPalace(cur);
      sum += gongBenShuOf(palace);
    }
    cur = cur % 16 + 1;
  }
  return sum; // raw sum, no formatCount
}
