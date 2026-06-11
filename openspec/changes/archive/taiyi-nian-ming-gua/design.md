# 太乙年命卦（卷十三·天干配爻+策数）设计

## 概述

实现《太乙统宗宝鉴》卷十三"天地否泰之运"体系：给定年份 → 积年定卦 → 查该卦天干配爻配置 → 输出六爻天干+策数+所属十二运。

算法特点：**完全确定性**，无随机。核心规则是"五阳干循环 + 起始天干 + 第4爻重复规则"。

## 架构

### 新增 `lib/gua_core/`（共享卦数据层）

从 `lib/minggua/core/gua_sequence.dart` 移入，保持所有已有导出不变。扩展新增：
- `yangYaoCount(String guaName) → int`
- `ceCount(String guaName) → int`（阳×36 + 阴×24）

原 `minggua/core/gua_sequence.dart` 改为 re-export 兼容。

### 新增 `lib/nian_ming_gua/`（年命卦模块）

```
nian_ming_gua/
├── core/
│   ├── stem_assignment.dart         # 天干配爻算法
│   └── nian_ming_gua_engine.dart    # 主引擎
└── repository/
    └── nian_ming_gua_config_loader.dart  # JSON 配置加载
```

### 新增资产

`assets/nian_ming_gua/sixty_four_gua_stems.json` — 64卦配爻配置。

### 新增 Contract

`NianMingGuaResultContract` in `repository-interface-taiyishenshu`。

## 核心算法

### 天干配爻

```
G = [甲, 戊, 壬, 丙, 庚]  // 五阳干序列

assignStems(startIndex, repeatAtYao4):
  stems = []
  cursor = startIndex
  for i in 0..5:
    if i == 3 and repeatAtYao4:
      stems.add(G[cursor])   // 不前进，重复
    else:
      stems.add(G[cursor % 5])
      cursor++
  return stems
```

### 策数

```
ceCount = yangYaoCount × 36 + yinYaoCount × 24
```

### 年命卦主流程

```
1. accYear = year + epochBase (10153917)
2. guaIndex = accYear % 64 (余0=64)
3. guaName = kTaiYiGuaSequence[guaIndex - 1]
4. 查 JSON 配置 → (startStem, repeatAtYao4, yunIndex, yunName)
5. stems = assignStems(...)
6. ce = ceCount(guaName)
7. 返回 NianMingGuaResultContract
```

## JSON 配置格式

```json
[
  {
    "guaName": "乾",
    "startStemIndex": 0,
    "repeatAtYao4": false,
    "yunIndex": 1,
    "yunName": "天地否泰之运"
  },
  ...
]
```

## 不变原则

- `MingGuaEngine` 及其 Contract **不动**
- `findGuaNameByYao`、`kGuaYaoMap` 等 **原地复用**
- 两个功能（命卦 vs 年命卦）结果类型独立，共享 gua_core 数据
