---
layout: page
permalink: /publications/
title: Publications
# separate year lists for articles and preprints
article_years: [2024, 2023]
preprint_years: [2025]
nav: true
nav_order: 1
---

<div class="publications">
An up-to-date list is available on <a href="https://scholar.google.com/citations?user=Lmwd5akAAAAJ&hl=en" target="_blank">Google Scholar</a>.

<h1>Conference & Journal Articles</h1>
{%- for y in page.article_years %}
  <h2 class="year">{{ y }}</h2>
  {% bibliography -f papers -q @*[year={{y}} && type!=preprint]* %}
{% endfor %}

<h1>Preprints</h1>
{%- for y in page.preprint_years %}
  <h2 class="year">{{ y }}</h2>
  {% bibliography -f papers -q @*[year={{y}} && type=preprint]* %}
{% endfor %}

</div>
