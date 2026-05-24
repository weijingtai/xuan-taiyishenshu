import { defineConfig, devices } from '@playwright/test';

/**
 * 太乙神数流派管理系统 Playwright BDD 测试配置
 *
 * 运行前提：
 * 1. Flutter web build: flutter build web --web-renderer html
 * 2. 本地 serve: cd build/web && python3 -m http.server 8080
 * 3. 运行测试: npx playwright test
 */
export default defineConfig({
  testDir: './tests',
  fullyParallel: false,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: 1,
  reporter: [['html', { open: 'never' }]],
  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:8080',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],
});
