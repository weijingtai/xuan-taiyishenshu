# 太乙神数流派管理系统 — Playwright BDD 页面验收

## 概述

本目录包含 Story#4 的 Playwright BDD 页面验收测试，覆盖以下验收标准：

| AC  | 描述 | Feature 文件 |
|-----|------|-------------|
| AC8 | 星神 Dialog | deity_dialog.feature |
| AC9 | 星神显示偏好 | deity_dialog.feature |
| AC10 | 我的星神 | my_deity.feature |
| AC11 | 我的流派 | my_school.feature |
| AC12 | 传承链 | my_deity.feature / my_school.feature |
| AC13 | 隐藏关键项提醒 | hidden_key_warning.feature |
| AC14 | 多流派切换 | school_switching.feature |
| AC16 | 官方资产派生原则 | my_school.feature |

## 文件结构

```
test/bdd/
├── README.md                         # 本文件
├── package.json                      # npm 依赖
├── playwright.config.ts              # Playwright 配置
├── tsconfig.json                     # TypeScript 配置
├── features/                         # Gherkin Feature 文件
│   ├── school_switching.feature      # AC14 多流派切换
│   ├── deity_dialog.feature          # AC8/AC9 星神 Dialog
│   ├── my_deity.feature              # AC10/AC12 我的星神
│   ├── my_school.feature             # AC11/AC12/AC16 我的流派
│   └── hidden_key_warning.feature    # AC13 隐藏关键项提醒
└── tests/
    └── school-manager.spec.ts        # Playwright 测试实现
```

## 运行前提

1. **Flutter Web 构建**:
   ```bash
   cd xuan-taiyishenshu
   flutter build web --web-renderer html
   ```

2. **本地 Serve**:
   ```bash
   cd build/web
   python3 -m http.server 8080
   ```

3. **安装依赖**:
   ```bash
   cd test/bdd
   npm install
   npx playwright install chromium
   ```

## 运行测试

```bash
# 运行全部
npm test

# 带浏览器界面
npm run test:headed

# 调试模式
npm run test:debug

# 查看报告
npm run report
```

## 环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| BASE_URL | http://localhost:8080 | Flutter web 应用地址 |

## 注意事项

- **Flutter Web 选择器**: Flutter web (HTML renderer) 使用标准 DOM，可用 CSS 选择器和语义属性。CanvasKit renderer 使用 canvas + flt-semantics，需调整选择器。
- **前置条件**: 部分测试依赖用户已有自定义流派/星神。实际运行时需要通过 setup 脚本或 API 准备测试数据。
- **选择器调整**: 测试中的选择器（如 `[aria-label*="星神"]`）需要根据实际 Flutter UI 实现调整。
- **本测试不替代 Flutter 单元测试**: 只验证页面行为是否符合需求。
