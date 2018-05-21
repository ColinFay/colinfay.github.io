---
title: "[Just for fun] New R package — tuRbonegro"

post_date: 2017-31-00 21:00:00
layout: single
permalink: /rstats-turbonegro/
categories : r-blog-en
tags: [r, justforfun]
excerpt_separator: <!--more-->
---

Because sometime, you just need a little bit of punk with your coding. 

<!--more-->

## tuRbonegro

Spoiler: the tuRbonegro package was created for fun only ;) 

![tuRbonegro_hex](https://github.com/ColinFay/tuRbonegro/raw/master/hex_turbo.png)

This package contains only one function, which launch and plays a random Turbonegro clip in your R Viewer. Because you know, some time you need some deathpunk. 

This function has three parameters:

+ `width`: width of the video, in pixel. Default is 560.
+ `height`: width of the video, in pixel. Default is 315.
+ `autoplay`: set video autoplay. Default is TRUE.

## Install 

To install on your machine : 

```r
devtools::install_github("ColinFay/tuRbonegro")
```

## Play a random clip 

```r

library(tuRbonegro)
tuRbonegro()
```

![tuRbonegro_pic](https://github.com/ColinFay/tuRbonegro/raw/master/tuRbonegro.png)

And turn the volume on! 
