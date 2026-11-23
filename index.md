---
layout: default
---

<h1 class="sr-only">Aakash Solanki</h1>

<div class="block">
  <div class="body">
    <figure class="portrait">
      {% if site.logo %}<img src="{{ site.logo | relative_url }}" alt="Portrait of Aakash Solanki" loading="lazy">{% endif %}
    </figure>
    <p>Aakash Solanki is an anthropologist. His research examines how digital infrastructures are reshaping governance and democratic life in contemporary India. In addition to prior training in computer science, he has worked in government agencies in the US and India on data science projects in education, health, and skill development at municipal, state, and federal levels.</p>
    <p>His first book project, <em>Governing Indeterminately: An Ethnography of Technopopulism from India</em>, draws on long-term fieldwork in Indian state and central bureaucracies to examine how digital infrastructures mediate development, statecraft, and fiscal federal relations. The research is funded by the International Development Research Centre (IDRC) and the Wenner-Gren Foundation for Anthropological Research.</p>
    <p>His research has appeared in <em>South Asia: Journal of South Asian Studies</em> and interdisciplinary venues such as the <em>Proceedings of CHI 2026</em>.</p>
    <p>Aakash was educated at universities in <a target="_blank" rel="noopener noreferrer" href="https://www.utoronto.ca">Toronto</a>, <a target="_blank" rel="noopener noreferrer" href="https://www.uchicago.edu">Chicago</a>, and <a target="_blank" rel="noopener noreferrer" href="https://www.daiict.ac.in">Gandhinagar</a>.</p>
  </div>
</div>

<div class="block">
  <h2 class="label">Research interests</h2>
  <div class="body">
    <ul>
      <li>Colonial and postcolonial histories of statistics and statecraft</li>
      <li>Ethnography of the state and bureaucracy in South Asia</li>
      <li>Design, deployment, and maintenance of data infrastructures</li>
      <li>Caste, technoscience, and digital publics</li>
      <li>Mixed-method and collaborative approaches to studying governance technologies</li>
    </ul>
  </div>
</div>

<div class="block">
  <h2 class="label">Recent news</h2>
  <div class="body">
    <ul class="news">
      {%- for t in site.data.talks limit: 3 %}
      <li><span class="dt">{{ t.month }} {{ t.year }}</span><span>&ldquo;{{ t.title | escape }}.&rdquo; {% include talk-venue.html talk=t %}.</span></li>
      {%- endfor %}
    </ul>
    <p class="more">See all <a href="/talks/">talks</a> and <a href="/publications/">publications</a>.</p>
  </div>
</div>
