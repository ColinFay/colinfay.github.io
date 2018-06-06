---
ID: 1604
title: #RStats — Create a pixel map with R"

post_date: 2017-04-13 21:55:01
post_excerpt: ""
layout: single
permalink: /rstats-create-a-pixel-map-with-r/
published: true
tags: [r, justforfun]
categories : r-blog-en
---
## The whole webdesign of <a href="http://data-bzh.fr" target="_blank">Data Bzh</a> has recently been updated. With it,&nbsp;a new header containing a pixelized map of Brittany. Here's how you can replicate it&nbsp;in R, with a map of France, US and the world.#----#

### Load map

First, you'll need to load the ggplot2 package, and one of the default&nbsp;maps — &nbsp;the package includes _county_, _france_, _italy_, _nz_, _state_, _usa_, _world_, and _world2_. For more info, see&nbsp;_?map_data._

```r 
library(ggplot2)
map <- map_data("france")

```

You now have a dataframe ready to be plotted. In your ggplot call, set the data argument to _map_, the x and y of your aesthetic to _long_ and _lat_, and the group arg to _group_.&nbsp;

For this kind of map, you need to use the geom_polygon function, which works pretty much like _geom_path_, except the polygons are connnected with the&nbsp;_group_ arg, and can be filled.&nbsp;

The _coord_map _function&nbsp;sets the coordinate system for projecting a map, and allows to keep the proportions fixed, no matter how you change the size of your viewport. Note that you can also use _coord_fixed_ to always keep the x/y ratio to 1.&nbsp;

Finally, _theme_void_ allows you to get rid of everything except the geom.&nbsp;

```r 
ggplot(map, aes(long,lat, group=group)) +
geom_polygon() +
coord_map() +
theme_void()

```

<a href="/assets/img/blog/void-france-map.png"><img class="aligncenter size-full wp-image-1607" src="/assets/img/blog/void-france-map.png" alt="" width="500" height="500"></a>

Ok, not really sexy, I'll admit that :)

But here's is the tip for creating a pixel effect : round the _long_ and _lat_, in order&nbsp;to make the border more squared (now, we'll also fill according to groups).

```r 
ggplot(map, aes(round(long, 1),round(lat,1), group=group,fill = as.factor(group))) +
geom_polygon() +
guides(fill=FALSE) +
coord_map() +
theme_void()

```

<a href="/assets/img/blog/pixel-france.png"><img class="aligncenter size-full wp-image-1608" src="/assets/img/blog/pixel-france.png" alt="" width="500" height="500"></a>

Let's try a more hardcore pixelization :

```r 
ggplot(map, aes(round(long, 0),round(lat,0), group=group,fill = as.factor(group))) +
geom_polygon() +
guides(fill=FALSE) +
coord_map() +
theme_void()

```

<a href="/assets/img/blog/pixel-france-2.png"><img class="aligncenter size-full wp-image-1609" src="/assets/img/blog/pixel-france-2.png" alt="" width="500" height="500"></a>

Ok, that's not very informative, but this map looks cool, right!&nbsp;

For an even more sexy look, you can put the borders back with a _geom_path_:

```r 
ggplot(map, aes(round(long, 0),round(lat,0), group=group,fill = as.factor(group))) +
geom_polygon() +
geom_path(data = map, aes(long, lat, group=group)) +
guides(fill=FALSE) +
coord_map() +
theme_void()

```

<a href="/assets/img/blog/pixel-france-3.png"><img class="aligncenter size-full wp-image-1610" src="/assets/img/blog/pixel-france-3.png" alt="" width="500" height="500"></a>

Tada!
### US &amp; world map
Here is the code you can use to make a pixel world map.

```r 
ggplot(map_data("world"), aes(round(long, 0),round(lat, 0), group=group, fill = as.factor(group))) +
geom_polygon() +
guides(fill=FALSE) +
coord_fixed() +
theme_void()

```

<a href="/assets/img/blog/pixel-world-map.png"><img class="aligncenter size-full wp-image-1611" src="/assets/img/blog/pixel-world-map.png" alt="" width="1000" height="500"></a>

And a US map:

```r 
ggplot(map_data("state"), aes(round(long, 0),round(lat, 0), group=group, fill = as.factor(group))) +
geom_polygon() +
guides(fill=FALSE) +
coord_map() +
theme_void()

```

<a href="/assets/img/blog/us-pixel-map.png"><img class="aligncenter size-full wp-image-1613" src="/assets/img/blog/us-pixel-map.png" alt="" width="1000" height="500"></a>

And, of course, you can create your own pixel maps with other shapefiles ;)&nbsp;

The larger the portion of the earth you want to map, the more "imprecise" you need to make your lat and long variables — here, we're just cutting off the decimal part of these number, but you can imagine rounding to the closest decile. Anyone to give it a try?&nbsp;



