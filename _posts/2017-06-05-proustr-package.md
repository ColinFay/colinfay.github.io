---
title: "New R Package — proustr"

post_date: 2017-06-05
layout: single
permalink: /proustr-package/
categories : r-blog-en
tags: [r, package]
excerpt_separator: #----#
---

`proustr` is now on [CRAN](https://cran.r-project.org/web/packages/proustr/index.html).

<p align = "center"><img src="https://github.com/ColinFay/proustr/blob/master/proustr_hex.png?raw=true" width = "250"></p>

## An R Package for Marcel Proust's A La Recherche Du Temps Perdu

This package gives you access to all the books from Marcel Proust "À la recherche du temps perdu" collection. This collection is divided in books, which are divided in volumes. Inspired by the package [janeaustenr](https://github.com/juliasilge/janeaustenr) by Julia Silge. 

All books have been downloaded from [BEQ](https://beq.ebooksgratuits.com/auteurs/Proust/proust.htm) 

Here is a list of all the books contained in this pacakage : 

+ Du côté de chez Swann (1913): 2 volumes `ducotedechezswann1` & `ducotedechezswann2`. 
+ À l'ombre des jeunes filles en fleurs (1919): 3 volumes `alombredesjeunesfillesenfleurs1`, `alombredesjeunesfillesenfleurs2`, and `alombredesjeunesfillesenfleurs3`.
+ Le Côté de Guermantes (1920-1921): 3 volumes `lecotedeguermantes1`, `lecotedeguermantes2` and `lecotedeguermantes3`
+ Sodome et Gomorrhe I et II (1921-1922) : 2 volumes `sodomeetgomorrhe1` and `sodomeetgomorrhe2`.
+ La Prisonnière (1923) : 2 volumes `laprisonniere1` and `laprisonniere2`.
+ Albertine disparue (1925, also know as : La Fugitive) : `albertinedisparue`.
Le Temps retrouvé (1927) : 2 volumes `letempretrouve1` and `letempretrouve2`.


## Install proustr

Install this package directly in R : 

From CRAN :

```r
install.packages("proustr")
```

From Github :

```r
devtools::install_github("ColinFay/proustr")
```

## Examples 

```r
devtools::install_github("ThinkRstat/stopwords")
library(proustr)
library(tidytext)
library(tidyverse)
library(stopwords)
proust_books() %>% 
  mutate(text = stringr::str_replace_all(.$text, "’", " ")) %>% 
  unnest_tokens(word, text) %>%
  filter(!word %in% stopwords_iso$fr) %>%
  count(word, sort = TRUE)%>%
  head(10)
```

```r
# A tibble: 10 x 2
         word     n
        <chr> <int>
 1        mme  3106
 2      faire  2869
 3  albertine  2389
 4      grand  1833
 5 guermantes  1807
 6        vie  1732
 7      temps  1715
 8      swann  1682
 9     jamais  1639
10       voir  1568
```

### Contact

Questions and feedbacks [welcome](mailto:contact@colinfay.me) !



