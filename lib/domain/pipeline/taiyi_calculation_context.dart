/// 太乙神数排盘计算上下文。
///
/// 当前太乙排盘链路为纯同步计算，无需预加载异步数据，故本上下文当前为空。
/// 预留为后续管线扩展点（例如预加载积年表、局数规则等）。
/// 形态对齐七政四余 [QizhengCalculationContext]。
class TaiyiCalculationContext {
  const TaiyiCalculationContext();

  static Future<TaiyiCalculationContext> load() async {
    return const TaiyiCalculationContext();
  }
}
