---
layout: page
permalink: /presentations/
title: Presentations
years: [2025]
nav: true
nav_order: 2
---
<div class="publications">


<h1>Conference Talks</h1>
{%- for y in page.years %}
  <h2 class="year">{{y}}</h2>
  {% bibliography -f presentations -q @*[year={{y}}]* %}
{% endfor %}

</div>
