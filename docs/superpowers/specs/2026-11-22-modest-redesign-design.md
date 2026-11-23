# Modest redesign: design

Date: 2026-11-22. Status: draft for approval.

## Intent

The site reads as "bombastic": magazine styling, ornaments, a display slogan. The owner wants a modest, simple academic homepage. Every function stays: pages, URLs, links, Wayback archive arrows, dark mode, RSS, sitemap, SEO and citation metadata, JSON-LD.

## Goals

- Homepage opens with the person and the work, not a slogan.
- No decorative symbols, magazine labels, Roman numerals, numbered bullets or drop caps.
- Plain headings and plain type sizes.
- Main sections are one click from every page.
- Each talk is entered once and appears on the Talks page, in its JSON-LD and in homepage news.

## Non-goals

- No change to bio text, page content or URLs, apart from the fixes listed below.
- No new features, no CV page, no new build tooling.

## Anti-goals (failure even if it works)

- Any broken internal link, lost archive link, or lost metadata.
- A "minimal" look that still carries the old ornaments in leftover CSS.
- A generic template look with no warmth. Keep the paper colour and serif text.

## Approaches considered

1. **Rewrite the stylesheet (chosen).** Replace `assets/css/style.css` (about 1,050 lines) with a short new file. Remove ornament markup from the layouts and pages. Old styling cannot leak back.
2. **Trim the current stylesheet.** Less work up front, but leftover rules keep the site half-showy.
3. **Plain white page (direction B).** Rejected by the owner in the mockup round; loses the site's character.

## Decided by the owner

- Visual direction A, "Toned down": warm paper colour, serif body text, system sans for small labels. Mockups: `.superpowers/brainstorm/10425-1795407549/content/homepage-directions.html` (card A) and `talks-a.html`.
- Talks page as in `talks-a.html`.
- Book title everywhere: *Governing Indeterminately: An Ethnography of Technopopulism from India*. The Research page heading changes from *Governance after Planning*.
- One talks list in `_data/talks.yml`.

## Design

### Layout (`_layouts/default.html`)

- Header: name on the left. Nav on the right (owner's choice): Writing, Teaching, Talking, Contact, then the theme toggle. Current section underlined. Writing links to `/publications/`, and is marked current on Publications, Research, Projects, project subpages and Blog. Talking links to `/talks/`. A short line at the top of Publications links to the book project (Research), Projects and Blog.
- Footer: "Last updated …", a note "↗ = archived copy", ORCID and RSS. No ornament.
- Theme toggle (owner's choice): keep the diya icon, `id="theme-toggle"`, `aria-pressed`, `aria-label` and `assets/js/theme.js` logic. Drop the boxed border so it sits quietly in the nav.
- Fonts: load Newsreader only (400, 400i, 600), with an updated SRI hash. Drop Inter and JetBrains Mono; use the system sans and mono stacks.
- Keep all `<head>` metadata. Change JSON-LD `jobTitle` from "PhD Candidate" to "Anthropologist", per the standing bio rule.

### Stylesheet (`assets/css/style.css`, rewritten)

- Keep the token names and the light and dark palettes, so pages that use `var(--…)` still work.
- Body: serif, about 17px, line-height about 1.6, text column about 680px wide.
- Headings: page title about 1.6rem regular, no italics, no full stop. Section headings small sans, sentence case, no letter-spacing tricks.
- Lists: plain bullets. Dated lists use a narrow date column.
- Keep `.archive-link` styling and `.pub:target` highlighting.
- Phone width: one column, no horizontal scroll, 16px side margin.

### Pages

- Remove from every page: `.kicker` labels, `.stupa-coda`, `.pagehead .meta` boxes, `.sect .n` wheel marks, Roman numerals in labels, `.bullets .num` counters, the drop cap, `.back` "Back to Work" links.
- `index.md`: name-and-role heading in place of the slogan, smaller photo beside the bio, sections "Research interests" and "Recent news".
- `research.md`: new title; remove the two illustrative chart images ("Indicator review", "Coverage"). Keep the fieldwork photographs. Fold the funders into the text.
- `talks.md`: build from `_data/talks.yml`, grouped by bare year headings. Venue under the title. Titles in regular type with quotation marks. JSON-LD built from the same data.
- `work.md`: keep the URL so outside links still work, restyled as a plain list. Not in the nav.
- Other pages (`publications`, `teaching`, `projects`, `contact`, `blog`, project subpages, post and tag layouts): same treatment through the shared classes; content unchanged.

### Talks data (`_data/talks.yml`)

One entry per talk: `date` (YYYY-MM or YYYY-MM-DD), `title`, `venue`, optional `url`, optional `note` (e.g. "invited"). Homepage news shows the newest three entries. Non-talk news can be added later as a second list.

## Checks before going live

- Local `bundle exec jekyll build` passes and `htmlproofer` finds no broken internal links.
- Screenshots of every page in light and dark mode at 1280px and 390px wide.
- Page source still has the seo tags, citation tags, JSON-LD and RSS link.
- One PR, no AI attribution in commits or PR text.

## Left to the builder

- Exact spacing and colour values within direction A.
- How the Liquid templates for talks are structured.
- Commit split within the branch.
