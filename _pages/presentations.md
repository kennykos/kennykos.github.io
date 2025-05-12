---
layout: page
permalink: /presentations/
title: Presentations
description: An up-to-date list is available on <a href="https://scholar.google.com/citations?user=Lmwd5akAAAAJ&hl=en" target="_blank">Google Scholar</a>.
years: [2025]
nav: true
nav_order: 2
---
<div class="publications">


<h1>Presentations</h1>
{%- for y in page.years %}
  <h2 class="year">{{y}}</h2>
  {% bibliography -f presentations -q @*[year={{y}}]* %}
{% endfor %}

</div>
