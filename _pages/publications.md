---
layout: page
permalink: /publications/
title: Publications
description: An up-to-date list is available on <a href="https://scholar.google.com/citations?user=Lmwd5akAAAAJ&hl=en" target="_blank">Google Scholar</a>.
years: [2024, 2023]
nav: true
nav_order: 1
---
<!-- _pages/publications.md -->
<div class="publications">


<h1>Conference & Journal Articles</h1>
{%- for y in page.years %}
  <h2 class="year">{{y}}</h2>
  {% bibliography -f papers -q @*[year={{y}}]* %}
{% endfor %}

</div>
