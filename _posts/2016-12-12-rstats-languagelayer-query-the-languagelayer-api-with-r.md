---
ID: 1254
title: "#RStats — languagelayeR : query the languagelayer API with R"

post_date: 2016-12-12
post_excerpt: ""
layout: single
permalink: /rstats-languagelayer-query-the-languagelayer-api-with-r/
published: true
categories : r-blog-en
tags: [r, package, api]
---
## Improve your text analysis with this R package designed to access the languagelayer API.
LanguagelayeR is now on <a href="https://cran.r-project.org/package=languagelayeR">CRAN</a>

### languagelayerR
This package is designed to detect a language from a character string in R by acessing the languagelayer API — <a href="https://languagelayer.com/">https://languagelayer.com/</a>

## Language layer API
This package offers a language detection tool by connecting to the languagelayer API, a JSON interface designed to extract language information from a character string.

## Install languagelayerR
Install this package directly in R : `devtools::install_github"ColinFay/languagelayerR")`
## How languagelayeR works
The version 1.0.0 works with three functions. Which are :

```r 
getLanguage
``` 

Get language information from a character string

```r 
getSupportedLanguage
``` 

Get all current accessible languages on the languagelayer API

```r 
setApiKey
``` 
Set your API key to access the languagelayer API

## First of all
Before any request on the languagelayer, you need to set your API key for your current session. Use the function `setApiKey(apikey = "yourapikey")`.

You can get your api key on your languagelayer <a href="https://languagelayer.com/dashboard">dashboard</a>.

## Examples
### getLanguage
Detect a language from a character string.

```r
getLanguage("I really really love R and that's a good thing, right?")
```

List all the languages available on the languagelayer API.
```r
getSupportedLanguage()
```
### Contact

Questions and feedbacks <a href="mailto:contact@colinfay.me">welcome</a> !
&nbsp;






