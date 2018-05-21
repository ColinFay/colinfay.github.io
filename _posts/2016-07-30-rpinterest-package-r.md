---
ID: 1262
title: 'rpinterest : acess the Pinterest API with R'

post_date: 2016-07-31 21:00:00
post_excerpt: ""
layout: single
permalink: /rpinterest-package-r/
published: true
categories : r-blog-en
tags: [r, package, api]
---
## Access the Pinterest API with R with rpinterest. <!--more-->
This package requests information from the Pinterest API.

rpinterest is now on <a href="https://cran.r-project.org/web/packages/rpinterest/index.html">CRAN</a>
## Access the API
In order to get information from the API, you first need to get an access token from the <a href="https://developers.pinterest.com/tools/access_token/">Pinterest token generator</a>.
## Install rpinterest
Install this package directly in R :

``` r
devtools::install_github("ColinFay/rpinterest")
```

## How rpinterest works
The version 0.1.0 works with seven functions. Which are :
<ul>
 	<li>`BoardPinsByID` Get information about all the pins on a pinterest board using the board ID.</li>
 	<li>`BoardPinsByName` Get information about all the pins on a pinterest board using the board name.</li>
 	<li>`BoardSpecByID` Get information about a pinterest board using the board ID.</li>
 	<li>`BoardSpecByName` Get information about a pinterest board using the board name.</li>
 	<li>`PinSpecByID` Get information about a pinterest pin using the pin ID.</li>
 	<li>`UserSpecByID` Get information about a pinterest user using the user ID.</li>
 	<li>`UserSpecNyName` Get information about a pinterest user using the user name.</li>
</ul>

### Contact

Questions and feedbacks <a href="mailto:contact@colinfay.me">welcome</a> !
