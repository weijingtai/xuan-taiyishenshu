/// 宫位行走方向
enum WalkDirection { forward, reverse }

/// 算法模板类型
enum AlgorithmTemplateId {
  steppedCycle,
  branchWalker,
  cumulativeWalk,
  relativeOffset,
  fixedPosition,
  customFormula,
}

/// 宫位体系
enum PalaceSystem {
  nineGong,
  sixteenZhengJian,
  mixed,
}

/// 算法基础变量
enum AlgorithmBaseVariable {
  ji,
  ju,
  year,
}
