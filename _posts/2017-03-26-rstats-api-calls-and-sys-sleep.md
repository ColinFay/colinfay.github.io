---
ID: 1425
title: "#RStats — API calls and Sys.sleep"

post_date: 2017-03-26 14:30:53
post_excerpt: ""
layout: single
permalink: /rstats-api-calls-and-sys-sleep/
published: true
tags: [r, api]
categories : r-blog-en
---
## Lately, I received a mail concerning my blogpost on Discogs API, saying the code didn't work. Turned out it was due to new API limitations. Here's how to get along with it. <!--more-->
### Discogs calls
Here is <a href="http://colinfay.me/data-vinyles-discogs-r/">the blog post describing how to make calls on the Discogs API with R</a>.

I've recently received a mail saying the second part of the code wasn't working, returning only _NA_. It turned out it was due to recent changes in Discogs API policy, limiting the number of calls you can make within a specific time window.

Also recently, I've been using Microsoft's Computer Vision API — an API limiting calls to 20 per minute — for a blogpost on <a href="http://data-bzh.fr">Data Bzh</a>. So I said to myself: "time for a new blogpost!".

How can you automate your API calls when the API is time-limited (for example, if you have 282 calls to make)?
### Simplest way : a for loop and Sys.sleep()
_Note : I won't be making any API calls within this post, I'll use Sys.time() to show how Sys.sleep() works._

If you're calling _Sys.time_, and want to limit to 20 calls per minute, you'll need to use _Sys.sleep_(). This function only takes one argument, _time_, which is the number of seconds you want R to stop before resuming.

When run, this function pause your session during the number of seconds you've entered. If you use this in a for loop, you can make a pause on every iteration of the loop. Here is an example with 10 seconds :
```r 
for(i in 1:3){
  print(Sys.time())
  Sys.sleep(time = 10)
}
```
```r 
## [1] "2017-03-26 11:13:58 CET"
## [1] "2017-03-26 11:14:08 CET"
## [1] "2017-03-26 11:14:18 CET"
```
### With a lapply
If you have access to the core of the function you want to use (i.e. the function calling on the API), you can use a lapply and insert a _Sys.sleep()_ staight inside this function.

This is the method you'll need to use if you're trying to replicate the Discogs API calls.
```r 
library(tidyverse)
```
```r 
lapply(1:3, function(x) {
  print(x)
  print(Sys.time()) 
  Sys.sleep(3)
}) %>% do.call(rbind, .) 
```
```r 
## [1] 1
## [1] "2017-03-26 11:20:22 CET"
## [1] 2
## [1] "2017-03-26 11:20:25 CET"
## [1] 3
## [1] "2017-03-26 11:20:28 CET"
```

_Hope this can help!_
