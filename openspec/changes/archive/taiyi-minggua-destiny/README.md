# OpenSpec Change: taiyi-minggua-destiny

太乙命卦（统运入卦）+ 太乙人道命法（命盘）双体系开发。

## 目标

1. **太乙命卦（minggua）**：积年÷64 → 定本卦 → 定动爻 → 变卦，完整实现统宗命卦体系。
2. **太乙人道命法（destiny）**：时计局法入盘 → 星神定位 → 十二人身宫映射，全配置化可编辑。
3. 两者共享 MVVM+UseCase+Repository 架构，Contract 扩展 `repository-interface-taiyishenshu`。
4. MVP UI Sample 可直接看到计算结果。

## 与既有 change 的关系

- **依赖** `taiyi-rule-engine`：命法复用其规则引擎基础设施（rule kinds、JSON 算术树、SchoolDocument 模型）。
- **依赖** 现有 `taiyi_pan_calculator`：命法复用时计积时/入局/星神定位逻辑。
- 命卦为独立轻量引擎，不依赖 rule engine（算法简单，无需复杂规则调度）。

## 核心算法参照

- 命卦：`docs/classes/ming_gua.md`（卷十三64卦序 + 起卦公式）
- 命法：`docs/classes/ming_fa_vs_ming_gua.md`（五步流程详解）
- 命法校验清单：`docs/classes/ming_fa_vs_ming_gua_2.md`

## 数理基准

- 统宗积年：`公元后年份 + 10153917`
- 太乙卦序：卷十三专属64卦序（第43位为"姤"，非通行序的"夬"）
- 太乙九宫：乾1·离2·艮3·震4·中5(不入)·兑6·坤7·坎8·巽9（非洛书）

## Validation

```bash
openspec validate taiyi-minggua-destiny --strict --no-interactive
flutter test test/minggua/
flutter test test/destiny/
```
