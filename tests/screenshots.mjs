// Visual verification for the modest redesign (Task 6 of
// docs/superpowers/plans/2026-11-22-modest-redesign.md).
//
// Needs playwright-core and a Chromium build from the Playwright cache:
//   mkdir -p /tmp/pw && cd /tmp/pw && npm i playwright-core
//   PLAYWRIGHT_CORE=/tmp/pw/node_modules/playwright-core/index.mjs node tests/screenshots.mjs
//
// Serve the site first: bundle exec jekyll serve --port 4000
// Screenshots land in /tmp/site-shots/out; a JSON report goes to stdout.

// playwright-core is not a dependency of this site, so it is resolved from a
// scratch install: PLAYWRIGHT_CORE=/tmp/pw/node_modules/playwright-core/index.mjs
const { chromium } = await import(
  process.env.PLAYWRIGHT_CORE || 'playwright-core'
);
import fs from 'fs';

const BASE = process.env.SITE_BASE || 'http://127.0.0.1:4000';
const EXEC =
  process.env.CHROME_PATH ||
  `${process.env.HOME}/Library/Caches/ms-playwright/chromium-1234/chrome-mac-arm64/Google Chrome for Testing.app/Contents/MacOS/Google Chrome for Testing`;
const OUT = process.env.SHOT_DIR || '/tmp/site-shots/out';
fs.mkdirSync(OUT, { recursive: true });

const PAGES = [
  '/', '/research/', '/publications/', '/talks/', '/teaching/',
  '/collaborations/', '/libraries/', '/contact/', '/blog/', '/work/',
];
const VIEWPORTS = [
  { name: 'desk', width: 1280, height: 800 },
  { name: 'phone', width: 390, height: 844 },
];
const EXPECTED_NAV = ['/research/', '/teaching/', '/collaborations/', '/contact/'];

// Full-page capture does not scroll, so lazy images below the fold stay blank.
// Walk the document first, then come back to the top.
async function settle(page) {
  await page.evaluate(async () => {
    await new Promise((resolve) => {
      let y = 0;
      const step = setInterval(() => {
        y += 600;
        window.scrollTo(0, y);
        if (y > document.body.scrollHeight) {
          clearInterval(step);
          window.scrollTo(0, 0);
          resolve();
        }
      }, 30);
    });
  });
  await page.waitForLoadState('networkidle');
}

const browser = await chromium.launch({ executablePath: EXEC });
const report = [];
const problems = [];

for (const vp of VIEWPORTS) {
  for (const scheme of ['light', 'dark']) {
    const ctx = await browser.newContext({
      viewport: { width: vp.width, height: vp.height },
      colorScheme: scheme,
      deviceScaleFactor: 1,
    });
    const page = await ctx.newPage();
    for (const path of PAGES) {
      await page.goto(BASE + path, { waitUntil: 'networkidle' });
      await settle(page);
      const info = await page.evaluate(() => {
        const html = document.documentElement;
        const toggle = document.getElementById('theme-toggle');
        const box = toggle && toggle.getBoundingClientRect();
        const nav = document.querySelector('.mast-nav');
        const broken = [...document.images]
          .filter((i) => !i.complete || i.naturalWidth === 0)
          .map((i) => i.getAttribute('src'));
        return {
          scrollWidth: html.scrollWidth,
          innerWidth: window.innerWidth,
          theme: html.getAttribute('data-theme'),
          toggle: box ? { w: Math.round(box.width), h: Math.round(box.height) } : null,
          nav: nav ? [...nav.querySelectorAll('a')].map((a) => a.getAttribute('href')) : [],
          brokenImages: broken,
        };
      });
      const row = { page: path, vp: vp.name, scheme, ...info };
      report.push(row);

      if (info.scrollWidth > info.innerWidth) {
        problems.push(`horizontal scroll on ${path} (${vp.name}/${scheme}): ${info.scrollWidth} > ${info.innerWidth}`);
      }
      if (info.theme !== scheme) {
        problems.push(`theme on ${path} (${vp.name}) should follow OS ${scheme}, got ${info.theme}`);
      }
      if (info.nav.join() !== EXPECTED_NAV.join()) {
        problems.push(`nav on ${path} is ${info.nav.join(' ')}`);
      }
      if (vp.name === 'phone' && (!info.toggle || info.toggle.w < 44 || info.toggle.h < 44)) {
        problems.push(`theme toggle hit area on ${path} is ${JSON.stringify(info.toggle)}`);
      }
      if (info.brokenImages.length) {
        problems.push(`broken images on ${path}: ${info.brokenImages.join(', ')}`);
      }

      const slug = path === '/' ? 'home' : path.replace(/\//g, '_');
      await page.screenshot({ path: `${OUT}/${vp.name}-${scheme}${slug}.png`, fullPage: true });
    }
    await ctx.close();
  }
}

await browser.close();
console.log(JSON.stringify(report, null, 1));
if (problems.length) {
  console.error('\nPROBLEMS:\n' + problems.join('\n'));
  process.exit(1);
}
console.error(`\nOK: ${report.length} captures, no layout problems.`);
