---
layout: single
title: Blog
permalink: /categories/
# header: 
#   overlay_image: "assets/img/pexels/blogcolin.jpg"
---
## Jump to : 

+ [R blog (en)](#r-blog-en) 
+ [R blog (fr)](#r-blog-fr)
+ [Random](#r-blog-en)

<hr>

<div id="archives">
{% for category in site.categories %}
  <div class="archive-group">
    {% capture category_name %}{{ category | first }}{% endcapture %}
    <div id="#{{ category_name | slugize }}"></div>
    <p></p>
    
    <h3 class="{{ category_name }}">{{ category_name }}</h3>
    <a name="{{ category_name | slugize }}"></a>
    {% for post in site.categories[category_name] %}
    <article class="archive-item">
      <h4><a href="{{ site.baseurl }}{{ post.url }}">{{post.title}}</a></h4>
    </article>
    {% endfor %}
  </div>
{% endfor %}
</div>
