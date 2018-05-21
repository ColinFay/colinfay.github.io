---
title: "A Crazy Little Thing Called {purrr} - Part 3 : Setting NA"

post_date: 2017-12-06
layout: single
permalink: /purrr-set-na/
tags:
  - purrr
categories : r-blog-en
excerpt_separator: <!--more-->
---

Ok, you've got the Queen reference by now. 

<!--more-->

I think I've never been that assiduous on my blog. 

> Note: this blogpost is inspired by a recent discussion on the {naniar} Github repo

Here's the one million dollar question: how can we replace some values with NAs in a data.frame? And of course, how can we do that with a "tidyverse" mindset: that is to say with something like "replace_to_na_at" or "replace_to_na_if"?

In this blog post, I'll show you how to create these functions with {purrr} : 

+ `replace_to_na_when` : takes the dataframe, and replace to NA everywhere the condition is met in the data.frame. 

+ `replace_to_na_at` : replace at specific columns, where the condition is met. 

+ `replace_to_na_if` : replace if the column meets the condition and where the value meets the second condition. 

As you know, data.frames are list of same-length vectors. Let's decompose our process by starting with a simple question: how to change an element to NA under a certain condition in a vector. 

```r
library(purrr)
library(tidyverse)
library(rlang)
```

{purrr} has this amazing feature that allow to simply modify an element by creating a `~ val` mapper. So you can basically : 

```r
a <- letters[1:5]
map_chr(a, ~ "z")
[1] "z" "z" "z" "z" "z"
```

So maybe we should?

```r
map_chr(a, ~ NA)
[1] NA NA NA NA NA
```

Yes, we should. But we've said we just want to change a value if a condition is met. 

So, with `modify_if()`:

```r
c(modify_if(a, ~ .x == "a", ~ NA), recursive = TRUE)
[1] NA  "b" "c" "d" "e"
```

Ok, seems to be good. But as you may be thinking, this can't be that easy. If you're wondering : "what if there are already a NA in the vector?", that's exacty where I'm going for: 

```r
b <- c(NA, letters[1:5])
c(modify_if(b, ~ .x == "a", ~ NA), recursive = TRUE)
Error in .x[sel] <- map(.x[sel], .f, ...) : 
  NAs forbidden in indexed affectations
```

Yep, an error. So, we want to change the mapper, of course: 

```r
b <- c(NA, letters[1:5])
modify_if(b, ~ .x == "a" & !is.na(.x), ~ NA ) %>% reduce(c)
[1] NA  NA  "b" "c" "d" "e"
```

So here, if the condition is met, and if the value is not a NA, a NA is assigned. Sounds simple, right? Yet the thing is I don't want my end function to ask for a "custom mapper + a `& !is.na(.x)`". Cause you know, error prone, and "anything that can be automated, should be automated. Do as little as possible by hand" [source](http://r-pkgs.had.co.nz/intro.html) and all that. 

To sum up, I need a mapper composer that can take a user given mapper, and return this custom mapper with "`& !is.na(.x)`" at the end of it. For this, I'll use a little helper from {rlang}, `f_text()`, that extracts the right hand side of a formulat. Then, we'll glue this, turn it into a formulation, then into a mapper.

So here it is: 

```r
create_mapper_na <- function(.p){
  glue::glue("~ ({f_text(.p)}) & !is.na(.)") %>% 
    as.formula() %>%
    as_mapper()
}

create_mapper_na(~ .x < 20)

function (..., .x = ..1, .y = ..2, . = ..1) 
(.x < 20) & !is.na(.)

class(create_mapper_na(~ .x < 20))
[1] "function"

```

Yey 🎉 !! 

Now we need a `na_set()` that will take a predicate, and turn to NA if the `.p` condition is met. 

```r
na_set <- function(vec, .p) {
  modify_if(vec, create_mapper_na(.p) , ~ NA) %>% 
    reduce(c)
}

small <- airquality %>% 
  slice(1:10)
  
na_set(small$Ozone, ~ .x < 20)
[1] 41 36 NA NA NA 28 23 NA NA NA
```

> Note bis: here's another (cleaner) version proposed by Romain for na_set: [napalm](https://gist.github.com/romainfrancois/c9406cc7b9776706dd1c11269c0d1965)


k, so now that's quite easy: `replace_to_na_where` map over all the columns from a data.frame, and sets values to `NA` globally. 

```r
replace_to_na_when <- function(tbl, .p) {
  map_df(tbl, ~ na_set(.x, .p) )
} 

replace_to_na_when(small, ~ .x < 20)  
# A tibble: 10 x 6
   Ozone Solar.R  Wind  Temp Month   Day
   <int>   <int> <dbl> <int> <lgl> <lgl>
 1    41     190    NA    67    NA    NA
 2    36     118    NA    72    NA    NA
 3    NA     149    NA    74    NA    NA
 4    NA     313    NA    62    NA    NA
 5    NA      NA    NA    56    NA    NA
 6    28      NA    NA    66    NA    NA
 7    23     299    NA    65    NA    NA
 8    NA      99    NA    59    NA    NA
 9    NA      NA  20.1    61    NA    NA
10    NA     194    NA    69    NA    NA
```

`replace_to_na_at` is just a wrapper around `modify_at`:

```r
replace_to_na_at <- function(tbl, .at, .p) {
  modify_at(tbl, .at, ~ na_set(.x, .p))
} 

replace_to_na_at(tbl = small, .at = c("Wind", "Ozone"), ~ .x < 20) 
# A tibble: 10 x 6
   Ozone Solar.R  Wind  Temp Month   Day
   <int>   <int> <dbl> <int> <int> <int>
 1    41     190    NA    67     5     1
 2    36     118    NA    72     5     2
 3    NA     149    NA    74     5     3
 4    NA     313    NA    62     5     4
 5    NA      NA    NA    56     5     5
 6    28      NA    NA    66     5     6
 7    23     299    NA    65     5     7
 8    NA      99    NA    59     5     8
 9    NA      19  20.1    61     5     9
10    NA     194    NA    69     5    10
```

And `replace_to_na_if` a wrapper around `modify_if()`:
```r
replace_to_na_if <- function(tbl, .p, .pp) {
  modify_if(tbl, .p, ~ na_set(.x, .pp))
} 

small %>%
  mutate(Day = as.factor(small$Day)) %>%
  replace_to_na_if(is.numeric, ~ .x < 20) 

# A tibble: 10 x 6
   Ozone Solar.R  Wind  Temp Month    Day
   <int>   <int> <dbl> <int> <lgl> <fctr>
 1    41     190    NA    67    NA      1
 2    36     118    NA    72    NA      2
 3    NA     149    NA    74    NA      3
 4    NA     313    NA    62    NA      4
 5    NA      NA    NA    56    NA      5
 6    28      NA    NA    66    NA      6
 7    23     299    NA    65    NA      7
 8    NA      99    NA    59    NA      8
 9    NA      NA  20.1    61    NA      9
10    NA     194    NA    69    NA     10
```

Cool stuff is you can build complexe predicates for replacing to NA : 

```r
replace_to_na_when(small, ~ sqrt(.x) > 5 | .x == 2)
# A tibble: 10 x 6
   Ozone Solar.R  Wind  Temp Month   Day
   <int>   <int> <dbl> <lgl> <int> <int>
 1    NA      NA   7.4    NA     5     1
 2    NA      NA   8.0    NA     5    NA
 3    12      NA  12.6    NA     5     3
 4    18      NA  11.5    NA     5     4
 5    NA      NA  14.3    NA     5     5
 6    NA      NA  14.9    NA     5     6
 7    23      NA   8.6    NA     5     7
 8    19      NA  13.8    NA     5     8
 9     8      19  20.1    NA     5     9
10    NA      NA   8.6    NA     5    10
```
> Note ter: as said by Romain on [twitter](https://twitter.com/romain_francois/status/938764972003414021), replacing to NA in a data.frame is more of a {dplyr} than a {purrr} job. Yet, the solution with {purrr} is more general, and can be used for all kinds of lists  
