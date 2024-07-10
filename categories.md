---
layout: single
title: On the blog
permalink: /categories/
---

<div id="archives">
{% for category in site.categories %}
  <div class="archive-group">
    {% capture category_name %}{{ category | first }}{% endcapture %}



     <h3 class="{{ category_name }}" id="#{{ category_name | slugize }}">
     <a name="{{ category_name | slugize }}" href = "/categories/#{{ category_name | slugize }}">🔗 {{ category_name }}</a></h3>

    {% for post in site.categories[category_name] %}
    <article class="archive-item" >
      <li>[{{post.post_date}}] - <a href="{{ site.baseurl }}{{ post.url }}">{{post.title}}</a><span class = "page__meta"></span></li>
    </article>
    {% endfor %}
  </div>
{% endfor %}
</div>
