---
layout: default
title: Talks
permalink: /talks/
description: "Recent talks, workshops, and invited presentations by Aakash Solanki."
---

<header class="pagehead">
  <h1>Talks</h1>
  <p class="standfirst">Invited lectures, conference presentations, and workshop talks.</p>
</header>

{% assign years = site.data.talks | group_by: "year" %}
{%- for y in years %}
<h2 class="sect">{{ y.name }}</h2>
{% for t in y.items %}
<div class="talk">
  <span class="dt">{{ t.month }}</span>
  <span class="ttl">&ldquo;{{ t.title | escape }}&rdquo;</span>
  <span class="at">{% include talk-venue.html talk=t %}</span>
</div>
{% endfor %}
{%- endfor %}

{% include talk-jsonld.html %}
