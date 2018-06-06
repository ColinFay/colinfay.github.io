---
title: "A Crazy Little Thing Called {purrr} - Part 4: mappers"

post_date: 2017-12-12
layout: single
permalink: /purrr-mappers/
tags:
  - purrr
categories : r-blog-en
output: jekyllthat::jekylldown
excerpt_separator: #----#
---

I won’t talk about the Queen reference anymore.

#----#

I’ve been working lately on a new package called {attempt}, which is an
attempt at making try catch and condition handling in R a little bit
friendlier. If you have some time to spare, I’ll be glad if you can give
me some feedbacks about it: positive, negative, PR, improvement
suggestions <https://github.com/ColinFay/attempt>… Feel free\!

This package relies a lot on {purrr} mappers (and on {rlang} but I won’t
be talking about {rlang} today… maybe in another series of posts). Today
I’m gonna talk briefly about this cool stuff in {purrr} called mappers.
(Well, these mappers are forwarded to {rlang} so this is a cool stuff
from {rlang}, yet the mappers constructor `as_mapper` is a {purrr}
function).

## What on earth are mappers

You’ve been using mappers a lot if, like me, you’ve been using {purrr} a
lot. These are the one sided formulas which are created as such :

``` r
library(purrr)
map_dbl(1:3, ~ .x * 10)
```

    ## [1] 10 20 30

``` r
# or 
map_dbl(1:3, ~ . * 10)
```

    ## [1] 10 20 30

``` r
# or 
map2_dbl(1:3, 3:5, ~ .x + .y)
```

    ## [1] 4 6 8

Here, you’re creating a lambda function on the fly: the first and second
multiplying each element by 10, and the third adding each `x` and `y`
together.

## What’s happening behind?

The first thing that `map` (and other map\_\*) do is turning a the `~ .x
\* 10` into a mapper with `as_mapper`.

``` r
map
```

    ## function(.x, .f, ...) {
    ##   .f <- as_mapper(.f, ...)
    ##   .Call(map_impl, environment(), ".x", ".f", "list")
    ## }
    ## <environment: namespace:purrr>

In the background, mappers are created with {rlang} `as_function`: so,
as you could have guessed, this turns formulas into functions.

``` r
addition <- as_mapper(~ .x + .y)
addition
```

    ## function (..., .x = ..1, .y = ..2, . = ..1) 
    ## .x + .y

As you can see, the function is created with the .x matching the first
argument, the .y matching the second, and the . alone matching the
first. It’s that simple, you now have a good old R function:

``` r
addition(1,3)
```

    ## [1] 4

## How is that useful?

### Don’t repeat yourself

This first comes handy when you have a lot of mapping to do:

``` r
map2_int(1:3, 4:6, addition)
```

    ## [1] 5 7 9

``` r
map2_int(1:10, 21:30, addition)
```

    ##  [1] 22 24 26 28 30 32 34 36 38 40

``` r
map2_int(2:3, 4:5, addition)
```

    ## [1] 6 8

### Flexible mappers

Mappers are what allow {purrr} flexibility with mapping, as it alows you
to use a defaut R functions inside map:

``` r
as_mapper(is.numeric)
```

    ## function (x) 
    ## is.numeric(x = x)
    ## <environment: base>

or characters and numbers that creates calls to `pluck`:

``` r
as_mapper(1)
```

    ## function (x, ...) 
    ## pluck(x, list(1), .default = NULL)
    ## <environment: 0x7fcae3543788>

``` r
as_mapper("this")
```

    ## function (x, ...) 
    ## pluck(x, list("this"), .default = NULL)
    ## <environment: 0x7fcae3280190>

or even another lambda function :

``` r
as_mapper(function(x, y) {x+y} )
```

    ## function(x, y) {x+y}

### mappers with more than two arguments

So, here’s the trick if you want to create mappers with more than two
arguments: use `..1`, `..2`, `..3`, etc. Here’s an example with `pmap`.

``` r
l <- list(rnorm(10),
          rnorm(100), 
          rnorm(1000))
pmap_dbl(list(l, 20, TRUE), ~ mean(..1, ..2, ..3)) 
```

    ## [1] 0.48879956 0.15248405 0.01861908

## Using mapper inside {attempt}

### try\_catch

These are also what allows {attempt} to be flexible when building
trycatch calls and condition handlers.

As you may know, `tryCatch` takes four arguments :

  - The expression to evaluate (mandatory)
  - A **function** to be run on error
  - A **function** to be run on warning
  - A **function** to be run on exit

So if you’ve followed along, you now know that I can use mappers here as
arguments of a `tryCatch` call. This is exactly what `try_catch`, from
{attempt}, does.

Here’s a shorten example (and slightly different from the one in
{attempt} as `try_that` is built with {rlang} `lang`) :

``` r
try_catch <- function(expr, .e) {
  tryCatch( expr,
    error = as_mapper(.e)
  )
}
try_catch(log("a"), .e = ~ paste("There was an error:", .x))
```

    ## [1] "There was an error: Error in log(\"a\"): argument non numérique pour une fonction mathématique\n"

### stop\_if

As package developers, we need to keep in mind that everything is
possible when it comes to functions being used in the wild (characters
in place of number is just an example).

So the first lines of a function are usually used to verify the inputs.
Like :

``` r
pimped_sum <- function(x, y){
  if (! is.numeric(x) | ! is.numeric(y)) {
    stop("x and y must be numeric")
  }
  x + y
}
pimped_sum("1", 2)
```

    ## Error in pimped_sum("1", 2): x and y must be numeric

But that’s a lot of duplicated code, a lot of if if there are lot of
checks to do, and not that much functions stating clearly what they do.

So here comes {attempt}:

``` r
library(attempt)
```

    ## 
    ## Attaching package: 'attempt'

    ## The following object is masked _by_ '.GlobalEnv':
    ## 
    ##     try_catch

``` r
pimped_sum <- function(x, y){
  stop_if_any( c(x, y), 
               ~ ! is.numeric(.x), 
               msg = "your args should be numeric")
  x + y
}
pimped_sum("1", 2)
```

    ## Error: your args should be numeric

You can have a look at what {attempt} does on the [GitHub
repo](https://github.com/ColinFay/attempt).

``` r
# Simpler example
small_by_ten <- function(x){
  stop_if( x, 
           ~ .x > 10, 
           msg = "x should be less than ten" )
  x * 10
}
small_by_ten(11)
```

    ## Error: x should be less than ten

So here, you can see that we are using a formula inside `stop_if`. How
does if work ? The second argument is turned into a mapper, and then
used to test x. Here’s a simplified version of this function:

``` r
stop_if <- function(.x, .p){
  .p <- as_mapper(.p)
  if ( .p(.x) )
      stop("Error!")
}
stop_if(10, ~ .x < 11)
```

    ## Error in stop_if(10, ~.x < 11): Error!

The flexibily of the mapper system allows you to pass base and classical
function, because as we’ve seen, they are all turned to the same
function template :

``` r
stop_if(10, is.numeric)
```

    ## Error in stop_if(10, is.numeric): Error!

``` r
stop_if(10, function(x) sqrt(x) < 100)
```

    ## Error in stop_if(10, function(x) sqrt(x) < 100): Error!

Aaaaaand that’s it for today :)



