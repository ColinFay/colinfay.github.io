---
title: "Some random R benchmarks"

post_date: 2018-01-09
layout: single
permalink: /random-r-benchmarks/
categories: r-blog-en
tags: [r, package, infrastructure]
output: jekyllthat::jekylldown
excerpt_separator: <!--more-->
---

Some random (one could say useless) benchmarks on R, serious or for fun,
and some advices to make your code run faster. <!--more-->

`disclamer::on()`

> As with all microbenchmarks, these won’t affect the performance of
> most code, but can be important for special cases. [Advanced R -
> Performance](http://adv-r.had.co.nz/Performance.html)

`disclamer::off()`

There are two main things you can do to optimise your code: **write more
and shorter functions** to avoid repeating yourself
(maintainance-oriented optimisation), and **find ways to make your R
code run faster** (usage-oriented optimisation).

One way to make you R code run really faster is to turn to languages
like C++. But you know, [it’s not that
easy](https://memegenerator.net/img/instances/500x/39604158/i-love-c-it-makes-people-cry.jpg),
and before turning to that, you can still use some tricks in plain R.

I was working on {attempt} lately, a package that (I hope) makes
conditions handling easier, and aims to be used inside other functions
([more on that](https://github.com/ColinFay/attempt)). As the {attempt}
functions are to be used inside other functions, I focused on trying to
speed things up as much as I could, in order to keep the general UX
attractive. And of course, I wanted to do that without having to go for
C / C++ (well, mainly because I don’t know how to program in C).

For this, I played a lot with {microbenchmark}, a package that allows to
**compare the time spent to run several R commands**, and in the end, I
was glad to see that using these benchmarks allowed me to write faster
functions (and sometimes, really faster). I won’t share them all here
(because this is a one thousand lines script), but here are some pieces
taken out of it.

> Because at the end of the day, someone always asks: “and what about
> performance?”

## return or stop as soon as possible

Funny thing: as I started writing this post, I came accross [this
blogpost](https://yihui.name/en/2018/01/stop-early/) by Yihui that
states the exact same thing I was writing: **focus on `return()` or
`stop()` as soon as possible**. Don’t make your code compute stuffs you
might never need in some cases, or make useless tests. For example, if
you have an if statement that will stop the function, test it first.

> Note: the examples that follow are of course toy examples.

``` r
library(microbenchmark)

compute_first <- function(a){
  b <- log(a) * 10 
  c <- log(a) * 100
  d <- b + c
  if( a == 1 ) {
    return(0)
  }
  return(d)
}
if_first <- function(a){
  if( a == 1 ) {
    return(0)
  }
  b <- log(a) * 10 
  c <- log(a) * 100
  d <- b + c
  return(d)
}

# First, make sure you're benchmarking on the same result
all.equal(compute_first(3), if_first(3))
```

    ## [1] TRUE

``` r
all.equal(compute_first(0), if_first(0))
```

    ## [1] TRUE

``` r
microbenchmark(compute_first(1), if_first(1), compute_first(0), if_first(0), times = 100)
```

    ## Unit: nanoseconds
    ##              expr min    lq   mean median    uq   max neval cld
    ##  compute_first(1) 487 509.5 684.65  522.5 568.0 12556   100   b
    ##       if_first(1) 238 257.0 291.21  265.5 298.0   779   100  a 
    ##  compute_first(0) 483 509.0 569.97  540.5 586.0  1196   100   b
    ##       if_first(0) 489 509.0 593.14  528.0 580.5  2657   100   b

As you can see, `compute_first` takes almost as much time to compute in
both cases. But you can save some time when using `if_first` : in the
case of `a == 1`, the function doesn’t compute `b`, `c` or `d`, so runs
faster.

Yes, it’s a matter of nanoseconds, but what if:

``` r
sleep_first <- function(b){
  Sys.sleep(0.01)
  if (b == 1 ){
    return(0)
  }
  return(b * 10)
}
sleep_second <- function(b){
  if (b == 1 ){
    return(0)
  }
  Sys.sleep(0.01)
  return(b * 10)
}

all.equal(sleep_first(1), sleep_second(1))
```

    ## [1] TRUE

``` r
all.equal(sleep_first(0), sleep_second(0))
```

    ## [1] TRUE

``` r
microbenchmark(sleep_first(1), sleep_second(1), sleep_first(0), sleep_second(0), times = 100)
```

    ## Unit: nanoseconds
    ##             expr      min       lq        mean     median       uq
    ##   sleep_first(1) 10050575 10491052 11331793.64 11289640.0 12139226
    ##  sleep_second(1)      309     1676     8646.22     7468.5     9717
    ##   sleep_first(0) 10061303 10690055 11506264.50 11464036.0 12452736
    ##  sleep_second(0) 10068596 10651320 11521164.44 11533203.5 12290622
    ##       max neval cld
    ##  12710034   100   b
    ##     85780   100  a 
    ##  14822220   100   b
    ##  15501758   100   b

## Use `importFrom`, not `::`

Yes, `::` is a function, so calling `pkg::function` is slower than
attaching the package and then use the function. That’s why when
creating a package, it’s better to use `@importFrom`. Do this instead of
just listing the package as dependency, and then using `::` inside your
functions.

We see this even with base:

``` r
a <- NULL
b <- NA
microbenchmark(is.null(a), 
               base::is.null(a), 
               is.na(b), 
               base::is.na(b),
               times = 10000)
```

    ## Unit: nanoseconds
    ##              expr  min     lq      mean median   uq     max neval cld
    ##        is.null(a)   80  144.0  250.1765  204.0  229  102375 10000 a  
    ##  base::is.null(a) 3670 6337.5 8280.9690 7444.0 8126  974538 10000  b 
    ##          is.na(b)  108  186.0  285.7768  262.0  298   52941 10000 a  
    ##    base::is.na(b) 3775 6469.0 9332.7668 7566.5 8274 3621082 10000   c

As a general rule of thumb, you should aim at **making as less function
calls as possible**: calling one function takes time, so if can be
avoided, avoid it.

Here, for example, there’s a way to avoid calling `::`, so use it :)

## Does `return()` make the funcion slower?

I’ve heard several times that `return()` slows your code a little bit
(that makes sens, return is a function call).

``` r
with_return <- function(x){
  return(x*1e3)
}

without_return <- function(x){
  x*1e3
}

all.equal(with_return(3), without_return(3))
```

    ## [1] TRUE

``` r
microbenchmark(with_return(3),
               without_return(3),
               times = 10000)
```

    ## Unit: nanoseconds
    ##               expr min  lq     mean median  uq     max neval cld
    ##     with_return(3) 227 248 521.5837    256 372 1713180 10000   a
    ##  without_return(3) 228 247 521.8669    256 375 1677252 10000   a

Surprisingly, `return()` doesn’t slow your code. So use it\!

## Brackets make the code (a little bit) slower

But they make it way clearer. So **keep it unless you want to win a
bunch of nanoseconds** :)

``` r
microbenchmark(if(TRUE)"yay",
               if(TRUE) {"yay"},
               if(FALSE) "yay" else "nay", 
               if(FALSE) {"yay"} else {"nay"}, 
               times = 10000)
```

    ## Unit: nanoseconds
    ##                                         expr min lq     mean median  uq
    ##                              if (TRUE) "yay"  38 50  55.7466     53  59
    ##                      if (TRUE) {     "yay" }  75 88  98.6950     93  97
    ##                  if (FALSE) "yay" else "nay"  39 54  59.8155     56  61
    ##  if (FALSE) {     "yay" } else {     "nay" }  77 91 101.4289     96 101
    ##    max neval cld
    ##   9717 10000  a 
    ##  10006 10000   b
    ##  12510 10000  a 
    ##   8601 10000   b

## Assign as less as possible

Yep, because assigning is a function.

``` r
with_assign <- function(a){
  b <- a*10e3
  c <- sqrt(b)
  d <- log(c)
  d
}
without_assign <- function(a){
  log(sqrt(a*10e3))
}

microbenchmark(with_assign(3),
               without_assign(3),
               times = 1000)
```

    ## Unit: nanoseconds
    ##               expr min  lq     mean median    uq     max neval cld
    ##     with_assign(3) 439 467 2733.461    488 535.5 2186584  1000   a
    ##  without_assign(3) 276 297 1726.264    306 330.5 1376750  1000   a

## What about the pipe ?

Does the pipe makes things slower?

``` r
library(magrittr)
with_pipe <- function(a){
  10e3 %>% "*"(a) %>% sqrt() %>% log()
}

all.equal(with_pipe(3), without_assign(3))
```

    ## [1] TRUE

``` r
microbenchmark(with_pipe(3),
               without_assign(3),
               times = 1000)
```

    ## Unit: nanoseconds
    ##               expr   min    lq      mean   median     uq     max neval cld
    ##       with_pipe(3) 94948 99167 126867.31 103021.5 121308 2566817  1000   b
    ##  without_assign(3)   278   318    594.12    514.5    622    9650  1000  a

You know, because `%>%` is a function.

## Conclusion

**These tests are just random tests I run**, and I can’t say they cover
all the technics you can use to speed up your code: rhese are just some
questions I can accross and wanted to share.

At the end of the day, there are also methods (like the bracket one)
that can help you save some nanoseconds. So don’t be afraid of not using
them, and stay focus on what’s more important: **write code that is easy
to understand. Because a piece of code that is easy to understand is a
piece of code that is easy to maintain\!** And never forget:

> It’s easy to get caught up in trying to remove all bottlenecks.
> Don’t\! Your time is valuable and is better spent analysing your
> data, not eliminating possible inefficiencies in your code. Be
> pragmatic: don’t spend hours of your time to save seconds of computer
> time. [Advanced R - Optimising
> code](http://adv-r.had.co.nz/Performance.html)

If you want to read more about code optimisation for speed, Colin
Gillespie and Robin Lovelace wrote a nice book about being more efficien
with R, with a chapter focused on performance: [Efficient
optimisation](https://csgillespie.github.io/efficientR/performance.html).
See also [Advanced R - Performant code](http://adv-r.had.co.nz/).
