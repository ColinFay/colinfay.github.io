---
title: "Explain R environments like I’m five"

post_date: 2018-02-15
layout: single
permalink: /explain-environments-eli5/
categories: r-blog-en
output: jekyllthat::jekylldown
tags: [r, environment, explainlikeimfive]
excerpt_separator: <--!more--> 
---

“Can you explain me what are environments in R?”

The beginning of a series of blogpost about R concepts, explained to my
daughter.



> Side note: no, my daughter is not five, and she’s not named Alice. And
> she doesn’t speak english either ¯\\*(ツ)*/¯.

“Daddy, I’ve seen you reading this book with a weird chapter named
‘Environments in R’. What does it mean?”

“Alice darling, just sit down for a minute.

Let’s say the world is a big computer, and everyone living in it is a
piece of information we call ‘data’. Right now, we are at home, and home
is a small piece from the whole world. In R, these smaller places are
called environments, and they are used just as our home: they can
contain data, and we can refer to these data with names which are
specific to the environment.

For example, when we are at home, there are five pieces of data: you,
me, mommy, and the two cats. At home, I can say ‘Darling’, and as we are
in this small subset of the whole world where ‘darling’ refers to you,
I’m pretty sure I will find you. But if I go in another home, that is
to say in another environment with other data, another dad is calling
his daughter ‘Darling’. In this small other environment, different from
ours, ‘Darling’ does not refer to the same piece of data. And the same
goes for “Mommy” and “Daddy”: in another home, they refer to other
persons.

If I go out in the wild world and try to use the word ‘Mommy’, this
won’t specifically refer to your mum, as there are not one single
‘Mommy’ in this world, and because this word refers to someone
specific to the home we are using it in. In the wild world, if I want to
refer to your mum, I’ll need to specify from which home the ‘Mommy’ I’m
looking for is coming from."

“So why don’t we use the full name every time then? It seems simpler.”

“Environments allow us to use the same word to refer to different data,
depending on where we are using the word. It also allows to give
information about a piece of data: it’s quite normal to think that a
father uses ‘Darling’ to refer to someone he loves very very much. Even
if, strictly speaking, nothing prevents the contrary from happening.

Also, it wouldn’t be fair to only allow only one ‘Darling’ in the whole
world. Thanks to environment, there won’t be any problem if every father
in the world use this word, as it refers, in each home, to a specific
little girl."

“Ok, thanks dadddy\!”

“You’re welcome, Darling”

## The R code behind

### About environments

``` r
# Creating two houses
home <- new.env()
home$Darling <- "Alice"
neighbour <- new.env()
neighbour$Darling <- "Jannet"

# If I want to call Darling from the wild world that is .GlobalEnv, 
# I'll need to specify where Darling comes from
home$Darling
```

    ## [1] "Alice"

``` r
neighbour$Darling
```

    ## [1] "Jannet"

``` r
# Use Darling as a symbol
Darling <- quote(Darling)

# Evaluate Darling if I'm home
eval(Darling, home)
```

    ## [1] "Alice"

``` r
# Evaluate Darling if I'm not home
eval(Darling, neighbour)
```

    ## [1] "Jannet"

### About packages

``` r
# A package is an environment containing functions
# Two package can contain functions that have the same name without any problem
find("lag")
```

    ## [1] "package:stats"

``` r
find("filter")
```

    ## [1] "package:stats"

``` r
library(tidyverse)
find("lag")
```

    ## [1] "package:dplyr" "package:stats"

``` r
find("filter")
```

    ## [1] "package:dplyr" "package:stats"

## About dataframes

``` r
# They are environments
one_data_frame <- data.frame(this_col = 1:26)
another_data_frame <- data.frame(this_col = letters)
this_col <- quote(this_col)
eval(this_col, envir = one_data_frame)
```

    ##  [1]  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23
    ## [24] 24 25 26

``` r
eval(this_col, envir = another_data_frame)
```

    ##  [1] a b c d e f g h i j k l m n o p q r s t u v w x y z
    ## Levels: a b c d e f g h i j k l m n o p q r s t u v w x y z

You have another “explain me like I’m five” for R environments? Feel
free to share it in the comments, or to reach me on Twitter :)

> Ps: this blogpost is inspired by this really cool
> [\#explainmelikeimfive](https://dev.to/ben/explain-websockets-like-im-five)






