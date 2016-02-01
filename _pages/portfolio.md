---
title: Portfolio
options: headless notitle footless
stylesheets:
  - filename: portfolio
---

TeX illustration
----------------

{% assign folia = site.folia | sort: 'order' %}
{% for folio in folia %}{% assign folio_name = folio.path | split:"/" | last | split:"." | first %}{% include portfolio/teaser.html name=folio_name description=folio.caption %}{% endfor %}


