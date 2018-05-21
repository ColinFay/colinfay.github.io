---
title: "A Crazy Little Thing Called {purrr} - Part 6 : doing statistics"

post_date: 2017-12-28
layout: single
permalink: /purrr-statistics/
tags:
  - purrr
categories: r-blog-en
output: jekyllthat::jekylldown
excerpt_separator: <!--more-->
---

This is gonna be the last time I make this Queen reference in 2017.

<!--more-->

I’ve been sharing some “stats with {purrr}” recipes on my [Twitter
account](https://twitter.com/_ColinFay) lately. Twitter being what it is
(a source of infinite temporary content), here’s the post gathering some
statistics tricks you can do with {purrr}.

## Looking for normality

If your data are in a data.frame, you can simply map a shapiro.test on
all the columns, keeping the one with a `p.value` \> to 0.05 (remember,
the shapiro tests for non-normality) :

``` r
library(purrr)
map(airquality, shapiro.test) %>% keep(~ .x$p.value > 0.05)
```

    ## $Wind
    ## 
    ##  Shapiro-Wilk normality test
    ## 
    ## data:  .x[[i]]
    ## W = 0.98575, p-value = 0.1178

Of course, you can do the same on a non-tabular list:

``` r
# rdunif is from purrr
l <- list(a = rnorm(10), b = rdunif(1000, 10))
map(l, shapiro.test) %>% keep(~ .x$p.value > 0.05)
```

    ## $a
    ## 
    ##  Shapiro-Wilk normality test
    ## 
    ## data:  .x[[i]]
    ## W = 0.91275, p-value = 0.3004

Also, `map_if` allows you to map only on numeric variables in your
data.frame:

``` r
map_if(iris, is.numeric, shapiro.test)
```

    ## $Sepal.Length
    ## 
    ##  Shapiro-Wilk normality test
    ## 
    ## data:  .x[[i]]
    ## W = 0.97609, p-value = 0.01018
    ## 
    ## 
    ## $Sepal.Width
    ## 
    ##  Shapiro-Wilk normality test
    ## 
    ## data:  .x[[i]]
    ## W = 0.98492, p-value = 0.1012
    ## 
    ## 
    ## $Petal.Length
    ## 
    ##  Shapiro-Wilk normality test
    ## 
    ## data:  .x[[i]]
    ## W = 0.87627, p-value = 7.412e-10
    ## 
    ## 
    ## $Petal.Width
    ## 
    ##  Shapiro-Wilk normality test
    ## 
    ## data:  .x[[i]]
    ## W = 0.90183, p-value = 1.68e-08
    ## 
    ## 
    ## $Species
    ##   [1] setosa     setosa     setosa     setosa     setosa     setosa    
    ##   [7] setosa     setosa     setosa     setosa     setosa     setosa    
    ##  [13] setosa     setosa     setosa     setosa     setosa     setosa    
    ##  [19] setosa     setosa     setosa     setosa     setosa     setosa    
    ##  [25] setosa     setosa     setosa     setosa     setosa     setosa    
    ##  [31] setosa     setosa     setosa     setosa     setosa     setosa    
    ##  [37] setosa     setosa     setosa     setosa     setosa     setosa    
    ##  [43] setosa     setosa     setosa     setosa     setosa     setosa    
    ##  [49] setosa     setosa     versicolor versicolor versicolor versicolor
    ##  [55] versicolor versicolor versicolor versicolor versicolor versicolor
    ##  [61] versicolor versicolor versicolor versicolor versicolor versicolor
    ##  [67] versicolor versicolor versicolor versicolor versicolor versicolor
    ##  [73] versicolor versicolor versicolor versicolor versicolor versicolor
    ##  [79] versicolor versicolor versicolor versicolor versicolor versicolor
    ##  [85] versicolor versicolor versicolor versicolor versicolor versicolor
    ##  [91] versicolor versicolor versicolor versicolor versicolor versicolor
    ##  [97] versicolor versicolor versicolor versicolor virginica  virginica 
    ## [103] virginica  virginica  virginica  virginica  virginica  virginica 
    ## [109] virginica  virginica  virginica  virginica  virginica  virginica 
    ## [115] virginica  virginica  virginica  virginica  virginica  virginica 
    ## [121] virginica  virginica  virginica  virginica  virginica  virginica 
    ## [127] virginica  virginica  virginica  virginica  virginica  virginica 
    ## [133] virginica  virginica  virginica  virginica  virginica  virginica 
    ## [139] virginica  virginica  virginica  virginica  virginica  virginica 
    ## [145] virginica  virginica  virginica  virginica  virginica  virginica 
    ## Levels: setosa versicolor virginica

## Bulk cor.test

As said on Twitter, this might be
[p.hacking](https://twitter.com/HBossier/status/943480783288889344), but
here’s how you can do a `cor.test` for all columns in a data.frame, with
a little help from `tidystringdist` and `broom` :

``` r
library(tidystringdist) # Works since v0.1.2 
comb <- tidy_comb_all(names(airquality))
knitr::kable(comb)
```

| V1      | V2      |
| :------ | :------ |
| Ozone   | Solar.R |
| Ozone   | Wind    |
| Ozone   | Temp    |
| Ozone   | Month   |
| Ozone   | Day     |
| Solar.R | Wind    |
| Solar.R | Temp    |
| Solar.R | Month   |
| Solar.R | Day     |
| Wind    | Temp    |
| Wind    | Month   |
| Wind    | Day     |
| Temp    | Month   |
| Temp    | Day     |
| Month   | Day     |

``` r
bulk_cor <- pmap(comb, ~ cor.test(airquality[[.x]], airquality[[.y]])) %>% 
  map_df(broom::tidy) %>% 
  cbind(comb, .)

knitr::kable(bulk_cor, digits = 3)
```

| V1      | V2      | estimate | statistic | p.value | parameter | conf.low | conf.high | method                               | alternative |
| :------ | :------ | -------: | --------: | ------: | --------: | -------: | --------: | :----------------------------------- | :---------- |
| Ozone   | Solar.R |    0.348 |     3.880 |   0.000 |       109 |    0.173 |     0.502 | Pearson’s product-moment correlation | two.sided   |
| Ozone   | Wind    |  \-0.602 |   \-8.040 |   0.000 |       114 |  \-0.706 |   \-0.471 | Pearson’s product-moment correlation | two.sided   |
| Ozone   | Temp    |    0.698 |    10.418 |   0.000 |       114 |    0.591 |     0.781 | Pearson’s product-moment correlation | two.sided   |
| Ozone   | Month   |    0.165 |     1.781 |   0.078 |       114 |  \-0.018 |     0.337 | Pearson’s product-moment correlation | two.sided   |
| Ozone   | Day     |  \-0.013 |   \-0.141 |   0.888 |       114 |  \-0.195 |     0.169 | Pearson’s product-moment correlation | two.sided   |
| Solar.R | Wind    |  \-0.057 |   \-0.683 |   0.496 |       144 |  \-0.217 |     0.107 | Pearson’s product-moment correlation | two.sided   |
| Solar.R | Temp    |    0.276 |     3.444 |   0.001 |       144 |    0.119 |     0.419 | Pearson’s product-moment correlation | two.sided   |
| Solar.R | Month   |  \-0.075 |   \-0.906 |   0.366 |       144 |  \-0.235 |     0.088 | Pearson’s product-moment correlation | two.sided   |
| Solar.R | Day     |  \-0.150 |   \-1.824 |   0.070 |       144 |  \-0.305 |     0.012 | Pearson’s product-moment correlation | two.sided   |
| Wind    | Temp    |  \-0.458 |   \-6.331 |   0.000 |       151 |  \-0.575 |   \-0.323 | Pearson’s product-moment correlation | two.sided   |
| Wind    | Month   |  \-0.178 |   \-2.227 |   0.027 |       151 |  \-0.328 |   \-0.020 | Pearson’s product-moment correlation | two.sided   |
| Wind    | Day     |    0.027 |     0.334 |   0.739 |       151 |  \-0.132 |     0.185 | Pearson’s product-moment correlation | two.sided   |
| Temp    | Month   |    0.421 |     5.703 |   0.000 |       151 |    0.281 |     0.543 | Pearson’s product-moment correlation | two.sided   |
| Temp    | Day     |  \-0.131 |   \-1.619 |   0.108 |       151 |  \-0.283 |     0.029 | Pearson’s product-moment correlation | two.sided   |
| Month   | Day     |  \-0.008 |   \-0.098 |   0.922 |       151 |  \-0.166 |     0.151 | Pearson’s product-moment correlation | two.sided   |

## Some Machine Learning

### lm

Let’s build a linear model of all possible iris combinations:

``` r
res <- pmap(comb, ~ lm(airquality[[.x]] ~ airquality[[.y]]))
get_rsquared <- compose(as_mapper(~ .x$r.squared), summary)
map_dbl(res, get_rsquared)
```

    ##  [1] 1.213419e-01 3.618582e-01 4.877072e-01 2.706660e-02 1.749177e-04
    ##  [6] 3.225293e-03 7.608786e-02 5.670205e-03 2.258257e-02 2.097529e-01
    ## [11] 3.178824e-02 7.388015e-04 1.771966e-01 1.705458e-02 6.338966e-05

Any chance there’s a r.squared above 0.5 ?

``` r
map(res, get_rsquared) %>% some(~ .x > 0.5)
```

    ## [1] FALSE

### rpart

We’ll build 20 `rpart` to find the better model. Yes, this will be
better to do it with a random forest, but we’re here for the example :)

#### Training and validation

Let’s do the train / validation.

``` r
library(dplyr)
library(readr)
titanic <- read_csv("http://biostat.mc.vanderbilt.edu/wiki/pub/Main/DataSets/titanic3.csv")
train <- rerun(20, sample_frac(titanic, size = 0.8))
validation <- map(train, ~ anti_join(titanic, .x))
```

Check if the sizes of all validation datasets are the same:

``` r
map_int(validation, nrow) %>% every(~ .x == 262)
```

    ## [1] TRUE

### Create a model builder

We’ll create a simple model to predict survival based on sex.

``` r
library(rpart)
rpart_pimped <- partial(rpart, formula = survived ~ sex, method = "class")
res <- map(train, ~ rpart_pimped(data = .x))
```

### Make prediction

``` r
prediction <- map2(validation, res, ~ predict(.y, .x, type = "class"))
w_prediction <- map2(validation, prediction, ~ mutate(.x, prediction = .y))
```

### Confusion matrix

Now let’s map a conf matrix on all these results:

``` r
library(caret)
conf_mats <- map(w_prediction, ~ confusionMatrix(.x$prediction, .x$survived))
```

Is the “Sensivity” for all models above 0.8?

``` r
map_dbl(conf_mats, ~ .x$byClass["Sensitivity"]) %>% every(~ .x > 0.8)
```

    ## [1] TRUE

Is the “Specificity” for all models above 0.8?

``` r
map_dbl(conf_mats, ~ .x$byClass["Specificity"]) %>% every(~ .x > 0.8)
```

    ## [1] FALSE

### keep\_index

Let’s modify `keep` a little bit so we can extract the models we need:

``` r
# Here's the keep source code
keep
```

    ## function(.x, .p, ...) {
    ##   sel <- probe(.x, .p, ...)
    ##   .x[!is.na(sel) & sel]
    ## }
    ## <environment: namespace:purrr>

``` r
# Let's tweak it a little bit
keep_index <- function(.x, .p, ...) {
  sel <- purrr:::probe(.x, .p, ...)
  which(sel)
}
```

So, which are the models with a sensitivity superior to
0.85?

``` r
map_dbl(conf_mats, ~ .x$byClass["Sensitivity"]) %>% keep_index(~ .x > 0.85)
```

    ##  [1]  1  3  4  6 11 13 14 15 16 18 19

And the models with a specificity superior to
0.7?

``` r
map_dbl(conf_mats, ~ .x$byClass["Specificity"]) %>% keep_index(~ .x > 0.7)
```

    ## [1]  2  7 13 14 17

Which models are in
both?

``` r
sens <- map_dbl(conf_mats, ~ .x$byClass["Sensitivity"]) %>% keep_index(~ .x > 0.85)
spec <- map_dbl(conf_mats, ~ .x$byClass["Specificity"]) %>% keep_index(~ .x > 0.7)
keep(sens, map_lgl(sens, ~ .x %in% spec))
```

    ## [1] 13 14

So, I guess we’ll go for model(s) number 13, 14\!

![](https://media.giphy.com/media/ohdY5OaQmUmVW/giphy.gif)
