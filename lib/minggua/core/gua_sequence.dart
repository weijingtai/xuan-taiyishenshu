/// 《太乙统宗宝鉴》卷十三专属六十四卦序。
/// 索引 0..63,对应卦序 1..64。
/// 第 42 位(序号43)为'姤',与周易通行序(夬)不同。
const List<String> kTaiYiGuaSequence = [
  '乾', '坤', '屯', '蒙', '需', '讼', '师', '比',
  '小畜', '履', '泰', '否', '同人', '大有', '谦', '豫',
  '随', '蛊', '临', '观', '噬嗑', '贲', '剥', '复',
  '无妄', '大畜', '颐', '大过', '坎', '离', '咸', '恒',
  '遁', '大壮', '晋', '明夷', '家人', '睽', '蹇', '解',
  '损', '益', '姤', '夬', '萃', '升', '困', '井', '革',
  '鼎', '震', '艮', '渐', '归妹', '丰', '旅', '巽',
  '兑', '涣', '节', '中孚', '小过', '既济', '未济',
];

/// 八经卦三爻编码。true=阳(━),false=阴(╴╴)。
/// 顺序:初爻→上爻(从下往上)。
const Map<String, List<bool>> kBaGuaYao = {
  '乾': [true, true, true],
  '坤': [false, false, false],
  '震': [true, false, false],
  '艮': [false, false, true],
  '离': [true, false, true],
  '坎': [false, true, false],
  '兑': [true, true, false],
  '巽': [false, true, true],
};

/// 六十四卦分解表:卦名→(下卦名,上卦名)。
const Map<String, (String, String)> kGuaDecompose = {
  '乾': ('乾', '乾'),
  '坤': ('坤', '坤'),
  '屯': ('震', '坎'),
  '蒙': ('坎', '艮'),
  '需': ('乾', '坎'),
  '讼': ('坎', '乾'),
  '师': ('坤', '坎'),
  '比': ('坎', '坤'),
  '小畜': ('乾', '巽'),
  '履': ('兑', '乾'),
  '泰': ('坤', '乾'),
  '否': ('乾', '坤'),
  '同人': ('离', '乾'),
  '大有': ('乾', '离'),
  '谦': ('艮', '坤'),
  '豫': ('坤', '震'),
  '随': ('震', '兑'),
  '蛊': ('巽', '艮'),
  '临': ('坤', '兑'),
  '观': ('巽', '坤'),
  '噬嗑': ('震', '离'),
  '贲': ('离', '艮'),
  '剥': ('坤', '艮'),
  '复': ('震', '坤'),
  '无妄': ('震', '乾'),
  '大畜': ('乾', '艮'),
  '颐': ('震', '艮'),
  '大过': ('巽', '兑'),
  '坎': ('坎', '坎'),
  '离': ('离', '离'),
  '咸': ('艮', '兑'),
  '恒': ('巽', '震'),
  '遁': ('艮', '乾'),
  '大壮': ('震', '乾'),
  '晋': ('坤', '离'),
  '明夷': ('离', '坤'),
  '家人': ('离', '巽'),
  '睽': ('兑', '离'),
  '蹇': ('艮', '坎'),
  '解': ('坎', '震'),
  '损': ('兑', '艮'),
  '益': ('震', '巽'),
  '姤': ('巽', '乾'),
  '夬': ('乾', '兑'),
  '萃': ('坤', '兑'),
  '升': ('巽', '坤'),
  '困': ('坎', '兑'),
  '井': ('巽', '坎'),
  '革': ('离', '兑'),
  '鼎': ('巽', '离'),
  '震': ('震', '震'),
  '艮': ('艮', '艮'),
  '渐': ('巽', '艮'),
  '归妹': ('震', '兑'),
  '丰': ('震', '离'),
  '旅': ('离', '艮'),
  '巽': ('巽', '巽'),
  '兑': ('兑', '兑'),
  '涣': ('巽', '坎'),
  '节': ('兑', '坎'),
  '中孚': ('兑', '巽'),
  '小过': ('震', '艮'),
  '既济': ('离', '坎'),
  '未济': ('坎', '离'),
};

/// 六十四卦的六爻编码(由下卦+上卦组合)。
/// key=卦名, value=[初爻,二爻,三爻,四爻,五爻,上爻]。
const Map<String, List<bool>> kGuaYaoMap = {
  '乾': [true, true, true, true, true, true],
  '坤': [false, false, false, false, false, false],
  '屯': [true, false, false, false, true, false],
  '蒙': [false, true, false, false, false, true],
  '需': [true, true, true, false, true, false],
  '讼': [false, true, false, true, true, true],
  '师': [false, false, false, false, true, false],
  '比': [false, true, false, false, false, false],
  '小畜': [true, true, true, false, true, true],
  '履': [true, true, false, true, true, true],
  '泰': [false, false, false, true, true, true],
  '否': [true, true, true, false, false, false],
  '同人': [true, false, true, true, true, true],
  '大有': [true, true, true, true, false, true],
  '谦': [false, false, true, false, false, false],
  '豫': [false, false, false, true, false, false],
  '随': [true, false, false, true, true, false],
  '蛊': [false, true, true, false, false, true],
  '临': [false, false, false, true, true, false],
  '观': [false, true, true, false, false, false],
  '噬嗑': [true, false, false, true, false, true],
  '贲': [true, false, true, false, false, true],
  '剥': [false, false, false, false, false, true],
  '复': [true, false, false, false, false, false],
  '无妄': [true, false, false, true, true, true],
  '大畜': [true, true, true, false, false, true],
  '颐': [true, false, false, false, false, true],
  '大过': [false, true, true, true, true, false],
  '坎': [false, true, false, false, true, false],
  '离': [true, false, true, true, false, true],
  '咸': [false, false, true, true, true, false],
  '恒': [false, true, true, true, false, false],
  '遁': [false, false, true, true, true, true],
  '大壮': [true, false, false, true, true, true],
  '晋': [false, false, false, true, false, true],
  '明夷': [true, false, true, false, false, false],
  '家人': [true, false, true, false, true, true],
  '睽': [true, true, false, true, false, true],
  '蹇': [false, false, true, false, true, false],
  '解': [false, true, false, true, false, false],
  '损': [true, true, false, false, false, true],
  '益': [true, false, false, false, true, true],
  '姤': [false, true, true, true, true, true],
  '夬': [true, true, true, true, true, false],
  '萃': [false, false, false, true, true, false],
  '升': [false, true, true, false, false, false],
  '困': [false, true, false, true, true, false],
  '井': [false, true, true, false, true, false],
  '革': [true, false, true, true, true, false],
  '鼎': [false, true, true, true, false, true],
  '震': [true, false, false, true, false, false],
  '艮': [false, false, true, false, false, true],
  '渐': [false, true, true, false, false, true],
  '归妹': [true, false, false, true, true, false],
  '丰': [true, false, false, true, false, true],
  '旅': [true, false, true, false, false, true],
  '巽': [false, true, true, false, true, true],
  '兑': [true, true, false, true, true, false],
  '涣': [false, true, true, false, true, false],
  '节': [true, true, false, false, true, false],
  '中孚': [true, true, false, false, true, true],
  '小过': [true, false, false, false, false, true],
  '既济': [true, false, true, false, true, false],
  '未济': [false, true, false, true, false, true],
};

/// 根据六爻编码反查卦名。找不到返回 null。
String? findGuaNameByYao(List<bool> yao) {
  if (yao.length != 6) return null;
  for (final entry in kGuaYaoMap.entries) {
    if (_listEquals(entry.value, yao)) return entry.key;
  }
  return null;
}

bool _listEquals(List<bool> a, List<bool> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
