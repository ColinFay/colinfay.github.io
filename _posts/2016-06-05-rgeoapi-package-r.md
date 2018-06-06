---
ID: 1264
title: "rgeoapi — A package to access the GéoAPI"

post_date: 2016-06-05 19:11:29
post_excerpt: ""
layout: single
permalink: /rgeoapi-package-r/
published: true
categories : r-blog-en
tags: [r, package, api]
---
## rgeoapi connects R to the GéoAPI, in order to get information about french geography.
#----#
rgeoapi is now on <a href="https://cran.r-project.org/web/packages/rgeoapi/">CRAN</a>
# <a id="user-content-rgeoapi" class="anchor" href="https://github.com/ColinFay/rgeoapi#rgeoapi"></a>rgeoapi
This package requests informations from the French GeoAPI inside R — <a href="https://api.gouv.fr/explorer/geoapi/">https://api.gouv.fr/explorer/geoapi/</a>
## <a id="user-content-geoapi" class="anchor" href="https://github.com/ColinFay/rgeoapi#geoapi"></a>GeoAPI
Developped by Etalab, with La Poste, l’INSEE and OpenStreetMap, the <a href="https://api.gouv.fr/explorer/geoapi/">GeoAPI</a> API is a JSON interface designed to make requests on the French geographic database.

rgeoapi was developped to facilitate your geographic projects by giving you access to these informations straight inside R. With `rgeoapi`, you can get any coordinate, size and population of a French city, to be used in your maps.

For an optimal compatibility, all the names (especially outputs) used in this package are the same as the ones used in the GeoAPI. Please note that this package works only with French cities.

## Install this package directly in R :

```r
devtools::install_github"ColinFay/rgeoapi")
```

## How rgeoapi works
The version 1.0.0 works with eleven functions. Which are :
<ul>
 	<li>`ComByCode` Get City by INSEE Code</li>
 	<li>`ComByCoord` Get City by Coordinates</li>
 	<li>`ComByDep` Get Cities by Department</li>
 	<li>`ComByName` Get City by Name</li>
 	<li>`ComByPostal` Get City by Postal Code</li>
 	<li>`ComByReg` Get Cities by Region</li>
 	<li>`DepByCode` Get Department by INSEE Code</li>
 	<li>`DepByName` Get Department by Name</li>
 	<li>`DepByReg` Get Departments by Region</li>
 	<li>`RegByCode` Get Region by INSEE Code</li>
 	<li>`RegByName` Get Region by Name</li>
</ul>
## How the functions are constructed
In the <a href="https://api.gouv.fr/explorer/geoapi/">GeoAPI</a>, you can request for "Commune", "Département" or "Région". All the functions are constructed using this terminology : AByB.
<ul>
 	<li>A being the output you need -- Com for "Commune" (refering to French cities), Dep for Département (for Department) and Reg for Région.</li>
 	<li>B being the request parameter -- Code for INSEE Code, Coord for Coordinates (WGS-84), Dep for Department, Name for name, Postal for Postal Code and Reg for Region.</li>
</ul>

### French Tutorial &amp; contact
A French tutorial on <a href="http://colinfay.me/rgeoapi-v1/">my website</a>. Questions and feedbacks <a href="mailto:contact@colinfay.me">welcome</a> !




