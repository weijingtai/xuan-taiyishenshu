# BASELINE: xuan-taiyishenshu 开工前既有测试/分析基线

> 只读记录，未修改任何文件。
> 分支: feat/taiyi-algorithm-config-management
> 日期: 2026-06-08

---

## 1. flutter test test/taiyi/

```
总计: 173 tests
通过: 170
失败: 3
错误: 0
```

### 失败用例 (3 个，均在同一文件)

| # | 测试名 | 文件 | 行号 | 错误 |
|---|--------|------|------|------|
| 1 | 太乙在金镜派2026年位置验证 | official_assets_verification_test.dart | — | Expected: not null / Actual: <null> |
| 2 | 文昌在金镜派2026年位置验证 | official_assets_verification_test.dart | 79 | Null check operator used on a null value |
| 3 | Regression - Official File Paths (kebab-case) | official_assets_verification_test.dart | 104 | Expected: not null / Actual: <null> |

### 根因

三个失败均源于 `jingMirror` 学校资源文件未找到：
```
school asset not found for ID 'jingMirror'
at path: assets/schools/jing-mirror.json
```

推测原因：资源文件路径或 assets 声明在近期改动中被破坏，导致 `OfficialJsonSchoolRepository` 无法加载 `jing-mirror.json`。

### 标记

以上 3 个失败为 **pre-existing**，不在本次 rule-engine 改动范围内，不做修复。

---

## 2. flutter analyze

```
总计: 307 issues
errors:   0
warnings: 71
info:     236
```

### 主要 warnings 分类

| 类型 | 数量 | 说明 |
|------|------|------|
| unused_import | 3 | test 文件中 |
| undefined_shown_name | 7 | SchoolRepository 导出了不存在的 Mapper 类型 |
| unused_local_variable | 1 | |
| avoid_relative_lib_imports | 若干 | |
| unnecessary_import | 若干 | |
| deprecated_member_use | 若干 | |

### 标记

71 个 warnings 均为 **pre-existing**，不在本次改动范围内。0 errors 满足基线要求。

---

## 3. 总结

| 指标 | 值 | 状态 |
|------|-----|------|
| 测试通过率 | 170/173 (98.3%) | pre-existing 3 红 |
| analyzer errors | 0 | ✅ 无阻塞 |
| analyzer warnings | 71 | pre-existing |
| 本次引入新失败 | 0 | 待验证 |
