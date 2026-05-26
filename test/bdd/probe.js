const { chromium } = require('playwright');
(async () => {
  const browser = await chromium.launch();
  const ctx = await browser.newContext();
  const page = await ctx.newPage();
  page.on('console', msg => console.log('CONSOLE['+msg.type()+']:', msg.text().slice(0, 200)));
  page.on('pageerror', err => console.log('PAGEERROR:', err.message.slice(0, 300)));
  const resp = await page.goto('http://localhost:8081/', { waitUntil: 'load', timeout: 15000 });
  console.log('STATUS:', resp.status());
  // Wait 20s
  await page.waitForTimeout(20000);
  const semanticsCount = await page.locator('[flt-semantics-identifier]').count();
  console.log('semantics count after 20s:', semanticsCount);
  const flutterView = await page.locator('flutter-view').count();
  console.log('flutter-view count:', flutterView);
  const canvas = await page.locator('canvas').count();
  console.log('canvas count:', canvas);
  console.log('--- Last 500 chars of body ---');
  console.log((await page.content()).slice(-1500));
  await browser.close();
})();
