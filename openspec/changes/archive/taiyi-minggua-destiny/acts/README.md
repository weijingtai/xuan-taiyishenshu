# ACTs: taiyi-minggua-destiny

AI Agent 可直接执行的具体任务（按依赖顺序排列）。

## 执行顺序

### Phase 1: 命卦核心 + Interface

| ACT | 任务 | 目标文件 | 依赖 |
|-----|------|----------|------|
| ACT-001 | 64卦序常量数据 + 六爻编码 | `lib/minggua/core/gua_sequence.dart` | 无 |
| ACT-002 | 命卦核心计算引擎 | `lib/minggua/core/ming_gua_engine.dart` | ACT-001 |
| ACT-003 | 命卦 Contract DTO (freezed) | `repository-interface.../ming_gua_contracts.dart` | 无 |
| ACT-004 | 命卦 Repository 接口 | `repository-interface.../ming_gua_repository.dart` | ACT-003 |

### Phase 2: 命卦应用层

| ACT | 任务 | 目标文件 | 依赖 |
|-----|------|----------|------|
| ACT-005 | 命卦 Repository 实现 | `lib/minggua/repository/ming_gua_repository_impl.dart` | ACT-004, ACT-012 |
| ACT-006 | UseCase + ViewModel | `lib/minggua/usecases/` + `viewmodels/` | ACT-002, ACT-005 |
| ACT-010 | 命卦 MVP UI 页面 | `lib/pages/ming_gua_sample_page.dart` | ACT-006 |
| ACT-012 | 资产 JSON 文件 | `assets/minggua/tong_zong_sequence.json` | 无 |

### Phase 3: 命法核心 + Interface

| ACT | 任务 | 目标文件 | 依赖 |
|-----|------|----------|------|
| ACT-007 | 命法 Contract DTO (freezed) | `repository-interface.../destiny_contracts.dart` | 无 |
| ACT-008 | 十二宫映射引擎 | `lib/destiny/core/twelve_palaces.dart` | ACT-007 |
| ACT-009 | 命法核心调度引擎 | `lib/destiny/core/destiny_engine.dart` | ACT-008 |

### Phase 4: 命法应用层

| ACT | 任务 | 目标文件 | 依赖 |
|-----|------|----------|------|
| ACT-011 | 命法 MVP UI 页面 | `lib/pages/destiny_sample_page.dart` | ACT-009 |

## 并行执行指南

可并行的任务组：
- **Group A**（无依赖）：ACT-001, ACT-003, ACT-007, ACT-012
- **Group B**（依赖 Group A）：ACT-002, ACT-004, ACT-005, ACT-008
- **Group C**（依赖 Group B）：ACT-006, ACT-009, ACT-010, ACT-011
