---
layout: single
title: On the blog
permalink: /categories/
---

<div id="archives">
{% for category in site.categories %}
  <div class="archive-group">
    {% capture category_name %}{{ category | first }}{% endcapture %}
    <div id="#{{ category_name | slugize }}"></div>
    
    <h3 class="{{ category_name }}">{{ category_name }}</h3>
    <a name="{{ category_name | slugize }}"></a>
    {% for post in site.categories[category_name] %}
    <article class="archive-item" >
      <li><a href="{{ site.baseurl }}{{ post.url }}">{{post.title}}</a><span class = "page__meta"> — {{post.post_date}}</span></li>
    </article>
    {% endfor %}
  </div>
{% endfor %}
</div>
