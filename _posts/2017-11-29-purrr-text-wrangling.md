---
title: "A Crazy Little Thing Called {purrr} - Part 2 : Text Wrangling"

post_date: 2017-11-29
layout: single
permalink: /purrr-text-wrangling/
tags:
  - purrr
categories : r-blog-en
excerpt_separator: <--!more--> 
---

Yes, this title is still a Queen reference. 



I've recently been exchanging DM with Rémi (who writes cool stuffs about data science and SEO on his blog, so here's some [Google Juice](https://remibacha.com/) for him) who was looking for a way to turn this kind of dataframe: 

|Keywords                  |
|:-|
|articlexyz for sale       |
|cheap articlexyz          |
|razor articlexyz          |
|articlexyz walmart        |
|articlexyz games          |
|articlexyz amazon         |
|bluetooth articlexyz      |
|how much is a articlexyz  |
|articlexyz for sale cheap |

Into something like : 

|Keywords                  |
|:-|
|for sale       |
|cheap           |
|razor           |
|walmart        |
|games          |
|amazon         |
|bluetooth       |
|how much is a   |
| for sale cheap |

If ever you've been playing with adwords, this may look like something you're familiar with (I guess this is what Rémi has been playing with). 

Anyway, the question then is how to write a function that can remove the n most common words out of this data.frame. As you know, I love {purrr}, and this is the kind of exercise I just can't resist to solve. 

So basically, here's the how-to.

## A little bit of context

The first thing that came to my mind there (there might be some more straightforward ways to do this, feel free to comment at the bottom of this article if you have another approach) is to build a regex and `str_replace` the matching patterns (i.e. the top words) with a blank. 

This is kind of easy if you've just want to remove the most common one. But I wanted to have a more flexible function which could remove as many common words as I wanted. More or less, something that takes a n arg and remove the n most commons.

Basically, in this example, the most common word is articlexyz, so I want a function that can remove just this one, or articlexyz and the second most common, etc. 

Oh, and of course, with tidy eval.

```r
library(tidyverse)
library(magrittr)
library(tidytext)
# Here's my example data.frame
df <- tribble(
  ~Keywords, 
  "articlexyz for sale", 
  "cheap articlexyz for sale", 
  "amazon articlexyz", 
  "articlexyz walmart cheap", 
  "articlexyz games", 
  "articlexyz amazon", 
  "bluetooth articlexyz", 
  "how much is a articlexyz on amazon", 
  "articlexyz for sale cheap" 
)

```

## The regex builder

So, here's how to build a regex builder of the most common words with {purrr}, {dplyr} and {tidytext}. 

### First of all, extract the most common

```r
concat_commons <- function(df, col, levels){
  unnest_tokens(df, word, !! enquo(col)) %>%
    count(word) %>%
    anti_join(stop_words) %>%
    arrange(desc(n)) %>%
    slice(1:levels) %>% 
    pull(word)
}

```

Nothing fancy here, just a common words extractor : 
  
```r
concat_commons(df, Keywords, 2)
[1] "articlexyz" "amazon" 
```

### The regex builder

The most complex thing here is that my end result should match only words, not letter inside a word: i.e. if "a" is the most common word, `articlexyz` should be turned into `rticlexyz`, but '` a `' (space-a-space) should be removed. Here, you can't go for for space-pattern-space matching, cause "articlexyz bla bla bla" won't match because there is no blank at the beginning. ^articlexyz$ won't match "bla articlexyz bla bla" either, as this is a blank-word-blank pattern. 

So let's be this xkcd guy : 

![](https://imgs.xkcd.com/comics/regular_expressions.png)

Here's the regex put at the beginning and the end of the pattern : `\\barticlexyz\\b`, as `\b`  will match a word bundary. 

```r
regex_build <- function(list){
  # Make sure only the words are matched
  map(list, ~ paste0("\\b", .x, "\\b")) %>%
    # Reduce everything
    reduce(~ paste(.x, .y, sep = "|"))
}
```
So we've got our regex with:

```r
concat_commons(df, Keywords, 2) %>%
  regex_build()
[1] "\\barticlexyz\\b|\\bamazon\\b"
```
Let's bulk replace

```r
bulk_replace <- function(regex, vec){
    map(vec, ~ stringr::str_replace_all(string = .x, pattern = regex, replacement = "") ) %>%
    # Prevent the "too many spaces" to come
    map(~ stringr::str_replace_all(string = .x, pattern = " {2,}", replacement = " "))
}

reg <- concat_commons(df, Keywords, 2) %>%
  regex_build() 
bulk_replace(reg, df$Keywords)

[[1]]
[1] " for sale"

[[2]]
[1] "cheap for sale"

[[3]]
[1] " "

[[4]]
[1] " walmart cheap"

....

```

### The not-so-regex solution

If you're not that into regex (nobody's perfect), let's do something with less regex and more {purrr}: string split, map, reduce. 

```r
regex_build <- function(list){
    reduce(list, ~ paste(.x, .y, sep = "|"))
}
```
Simple regex here:

```r
concat_commons(df, Keywords, 2) %>%
  regex_build()
[1] "articlexyz|amazon""
```

### Bulk replace this with stringsplit

Here the trick to forget this "beginning end whitespace" nightmare (not a nightmare, really) is to split and test every element against the regex, so split, replace, unsplit. 

To do the "unsplit", as the result is a list of depth one, we need to `modify_depth`:

```r
bulk_replace <- function(regex, vec){
  str_split(vec, " ") %>%
    map(~ stringr::str_replace_all(string = .x, pattern = regex, replacement = "") )  %>%
    # We need to modify at the first level 
    modify_depth(1, ~ reduce(.x, ~ paste(.x, .y, sep = " "))) %>%
    # Prevent the "too many spaces" to come
    map(~ stringr::str_replace_all(string = .x, pattern = " {2,}", replacement = " "))
}

reg <- concat_commons(df, Keywords, 2) %>%
  regex_build() 
bulk_replace(reg, df$Keywords)

[[1]]
[1] " for sale"

[[2]]
[1] "cheap for sale"

[[3]]
[1] " "

[[4]]
[1] " walmart cheap"

....

```

Yes. The very same result.

### Remove commons

Ok let's wrap this in a function : 

```r
remove_commons <- function(df, input, output, levels){
  input <- enquo(input)
  output <- quo_name(enquo(output))
  most_common <- concat_commons(df, !! input, levels)
  df %>%
    mutate(!! output := bulk_replace( regex_build(most_common), !! input )) %>%
    unnest()
}
```

So here, we've got a function that takes a data.frame, the name of the input and output columns, and the number of common words to remove. Let's try this: 

```r
remove_commons(df, Keywords, group, 2)
# A tibble: 9 x 2
                            Keywords             group
                               <chr>             <chr>
1                articlexyz for sale          for sale
2          cheap articlexyz for sale    cheap for sale
3                  amazon articlexyz                  
4           articlexyz walmart cheap     walmart cheap
5                   articlexyz games             games
6                  articlexyz amazon                  
7               bluetooth articlexyz        bluetooth 
8 how much is a articlexyz on amazon how much is a on 
9          articlexyz for sale cheap    for sale cheap
```

🎉 !!

Of course we've got some blank shere, as two observations are composed of the most common words
. Let's count: 
```r
remove_commons(df, Keywords, group, 1) %>%
  unnest_tokens(word, group) %>%
  anti_join(stop_words) %>%
  count(word, sort = TRUE)
 A tibble: 6 x 2
       word     n
      <chr> <int>
1    amazon     3
2     cheap     3
3      sale     3
4 bluetooth     1
5     games     1
6   walmart     1
```

### Labels

So now, maybe we want to assign each observation to its "most common label but not the n first", that is to say, I want "articlexyz for sale on amazon" to be assigned a label "sale" if this is the most common after the n, or amazon, etc. 

So here comes `detect()` : 

```r
which_label <- function(vec, list) {
  detect(list, ~ grepl(pattern = .x, vec)) %||% NA 
}

# List of common words :
commons_words <- concat_commons(df, Keywords, 2)

df %>% 
  mutate(group = map_chr(df$Keywords, 
                         ~ which_label(.x, common_words$group))) 
# A tibble: 9 x 2
                            Keywords     group
                               <chr>     <chr>
1                articlexyz for sale      sale
2          cheap articlexyz for sale     cheap
3                  amazon articlexyz    amazon
4           articlexyz walmart cheap     cheap
5                   articlexyz games     games
6                  articlexyz amazon    amazon
7               bluetooth articlexyz bluetooth
8 how much is a articlexyz on amazon    amazon
9          articlexyz for sale cheap     cheap
```

And now, let's sell some Google Ads! 

![](https://i.giphy.com/media/VTxmwaCEwSlZm/200.gif)






