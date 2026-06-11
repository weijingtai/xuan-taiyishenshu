# Tasks: taiyi-minggua-destiny

## Phase 1: Interface + 命卦核心

- [ ] 在 `repository-interface-taiyishenshu` 新增 `ming_gua_contracts.dart`（freezed DTO）
- [ ] 在 `repository-interface-taiyishenshu` 新增 `destiny_contracts.dart`（freezed DTO）
- [ ] 在 `repository-interface-taiyishenshu` 新增 `ming_gua_repository.dart`（抽象接口）
- [ ] 在 `repository-interface-taiyishenshu` 新增 `destiny_repository.dart`（抽象接口）
- [ ] 运行 `build_runner` 生成 freezed 代码
- [ ] 创建 `lib/minggua/core/gua_sequence.dart`（64卦序常量 + 八卦六爻数据）
- [ ] 创建 `lib/minggua/core/gua_models.dart`（内部模型）
- [ ] 创建 `lib/minggua/core/ming_gua_engine.dart`（核心计算引擎）
- [ ] 编写命卦单元测试（算法 + 卦序校验）

## Phase 2: 命卦 Repository + UseCase + UI

- [ ] 创建 `assets/minggua/tong_zong_sequence.json`
- [ ] 创建 `assets/minggua/config.json`
- [ ] 实现 `lib/minggua/repository/ming_gua_repository_impl.dart`
- [ ] 实现 `lib/minggua/usecases/calculate_ming_gua_usecase.dart`
- [ ] 实现 `lib/minggua/viewmodels/ming_gua_view_model.dart`
- [ ] 创建 `lib/pages/ming_gua_sample_page.dart`（MVP UI）
- [ ] 集成测试

## Phase 3: 命法核心

- [ ] 创建 `lib/destiny/core/destiny_models.dart`
- [ ] 创建 `lib/destiny/core/twelve_palaces.dart`（十二宫映射解释器）
- [ ] 创建 `lib/destiny/core/destiny_engine.dart`（调度引擎）
- [ ] 创建 `lib/destiny/rules/destiny_rule_kinds.dart`（如需新 rule kind）
- [ ] 创建 `assets/destiny/tong_zong_destiny.json`（统宗命法规则集）
- [ ] 创建 `assets/destiny/twelve_palaces_default.json`（默认映射）
- [ ] 编写命法单元测试

## Phase 4: 命法 Repository + UseCase + UI

- [ ] 实现 `lib/destiny/repository/destiny_repository_impl.dart`
- [ ] 实现 `lib/destiny/usecases/calculate_destiny_usecase.dart`
- [ ] 实现 `lib/destiny/viewmodels/destiny_view_model.dart`
- [ ] 创建 `lib/pages/destiny_sample_page.dart`（MVP UI）
- [ ] 集成测试

## Phase 5: 验证 + 文档

- [ ] 端到端集成测试
- [ ] Import boundary 测试（minggua/ ≠ destiny/）
- [ ] 更新 README.md
- [ ] 更新 Understand Anything 知识图谱
- [ ] 归档 OpenSpec（标记完成）
