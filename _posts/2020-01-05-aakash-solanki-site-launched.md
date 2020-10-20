---
layout: post
title: "Aakash Solanki, lazy student, Launches Site"
date: 2020-01-05
tags: ["test","post"]
author: aakash
---

Well. Finally got around to putting this old website together. Neat thing about it - powered by [Jekyll](http://jekyllrb.com) and I can use Markdown to author my posts. It actually is a lot easier than I thought it was going to be.

<!doctype html>
<html lang="en">
  <head>
    <title>{{page.title}}</title>
  </head>
  <body>
    <h1>{{page.title}}</h1>
    {{content}}
    <p>
      Tagged 
      {% for tag in page.tags %}
      <a class="post" href="/tag/{{tag}}">#{{tag}}</a>{% unless forloop.last %}, {% endunless %}
      {% endfor %}
    </p>
  </body>
</html>