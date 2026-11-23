# Modest Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restyle aakashsolanki.net as a modest academic site (direction A) and drive talks from one data file, with no loss of function.

**Architecture:** Jekyll site built by GitHub Pages (`github-pages` gem, safe mode: `_plugins/` does not run). A new short `assets/css/style.css` replaces the old one. Ornament markup leaves the layout and pages. `_data/talks.yml` feeds `/talks/`, its JSON-LD, and homepage news through Liquid.

**Tech Stack:** Jekyll (github-pages gem), Liquid, plain CSS, html-proofer, headless Chromium for screenshots.

**Spec:** `docs/superpowers/specs/2026-11-22-modest-redesign-design.md`

## Global Constraints

- No URL changes. `/work/` stays reachable but leaves the nav.
- Nav, in order: Writing (`/publications/`), Teaching (`/teaching/`), Talking (`/talks/`), Contact (`/contact/`), then the diya theme toggle with no boxed border.
- Writing is marked current on `/publications/`, `/research/`, `/projects/`, the four project subpages, `/blog/` and posts.
- Book title everywhere: *Governing Indeterminately: An Ethnography of Technopopulism from India*.
- JSON-LD `jobTitle`: "Anthropologist".
- Keep: every `.archive-link`, all `<head>` meta, `{% seo %}`, JSON-LD, RSS link, sitemap, `theme.js` behaviour, light and dark palettes.
- Fonts: Newsreader only (400, 400i, 600) from fonts.bunny.net with a fresh SRI hash; system sans and mono stacks otherwise.
- Remove: `.kicker`, `.stupa-coda`, `.pagehead .meta`, `.sect .n`, Roman numerals and "§ 0n" in headings, `.bullets .num`, drop cap, `.back` "Back to …" links, footer `.ornament`, the homepage wheel divider.
- Commits and PR text carry no AI attribution. Nothing merges to `main` until the owner says ship.
- AGENTS.md: no commit without the owner's "ship". The per-task commit steps run only if the owner allows local commits on `design/modest-redesign`; otherwise skip them and make the commits on ship.
- Work on branch `design/modest-redesign`; claim scope in `WORKING.md` first.

## Review Focus

1. Phone width (390px): no horizontal scroll, nav wraps cleanly, toggle still tappable (44px target). Test: Task 6 screenshot at 390px plus `scrollWidth` check.
2. Dark mode on first visit with OS dark preference: no flash of light, toggle shows the correct state. Test: Task 6 screenshots in both modes.
3. A talk entry with no `url`: renders venue as plain text, no empty `<a>` or archive arrow, JSON-LD omits `url`. Test: Task 2 check on the "Graduate Workshop" entry.
4. A talk title containing quotes or `&` (e.g. "Data & Society"): escapes correctly in HTML and stays valid JSON. Test: Task 2 JSON parse check.
5. Publications anchors (`#solanki-2025-express` etc.) still highlight via `.pub:target`. Test: Task 1 check that every `.pub` keeps its `id`.

---

### Task 1: Local build and site check script

**Files:**
- Create: `tests/check_site.sh`
- Modify: `.gitignore` (add `vendor/`, `.bundle/`), `_config.yml` (add `vendor`, `tests`, `docs` to `exclude` if not present)

**Interfaces:**
- Produces: `bash tests/check_site.sh` — builds to `_site`, runs html-proofer, then the assertions below; exits non-zero on the first failure with a one-line reason.

- [ ] **Step 1: Set up Ruby.** `RBENV_VERSION=3.3.0 bundle config set --local path vendor/bundle && RBENV_VERSION=3.3.0 bundle install`. If `jekyll serve` later needs it, add `gem "webrick"` to the Gemfile. Expected: `bundle exec jekyll -v` prints a version.
- [ ] **Step 2: Write `tests/check_site.sh`.** It runs `bundle exec jekyll build` and `htmlproofer ./_site --disable-external --ignore-empty-alt --ignore-urls "/^\/freelibraries4all/"` (same flags as `.github/workflows/htmlproofer.yml`), then asserts on `_site`:
  - no file contains `class="kicker"`, `stupa-coda`, `class="ornament"`, `class="num"`, `class="n"`, `class="back"`;
  - no file contains `Governance after Planning`, `diagrams/dashboard.svg`, `diagrams/coverage.svg`, `PhD Candidate`;
  - `index.html` contains `citation_author`, `application/ld+json`, `feed.xml`, `og:image`, `"jobTitle": "Anthropologist"`, `id="theme-toggle"`;
  - nav in `index.html` has exactly the links `/publications/`, `/teaching/`, `/talks/`, `/contact/` in that order;
  - `talks/index.html` has 13 `class="talk"` items, and its JSON-LD parses (`python3 -c json.loads`) with 13 `itemListElement`s;
  - `index.html` news list has exactly 3 items, the first containing `Not a Data Project`;
  - `publications/index.html` keeps 9 `class="pub"` elements, each with an `id`.
- [ ] **Step 3: Run it.** `bash tests/check_site.sh`. Expected: build and html-proofer pass; the assertions FAIL (first failure: `kicker` found).
- [ ] **Step 4: Commit.** `git add tests/check_site.sh .gitignore _config.yml Gemfile && git commit -m "test: add site check script for modest redesign"`

### Task 2: Talks from one data file

**Files:**
- Create: `_data/talks.yml`, `_includes/talk-jsonld.html`
- Modify: `talks.md` (whole body), `index.md` (news list only)

**Interfaces:**
- Produces: `site.data.talks` — a list, newest first, each item with `year` (int), `month` (e.g. `"Nov"`), `start` (ISO string as in the current JSON-LD, e.g. `"2026-04"` or `"2026-11-20T17:00:00-05:00"`), optional `end`, `title` (plain text, curly quotes as Unicode), `venue`, optional `url`, optional `note` (`"invited"`, `"guest"`), optional `address`.

- [ ] **Step 1: Write `_data/talks.yml`** with the 13 talks now in `talks.md`, values copied exactly. Move "(invited)"/"(guest)" out of `venue` into `note`. Ethnography Lab entry carries `end` and `address: "19 Ursula Franklin St., Toronto, ON"`.
- [ ] **Step 2: Rewrite `talks.md` body.** Header: `<h1>Talks</h1>` and the existing intro sentence. Loop `site.data.talks | group_by: "year"`; each group gets `<h2>{{ year }}</h2>` then one `.talk` per item: `.dt` = month, `.ttl` = “title” (no italics), `.at` = venue (linked with `.archive-link` arrow only when `url` exists) plus `, note` when present. JSON-LD block generated by `_includes/talk-jsonld.html` using `| jsonify` for every string; omit `url`, `endDate`, `address` keys when absent.
- [ ] **Step 3: Rewrite the homepage news list** to `site.data.talks | slice: 0, 3`: date `month year`, then `Talk: “title,” venue` with the same link/arrow rule. Replace the inline-styled "See all" paragraph with a plain `<p class="more">` linking talks and publications.
- [ ] **Step 4: Run `bash tests/check_site.sh`.** Expected: talks count, JSON-LD parse and news assertions PASS; ornament assertions still FAIL.
- [ ] **Step 5: Diff check.** Compare the 13 rendered talks against `git show HEAD:talks.md` by eye: same titles, venues, links. Then commit: `git commit -am "content: build talks and homepage news from _data/talks.yml"` (add the new files first).

### Task 3: Layout — nav, toggle, footer, fonts, metadata

**Files:**
- Modify: `_layouts/default.html`, `_layouts/post.html`, `_layouts/tag.html`

- [ ] **Step 1: Nav.** Replace the two links with the four Global Constraints links. `active`/`aria-current` rules: Writing when `page.url` contains `/publications`, `/research`, `/projects`, `/caste-technoscience`, `/states-startups-capital`, `/digital-rights-activism-dialogues`, `/libraries`, `/utdevsem`, `/blog`, or `page.layout == 'post'`; others by their own path.
- [ ] **Step 2: Toggle.** Keep the diya SVG, id, aria attributes. Styling moves to CSS in Task 4 (no border).
- [ ] **Step 3: Footer.** `Last updated …` · `↗ marks an archived copy` · ORCID · RSS feed. Delete the `.ornament` span.
- [ ] **Step 4: Fonts.** URL `https://fonts.bunny.net/css?family=newsreader:400,400i,600&display=swap`. Hash: `curl -s "$URL" | openssl dgst -sha384 -binary | openssl base64 -A`, prefixed `sha384-`.
- [ ] **Step 5: JSON-LD** `"jobTitle": "Anthropologist"`. Remove `.back`/`.kicker` markup from `post.html` and `tag.html`.
- [ ] **Step 6: Run `bash tests/check_site.sh`.** Expected: nav, jobTitle, metadata assertions PASS. Commit: `git commit -am "layout: modest nav, footer and fonts"`.

### Task 4: Rewrite the stylesheet

**Files:**
- Modify: `assets/css/style.css` (full rewrite)

- [ ] **Step 1: Write the new file.** Keep token names `--paper --paper-2 --paper-3 --ink --ink-2 --ink-3 --rule --accent` and both palettes as now; drop `--accent-2 --accent-blue --fs-display --fs-title`, set `--serif: "Newsreader", Georgia, serif; --sans: system-ui, -apple-system, sans-serif; --mono: ui-monospace, Menlo, monospace`. Body serif 1.0625rem/1.6; content column `max-width: 680px`; wrapper `max-width: 960px`, side padding 16px under 640px. `h1` 1.6rem weight 400, no italics. `h2` section headings: sans 0.8125rem weight 600, `--ink-3`, sentence case. Plain `ul` bullets. Date-column lists (`.news li`, `.talk`): grid `72px 1fr`, single column under 640px. Keep and restyle every class still in use: `.skip-link .sr-only .mast .mast-title .mast-nav #theme-toggle .lede .portrait .block .label .body .bullets .news .talk .dt .ttl .at .pub .pub-anchor .pub:target .yr .main .title .venue .note .blurb .tags .course .role .desc .when .where .project .posts .post-date .posts-empty .contact-links .row .k .page-figure .inline-figure .diptych .thread .thread-img .thread-text .research-map .india-map .india-outline .india-sites .archive-link .post-meta .post-title .post-tags .prose .work-list .more footer.site`. `#theme-toggle`: no border, transparent background, 44×44px hit area.
- [ ] **Step 2: Confirm no dangling classes.** `grep -ohE 'class="[^"]+"' _site -r | tr ' ' '\n' | sort -u` against the selectors in the new file; every class used in `_site` either has a rule or is intentionally unstyled.
- [ ] **Step 3: Run `bash tests/check_site.sh`.** Expected: build and html-proofer PASS. Commit: `git commit -am "style: rewrite stylesheet for a modest academic look"`.

### Task 5: Page cleanup

**Files:**
- Modify: `index.md`, `research.md`, `publications.md`, `work.md`, `teaching.md`, `projects.md`, `contact.md`, `utdevsem.md`, `caste-technoscience.md`, `states-startups-capital.md`, `digital-rights-activism-dialogues.md`, `libraries.md`, `blog/index.html`

- [ ] **Step 1: Every page.** Delete `.kicker` divs, `.pagehead .meta` blocks, `.stupa-coda` divs, `.back` paragraphs, `<span class="n">…</span>` in headings, `.num` spans. Turn `<h2 class="label">I. Biography</h2>` style labels into `<h2 class="label">Biography</h2>`. Page `h1`s lose trailing full stops and italics markup (`Writings.` → `Publications`, `Lectures &amp; panels.` already handled in Task 2). Talks/teaching year headings become bare years.
- [ ] **Step 2: `index.md`.** Lede becomes `<h1>Aakash Solanki</h1>` + `<p class="standfirst">Anthropologist. Research on bureaucracy, data infrastructures, and the technopolitics of the Indian state.</p>` with the portrait at `max-width: 200px` beside the bio. Research interests become a plain `<ul>`.
- [ ] **Step 3: `research.md`.** `h1` → *Governing Indeterminately: An Ethnography of Technopopulism from India*. Delete the `figure.diptych.diptych--svg` holding `dashboard.svg` and `coverage.svg`. Replace the meta box with one sentence after the intro: "Fieldwork 2019–2023 in the national capital, state capitals and districts, with archival work from 1950 to the present. Funded by IDRC and the <a …>Wenner-Gren Foundation</a>" keeping its archive arrow. Keep photos, `platform.svg`, the India map.
- [ ] **Step 4: `publications.md`.** Add under the intro: `<p class="more">See also the <a href="/research/">book project</a>, <a href="/projects/">projects</a>, and the <a href="/blog/">blog</a>.</p>`.
- [ ] **Step 5: `work.md`.** Plain `h1` "Work" and the existing link list; drop the figure.
- [ ] **Step 6: Run `bash tests/check_site.sh`.** Expected: ALL assertions PASS. Commit: `git commit -am "content: strip ornaments and magazine labels from pages"`.

### Task 6: Visual verification and PR

**Files:**
- Create: `tests/screenshots.mjs` (not committed if the owner prefers; keep under `tests/`)

- [ ] **Step 1: Serve locally.** `bundle exec jekyll serve --port 4000` in the background.
- [ ] **Step 2: Screenshot script.** Node + `playwright-core` with `executablePath` = `~/Library/Caches/ms-playwright/chromium-1234/chrome-mac-arm64/Google Chrome for Testing.app/Contents/MacOS/Google Chrome for Testing`. For `/`, `/publications/`, `/research/`, `/talks/`, `/teaching/`, `/projects/`, `/contact/`, `/blog/`, `/work/`: viewports 1280×800 and 390×844, `colorScheme` light and dark, full page, into the session scratchpad. Also print `document.documentElement.scrollWidth > innerWidth` per page; expected `false` everywhere.
- [ ] **Step 3: Review the screenshots** against the mockups (`homepage-directions.html` card A, `talks-a.html`). Fix and re-run Task 1's check after any change.
- [ ] **Step 4: Show the owner** the homepage and talks screenshots. Wait for "ship".
- [ ] **Step 5: On ship.** Push `design/modest-redesign`, open the PR (no attribution), wait for checks, squash-merge, confirm the live homepage shows `<h1>Aakash Solanki</h1>`.
