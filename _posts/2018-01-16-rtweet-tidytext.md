---
title: "Combining the new {rtweet} and {tidytext}"

post_date: 2018-01-16
layout: single
permalink: /rtweet-tidytext/
categories: r-blog-en
tags: [rtweet, package, tidytext]
output: jekyllthat::jekylldown
excerpt_separator: <--!more--> 
---

About keeping your packages up to date.



I’ve received recently some mails and comments asking why the code in :

  - [Collecting tweets with R and
    {rtweet}](http://colinfay.me/collect-rtweet/)

  - [Visualising text data with
    ggplot2](https://github.com/ColinFay/conf/blob/master/2017-11-budapest/fay_colin_text_data_ggplot2.pdf)

couldn’t be reproduced.

Spoiler: this is due to the behavior of {tidytext}, which doesn’t accept
the output of the new {rtweet}. The problem is almost solved (well, it
has shifted, as you’ll see below). I thought the answer to these
comments and mails would also be the **perfect occasion for me to talk a
little bit about how to return to previous versions of a package** (and
also, to provide a little workaround about the current error thrown when
trying to mine the `hashtags` column of the {rtweet} output).

## New {rtweet} vs previous {tidytext}

The update of {rtweet} was published on CRAN on 2017-11-16, (so after I
published the blogposts / slides I just mentioned). It comes with a new
feature: list columns.

Problem is: **you can’t pass a data frame containing list-columns** to
`unnest_tokens` in version 0.1.5 of {tidytext}. This was prevented by
the third to fifth lines of `tidytext:::unnest_tokens.data.frame`:

``` r
if (any(!purrr::map_lgl(tbl, is.atomic))) {
  stop("unnest_tokens expects all columns of input to be atomic vectors (not lists)")
}
```

### Getting back to a previous version of a package

To examplify this {rtweet} and {tidytext} issue, **let’s go back in time
to previous versions of theses packages**. For this, we’ll use the
`install_version()` function from {devtools}:

``` r
library(devtools)
install_version("rtweet", version = "0.4.0", repos = "http://cran.us.r-project.org", quiet = TRUE)
Downloading package from url: http://cran.us.r-project.org/src/contrib/Archive/rtweet/rtweet_0.4.0.tar.gz
Installing rtweet
'/Library/Frameworks/R.framework/Resources/bin/R' --no-site-file --no-environ --no-save --no-restore --quiet CMD  \
  INSTALL '/private/var/folders/lz/thnnmbpd1rz0h1tmyzgg0mh00000gn/T/RtmpPiXNRI/devtools766408992de/rtweet'  \
  --library='/Library/Frameworks/R.framework/Versions/3.4/Resources/library' --install-tests 

* installing *source* package ‘rtweet’ ...
** package ‘rtweet’ correctement décompressé et sommes MD5 vérifiées
** R
** inst
** tests
** preparing package for lazy loading
** help
*** installing help indices
** building package indices
** installing vignettes
** testing if installed package can be loaded
* DONE (rtweet)

install_version("tidytext", version = "0.1.5", repos = "http://cran.us.r-project.org", quiet = TRUE)
Downloading package from url: http://cran.us.r-project.org/src/contrib/Archive/tidytext/tidytext_0.1.5.tar.gz
Installing tidytext
'/Library/Frameworks/R.framework/Resources/bin/R' --no-site-file --no-environ --no-save --no-restore --quiet CMD  \
  INSTALL '/private/var/folders/lz/thnnmbpd1rz0h1tmyzgg0mh00000gn/T/RtmpPiXNRI/devtools7664a041fa4/tidytext'  \
  --library='/Library/Frameworks/R.framework/Versions/3.4/Resources/library' --install-tests 

* installing *source* package ‘tidytext’ ...
** package ‘tidytext’ correctement décompressé et sommes MD5 vérifiées
** R
** data
*** moving datasets to lazyload DB
** inst
** tests
** preparing package for lazy loading
** help
*** installing help indices
** building package indices
** installing vignettes
** testing if installed package can be loaded
* DONE (tidytext)

packageVersion("rtweet")
[1] ‘0.4.0’
packageVersion("tidytext")
[1] ‘0.1.5’
```

``` r
library(dplyr)
rtweets04 <- rtweet::search_tweets("#RStats", n = 10)
Searching for tweets...
Finished collecting tweets!
 glimpse(rtweets04)
Observations: 77
Variables: 35
$ screen_name                    <chr> "brian_leavell", "Pranesh___K", "OpenCageData", "haseebmahmud", "XihongLin"...
$ user_id                        <chr> "770639488645300225", "1445945130", "1404653376", "15199563", "893499404728...
$ created_at                     <dttm> 2018-01-16 12:51:36, 2018-01-16 12:51:16, 2018-01-16 12:50:56, 2018-01-16 ...
$ status_id                      <chr> "953248371606736896", "953248285497573376", "953248203708694528", "95324813...
$ text                           <chr> "RT @kateumbers: What to do if you have a compulsive data collating problem...
$ retweet_count                  <int> 1, 2, 2, 43, 6, 12, 12, 12, 43, 43, 6, 43, 43, 2, 43, 43, 6, 43, 0, 43, 43,...
$ favorite_count                 <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ...
$ is_quote_status                <lgl> TRUE, FALSE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, ...
$ quote_status_id                <chr> "953004640118874112", NA, "953229496819306496", NA, NA, NA, NA, NA, NA, NA,...
$ is_retweet                     <lgl> TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRU...
$ retweet_status_id              <chr> "953179356574113793", "952989197148749824", "953234288530608129", "95310176...
$ in_reply_to_status_status_id   <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,...
$ in_reply_to_status_user_id     <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,...
$ in_reply_to_status_screen_name <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,...
$ lang                           <chr> "en", "en", "en", "en", "en", "en", "en", "en", "en", "en", "en", "en", "en...
$ source                         <chr> "Twitter for Android", "Twitter Web Client", "Twitter Web Client", "Twitter...
$ media_id                       <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,...
$ media_url                      <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,...
$ media_url_expanded             <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,...
$ urls                           <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,...
$ urls_display                   <chr> NA, NA, NA, "buff.ly/2DyyumE", "rich-iannone.github.io/DiagrammeR/", "wp.me...
$ urls_expanded                  <chr> NA, NA, NA, "https://buff.ly/2DyyumE", "http://rich-iannone.github.io/Diagr...
$ mentions_screen_name           <chr> "kateumbers", "jasonbaik94", "ma_salmon dpprdan rOpenSci OpenCageData", "da...
$ mentions_user_id               <chr> "322411475", "1888111382", "2865404679 828915258211303424 342250615 1404653...
$ symbols                        <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,...
$ hashtags                       <chr> "r rstats meta ecology evolution data metaanalysis", "rstats", "rstats", "r...
$ coordinates                    <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,...
$ place_id                       <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,...
$ place_type                     <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,...
$ place_name                     <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,...
$ place_full_name                <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,...
$ country_code                   <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,...
$ country                        <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,...
$ bounding_box_coordinates       <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,...
$ bounding_box_type              <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,...
```

With these versions, you could simply do this (as you can find in the
slides):

``` r
rtweets04 %>% 
      tidytext::unnest_tokens(word, hashtags) %>% 
      select(screen_name, word) %>%
      slice(1:5)
# A tibble: 5 x 2
    screen_name      word
          <chr>     <chr>
1 brian_leavell         r
2 brian_leavell    rstats
3 brian_leavell      meta
4 brian_leavell   ecology
5 brian_leavell evolution
```

### {rtweet} 0.6

For a while, there were an issue while trying to use the two packages
together, as {rtweet} 0.6 was released on 2017-11-16, and {tidytext}
0.1.6 on 2018-01-07. When these two versions were used together, if you
tried to put the {rtweet} result into `unnest_tokens()`, you got an
error.

Let’s **simulate this behavior** by updating to {rtweet} 0.6, while
staying at {tidytext} 0.1.5.

``` r
detach("package:rtweet")
install.packages("rtweet", repos = "http://cran.us.r-project.org", quiet = TRUE)
packageVersion("rtweet")
[1] ‘0.6.0’
packageVersion("tidytext")
[1] ‘0.1.5’
```

So if I try to do the exact same thing:

``` r
library(rtweet)
rtweets06 <- search_tweets("#RStats", n = 10)
Searching for tweets...
Finished collecting tweets!
 glimpse(rtweets06)
Observations: 9
Variables: 42
$ status_id              <chr> "953248371606736896", "953248285497573376", "953248203708694528", "9532481352031723...
$ created_at             <dttm> 2018-01-16 12:51:36, 2018-01-16 12:51:16, 2018-01-16 12:50:56, 2018-01-16 12:50:40...
$ user_id                <chr> "770639488645300225", "1445945130", "1404653376", "15199563", "893499404728053760",...
$ screen_name            <chr> "brian_leavell", "Pranesh___K", "OpenCageData", "haseebmahmud", "XihongLin", "sello...
$ text                   <chr> "RT @kateumbers: What to do if you have a compulsive data collating problem. #r #rs...
$ source                 <chr> "Twitter for Android", "Twitter Web Client", "Twitter Web Client", "Twitter for iPh...
$ reply_to_status_id     <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA
$ reply_to_user_id       <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA
$ reply_to_screen_name   <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA
$ is_quote               <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE
$ is_retweet             <lgl> TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE
$ favorite_count         <int> 0, 0, 0, 0, 0, 0, 0, 0, 0
$ retweet_count          <int> 1, 2, 2, 43, 6, 12, 12, 12, 43
$ hashtags               <list> [<"r", "rstats", "meta", "ecology", "evolution", "data", "metaanalysis">, "rstats"...
$ symbols                <list> [NA, NA, NA, NA, NA, NA, NA, NA, NA]
$ urls_url               <list> [NA, NA, NA, "buff.ly/2DyyumE", "rich-iannone.github.io/DiagrammeR/", "wp.me/pMm6L...
$ urls_t.co              <list> [NA, NA, NA, "https://t.co/gpTEhFhfY5", "https://t.co/TZdttVMrTf", "https://t.co/4...
$ urls_expanded_url      <list> [NA, NA, NA, "https://buff.ly/2DyyumE", "http://rich-iannone.github.io/DiagrammeR/...
$ media_url              <list> [NA, NA, NA, NA, NA, NA, NA, NA, NA]
$ media_t.co             <list> [NA, NA, NA, NA, NA, NA, NA, NA, NA]
$ media_expanded_url     <list> [NA, NA, NA, NA, NA, NA, NA, NA, NA]
$ media_type             <list> [NA, NA, NA, NA, NA, NA, NA, NA, NA]
$ ext_media_url          <list> [NA, NA, NA, NA, NA, NA, NA, NA, NA]
$ ext_media_t.co         <list> [NA, NA, NA, NA, NA, NA, NA, NA, NA]
$ ext_media_expanded_url <list> [NA, NA, NA, NA, NA, NA, NA, NA, NA]
$ ext_media_type         <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA
$ mentions_user_id       <list> ["322411475", "1888111382", <"2865404679", "828915258211303424", "342250615", "140...
$ mentions_screen_name   <list> ["kateumbers", "jasonbaik94", <"ma_salmon", "dpprdan", "rOpenSci", "OpenCageData">...
$ lang                   <chr> "en", "en", "en", "en", "en", "en", "en", "en", "en"
$ quoted_status_id       <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA
$ quoted_text            <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA
$ retweet_status_id      <chr> "953179356574113793", "952989197148749824", "953234288530608129", "9531017606960619...
$ retweet_text           <chr> "What to do if you have a compulsive data collating problem. #r #rstats #meta #ecol...
$ place_url              <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA
$ place_name             <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA
$ place_full_name        <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA
$ place_type             <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA
$ country                <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA
$ country_code           <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA
$ geo_coords             <list> [<NA, NA>, <NA, NA>, <NA, NA>, <NA, NA>, <NA, NA>, <NA, NA>, <NA, NA>, <NA, NA>, <...
$ coords_coords          <list> [<NA, NA>, <NA, NA>, <NA, NA>, <NA, NA>, <NA, NA>, <NA, NA>, <NA, NA>, <NA, NA>, <...
$ bbox_coords            <list> [<NA, NA, NA, NA, NA, NA, NA, NA>, <NA, NA, NA, NA, NA, NA, NA, NA>, <NA, NA, NA, ...

rtweets06 %>% 
    tidytext::unnest_tokens(word, text) %>% 
    select(screen_name, word) %>%
    slice(1:5)
Error in unnest_tokens.data.frame(., word, text) : 
  unnest_tokens expects all columns of input to be atomic vectors (not lists)
```

This doesn’t work because {rtweet} results now have list columns, which
throws an error when we call `unnest_tokens()` from {tidytext} 0.1.5.
The function checks if all the columns of the df are atomic.

The new {tidytext} version prevents this behavior, as you can pass a df
containing list
columns.

``` r
# I'm restarting R from RStudio here, to avaid internal error -3 in R_decompress1 error
.rs.restartR()
NULL

Restarting R session...

install.packages("tidytext", repos = "http://cran.us.r-project.org", quiet = TRUE)

  There is a binary version available but the source version is later:
         binary source needs_compilation
tidytext  0.1.5  0.1.6             FALSE

installing the source package ‘tidytext’

 
packageVersion("tidytext")
[1] ‘0.1.6’

library(tidytext)
library(dplyr)
```

``` r
rtweets06 %>% 
      unnest_tokens(word, text) %>% 
      select(screen_name, word) %>%
      slice(1:5)
# A tibble: 5 x 2
    screen_name       word
          <chr>      <chr>
1 brian_leavell         rt
2 brian_leavell kateumbers
3 brian_leavell       what
4 brian_leavell         to
5 brian_leavell         do
```

This now works because {tidytext} no longer checks if all the columns
are atomic.

Yet we’ve got an issue if we move to the `hashtag` column:

``` r
rtweets06 %>% 
      unnest_tokens(word, hashtag) %>% 
      select(screen_name, word) %>%
      slice(1:5)
Error in check_input(x) : 
  Input must be a character vector of any length or a list of character
  vectors, each of which has a length of 1.
```

In fact, **the problem has moved**: the function now checks at a lower
level: you can indeed use a df containing list-columns, but you can’t
pass a list-column as input.

## Workaround for hashtag column

So, as promised, here’s the workaround:

``` r
library(purrr)
as_vector(rtweets06$hashtags) %>% 
      table() %>% 
      as.data.frame() %>% 
      arrange(Freq) %>% 
      top_n(5)
Selecting by Freq
              . Freq
1          data    1
2       ecology    1
3     evolution    1
4          meta    1
5  metaanalysis    1
6             r    1
7       dataviz    2
8       ggplot2    2
9   DataScience    3
10       rstats    9
```






