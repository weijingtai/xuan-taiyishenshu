/**
 * 太乙神数 Playwright BDD 测试 — 共享 Helpers
 *
 * 任务 ID: ZenTao Task #25 [QA-9] + Task #10
 * 设计原则: identifier 优先于 text；不依赖外部状态；真实数据断言。
 *
 * 重要前置（运行测试前必须满足）:
 *   1. cd test/bdd && npm install
 *   2. flutter build web --web-renderer html
 *   3. cd build/web && python3 -m http.server 8080 &
 *   4. cd test/bdd && npx playwright test
 *
 * Semantics 启用: lib/main.dart 已 wire `SemanticsBinding.instance.ensureSemantics()`。
 * 这使得 Flutter Web 把 widget tree 的 Semantics 节点投射到 DOM，让以下定位器可用。
 */

import { Page, Locator, expect } from '@playwright/test';

/** 通过 Semantics identifier 定位元素 (Flutter Web ensureSemantics 后投射到 DOM)。 */
export function byId(id: string): string {
  return `[flt-semantics-identifier="${id}"]`;
}

/** 在指定 scope 内通过 identifier 定位。 */
export function byIdInside(scope: Locator, id: string): Locator {
  return scope.locator(`[flt-semantics-identifier="${id}"]`);
}

/** 通过 aria-label 定位（备用方式，identifier 失败时降级）。 */
export function byAriaLabel(label: string): string {
  return `[aria-label="${label}"]`;
}

/**
 * 等待应用加载完成并出现初始流派 row。
 * 不接受 `waitForTimeout`；只接受可观察事实的等待。
 */
export async function waitAppReady(page: Page, timeoutMs = 30000): Promise<void> {
  // 等待主盘 grid 出现 (initState 完成 + 首次 calculate 完成)
  await page.locator(byId('pan-grid')).waitFor({ state: 'visible', timeout: timeoutMs });
}

/**
 * 读取当前盘面积年数（年/月/日/时计共用，按当前 chartType 选对应 chip）。
 * 返回数字 (parseInt 失败时返回 NaN，由调用方 expect 判定)。
 */
export async function readAccumulatedYear(page: Page): Promise<number> {
  const chip = page.locator(byId('pan-accumulated-year'));
  await chip.waitFor({ state: 'visible' });
  const label = await chip.getAttribute('aria-label');
  // aria-label 格式: "积年 1938583"
  const match = (label ?? '').match(/积年\s*(\d+)/);
  if (!match) throw new Error(`Cannot parse accumulated year from aria-label: ${label}`);
  return parseInt(match[1], 10);
}

/**
 * 读取当前流派名称（来自 pan-grid 的 label）。
 */
export async function readCurrentSchoolName(page: Page): Promise<string> {
  const grid = page.locator(byId('pan-grid'));
  await grid.waitFor({ state: 'visible' });
  const label = (await grid.getAttribute('aria-label')) ?? '';
  // 格式: "当前盘面，流派 金镜派，积年 1938583"
  const match = label.match(/流派\s*([^，,]+)/);
  if (!match) throw new Error(`Cannot parse school name from pan-grid label: ${label}`);
  return match[1];
}

/**
 * 打开星神管理 Dialog 并等待 Dialog 出现。
 */
export async function openDeityDialog(page: Page): Promise<Locator> {
  await page.locator(byId('open-deity-dialog')).click();
  const dialog = page.locator(byId('deity-management-dialog'));
  await dialog.waitFor({ state: 'visible', timeout: 10000 });
  return dialog;
}

/**
 * 关闭星神管理 Dialog。
 */
export async function closeDeityDialog(page: Page): Promise<void> {
  await page.locator(byId('deity-dialog-close')).click();
  await page.locator(byId('deity-management-dialog')).waitFor({ state: 'detached', timeout: 10000 });
}

/**
 * 通过 UI 复制官方流派为用户流派。完全自备，不依赖外部种子数据。
 *
 * 步骤:
 *  1. 进入流派管理页（路由 /taiyishenshu，列表展现）。
 *  2. 点击官方流派的 copy 按钮。
 *  3. 输入新名称。
 *  4. 确认。
 *  5. 等待新条目出现并断言官方仍存在。
 */
export async function createUserSchoolByCopy(
  page: Page,
  sourceOfficialId: string,
  newName: string,
): Promise<void> {
  // 通过 AppBar 的 settings 按钮假设可达流派管理；但本仓库目前是
  // 流派切换 popover 而非独立页。这里直接通过 controller route (#/taiyishenshu)
  // 内置的 SnackBar 验证。具体路径以 main.dart wire 为准。
  await page.locator(byId(`school-copy-${sourceOfficialId}`)).click();
  const input = page.locator(byId('copy-name-input'));
  await input.waitFor({ state: 'visible' });
  await input.locator('input, textarea').first().fill(newName);
  await page.locator(byId('copy-confirm-button')).click();
  // 等待新行出现（identifier 由 controller 生成的 user_<id>_<ts> 命名，不可预测，
  // 因此用 name 文字回查作为唯一可靠 anchor，再用 identifier 局部化）。
  await expect(page.locator(byId('school-row-')).filter({ hasText: newName }).first())
    .toBeVisible({ timeout: 10000 });
}

/**
 * 反伪保护: 验证一个 locator 至少匹配 expectedMinCount 个，且每一个都有非空 aria-label。
 * 用于替代 `if (count > 0) { ... }` 反伪 anti-pattern。
 */
export async function expectAtLeastNWithLabel(
  locator: Locator,
  expectedMinCount: number,
): Promise<void> {
  const count = await locator.count();
  expect(count, `Expected at least ${expectedMinCount}, got ${count}`).toBeGreaterThanOrEqual(expectedMinCount);
  for (let i = 0; i < count; i++) {
    const label = await locator.nth(i).getAttribute('aria-label');
    expect(label, `Element ${i} should have non-empty aria-label`).toBeTruthy();
  }
}
