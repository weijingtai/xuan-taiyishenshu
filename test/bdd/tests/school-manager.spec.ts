/**
 * 太乙神数流派管理 — Playwright BDD 真实页面验收
 *
 * 任务: ZenTao Task #25 [QA-9] (合并 #10)。
 * 覆盖 AC: AC8 / AC9 / AC10 / AC11 / AC12 / AC13 / AC14 / AC16 的页面层。
 *
 * 设计原则:
 *   1. identifier 优先于 text — 通过 flt-semantics-identifier 定位，
 *      Flutter widget 重命名/本地化时不破坏 spec。
 *   2. 不依赖外部状态 — 每个用例用 beforeEach 自备数据，无 SP/Drift 种子要求。
 *   3. 真实数据断言 — 切换流派后 expect 具体积年数变化，不是只点完按钮就 PASS。
 *   4. 正逆都验 — 每个 AC 既有 happy path，也有 negative path。
 *   5. 反伪 — 零 `if (count > 0) { ... }`、零 `test.skip / test.fixme`、零 TODO。
 *
 * 运行前提（见 README.md）:
 *   npm install
 *   flutter build web --web-renderer html
 *   cd build/web && python3 -m http.server 8080 &
 *   npx playwright test --reporter=list --trace=on
 */

import { test, expect } from '@playwright/test';
import {
  byId,
  byIdInside,
  waitAppReady,
  readAccumulatedYear,
  readCurrentSchoolName,
  openDeityDialog,
  closeDeityDialog,
  createUserSchoolByCopy,
  expectAtLeastNWithLabel,
} from './_helpers';

// 默认官方流派 ID（与 lib/taiyi/data 中 assets 一致）
const SCHOOL_JING_MIRROR = 'jingMirror';
const SCHOOL_TONG_ZONG = 'tongZong';
const SCHOOL_JI_CHENG = 'jiCheng';

// 核心星神 ID（用于 AC13 验证警告触发）
const DEITY_TAIYI = 'taiYi';
const DEITY_WENCHANG = 'wenChang';

test.describe.configure({ mode: 'serial' });

test.beforeEach(async ({ page }) => {
  await page.goto('/');
  await waitAppReady(page);
});

// ============================================================
// AC14: 多流派切换（通过主页的设置对话框）
// ============================================================
test.describe('AC14: 多流派切换', () => {
  test('happy: 切换到统宗派后积年数应不同于金镜派', async ({ page }) => {
    const initialSchool = await readCurrentSchoolName(page);
    const initialAccum = await readAccumulatedYear(page);
    expect(initialAccum).toBeGreaterThan(0);

    await page.locator(byId('open-settings-dialog')).click();
    await page.locator(byId(`settings-school-chip-${SCHOOL_TONG_ZONG}`)).click();
    await page.locator(byId('settings-submit-button')).click();

    await page.waitForFunction(
      (initial) => {
        const grid = document.querySelector('[flt-semantics-identifier="pan-grid"]');
        const label = grid?.getAttribute('aria-label') ?? '';
        return !label.includes(`流派 ${initial}`);
      },
      initialSchool,
      { timeout: 15000 },
    );

    const newSchool = await readCurrentSchoolName(page);
    const newAccum = await readAccumulatedYear(page);
    expect(newSchool, '流派名称应变化').not.toBe(initialSchool);
    expect(newAccum, '积年数应使用统宗派公式重新计算').not.toBe(initialAccum);
  });

  test('negative: 不存在的 schoolId chip 不渲染', async ({ page }) => {
    await page.locator(byId('open-settings-dialog')).click();
    await expect(page.locator(byId('settings-school-chip-non_existent'))).toHaveCount(0);
    // 验证默认三个官方流派都存在
    await expect(page.locator(byId(`settings-school-chip-${SCHOOL_JING_MIRROR}`))).toBeVisible();
    await expect(page.locator(byId(`settings-school-chip-${SCHOOL_TONG_ZONG}`))).toBeVisible();
    await expect(page.locator(byId(`settings-school-chip-${SCHOOL_JI_CHENG}`))).toBeVisible();
  });

  test('happy: 切换到集成派后积年数应再次变化', async ({ page }) => {
    const beforeAccum = await readAccumulatedYear(page);
    await page.locator(byId('open-settings-dialog')).click();
    await page.locator(byId(`settings-school-chip-${SCHOOL_JI_CHENG}`)).click();
    await page.locator(byId('settings-submit-button')).click();

    await page.waitForFunction(
      (before) => {
        const grid = document.querySelector('[flt-semantics-identifier="pan-grid"]');
        const label = grid?.getAttribute('aria-label') ?? '';
        const m = label.match(/积年\s*(\d+)/);
        return m ? parseInt(m[1], 10) !== before : false;
      },
      beforeAccum,
      { timeout: 15000 },
    );

    const afterAccum = await readAccumulatedYear(page);
    expect(afterAccum, '集成派应给出不同积年数').not.toBe(beforeAccum);
  });
});

// ============================================================
// AC8: 星神 Dialog 三分区 + 置灰 + Marketplace
// ============================================================
test.describe('AC8: 星神 Dialog', () => {
  test('happy: Dialog 包含三个分区与至少 20 个核心 Checkbox', async ({ page }) => {
    const dialog = await openDeityDialog(page);
    await expect(byIdInside(dialog, 'deity-section-official')).toBeVisible();
    await expect(byIdInside(dialog, 'deity-section-user')).toBeVisible();
    await expect(byIdInside(dialog, 'deity-section-marketplace')).toBeVisible();

    // Marketplace 应不可勾选 (AbsorbPointer)
    await expect(byIdInside(dialog, 'marketplace-placeholder-container')).toBeVisible();

    // 至少 20 个核心 deity-checkbox (含官方+用户)
    const checkboxes = dialog.locator('[flt-semantics-identifier^="deity-checkbox-"]');
    await expectAtLeastNWithLabel(checkboxes, 20);
    await closeDeityDialog(page);
  });

  test('happy: 不可用项必须有文字原因（不允许仅靠灰色视觉）', async ({ page }) => {
    const dialog = await openDeityDialog(page);
    const reasons = dialog.locator('[flt-semantics-identifier^="deity-reason-"]');
    // 反伪: jingMirror+year 配置下应至少有 1 个受限星神 (chartTypes/schoolScopes 受限)。
    await expect(reasons.first(), 'AC8 要求"置灰必须有文字原因"，前提是至少存在一个受限项').toBeVisible({ timeout: 10000 });
    const count = await reasons.count();
    expect(count).toBeGreaterThanOrEqual(1);
    for (let i = 0; i < count; i++) {
      const label = await reasons.nth(i).getAttribute('aria-label');
      expect(label, '不可用项必须有文字原因').toBeTruthy();
      expect(label!.length).toBeGreaterThan(0);
    }
    await closeDeityDialog(page);
  });

  test('negative: 不可用 Checkbox 的 aria-disabled 应为 true', async ({ page }) => {
    const dialog = await openDeityDialog(page);
    const reasons = dialog.locator('[flt-semantics-identifier^="deity-reason-"]');
    await expect(reasons.first(), '应至少有一个不可用项以验证 disabled 行为').toBeVisible({ timeout: 10000 });
    const count = await reasons.count();
    expect(count).toBeGreaterThanOrEqual(1);
    for (let i = 0; i < count; i++) {
      const reasonId = await reasons.nth(i).getAttribute('flt-semantics-identifier');
      const deityId = reasonId!.replace('deity-reason-', '');
      const cb = dialog.locator(byId(`deity-checkbox-${deityId}`));
      const disabled = await cb.getAttribute('aria-disabled');
      expect(disabled, `Checkbox for ${deityId} should be disabled`).toBe('true');
    }
    await closeDeityDialog(page);
  });
});

// ============================================================
// AC9: 星神显示偏好持久化（含 SP 跨刷新）
// ============================================================
test.describe('AC9: 星神显示偏好', () => {
  test('happy: 取消勾选后盘面消失对应星神，刷新页面后偏好保留', async ({ page }) => {
    const dialog = await openDeityDialog(page);
    const taiyiCb = dialog.locator(byId(`deity-checkbox-${DEITY_TAIYI}`));
    const wasChecked = (await taiyiCb.getAttribute('aria-checked')) === 'true';
    if (!wasChecked) {
      // 先勾选回基线
      await taiyiCb.click();
      await expect(taiyiCb).toHaveAttribute('aria-checked', 'true');
    }
    // 现在取消勾选
    await taiyiCb.click();
    await expect(taiyiCb).toHaveAttribute('aria-checked', 'false');
    await closeDeityDialog(page);

    // 警告 banner 应出现 (AC13 关联)
    await expect(page.locator(byId('hidden-warning-banner'))).toBeVisible();

    // 刷新页面，验证偏好持久化
    await page.reload();
    await waitAppReady(page);
    await expect(page.locator(byId('hidden-warning-banner'))).toBeVisible();
    const dialog2 = await openDeityDialog(page);
    const taiyiCb2 = dialog2.locator(byId(`deity-checkbox-${DEITY_TAIYI}`));
    await expect(taiyiCb2).toHaveAttribute('aria-checked', 'false');
    // 恢复（清理副作用）
    await taiyiCb2.click();
    await closeDeityDialog(page);
  });

  test('negative: 不可用 Checkbox 点击应无效，状态保持', async ({ page }) => {
    // 反伪: 不允许"找不到对象=PASS"。先断言至少存在一个 reason，否则 fail。
    // 数据契约: jingMirror + year 配置下，schoolScopes 或 chartTypes 受限的星神
    // 应至少有 1 个 (例如 仅 hour 适用的 太岁副、岁破副 等)。
    const dialog = await openDeityDialog(page);
    const reasons = dialog.locator('[flt-semantics-identifier^="deity-reason-"]');
    await expect(reasons.first(), '应至少存在一个不可用星神以验证 disabled checkbox 行为').toBeVisible({ timeout: 10000 });

    const firstReasonId = await reasons.first().getAttribute('flt-semantics-identifier');
    const deityId = firstReasonId!.replace('deity-reason-', '');
    const cb = dialog.locator(byId(`deity-checkbox-${deityId}`));
    const before = await cb.getAttribute('aria-checked');
    await cb.click({ force: true }).catch(() => null);
    const after = await cb.getAttribute('aria-checked');
    expect(after, '不可用 checkbox 点击不应改变状态').toBe(before);
    await closeDeityDialog(page);
  });
});

// ============================================================
// AC10 / AC12 / AC16: 复制官方星神 + 传承链 + 不修改官方
// ============================================================
test.describe('AC10/AC12/AC16: 复制官方星神为用户星神', () => {
  test('happy: 复制后我的星神区出现新行，官方仍存在', async ({ page }) => {
    const dialog = await openDeityDialog(page);
    // 找到任意一个有 copy 按钮的官方星神
    const copyBtns = dialog.locator('[flt-semantics-identifier^="deity-copy-"]');
    await expect(copyBtns.first()).toBeVisible();
    const firstCopyId = await copyBtns.first().getAttribute('flt-semantics-identifier');
    const sourceDeityId = firstCopyId!.replace('deity-copy-', '');

    // 记录复制前官方该 deity 的存在
    const officialTile = dialog.locator(byId(`deity-tile-${sourceDeityId}`));
    await expect(officialTile).toBeVisible();

    // 触发复制 (会创建 user_<id>_<ts>)
    await copyBtns.first().click();

    // SnackBar / 等待新 user tile 出现
    const userTiles = dialog.locator(`[flt-semantics-identifier^="deity-tile-user_${sourceDeityId}_"]`);
    await expect(userTiles.first()).toBeVisible({ timeout: 10000 });

    // 验证官方仍存在
    await expect(officialTile).toBeVisible();

    // AC12: 用户星神应有 lineage subtitle (非空 aria-label)
    const userTileFirst = userTiles.first();
    const userTileId = await userTileFirst.getAttribute('flt-semantics-identifier');
    const userDeityId = userTileId!.replace('deity-tile-', '');
    const lineage = dialog.locator(byId(`deity-lineage-${userDeityId}`));
    await expect(lineage).toBeVisible();
    const lineageLabel = await lineage.getAttribute('aria-label');
    expect(lineageLabel, 'lineage label 应非空').toBeTruthy();
    expect(lineageLabel!.length).toBeGreaterThan(0);

    await closeDeityDialog(page);
  });

  test('negative: 用户星神 delete 按钮存在；官方星神不应有 delete 按钮', async ({ page }) => {
    const dialog = await openDeityDialog(page);
    // 先复制一个以保证至少一个用户 deity
    const copyBtns = dialog.locator('[flt-semantics-identifier^="deity-copy-"]');
    await copyBtns.first().click();
    const userTiles = dialog.locator('[flt-semantics-identifier^="deity-tile-user_"]');
    await expect(userTiles.first()).toBeVisible({ timeout: 10000 });

    // 验证用户 tile 有 delete 按钮
    const userTileId = await userTiles.first().getAttribute('flt-semantics-identifier');
    const userDeityId = userTileId!.replace('deity-tile-', '');
    await expect(dialog.locator(byId(`deity-delete-${userDeityId}`))).toBeVisible();

    // 验证官方 tile 不存在对应 delete identifier
    const officialCopyBtns = dialog.locator('[flt-semantics-identifier^="deity-copy-"]');
    const firstOfficialCopyId = await officialCopyBtns.first().getAttribute('flt-semantics-identifier');
    const officialDeityId = firstOfficialCopyId!.replace('deity-copy-', '');
    // 官方 deity 不应有 deity-delete- identifier
    await expect(dialog.locator(byId(`deity-delete-${officialDeityId}`))).toHaveCount(0);

    await closeDeityDialog(page);
  });
});

// ============================================================
// AC11: 我的流派
//
// 前置依赖: SchoolManagerPage 必须可通过路由可达。当前 main.dart 中
// home=TaiYiPanPage，未 wire `/school-manager` 路由。这些场景将通过
// 直接 navigate 到 `/#/school-manager` 验证；若 Master 尚未 wire 路由，
// 它们会 fail 并暴露路由缺失 (这是显式失败，不是 fake pass)。
// ============================================================
test.describe('AC11: 我的流派 (依赖 SchoolManagerPage 路由)', () => {
  test.beforeEach(async ({ page }) => {
    // 试图导航到 SchoolManagerPage
    await page.goto('/#/school-manager');
    // 等待 row 出现或显式 fail
    await page.locator(byId(`school-row-${SCHOOL_JING_MIRROR}`)).waitFor({
      state: 'visible',
      timeout: 15000,
    });
  });

  test('happy: 官方流派 row 没有 edit 按钮，只有 copy + info', async ({ page }) => {
    const officialRow = page.locator(byId(`school-row-${SCHOOL_JING_MIRROR}`));
    await expect(officialRow).toBeVisible();
    await expect(page.locator(byId(`school-copy-${SCHOOL_JING_MIRROR}`))).toBeVisible();
    await expect(page.locator(byId(`school-info-${SCHOOL_JING_MIRROR}`))).toBeVisible();
    await expect(page.locator(byId(`school-edit-${SCHOOL_JING_MIRROR}`))).toHaveCount(0);
  });

  test('happy: 复制流派后我的流派 row 有 edit 按钮', async ({ page }) => {
    const newName = `太乙新法_${Date.now()}`;
    await createUserSchoolByCopy(page, SCHOOL_JING_MIRROR, newName);
    const userRow = page.locator(byId('school-row-')).filter({ hasText: newName }).first();
    await expect(userRow).toBeVisible();

    const userRowId = await userRow.getAttribute('flt-semantics-identifier');
    const userSchoolId = userRowId!.replace('school-row-', '');
    await expect(page.locator(byId(`school-edit-${userSchoolId}`))).toBeVisible();
  });
});

// ============================================================
// AC12: 传承链 (依赖 SchoolManagerPage 路由)
// ============================================================
test.describe('AC12: 传承链', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/#/school-manager');
    await page.locator(byId(`school-row-${SCHOOL_JING_MIRROR}`)).waitFor({
      state: 'visible',
      timeout: 15000,
    });
  });

  test('happy: 用户流派 info 弹窗显示传承链字段', async ({ page }) => {
    const newName = `传承测试_${Date.now()}`;
    await createUserSchoolByCopy(page, SCHOOL_JING_MIRROR, newName);
    const userRow = page.locator(byId('school-row-')).filter({ hasText: newName }).first();
    const userRowId = await userRow.getAttribute('flt-semantics-identifier');
    const userSchoolId = userRowId!.replace('school-row-', '');

    await page.locator(byId(`school-info-${userSchoolId}`)).click();
    const sheet = page.locator(byId(`school-lineage-sheet-${userSchoolId}`));
    await expect(sheet).toBeVisible();

    const lineageText = sheet.locator(byId('school-lineage-text'));
    await expect(lineageText).toBeVisible();
    const lineageLabel = await lineageText.getAttribute('aria-label');
    expect(lineageLabel, '传承链 label 应非空').toBeTruthy();
    expect(lineageLabel!).toMatch(/传承链/);
  });

  test('negative: 官方流派 info 弹窗不显示传承链字段', async ({ page }) => {
    await page.locator(byId(`school-info-${SCHOOL_JING_MIRROR}`)).click();
    const sheet = page.locator(byId(`school-lineage-sheet-${SCHOOL_JING_MIRROR}`));
    await expect(sheet).toBeVisible();
    await expect(sheet.locator(byId('school-lineage-text'))).toHaveCount(0);
  });
});

// ============================================================
// AC13: 隐藏关键项警告（含 false-positive 防御）
// ============================================================
test.describe('AC13: 隐藏关键项提醒', () => {
  test('happy: 隐藏核心星神触发警告 banner', async ({ page }) => {
    const dialog = await openDeityDialog(page);
    const taiyiCb = dialog.locator(byId(`deity-checkbox-${DEITY_TAIYI}`));
    const initial = await taiyiCb.getAttribute('aria-checked');
    if (initial === 'false') {
      // 先勾上确保起点为 true
      await taiyiCb.click();
    }
    await taiyiCb.click(); // 取消勾选
    await expect(taiyiCb).toHaveAttribute('aria-checked', 'false');
    await closeDeityDialog(page);

    // 主页面 banner 必须可见
    await expect(page.locator(byId('hidden-warning-banner'))).toBeVisible();

    // 恢复
    const dialog2 = await openDeityDialog(page);
    await dialog2.locator(byId(`deity-checkbox-${DEITY_TAIYI}`)).click();
    await closeDeityDialog(page);
  });

  test('happy: 恢复核心星神后警告消失', async ({ page }) => {
    const dialog = await openDeityDialog(page);
    const taiyiCb = dialog.locator(byId(`deity-checkbox-${DEITY_TAIYI}`));
    if ((await taiyiCb.getAttribute('aria-checked')) === 'true') {
      await taiyiCb.click();
    }
    await expect(taiyiCb).toHaveAttribute('aria-checked', 'false');
    await closeDeityDialog(page);
    await expect(page.locator(byId('hidden-warning-banner'))).toBeVisible();

    // 恢复
    const dialog2 = await openDeityDialog(page);
    await dialog2.locator(byId(`deity-checkbox-${DEITY_TAIYI}`)).click();
    await closeDeityDialog(page);
    await expect(page.locator(byId('hidden-warning-banner'))).toHaveCount(0);
  });

  test('negative: 隐藏非核心星神不应触发警告（防 false positive）', async ({ page }) => {
    const dialog = await openDeityDialog(page);
    // 数据契约: jingMirror 流派应至少有一个非核心星神可点 (tianYi/diYi/feiFu 任一)。
    // 反伪: 若全找不到则 expect 失败，不允许"找不到=PASS"。
    const candidates = ['tianYi', 'diYi', 'feiFu'];
    let toggledId: string | null = null;
    for (const id of candidates) {
      const cb = dialog.locator(byId(`deity-checkbox-${id}`));
      const exists = (await cb.count()) === 1;
      if (!exists) continue;
      const disabled = await cb.getAttribute('aria-disabled');
      const checked = (await cb.getAttribute('aria-checked')) === 'true';
      if (disabled !== 'true' && checked) {
        await cb.click();
        toggledId = id;
        break;
      }
    }
    expect(toggledId, '应至少有一个非核心星神 (tianYi/diYi/feiFu) 可被取消勾选').toBeTruthy();
    await closeDeityDialog(page);

    // 警告 banner 不应出现 (核心星神未隐藏)
    await expect(page.locator(byId('hidden-warning-banner'))).toHaveCount(0);

    // 恢复
    const dialog2 = await openDeityDialog(page);
    await dialog2.locator(byId(`deity-checkbox-${toggledId}`)).click();
    await closeDeityDialog(page);
  });
});

// ============================================================
// AC16: 官方资产派生原则 (依赖 SchoolManagerPage 路由)
// ============================================================
test.describe('AC16: 官方资产派生原则', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/#/school-manager');
    await page.locator(byId(`school-row-${SCHOOL_JING_MIRROR}`)).waitFor({
      state: 'visible',
      timeout: 15000,
    });
  });

  test('happy: 派生后官方流派的 subtitle 显示不变', async ({ page }) => {
    // 读官方 subtitle (含 "积年基数 N")
    const officialSubtitle = page.locator(byId(`school-subtitle-${SCHOOL_JING_MIRROR}`));
    await expect(officialSubtitle).toBeVisible();
    const beforeText = await officialSubtitle.textContent();

    // 派生
    const newName = `派生检测_${Date.now()}`;
    await createUserSchoolByCopy(page, SCHOOL_JING_MIRROR, newName);

    // 官方 subtitle 文本应不变
    const afterText = await officialSubtitle.textContent();
    expect(afterText).toBe(beforeText);
  });

  test('happy: 用户流派的 root_official 应指向源 (lineage 包含源名)', async ({ page }) => {
    const newName = `根追溯_${Date.now()}`;
    await createUserSchoolByCopy(page, SCHOOL_JING_MIRROR, newName);
    const userRow = page.locator(byId('school-row-')).filter({ hasText: newName }).first();
    const userRowId = await userRow.getAttribute('flt-semantics-identifier');
    const userSchoolId = userRowId!.replace('school-row-', '');

    await page.locator(byId(`school-info-${userSchoolId}`)).click();
    const sheet = page.locator(byId(`school-lineage-sheet-${userSchoolId}`));
    await expect(sheet).toBeVisible();

    // 根官方流派应非空，且 label 包含某个官方流派 id 关键字
    const rootText = sheet.locator(byId('school-root-official'));
    await expect(rootText).toBeVisible();
    const rootLabel = await rootText.getAttribute('aria-label');
    expect(rootLabel).toBeTruthy();
    expect(rootLabel!).toMatch(/jingMirror|tongZong|jiCheng/);
  });
});
