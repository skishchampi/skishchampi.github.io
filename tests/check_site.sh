#!/usr/bin/env bash
# Build the site and check the modest-redesign contract.
# Uses rbenv Ruby 3.3.0 and gems in .venv/ (never the macOS system Ruby).
set -euo pipefail
cd "$(dirname "$0")/.."
export RBENV_VERSION="${RBENV_VERSION:-3.3.0}"

fail() { echo "FAIL: $*"; exit 1; }
has() { grep -q -- "$2" "$1" || fail "$1 lacks $2"; }

# Build only what git tracks or has staged (as CI does), ignoring local scratch files.
SRC=$(cd "$(mktemp -d)" && pwd -P)
trap 'rm -rf "$SRC"' EXIT
git ls-files -z | tar --null -T - -cf - | tar -xf - -C "$SRC"
bundle exec jekyll build -q -s "$SRC" -d _site
GEM_HOME=.venv/proofer GEM_PATH=.venv/proofer .venv/proofer/bin/htmlproofer ./_site \
  --disable-external --ignore-empty-alt --ignore-urls "/^\/freelibraries4all/" >/dev/null \
  || fail "htmlproofer"

# Talks come from _data/talks.yml: every title there renders on /talks/, newest three on the homepage.
python3 -I - <<'PY' || exit 1
import html, os, re, sys
if not os.path.exists("_data/talks.yml"): sys.exit("FAIL: _data/talks.yml missing")
titles = re.findall(r'^\s*title:\s*"(.*)"\s*$', open("_data/talks.yml").read(), re.M)
if len(titles) != 13: sys.exit(f"FAIL: talks.yml has {len(titles)} titles")
page = html.unescape(open("_site/talks/index.html").read())
home = html.unescape(open("_site/index.html").read())
for t in titles:
    if t not in page: sys.exit(f"FAIL: talks page lacks {t!r}")
for t in titles[:3]:
    if t not in home: sys.exit(f"FAIL: homepage news lacks {t!r}")
PY

# Ornaments and magazine labels are gone.
for pat in 'class="kicker"' 'stupa-coda' 'class="ornament"' 'class="num"' 'class="n"' 'class="back"' 'class="meta"'; do
  hit=$(grep -rl --include="*.html" -- "$pat" _site | head -1 || true)
  [ -z "$hit" ] || fail "$pat still in $hit"
done

# Retired content.
for pat in 'Governance after Planning' 'diagrams/dashboard.svg' 'diagrams/coverage.svg' 'PhD Candidate' 'Pedagogical Philosophy' 'Instructional Practice' 'available on request'; do
  hit=$(grep -rl --include="*.html" -- "$pat" _site | head -1 || true)
  [ -z "$hit" ] || fail "'$pat' still in $hit"
done

# Metadata kept.
for pat in citation_author 'application/ld+json' feed.xml 'og:image' '"jobTitle": "Anthropologist"' 'id="theme-toggle"'; do
  has _site/index.html "$pat"
done

# Nav: Writing, Teaching, Talking, Contact.
nav=$(python3 -I - <<'PY'
import re
s = open("_site/index.html").read()
m = re.search(r'<nav class="mast-nav".*?</nav>', s, re.S)
print(" ".join(re.findall(r'<a href="([^"]+)"', m.group(0))) if m else "")
PY
)
[ "$nav" = "/publications/ /teaching/ /talks/ /contact/" ] || fail "nav is '$nav'"

# Talks: 13 entries, JSON-LD valid with 13 items.
python3 -I - <<'PY' || exit 1
import json, re, sys
s = open("_site/talks/index.html").read()
n = len(re.findall(r'class="talk"', s))
blocks = re.findall(r'<script type="application/ld\+json">(.*?)</script>', s, re.S)
items = None
for b in blocks:
    d = json.loads(b)
    if d.get("@type") == "ItemList":
        items = d["itemListElement"]
if n != 13: sys.exit(f"FAIL: talks page has {n} talks")
if items is None or len(items) != 13: sys.exit("FAIL: talks JSON-LD missing or wrong length")
nourl = [i for i in items if "Graduate Workshop" in i["item"]["location"]["name"]][0]["item"]
if "url" in nourl: sys.exit("FAIL: talk without url has url in JSON-LD")
PY

# Homepage news: 3 items, newest first.
python3 -I - <<'PY' || exit 1
import re, sys
s = open("_site/index.html").read()
m = re.search(r'<ul class="news">(.*?)</ul>', s, re.S)
if not m: sys.exit("FAIL: no news list")
lis = re.findall(r"<li", m.group(1))
if len(lis) != 3: sys.exit(f"FAIL: news has {len(lis)} items")
if "Not a Data Project" not in m.group(1).split("</li>")[0]: sys.exit("FAIL: newest talk not first")
PY

# Homepage: name heading for screen readers only; photo sits inside the biography, not in a separate band.
has _site/index.html '<h1 class="sr-only"'
python3 -I - <<'PY' || exit 1
import re, sys
s = open("_site/index.html").read()
if 'class="lede"' in s: sys.exit("FAIL: homepage still has the separate lede band")
if '>Biography</h2>' in s: sys.exit("FAIL: homepage still has a Biography heading")
bio = re.search(r'<div class="block">(.*?)</div>\s*</div>', s, re.S)
if not bio or 'class="portrait"' not in bio.group(1) or 'is an anthropologist' not in bio.group(1): sys.exit("FAIL: portrait and bio not together in first block")
PY

# Teaching keeps its three courses.
[ "$(grep -c 'class="course"' _site/teaching/index.html)" = 3 ] || fail "teaching does not have 3 courses"

# Publications anchors kept.
python3 -I - <<'PY' || exit 1
import re, sys
s = open("_site/publications/index.html").read()
pubs = re.findall(r'<div class="pub"( id="[^"]+")?', s)
if len(pubs) != 9 or not all(pubs): sys.exit(f"FAIL: {len(pubs)} pubs, some without id")
PY

echo "PASS: site checks"
