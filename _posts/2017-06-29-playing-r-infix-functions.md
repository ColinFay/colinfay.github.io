---
title: "Playing with R, infix functions, and pizza"

post_date: 2017-06-29
layout: single
permalink: /playing-r-infix-functions/
categories : r-blog-en
tags: [r, justforfun]
excerpt_separator: #----#
---

Digging into a not so special type of R functions, in order to make an emoji-pizza-dplyr-slice one.

#----#

## What are infix functions? 

In R, most of the functions are "prefix" - meaning that the function name comes before the arguments, which are put between parentheses : `fun(a,b)`. With infix functions, the name comes between the arguments `a fun b`. In fact, you use this type on a daily basis with `:`, `+`, and so on. 

> So, how can you create your own infix functions? 

As an R user (and even if you come from another language), you're used to write your functions in this form : 

```r
a_function <- function(some_variable, another_one) {
  do_some_stuffs(some_variable,another_one)
}
# And write a function call this way:
a_function(some_variable,another_one)
```

But if your function has only two operators, you can write it this way : 

```r
`%some_function%` <- function(some_variable,another_one) {
  do_some_stuffs(some_variable,another_one)
}
# And use it with:
some_variable %a_function% another_one
```

![](https://media.giphy.com/media/sOGgevbtBDYKQ/giphy.gif)

At this point, you've noticed two things : 

### Back ticks 

Back ticks are R way to denote a special name. You can in fact put any characters between them (even emoji, as we'll see later on):

```r
# Impossible
123 <- function(a,b){a+b}
_some_function <- function(a,b){a+b}
#Possible
`123` <- function(a,b){a+b}
`_some_function` <- function(a,b){a+b}
```

### Percent sign `%` 

The two `%` surrounding the function name are necessary if you want to create your own infix functions. As `%` is a special character, you need to use it inside back ticks. Note that basic infix functions in R don't need the percent sign, but user generated one do. 

```r
1:10
# is equivalent to 
`:`(1,10)
2+3
# is equivalent to 
`+`(2,3)
```

Good thing (or maybe not) is that you can override the default functions, if you want to drive someone mad: 

```r
# Warning : don't try this at home 
`+` <- function(a,b){a*b}
2+10
[1] 20

`<-` <- .Primitive("+")
2 <- 3
[1] 5

`:` <- .Primitive("*")
2:10
[1] 20

# Restore cosmic ordeR 
`<-` = .Primitive("<-")
`+` <- .Primitive("+")
`:` <- .Primitive(":")
```

## Some examples 

```r
`%oh_wait%` <- function(a,b) {
  print(a);Sys.sleep(3);print(b)
  }
Sys.time() %oh_wait% Sys.time()
[1] "2017-06-28 23:01:43 CEST"
[1] "2017-06-28 23:01:46 CEST"
```

This first function does nothing but printing the time twice, with 3 seconds of pause in-between. Needless to say that's useless, but that was just an example :) 

Let's do something more tidyverse friendly. For example, let's try a function `%select%` which will be the equivalent to `%>% select()`. 

```r
library(tidyverse)
`%select%` <- dplyr::select

iris %select% "Species"
# Is equivalent to 
iris %>% select("Species")
```

## And now, the cool stuffs

You can use (almost) any character you like between the two `%`, except %, of course. But... really **ANYTHING**? Because, you know, sometimes you just need to make some pizza function calls, or maybe you just like emojis. 

```r
# Not working 

🍕 <- dplyr::slice
> Erreur : unexpected input in "�"

# Working 

`%🍕%` <- dplyr::slice
iris %🍕% 2

# A tibble: 1 x 5
  Sepal.Length Sepal.Width Petal.Length Petal.Width Species
         <dbl>       <dbl>        <dbl>       <dbl>  <fctr>
1          5.1         3.5          1.4         0.2  setosa

```

So, anybody has some spare time to recode the whole tidyverse in emojis? 😃

More on infix functions : 

+ [R language definition](https://cran.r-project.org/doc/manuals/r-release/R-lang.html#Special-operators)
+ [Advanced R - Functions](http://adv-r.had.co.nz/Functions.html)



