---
ID: 1603
title: "#RStats — API calls et Sys.sleep"

post_date: 2017-04-14
post_excerpt: ""
layout: single
permalink: /rstats-api-calls-sys-sleep/
published: true
tags: [r, api]
categories : r-blog-fr
---
## J'ai récemment reçu un mail concernant mon post sur l'API Discogs, disant que le code ne fonctionnait pas.
## Il s'est avéré que cela était dû aux nouvelles limitations de l'API. Voici comment contourner ces limites avec R.

### Requête Discogs
Voici <a href="http://colinfay.me/data-vinyles-bibliotheque-discogs-r/" target="_blank">le billet de blog décrivant comment faire des requêtes sur l'API Discogs avec R</a>.

Il y a quelques semaines, j'ai reçu un mail indiquant que la deuxième partie du code ne fonctionnait pas, renvoyant seulement des _NA_. Il s'est avéré que cela était dû aux changements récents de l'API Discogs, limitant le nombre de requêtes possibles dans une période spécifique.

Récemment également, j'ai utilisé l'API _Computer Vision_ de Microsoft - une API limitant les requêtes à 20 par minute -  pour un blogpost sur <a href="http://data-bzh.fr">Data Bzh</a>.

Alors, comment automatiser le requêtage sur une API quand elle limite le nombre de requêtes par minutes / heure / jour (par exemple, si vous avez 282 images à analyser) ?
### Première méthode : for loop et Sys.sleep()

_Remarque : ce blogpost ne contient aucune requête API, j'utiliserais Sys.time () pour montrer comment fonctionne Sys.sleep ()._

Si vous souhaitez limiter à 20 appels par minute, vous devrez utiliser _Sys.sleep ()_. Cette fonction ne prend qu'un argument, _time_, qui est le nombre de secondes que vous souhaitez arrêter R avant de reprendre.

Par exemple, dans un for loop, vous pouvez faire une pause de 10 secondes à chaque itération de la boucle :
```r 
for(i in 1:3){
  print(Sys.time())
  Sys.sleep(time = 10)
}
```
```r 
## [1] "2017-03-26 11:13:58 CET"
## [1] "2017-03-26 11:14:08 CET"
## [1] "2017-03-26 11:14:18 CET"
```
### Avec un lapply
Si vous avez accès au cœur de la fonction que vous souhaitez utiliser (par exemple la fonction requêtant l'API), vous pouvez utiliser un _lapply_, et insérer _Sys.sleep ()_ dans cette fonction.

C'est cette méthode que vous devrez utiliser dans le code pour Discogs, et que j'ai utiliser dans le billet sur Computer Vision.
```r 
library(tidyverse)
```
```r 
lapply(1:3, function(x) {
  print(x)
  print(Sys.time()) 
  Sys.sleep(3)
}) %>% do.call(rbind, .) 
```
```r 
## [1] 1
## [1] "2017-03-26 11:20:22 CET"
## [1] 2
## [1] "2017-03-26 11:20:25 CET"
## [1] 3
## [1] "2017-03-26 11:20:28 CET"
```

_Hope this can help!_






