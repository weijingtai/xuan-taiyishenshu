/**
 * 太乙神数流派管理系统 BDD Step Definitions
 *
 * 覆盖 AC8-AC14, AC16 的页面验收场景。
 *
 * Flutter Web 注意事项：
 * - Flutter web (HTML renderer) 使用标准 DOM，可用 CSS 选择器
 * - Flutter web (CanvasKit renderer) 使用 canvas，需用 flt-semantics 节点
 * - 本测试假设使用 HTML renderer，选择器需根据实际构建调整
 */

import { test, expect, Page, Locator } from '@playwright/test';

// ============================================================
// Helper: Flutter web 页面中的通用定位器
// ============================================================

/** 通过语义文本定位元素 */
function byText(text: string): string {
  return `text="${text}"`;
}

/** 通过 tooltip/aria-label 定位按钮 */
function byRole(role: string, name?: string): string {
  if (name) return `[role="${role}"][aria-label*="${name}"], [role="${role}"]:has-text("${name}")`;
  return `[role="${role}"]`;
}

/** Checkbox 定位器 */
function checkboxFor(label: string): string {
  return `[role="checkbox"][aria-label*="${label}"], input[type="checkbox"][aria-label*="${label}"]`;
}

// ============================================================
// AC14: 多流派切换
// ============================================================

test.describe('AC14: 多流派切换', () => {

  test('切换到统宗派后重新排盘', async ({ page }) => {
    await page.goto('/');
    // 假设默认是金镜派
    await expect(page.locator(byText('金镜派'))).toBeVisible();

    // 打开流派选择器
    await page.locator(byText('金镜派')).click();

    // 选择统宗派
    await page.locator(byText('统宗派')).click();

    // 盘面刷新，验证积年数变化
    await expect(page.locator(byText('统宗派'))).toBeVisible();
    // 具体积年数值需要根据实际 UI 调整
  });

  test('切换到用户自定义流派', async ({ page }) => {
    await page.goto('/');
    // 前置条件：用户已创建"我的金镜派"
    // 这里测试 UI 切换行为
    await page.locator(byText('金镜派')).click();

    // 验证用户流派出现在列表中
    const userSchool = page.locator(byText('我的金镜派'));
    await expect(userSchool).toBeVisible();

    // 切换到用户流派
    await userSchool.click();

    // 验证盘面刷新
    await expect(page.locator(byText('我的金镜派'))).toBeVisible();
  });

  test('从自定义流派切回官方流派', async ({ page }) => {
    await page.goto('/');
    // 假设当前是用户流派
    await page.locator(byText('我的金镜派')).click();
    await page.locator(byText('金镜派')).click();

    // 验证切回官方流派
    await expect(page.locator(byText('金镜派'))).toBeVisible();
  });
});

// ============================================================
// AC8: 星神 Dialog
// ============================================================

test.describe('AC8: 星神 Dialog', () => {

  test('打开星神 Dialog', async ({ page }) => {
    await page.goto('/');

    // 点击星神管理按钮
    await page.locator('[aria-label*="星神"], button:has-text("星神")').click();

    // 验证 Dialog 出现
    const dialog = page.locator('[role="dialog"], .dialog, .modal');
    await expect(dialog).toBeVisible();

    // 验证三个分区
    await expect(dialog.locator(byText('系统内置'))).toBeVisible();
    await expect(dialog.locator(byText('我的'))).toBeVisible();
    await expect(dialog.locator(byText('Marketplace'))).toBeVisible();
  });

  test('系统内置核心星神列表完整', async ({ page }) => {
    await page.goto('/');
    await page.locator('[aria-label*="星神"], button:has-text("星神")').click();

    const dialog = page.locator('[role="dialog"], .dialog, .modal');

    // 核心层 20 个星神
    const coreDeities = [
      '太乙', '文昌', '计神', '始击',
      '主大将', '客大将', '主参将', '客参将', '定大将', '定参将',
      '君基', '臣基', '民基', '五福', '大游', '小游',
      '太岁', '岁破', '直符', '合神', '四神', '天乙', '地乙', '飞符',
    ];

    for (const deity of coreDeities) {
      await expect(dialog.locator(byText(deity))).toBeVisible();
    }
  });

  test('每个星神旁有 Checkbox', async ({ page }) => {
    await page.goto('/');
    await page.locator('[aria-label*="星神"], button:has-text("星神")').click();

    const dialog = page.locator('[role="dialog"], .dialog, .modal');
    // 验证至少有 Checkbox 存在
    const checkboxes = dialog.locator('[role="checkbox"], input[type="checkbox"]');
    await expect(checkboxes.first()).toBeVisible();
    const count = await checkboxes.count();
    expect(count).toBeGreaterThanOrEqual(20); // 至少核心层 20 个
  });
});

// ============================================================
// AC9: 星神显示偏好
// ============================================================

test.describe('AC9: 星神显示偏好', () => {

  test('勾选星神后盘面立即刷新', async ({ page }) => {
    await page.goto('/');
    await page.locator('[aria-label*="星神"], button:has-text("星神")').click();

    const dialog = page.locator('[role="dialog"], .dialog, .modal');
    // 假设"君基"当前未勾选
    const junJiCheckbox = dialog.locator(checkboxFor('君基'));
    await junJiCheckbox.click();

    // 关闭 Dialog
    await page.keyboard.press('Escape');

    // 验证盘面上出现"君基"
    await expect(page.locator(byText('君基'))).toBeVisible();
  });

  test('取消勾选星神后盘面立即隐藏', async ({ page }) => {
    await page.goto('/');
    await page.locator('[aria-label*="星神"], button:has-text("星神")').click();

    const dialog = page.locator('[role="dialog"], .dialog, .modal');
    // 假设"君基"当前已勾选
    const junJiCheckbox = dialog.locator(checkboxFor('君基'));
    await junJiCheckbox.click(); // 取消勾选

    await page.keyboard.press('Escape');

    // 验证盘面上"君基"消失（在落宫区域，非 Dialog 内）
    // 具体断言需要根据实际 UI 结构调整
  });
});

// ============================================================
// AC8 (续): 不可用项置灰
// ============================================================

test.describe('AC8: 星神可用性', () => {

  test('不可用的星神置灰并显示原因', async ({ page }) => {
    await page.goto('/');
    await page.locator('[aria-label*="星神"], button:has-text("星神")').click();

    const dialog = page.locator('[role="dialog"], .dialog, .modal');

    // 查找置灰的星神项
    const greyedItems = dialog.locator('.disabled, [aria-disabled="true"], .greyed-out');
    const count = await greyedItems.count();

    if (count > 0) {
      // 验证置灰项有不可用原因说明
      for (let i = 0; i < count; i++) {
        const item = greyedItems.nth(i);
        const reasonText = await item.locator('.reason, .tooltip, [title]').textContent();
        expect(reasonText).toBeTruthy();
      }
    }
  });

  test('置灰的星神 Checkbox 不可勾选', async ({ page }) => {
    await page.goto('/');
    await page.locator('[aria-label*="星神"], button:has-text("星神")').click();

    const dialog = page.locator('[role="dialog"], .dialog, .modal');
    const disabledCheckbox = dialog.locator('[role="checkbox"][aria-disabled="true"], input[type="checkbox"]:disabled');

    const count = await disabledCheckbox.count();
    if (count > 0) {
      // 验证不可勾选
      await expect(disabledCheckbox.first()).toBeDisabled();
    }
  });
});

// ============================================================
// AC10: 我的星神
// ============================================================

test.describe('AC10: 我的星神', () => {

  test('复制官方星神为我的星神', async ({ page }) => {
    await page.goto('/');
    await page.locator('[aria-label*="星神"], button:has-text("星神")').click();

    const dialog = page.locator('[role="dialog"], .dialog, .modal');

    // 找到"阳九"并点击复制
    const yangJiu = dialog.locator(byText('阳九')).first();
    await yangJiu.locator('..').locator('button:has-text("复制"), [aria-label*="复制"]').click();

    // 编辑对话框
    const editDialog = page.locator('[role="dialog"]:not(:has-text("系统内置"))');
    await expect(editDialog).toBeVisible();

    // 修改名称
    const nameInput = editDialog.locator('input[aria-label*="名称"], input[name*="name"]');
    await nameInput.clear();
    await nameInput.fill('阳九-红色实验版');

    // 保存
    await editDialog.locator('button:has-text("保存")').click();

    // 验证"我的"分区出现新星神
    const mySection = dialog.locator(':text("我的")').locator('..');
    await expect(mySection.locator(byText('阳九-红色实验版'))).toBeVisible();

    // 验证官方"阳九"未被修改
    await expect(dialog.locator(':text("系统内置")').locator('..').locator(byText('阳九'))).toBeVisible();
  });

  test('复制后的星神默认对所有流派和盘型可用', async ({ page }) => {
    // 验证复制时 applicableSchools 和 applicableChartTypes 为空
    await page.goto('/');
    await page.locator('[aria-label*="星神"], button:has-text("星神")').click();

    const dialog = page.locator('[role="dialog"], .dialog, .modal');
    const mySection = dialog.locator(':text("我的")').locator('..');
    const myDeity = mySection.locator(byText('我的阳九'));

    // 点击编辑查看适用范围
    await myDeity.locator('..').locator('button:has-text("编辑"), [aria-label*="编辑"]').click();

    // 验证适用流派为空（全部可用）
    const schoolSelector = page.locator('[aria-label*="适用流派"]');
    // 具体断言需根据 UI 实现调整
  });

  test('官方和用户星神可同盘显示', async ({ page }) => {
    await page.goto('/');

    // 前置：确保官方"阳九"和"我的阳九"都已勾选
    await page.locator('[aria-label*="星神"], button:has-text("星神")').click();
    const dialog = page.locator('[role="dialog"], .dialog, .modal');

    // 勾选两个
    await dialog.locator(checkboxFor('阳九')).first().check();
    await dialog.locator(checkboxFor('我的阳九')).check();
    await page.keyboard.press('Escape');

    // 验证盘面上两个都显示
    // 具体断言需根据 UI 结构调整
  });

  test('复制的星神不可修改 templateId', async ({ page }) => {
    await page.goto('/');
    await page.locator('[aria-label*="星神"], button:has-text("星神")').click();

    const dialog = page.locator('[role="dialog"], .dialog, .modal');
    const mySection = dialog.locator(':text("我的")').locator('..');
    await mySection.locator(byText('我的阳九')).locator('..').locator('button:has-text("编辑")').click();

    // 验证 templateId 字段不可编辑
    const templateField = page.locator('[aria-label*="templateId"], [name*="template"]');
    if (await templateField.isVisible()) {
      await expect(templateField).toBeDisabled();
    }
  });
});

// ============================================================
// AC11: 我的流派
// ============================================================

test.describe('AC11: 我的流派', () => {

  test('官方流派不可修改', async ({ page }) => {
    await page.goto('/');
    // 查看官方流派
    await page.locator(byText('金镜派')).click();

    // 验证没有编辑/删除按钮
    const editBtn = page.locator('button:has-text("编辑"), [aria-label*="编辑"]');
    const deleteBtn = page.locator('button:has-text("删除"), [aria-label*="删除"]');
    await expect(editBtn).not.toBeVisible();
    await expect(deleteBtn).not.toBeVisible();

    // 只有复制按钮
    const copyBtn = page.locator('button:has-text("复制"), [aria-label*="复制"]');
    await expect(copyBtn).toBeVisible();
  });

  test('复制官方流派创建用户流派', async ({ page }) => {
    await page.goto('/');
    // 点击金镜派的复制按钮
    await page.locator(byText('金镜派')).locator('..').locator('button:has-text("复制")').click();

    // 编辑对话框
    const editDialog = page.locator('[role="dialog"], .modal');
    await expect(editDialog).toBeVisible();

    // 修改名称
    const nameInput = editDialog.locator('input[aria-label*="名称"], input[name*="name"]');
    await nameInput.clear();
    await nameInput.fill('太乙新法');

    // 修改 ancientBase
    const baseInput = editDialog.locator('input[aria-label*="积年"], input[name*="ancientBase"]');
    if (await baseInput.isVisible()) {
      await baseInput.clear();
      await baseInput.fill('2000000');
    }

    // 保存
    await editDialog.locator('button:has-text("保存")').click();

    // 验证列表出现新流派
    await expect(page.locator(byText('太乙新法'))).toBeVisible();

    // 验证金镜派未被修改
    await expect(page.locator(byText('金镜派'))).toBeVisible();
  });

  test('用户流派保存传承链', async ({ page }) => {
    await page.goto('/');
    // 查看用户流派详情
    await page.locator(byText('我的金镜派')).click();
    await page.locator('button:has-text("详情"), [aria-label*="详情"]').click();

    // 验证传承路径
    await expect(page.locator(byText('金镜派 > 我的金镜派'))).toBeVisible();
  });
});

// ============================================================
// AC13: 隐藏关键项提醒
// ============================================================

test.describe('AC13: 隐藏关键项提醒', () => {

  test('隐藏核心星神时显示提醒', async ({ page }) => {
    await page.goto('/');
    await page.locator('[aria-label*="星神"], button:has-text("星神")').click();

    const dialog = page.locator('[role="dialog"], .dialog, .modal');

    // 取消勾选核心星神"太乙"
    await dialog.locator(checkboxFor('太乙')).click();

    // 验证提醒出现
    await expect(page.locator(byText('盘面解释可能不完整'))).toBeVisible();
  });

  test('恢复所有核心星神后提醒消失', async ({ page }) => {
    await page.goto('/');
    await page.locator('[aria-label*="星神"], button:has-text("星神")').click();

    const dialog = page.locator('[role="dialog"], .dialog, .modal');

    // 先隐藏太乙
    await dialog.locator(checkboxFor('太乙')).click();
    await expect(page.locator(byText('盘面解释可能不完整'))).toBeVisible();

    // 恢复太乙
    await dialog.locator(checkboxFor('太乙')).click();

    // 验证提醒消失
    await expect(page.locator(byText('盘面解释可能不完整'))).not.toBeVisible();
  });
});

// ============================================================
// AC16: 官方资产派生原则
// ============================================================

test.describe('AC16: 官方资产派生原则', () => {

  test('派生对象保留传承链字段', async ({ page }) => {
    await page.goto('/');

    // 复制官方星神
    await page.locator('[aria-label*="星神"], button:has-text("星神")').click();
    const dialog = page.locator('[role="dialog"], .dialog, .modal');
    await dialog.locator(byText('阳九')).first().locator('..').locator('button:has-text("复制")').click();

    const editDialog = page.locator('[role="dialog"]:not(:has-text("系统内置"))');
    await editDialog.locator('input[aria-label*="名称"]').fill('测试派生');
    await editDialog.locator('button:has-text("保存")').click();

    // 验证派生对象有 lineage 字段（通过详情查看）
    const mySection = dialog.locator(':text("我的")').locator('..');
    await mySection.locator(byText('测试派生')).locator('..').locator('button:has-text("详情")').click();

    // 验证显示来源路径
    await expect(page.locator(byText('阳九 > 测试派生'))).toBeVisible();
  });
});
