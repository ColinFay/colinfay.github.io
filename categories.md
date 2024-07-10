---
layout: single
title: On the blog
permalink: /categories/
---

<div id="archives">
{% for category in site.categories %}
  <div class="archive-group">
    {% capture category_name %}{{ category | first }}{% endcapture %}


    <a name="{{ category_name | slugize }}">
     <h3 class="{{ category_name }}" id="#{{ category_name | slugize }}">🔗 {{ category_name }}</h3>
    </a>
    {% for post in site.categories[category_name] %}
    <article class="archive-item" >
      <li>[{{post.post_date}}] - <a href="{{ site.baseurl }}{{ post.url }}">{{post.title}}</a><span class = "page__meta"></span></li>
    </article>
    {% endfor %}
  </div>
{% endfor %}
</div>
