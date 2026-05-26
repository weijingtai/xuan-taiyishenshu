import { defineConfig, devices } from '@playwright/test';

/**
 * 太乙神数流派管理系统 Playwright BDD 测试配置
 *
 * 任务: ZenTao Task #25 [QA-9] + Task #10
 * 设计原则: 强制 trace + screenshot；single-worker 串行；零 retry；
 *           本地无 webServer 自动管理，由人或 CI 脚本预 serve（避免在沙箱中 spawn）。
 *
 * 运行前提:
 *   1. cd test/bdd && npm install && npx playwright install chromium
 *   2. flutter build web --web-renderer html  (从仓库根)
 *   3. cd build/web && python3 -m http.server 8080 &
 *   4. cd test/bdd && npx playwright test --reporter=list,html --trace=on
 */
export default defineConfig({
  testDir: './tests',
  testMatch: '**/*.spec.ts',
  fullyParallel: false,
  forbidOnly: !!process.env.CI,
  retries: 0, // 反伪: 不允许 retry 掩盖 flaky 测试。
  workers: 1, // 串行执行以避免 SP/Drift 共享态。
  reporter: [
    ['list'],
    ['html', { open: 'never', outputFolder: 'playwright-report' }],
  ],
  outputDir: 'test-results',
  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:8080',
    // 反伪: trace 与 screenshot 强制 on，每个失败都留证。
    trace: 'on',
    screenshot: 'on',
    video: 'retain-on-failure',
    actionTimeout: 15000,
    navigationTimeout: 30000,
  },
  expect: {
    timeout: 10000,
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],
});
