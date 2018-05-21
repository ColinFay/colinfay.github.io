---
ID: 1001
title: "Créer une carte avec R — rgeoapi et ggplot2"

post_date: 2016-07-28 13:52:20
post_excerpt: ""
layout: single
permalink: /carte-r-rgeoapi-ggplot2/
published: true
categories : r-blog-fr
tags: [r, tidyverse]
---
## Pensé pour simplifier les travaux de cartographie, rgeoapi est un package qui interroge la base de données géographique française. Résultat : des visualisations de cartes, _easy peasy_. Si si.
<!--more-->
### rgeoquoi ?
Disponible sur <a href="https://github.com/ColinFay">Github</a>, `rgeoapi` permet d’effectuer des requêtes sur la base de données cartographique française. Pour quoi faire dites-vous ? Ce package vous permet, entre autres, d’obtenir les coordonnées d’une ville à partir de son nom, de son code INSEE ou encore de son code postal. _How cool is that?_

Pour installer rgeoapi :
```r 
devtools::install_github("ColinFay/rgeoapi")
```

### Récupérer les coordonnées des villes
Imaginons donc que vous possédiez un jeu de données avec pour unique référent géographique les noms des villes à représenter. Dans l'idées, nous aurions :
```r 
villes <- data.frame(nom = c("Rennes", "Lorient", "Brest", "Vannes"), variable1 = c("a", "b", "c", "b"), variable2 = c("Un", "Deux", "Un", "Deux"))

```
<table style="width: 44%;"><colgroup> <col width="11%" /> <col width="16%" /> <col width="16%" /> </colgroup>
<thead>
<tr class="header">
<th align="center">nom</th>
<th align="center">variable1</th>
<th align="center">variable2</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="center">Rennes</td>
<td align="center">a</td>
<td align="center">Un</td>
</tr>
<tr class="even">
<td align="center">Lorient</td>
<td align="center">b</td>
<td align="center">Deux</td>
</tr>
<tr class="odd">
<td align="center">Brest</td>
<td align="center">c</td>
<td align="center">Un</td>
</tr>
<tr class="even">
<td align="center">Vannes</td>
<td align="center">b</td>
<td align="center">Deux</td>
</tr>
</tbody>
</table>
Pour représenter ces données sur une carte de manière précise, vous aurez besoin des coordonnées des villes. C’est à ce moment qu’entre en scène `rgeoapi`!

Nous lançons donc une requête sur les noms contenus dans notre data.frame.
```r 
library(rgeoapi)
```
```r 
library(plyr)
geo <- ldply(villes$nom, ComByName)

```
<table><caption> </caption><colgroup> <col width="28%" /> <col width="15%" /> <col width="23%" /> <col width="16%" /> <col width="16%" /> </colgroup>
<thead>
<tr class="header">
<th align="center">name</th>
<th align="center">codeInsee</th>
<th align="center">codeDepartement</th>
<th align="center">codeRegion</th>
<th align="center">population</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="center">Rennes</td>
<td align="center">35238</td>
<td align="center">35</td>
<td align="center">53</td>
<td align="center">211373</td>
</tr>
<tr class="even">
<td align="center">Rennes-le-Château</td>
<td align="center">11309</td>
<td align="center">11</td>
<td align="center">76</td>
<td align="center">58</td>
</tr>
<tr class="odd">
<td align="center">Rennes-les-Bains</td>
<td align="center">11310</td>
<td align="center">11</td>
<td align="center">76</td>
<td align="center">258</td>
</tr>
<tr class="even">
<td align="center">Rennes-sur-Loue</td>
<td align="center">25488</td>
<td align="center">25</td>
<td align="center">27</td>
<td align="center">88</td>
</tr>
<tr class="odd">
<td align="center">Rennes-en-Grenouilles</td>
<td align="center">53189</td>
<td align="center">53</td>
<td align="center">52</td>
<td align="center">117</td>
</tr>
<tr class="even">
<td align="center">Lorient</td>
<td align="center">56121</td>
<td align="center">56</td>
<td align="center">53</td>
<td align="center">57961</td>
</tr>
<tr class="odd">
<td align="center">Brest</td>
<td align="center">29019</td>
<td align="center">29</td>
<td align="center">53</td>
<td align="center">139386</td>
</tr>
<tr class="even">
<td align="center">Brestot</td>
<td align="center">27110</td>
<td align="center">27</td>
<td align="center">28</td>
<td align="center">518</td>
</tr>
<tr class="odd">
<td align="center">Esboz-Brest</td>
<td align="center">70216</td>
<td align="center">70</td>
<td align="center">27</td>
<td align="center">485</td>
</tr>
<tr class="even">
<td align="center">Vannes</td>
<td align="center">56260</td>
<td align="center">56</td>
<td align="center">53</td>
<td align="center">53032</td>
</tr>
<tr class="odd">
<td align="center">Vannes-le-Châtel</td>
<td align="center">54548</td>
<td align="center">54</td>
<td align="center">44</td>
<td align="center">579</td>
</tr>
<tr class="even">
<td align="center">Pouy-sur-Vannes</td>
<td align="center">10301</td>
<td align="center">10</td>
<td align="center">44</td>
<td align="center">145</td>
</tr>
<tr class="odd">
<td align="center">Saulxures-lès-Vannes</td>
<td align="center">54496</td>
<td align="center">54</td>
<td align="center">44</td>
<td align="center">363</td>
</tr>
<tr class="even">
<td align="center">Vannes-sur-Cosson</td>
<td align="center">45331</td>
<td align="center">45</td>
<td align="center">24</td>
<td align="center">589</td>
</tr>
</tbody>
</table>
<table style="width: 46%;"><colgroup> <col width="13%" /> <col width="8%" /> <col width="11%" /> <col width="12%" /> </colgroup>
<thead>
<tr class="header">
<th align="center">surface</th>
<th align="center">lat</th>
<th align="center">long</th>
<th align="center">X_score</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="center">5035</td>
<td align="center">48.11</td>
<td align="center">-1.679</td>
<td align="center">1</td>
</tr>
<tr class="even">
<td align="center">1497</td>
<td align="center">42.91</td>
<td align="center">2.277</td>
<td align="center">0.7636</td>
</tr>
<tr class="odd">
<td align="center">1975</td>
<td align="center">42.92</td>
<td align="center">2.341</td>
<td align="center">0.7533</td>
</tr>
<tr class="even">
<td align="center">547</td>
<td align="center">47.01</td>
<td align="center">5.855</td>
<td align="center">0.6743</td>
</tr>
<tr class="odd">
<td align="center">801</td>
<td align="center">48.49</td>
<td align="center">-0.5083</td>
<td align="center">0.6239</td>
</tr>
<tr class="even">
<td align="center">1533</td>
<td align="center">47.75</td>
<td align="center">-3.378</td>
<td align="center">1</td>
</tr>
<tr class="odd">
<td align="center">4948</td>
<td align="center">48.4</td>
<td align="center">-4.502</td>
<td align="center">0.7183</td>
</tr>
<tr class="even">
<td align="center">884</td>
<td align="center">49.34</td>
<td align="center">0.6783</td>
<td align="center">0.6958</td>
</tr>
<tr class="odd">
<td align="center">977</td>
<td align="center">47.8</td>
<td align="center">6.441</td>
<td align="center">0.4919</td>
</tr>
<tr class="even">
<td align="center">3313</td>
<td align="center">47.65</td>
<td align="center">-2.749</td>
<td align="center">1</td>
</tr>
<tr class="odd">
<td align="center">1747</td>
<td align="center">48.57</td>
<td align="center">5.785</td>
<td align="center">0.7384</td>
</tr>
<tr class="even">
<td align="center">1579</td>
<td align="center">48.3</td>
<td align="center">3.597</td>
<td align="center">0.6873</td>
</tr>
<tr class="odd">
<td align="center">1826</td>
<td align="center">48.52</td>
<td align="center">5.804</td>
<td align="center">0.678</td>
</tr>
<tr class="even">
<td align="center">3558</td>
<td align="center">47.72</td>
<td align="center">2.202</td>
<td align="center">0.6653</td>
</tr>
</tbody>
</table>
À noter : à partir d'un nom, il est possible que le package vous retourne plusieurs résultats pour une même requête. Ce pour plusieurs raisons :
<ul>
 	<li>Plusieurs villes possèdent cette chaine de caractères dans leur nom</li>
 	<li>La commune en question couvre plusieurs codes postaux et le paramètre `postal` est `TRUE` (ce dernier est `FALSE` par défaut)</li>
 	<li>Votre requête est en _partial match_</li>
</ul>
Nous avons donc ici un tableau qui nous retourne toutes les coordonnées des villes qui nous intéressent, avec leur surface et leur population. Bien, ne reste plus qu’à effectuer une jointure des deux !
```r 
names(villes)[1] <- "name"
villes <- merge(villes, geo, by = "name", all.x = TRUE)
```
Passons maintenant aux choses sérieuses.
### Créer une carte avec ggmap et ggplot2
Le package `ggmap `a été spécialement pensé pour produire des fonds de cartes à insérer en background de vos `ggplot2`, autrement dit des cartes qui seront utilisées comme couche de `mapping` de votre visualisation. La fonction rapide de carte est `qmap` (une terminologie qui devrait sonner familière aux adeptes des `qplot` de `ggplot`) – le premier argument faisant référence à la requête (ville / département / région…) et le second au niveau de zoom de Google map.
```r 
library(ggmap)
```
```r 
map <- qmap('Bretagne', zoom = 8)
```
Une fois l’objet `map` créé, il ne vous reste qu’à l’utiliser comme première layer de votre fonction `ggplot`, en utilisant les fonctions `geom` habituelles :
```r 
map + geom_point(data = villes, aes(x = long, y = lat, color= variable2, size = surface))
```
<a href="/assets/img/blog/carte-avec-rgeoapi.jpeg"><img class="aligncenter size-full wp-image-1017" src="/assets/img/blog/carte-avec-rgeoapi.jpeg" alt="Réaliser une carte avec R, ggplot2 et rgeoapi" width="600" height="400" /></a>

Et voilà, c’est presque trop simple ! N’hésitez pas à me faire vos retours sur rgeoapi directement sur GitHub, ou à m’envoyer vos questions sur le package via <a href="mailto:contact@colinfay.me">mail</a>.
