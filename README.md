# aakashsolanki.net

Personal site for Aakash Solanki — PhD candidate in Anthropology and South
Asian Studies at the University of Toronto.

Built with Jekyll. Custom layout (`_layouts/default.html`), custom CSS
(`assets/css/style.css`), no third-party theme. Fonts via
[Bunny Fonts](https://fonts.bunny.net) (open-source, privacy-friendly mirror
of Google Fonts).

## Layout

- `index.md` — About / home
- `research.md` — Research
- `publications.md`, `teaching.md`, `talks.md`, `projects.md` — Folio sub-pages
- `caste-technoscience.md` — collaborative project page
- `utdevsem.md` — archived Development Seminar concept note
- `contact.md` — contact links and an open invitation
- `work.md` — index of the Folio sub-pages
- `blog/index.html` — blog post listing
- `_posts/` — blog posts (filename: `YYYY-MM-DD-slug.md`)
- `_drafts/` — unpublished drafts
- `_layouts/` — page templates
- `_plugins/tags.rb` — generates tag pages (⚠️ inactive on production: GitHub Pages legacy build mode does not run user plugins. To activate, migrate the build to GitHub Actions. Layout, generator, and `tag.html` are kept in place as scaffolding for that migration.)

## Deploy

GitHub Pages builds from `main` in legacy Jekyll mode. Every push to `main` deploys.

Plugins active on production are limited to the GitHub Pages whitelist: `jekyll-feed`, `jekyll-seo-tag`, `jekyll-sitemap`. To use any plugin outside that list (e.g. `jekyll-last-modified-at`, the in-repo `_plugins/tags.rb`), the site needs to migrate from "Deploy from a branch" to a custom GitHub Actions workflow.

```sh
git push
```

## Authoring a blog post

1. Copy `_drafts/post-template.md` to `_posts/YYYY-MM-DD-slug.md`.
2. Fill in `title`, `tags`, optional `excerpt`.
3. Write in Markdown below the front matter.
4. Commit, push, deploy.
