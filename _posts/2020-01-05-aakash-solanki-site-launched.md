---
layout: post
title: "Aakash Solanki, lazy student, Launches Site"
date: 2020-01-05
tags: ["test","post"]
author: aakash
---

Well. Finally got around to putting this old website together. Neat thing about it - powered by [Jekyll](http://jekyllrb.com) and I can use Markdown to author my posts. It actually is a lot easier than I thought it was going to be.

<div class="post-tags">
  {% if post %}
    {% assign tags = post.tags %}
  {% else %}
    {% assign tags = page.tags %}
  {% endif %}
  {% for tag in tags %}
  <a href="{{site.baseurl}}/tag/#{{tag|slugize}}">{{tag}}</a>
  {% unless forloop.last %}&nbsp;{% endunless %}
  {% endfor %}
</div>