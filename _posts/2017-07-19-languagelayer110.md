---
title: "languagelayeR 1.1.0 is now on CRAN"

post_date: 2017-07-19
layout: single
permalink: /languagelayer110/
categories : r-blog-en
tags: [r, package, cran]
excerpt_separator: <--!more--> 
---

I took a studious resolution for this summer: update, clean and create better docs for my old packages which are on the CRAN. `languagelayeR` is the first to go! 



## languagelayer 

This package offers a language detection tool by connecting to the languagelayer API, a JSON interface designed to extract language information from a character string.

## How languagelayeR works

The version 1.1.0 works with two functions. Which are :

`get_lang` Get language information from a character string

`get_supported_lang` Get all current available languages on the languagelayer API. 

## What's new with version 1.1.0 ? 

+ `setApiKey` is now deprecated 
+ `getSupportedLanguage` is now `get_supported_lang`
+ `getLanguage` is now `get_lang`
+ New vignette: `browseVignettes("languagelayeR")`

## Some examples 

Here are some example of how to use languagelayeR. Let's start with random Gutenberg project books, and try with french, german and spanish books.

```r
library(languagelayeR)
library(gutenbergr)
library(magrittr)
library(tidyverse)
api_key <- "XXX"

# There are 55080 books on the gutenberg project at the time

## Test one 

sample(1:55080, 1) %>%
  gutenberg_download() %>%
  select(text) %>%
  sample_n(1) %>%
  get_lang(api_key) %>%
  as.list()

## note: I turned into a list for the sake of readability

$text
[1] "in this way: On the preceding evening, after the firing had ceased,"

$language_code
[1] "en"

$language_name
[1] "English"

$probability
[1] 58.82599

$percentage
[1] 100

$reliable_result
[1] TRUE

# Test 2 

$text
[1] "Notwithstanding these efforts, it is a fact that scarcely any of the"

$language_code
[1] "en"

$language_name
[1] "English"

$probability
[1] 53.71964

$percentage
[1] 100

$reliable_result
[1] TRUE

# Test 3 

$text
[1] "which she used to employ at Keeton, when she had occasion to"

$language_code
[1] "en"

$language_name
[1] "English"

$probability
[1] 43.51029

$percentage
[1] 100

$reliable_result
[1] TRUE

# With other languages books 

## Proust (French)

gutenberg_download("2650") %>%
  select(text) %>%
  sample_n(1) %>%
  get_lang(api_key) %>%
  as.list()

$text
[1] "noirceur de ses intentions."

$language_code
[1] "fr"

$language_name
[1] "French"

$probability
[1] 22.70587

$percentage
[1] 100

$reliable_result
[1] TRUE
 

## Vernes (French)

gutenberg_download("54873") %>%
  select(text) %>%
  sample_n(1) %>%
  get_lang(api_key) %>%
  as.list()

$text
[1] "Depuis ce jour, qui pourra dire jusqu'où nous entraîna le _Nautilus_"

$language_code
[1] "fr"

$language_name
[1] "French"

$probability
[1] 33.59961

$percentage
[1] 100

$reliable_result
[1] FALSE


## Kant (Deutch)

gutenberg_download("38295") %>%
  select(text) %>%
  sample_n(1) %>%
  get_lang(api_key) %>%
  as.list()

$text
[1] "jetzt aus elender Ziererei der Buchdrucker (denn Buchstaben haben doch"

$language_code
[1] "de"

$language_name
[1] "German"

$probability
[1] 45.72145

$percentage
[1] 100

$reliable_result
[1] TRUE

## Stevenson (but in Spanish)

gutenberg_download("45438") %>%
  select(text) %>%
  sample_n(1) %>%
  get_lang(api_key) %>%
  as.list()

$text
[1] "tiempo el beneficio de sus opiniones."

$language_code
[1] "es"

$language_name
[1] "Spanish"

$probability
[1] 23.14516

$percentage
[1] 100

$reliable_result
[1] TRUE

```

I'll be glad to have some feedback about this package. Feel free to reach me out on [Twitter](http://www.twitter.com/_colinfay)! You can also send some PR or open issue on the [GitHub repo](https://github.com/ColinFay/languagelayeR). 






