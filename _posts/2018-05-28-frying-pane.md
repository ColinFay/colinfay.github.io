---
title: "Serve your dataset in RStudio Connection Pane with {fryingpane}"
post_date: 2018-05-28
layout: single
permalink: /frying-pane/
categories: r-blog-en
output: jekyllthat::jekylldown
excerpt_separator: <!--more-->
---

Serve the dataset from a package in RStudio Connection Pane.

<!--more-->

## About

{fryingpane} is ~~a nice R dad joke~~ a package that has only two
functions:

  - `cook`: serve the dataset from a package in your RStudio Connection
    Pane:

![](https://raw.githubusercontent.com/ColinFay/fryingpane/master/readme_fig/fryingpane.gif)

  - `serve`: create a function in your package that will serve the
    datasets from the package inside the Connection Pane, with this kind
    of code:

<!-- end list -->

``` r
#' Launch Connection Pane
#' @export
#' @importFrom fryingpane serve
#' @example 

open_connection <- fryingpane::serve("mypkg")
```

You can install it with:

``` r
# install.packages("remotes")
remotes::install_github("ColinFay/fryingpane")
```

## Why this package ?

This package, depsite is (obvious) usefullness, was a neat opportunity
for me to learn how to deal with RStudio Connection Pane - an adventure
I’ll be sharing on [rtask](http://rtask.thinkr.fr/) in a near future. I
have to say this RStudio feature seems promising, even if a little bit
complex to handle in the first place.

Meanwhile if you have any idea for improving the package (I could for
example put some buttons on top of the Connection Panel), feel free to
open an issue on the [GitHub
repo](https://github.com/ColinFay/fryingpane).
