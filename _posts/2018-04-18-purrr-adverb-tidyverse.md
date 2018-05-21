---
title: "[How to] Write a purrr-like adverb"
post_date: 2018-04-18
layout: single
permalink: /purrr-adverb-tidyverse/
categories: r-blog-en
output: jekyllthat::jekylldown
excerpt_separator: <!--more-->
---

Create your own `safely`, `compose` and friends!

<!--more-->

What is an adverb
-----------------

If you read carefully the [purrr documentation](http://purrr.tidyverse.org/reference/index.html#section-adverbs), you'll find this simple explanation :

> Adverbs modify the action of a function; taking a function as input and returning a function with modified action as output.

In other words, adverbs take a function, and return this function modified. Yes, just as an adverb modifies a verb. So if you do :

``` r
library(purrr)
safe_log <- safely(log)
```

The returned object is another function that you can use just as a regular one.

``` r
class(safe_log)
```

    ## [1] "function"

``` r
safe_log("a")
```

    ## $result
    ## NULL
    ## 
    ## $error
    ## <simpleError in log(x = x, base = base): argument non numérique pour une fonction mathématique>

In computer science, these adverbs are what is called "high-order functions".

How to write your own?
----------------------

I've been playing with adverbs in [{attempt}](https://github.com/ColinFay/attempt), notably through these adverbs :

``` r
library(attempt)

# Silently only return the errors, and nothing if the function succeeds
silent_log <- silently(log)
silent_log(1)
```

``` r
# Surely make a function always work, without stopping the process
sure_log <- surely(log)
sure_log(1)
```

    ## [1] 0

``` r
sure_log("a")
```

``` r
# with_message and with_warning
as_num_msg <- with_message(as.numeric, msg = "We're performing a numeric conversion")
as_num_warn <- with_warning(as.numeric, msg = "We're performing a numeric conversion")
as_num_msg("1")
```

    ## We're performing a numeric conversion

    ## [1] 1

``` r
as_num_warn("1")
```

    ## Warning in as_num_warn("1"): We're performing a numeric conversion

    ## [1] 1

So, how to implement this kind of behavior? Let's take a simple example with `sleepy`, also shared on [Twitter](https://twitter.com/_ColinFay/status/981435910989533184).

``` r
sleepy <- function(fun, sleep){
  function(...){
    Sys.sleep(sleep)
    fun(...)
  }
}

sleep_print <- sleepy(Sys.time, 5)
class(sleep_print)
```

    ## [1] "function"

``` r
# Let's try
Sys.time()
```

    ## [1] "2018-04-19 10:20:58 CEST"

``` r
sleep_print()
```

    ## [1] "2018-04-19 10:21:03 CEST"

Let's decompose what we've got here.

First of all, the function should return another function, so we need to start with :

``` r
talky <- function(){
  function(){
    
  }
}
```

What this function will take as a first argument is another function, that will be executed when our future new function is called.

So let's do this:

``` r
talky <- function(fun){
  function(){
    fun()
  }
}
```

Because you know, with R referential transparency, you can create a variable that is a function:

``` r
plop <- mean
plop(1:10)
```

    ## [1] 5.5

This simple skeleton will work if we take a function without any args:

``` r
sys_time <- talky(Sys.time)
sys_time()
```

    ## [1] "2018-04-19 10:21:03 CEST"

But hey, this is not what we want: we need this new function to be able to take arguments. So let's use our friend `...`.

``` r
talky <- function(fun){
  function(...){
    fun(...)
  }
}
```

Now, our new adverb creates a function that can take arguments. But as you've notice, this is still not really an adverb: we need to **modify** something. Now you're only limited by your imagination ;)

``` r
# Print the time
talky <- function(fun){
  function(...){
    print(Sys.time())
    fun(...)
  }
}
talky_sqrt <- talky(sqrt)
talky_sqrt(10)
```

    ## [1] "2018-04-19 10:21:03 CEST"

    ## [1] 3.162278

``` r
# Or with a kind message ? 
talky <- function(fun, mess){
  function(...){
    message(mess)
    fun(...)
  }
}
talky_sqrt<- talky(fun = sqrt, mess = "Hey there! You Rock!")
talky_sqrt(1)
```

    ## Hey there! You Rock!

    ## [1] 1

``` r
# Run it or not ?
maybe <- function(fun){
  function(...){
    num <- sample(1:100, 1)
    if (num > 50) {
      fun(...)
    }
  }
}
maybe_sqrt <- maybe(fun = sqrt)
maybe_sqrt(1)
maybe_sqrt(1)
```

    ## [1] 1

``` r
maybe_sqrt(1)
```

    ## [1] 1

``` r
# Create a log file of a function 
log_calls <- function(fun, file){
  function(...){
    write(as.character(Sys.time()), file, append = TRUE, sep = "\n")
    fun(...)
  }
}
log_sqrt <- log_calls(sqrt, file = "logs")
log_sqrt(10)
```

    ## [1] 3.162278

``` r
log_sqrt(13)
```

    ## [1] 3.605551

``` r
readLines("logs")
```

    ## [1] "2018-04-19 10:21:03" "2018-04-19 10:21:03"
