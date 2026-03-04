---
layout: page
title: Demos
permalink: /demos/
description: A growing collection of your cool demos.
nav: true
nav_order: 4
display_categories: [software]
horizontal: true
---

<!-- pages/demos.md -->
<div class="demos">
{%- if site.enable_demo_categories and page.display_categories %}
  <!-- Display categorized demos -->
  {%- for category in page.display_categories %}
  <h2 class="category">{{ category }}</h2>
  {%- assign categorized_demos = site.demos | where: "category", category -%}
  {%- assign sorted_demos = categorized_demos | sort: "importance" %}
  <!-- Generate cards for each demo -->
  {% if page.horizontal -%}
  <div class="container">
    <div class="row row-cols-1">
    {%- for demo in sorted_demos -%}
      {% include demos_horizontal.html %}
    {%- endfor %}
    </div>
  </div>
  {%- else -%}
  <div class="grid">
    {%- for demo in sorted_demos -%}
      {% include demos.html %}
    {%- endfor %}
  </div>
  {%- endif -%}
  {% endfor %}

{%- else -%}
<!-- Display demos without categories -->
  {%- assign sorted_demos = site.demos | sort: "importance" -%}
  <!-- Generate cards for each demo -->
  {% if page.horizontal -%}
  <div class="container">
    <div class="row row-cols-2">
    {%- for demo in sorted_demos -%}
      {% include demos_horizontal.html %}
    {%- endfor %}
    </div>
  </div>
  {%- else -%}
  <div class="grid">
    {%- for demo in sorted_demos -%}
      {% include demos.html %}
    {%- endfor %}
  </div>
  {%- endif -%}
{%- endif -%}
</div>
