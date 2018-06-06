---
title: "A Crazy Little Thing Called {purrr} - Part 1 : Web Mining "

post_date: 2017-11-24
layout: single
permalink: /purrr-web-mining/
tags:
  - purrr
categories : r-blog-en
excerpt_separator: <--!more--> 
---

Yes, this title is a Queen reference. 



Yesterday, I presented a talk called "Le Text Mining expliqué à ma grand-mère" at the Breizh Data Club Meetup. As the title suggests ("Text Mining explained to my Grand Mother"), this talk was about explaining text mining to someone that doesn't understand anything about data science. If you want to check the slides, they are [on this GitHub repo](https://github.com/ColinFay/conf/blob/master/2017-11-breizh-data-club/fay_colin_tm_explique_grand_mere.pdf). 

As I was searching for a "light" subject to do text-mining on, and something appealing for my grand-mother, I thought about mining Michel Sardou's lyrics (if you don't know him, he's a famous french singer, who wrote quite a lot of cheesy songs, and was really popular around the 80's - you should look for him on YouTube or Spotify if you want to hear more about him (but honestly, don't do that)). As there are no available dataset with the lyrics, I needed to scrap the data from the web. 

But I'm not here to talk about what's in the slides, but more to share some tricks to use {purrr} for doing web scraping. 

## Scraping the web with {purrr} and {rvest}

> Disclaimer: this post is neither an {rvest} nor a {stringr} tutorial. There's plenty of available great tutorials out there, feel free to look for them if you're not familiar with theses packages. 

So, the first step was to gather the data. I found [this website](http://paroles2chansons.lemonde.fr) which seemed to be containing everything I needed. 

```r
library(rvest)
library(tidyverse)
get_album_list <- function(url){
  read_html(url)  %>% 
    html_nodes(".col-md-12") %>%
    html_nodes("a") %>%
    html_attr("href")
    
}

url_album <- get_album_list("http://paroles2chansons.lemonde.fr/paroles-michel-sardou/discographie.html")
```

No {purrr} there, let's move to the next function, which get all the infos from an album list : 


```r
get_album_info <- function(url){
  page <- read_html(url) 
  date <- page %>% 
    html_nodes("small") %>%
    html_text() %>%
    stringr::str_replace_all("Date de Sortie : ", "") %>%
    lubridate::dmy()
  song_list <- page %>% 
    html_nodes(".font-small") %>%
    html_text() %>%
    discard(~ .x == "Plan de site" | .x == "Mention légale" | .x == "Chansons de mariage" | .x == "Chansons d'enterrement" )
  
  url_list <- page %>% 
    html_nodes(".font-small") %>%
    html_attr("href") %>%
    discard(~ .x == "/plan-du-site.html" | .x == "/mentions-legales.html" | .x == "/paroles-chansons-de-messe-d-enterrement/"| .x == "/paroles-chansons-de-messe-de-mariage/")
  
  album_name <- page %>%
    html_nodes(".breadcrumb") %>%
    html_text() %>%
    stringr::str_extract("\t.*$") %>%
    stringr::str_replace_all("\t", "")
  
  tibble(chanson = song_list, 
         url = url_list, 
         nom = album_name, 
         date = date)

}

```

When doing web mining, there are sometimes stuffs you want to discard: here, for example, every pages of the website has four links I don't want to keep. For that, I used the `discard` function from {purrr}, which is a function that remove everything that matches the predicate it receives. 

```r
albums_infos <- map_df(url_album, get_album_info) %>%
  filter(grepl("sardou", url))
``` 

Here, a simple `map_df`, which iterates over the list of url, applies the function `get_album_info`, and always returns a data.frame. Out of security, I filtered the urls to be sure to match the name of the artist. 

```r
get_lyrics <- function(url, name){
  page <- read_html(url)
  lyrics <- page %>%
    html_nodes(".text-center") %>%
    html_nodes("div") %>%
    html_text() %>%
    stringr::str_replace_all("[\t+\r+\n+]", " ") %>%
    stringr::str_replace_all("[ ]{2}", " ") %>%
    stringr::str_replace_all("googletag.cmd.push\\(function\\(\\) \\{ googletag.display\\('container-middle-lyrics'\\)\\; \\}\\)\\;", "") %>% 
    stringr::str_replace_all("\\/\\* ringtone - Below Lyrics \\*\\/.*", "") %>%
    discard( ~ grepl("Corriger les paroles", .x)) %>%
    discard( ~ grepl("Paroles2Chansons", .x)) %>%
    discard( ~ nchar(.x)  < 2) 
  tibble(parole = lyrics, 
         song = name)
}
safe_lyr <- safely(get_lyrics)

lyrics_df <- map2(albums_infos$url, 
                     albums_infos$chanson, 
                     ~ safe_lyr(.x,.y)) %>%
  map("result") %>%
  compact() %>%
  reduce(bind_rows) %>%
  filter(! grepl("Soumettre une chanson", parole) )
```

This part is more interesting (in my humble opinion) and quite relevant for web mining. Nothing new in the `get_lyrics` function, but it turns out that `safely` can be an amazingly usefull tool for web scraping. What this function does is taking a function A, returning another function B which will run A and returns a list containing two element: `result` and `error`, one being `NULL` depending on the output of the function A. 

So the point is that __this function always works__ 🎉. If you've been doing some bulk web scraping, you know how frustrating it can be when your iteration stops because one out of your 500 urls is a 404. So, safely is here to help you prevent that: even if you iterate over 500 urls which are 404, your process won't stop: you'll always get an answer. 

That's what I'm doing here with `safe_lyr`. Once I get the results, I `map("result")` in order to keep only the result elements of the lists, and `compact()` to remove the `NULL` elements (i.e the url that returned a 404). As all my result elements are tibbles, I end with a `reduce(bind_rows)` [*], which iterates over the list binding two elements at a time. 

So here we are, let's join everyting up in a big dataframe ! 

```r 
albums_infos <- albums_infos %>%
  left_join(lyrics_df, by = c(chanson = "song")) 
```

![](h/assets/img/blogsardou.gif)

[*] As stated in the comment section, `bind_rows()` can take a list of data.frames as argument: I chose here to use `reduce` as an example of how this function works, yet this will not be, in practice, the best way to bind a list of data.frames. 






