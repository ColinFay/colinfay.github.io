---
ID: 906
title: "#RStats — Text mining avec R et gutenbergr"

post_date: 2016-05-24 18:00:32
post_excerpt: ""
layout: single
permalink: /rstats-text-mining-r-gutenbergr/
published: true
categories : r-blog-fr
tags: [r, textmining]
---
## Technique de data-mining et Graal des temps modernes, la fouille de texte permet de faire émerger des informations depuis un large corpus. Comment le réaliser avec R ?
<!--more-->

### Le text-mining, qu’est-ce que c’est
Au croisement de __la linguistique, de l’informatique et des statistiques__, le text-mining est utilisé pour analyser un corpus de manière automatique. L’objectif (au-delà de faire le malin devant vos collègues) : __faire émerger des patterns, des tendances et des singularités__ depuis une quantité importante de textes. Par exemple, le text-mining vous permettra de tirer des informations de la description Twitter de vos 1500 followers, ou encore de 5000 statuts Facebook… _Pretty cool, right?_

La première étape du text-mining, et peut-être la plus simple à saisir : __l'analyse de fréquence__. Comme son nom l’indique, cette technique calcule la récurrence des mots dans un corpus — en d’autres termes, leur fréquence d’apparition. En pratique, cela vous permet de __comparer deux corpus__ afin d’en tirer des conclusions… Un exemple ? Imaginez que vous analysiez les 2500 derniers commentaires sous la page Facebook de votre marque/ville/star préférée, et que vous découvriez que parmi les mots les plus fréquents se trouvent “merci”, “magnifique”, “super”. Si vous prenez deux marques/villes/stars concurrentes, vous tombez sur “bif-bof” et “moyen” sur l’une, “dégueu”, “beurk” et “catastrophique” sur l’autre… On peut en déduire quelque chose, n’est-il pas ?


### gutenbergr
Pour cette démonstration, j’ai choisi de m’intéresser au célèbre chef-d’oeuvre de Lewis Caroll, _Alice’s Adventures in Wonderland_. Pourquoi ce texte ? En effet, j’aurais pu sélectionner les 1500 derniers Tweets contenant le hashtag Rennes… mais :
<ul>
 	<li>D’autres l’ont fait avant nous</li>
 	<li>Un peu de vraie littérature, ça fait parfois du bien, non ? (Twittos, rassurez-vous : je vous aime)</li>
</ul>
Bref, retour à nos moutons. Déposé sur le CRAN le 16 mai 2016, <a href="https://cran.r-project.org/web/packages/gutenbergr/index.html">gutenbergr</a> permet de télécharger des ouvrages du domaine public sur le Projet Gutenberg, une bibliothèque de livres électroniques libres de droits.
```r 
library(gutenbergr)
```
```r 
aliceref <- gutenberg_works(title == "Alice's Adventures in Wonderland")
```
Cette première fonction vous retourne un objet contenant les informations sur une oeuvre déposée sur le projet Gutenberg, avec les données suivantes :
```r 
## [1] "gutenberg_id"        "title"               "author"             
## [4] "gutenberg_author_id" "language"            "gutenberg_bookshelf"
## [7] "rights"              "has_text"
```
La première colonne, contenant le 11, vous renvoie la référence de l’ouvrage sur le catalogue du projet : une information qui vous sera indispensable à la requête suivante :
```r 
library(magrittr)
alice <- gutenberg_download(aliceref$gutenberg_id) %>% gutenberg_strip()
```
Ici, `gutenberg_download` prend comme argument l’ID de l’ouvrage que vous souhaitez télécharger, vous renvoyant un data.frame avec le texte complet. La commande suivante `gutenberg_strip` retire les informations en haut et en bas de chaque éléments du projet : les métadonnées de l’ouvrage, que nous n'utiliserons pas pour l'analyse de fréquence.

### Text-mining de Alice’s Adventures in Wonderland

```r 
library(tidytext)
```
Bon, passons maintenant aux choses sérieuses. Pour réaliser un text-mining, vous aurez besoin du package `tidytext`, intitulé ainsi pour son usage au text mining via la philosphie "tidy data"(pas bête, non ?).

```r 
tidytext <- data_frame(line = 1:nrow(alice), text = alice$text) %>%
 unnest_tokens(word, text) %>%
 anti_join(stop_words) %>%
 count(word, sort = TRUE)
barplot(height=head(tidytext,10)$n, names.arg=head(tidytext,10)$word, xlab="Mots", ylab="Fréquence", col="#973232", main="Alice in Wonderland")

```
Alors… _Roulement de tambour_…

<a href="/assets/img/blog/alice-in-wonderland.png"><img class="aligncenter size-full wp-image-1663" src="/assets/img/blog/alice-in-wonderland.png" alt="" width="1200" height="600" /></a>

Pour aller plus loin :

<a href="http://data-bzh.fr/text-mining-r-part-2/">Racinisation et lemmatisation avec R</a>

<a href="http://data-bzh.fr/text-mining-r-part-3/">Créer un nuage de mots avec R</a>
### En lire plus :
<a href="https://www.amazon.fr/gp/product/1491981652/ref=as_li_tl?ie=UTF8&amp;camp=1642&amp;creative=6746&amp;creativeASIN=1491981652&amp;linkCode=as2&amp;tag=dabz-21" rel="nofollow">Text Mining With R: A Tidy Approach</a><img style="border: none !important; margin: 0px !important;" src="http://ir-fr.amazon-adsystem.com/e/ir?t=dabz-21&amp;l=as2&amp;o=8&amp;a=1491981652" alt="" width="1" height="1" border="0" />
<a href="https://www.amazon.fr/gp/product/148336934X/ref=as_li_tl?ie=UTF8&amp;camp=1642&amp;creative=6746&amp;creativeASIN=148336934X&amp;linkCode=as2&amp;tag=dabz-21" rel="nofollow">Text Mining: A Guidebook for the Social Sciences</a><img style="border: none !important; margin: 0px !important;" src="http://ir-fr.amazon-adsystem.com/e/ir?t=dabz-21&amp;l=as2&amp;o=8&amp;a=148336934X" alt="" width="1" height="1" border="0" />
<a href="https://www.amazon.fr/gp/product/1461432227/ref=as_li_tl?ie=UTF8&amp;camp=1642&amp;creative=6746&amp;creativeASIN=1461432227&amp;linkCode=as2&amp;tag=dabz-21" rel="nofollow">Mining Text Data</a><img style="border: none !important; margin: 0px !important;" src="http://ir-fr.amazon-adsystem.com/e/ir?t=dabz-21&amp;l=as2&amp;o=8&amp;a=1461432227" alt="" width="1" height="1" border="0" />
<a href="https://www.amazon.fr/gp/product/3330006455/ref=as_li_tl?ie=UTF8&amp;camp=1642&amp;creative=6746&amp;creativeASIN=3330006455&amp;linkCode=as2&amp;tag=dabz-21" rel="nofollow">Text Mining</a><img style="border: none !important; margin: 0px !important;" src="http://ir-fr.amazon-adsystem.com/e/ir?t=dabz-21&amp;l=as2&amp;o=8&amp;a=3330006455" alt="" width="1" height="1" border="0" />
<a href="https://www.amazon.fr/gp/product/178355181X/ref=as_li_tl?ie=UTF8&amp;camp=1642&amp;creative=6746&amp;creativeASIN=178355181X&amp;linkCode=as2&amp;tag=dabz-21" rel="nofollow">Mastering Text Mining with R</a><img style="border: none !important; margin: 0px !important;" src="http://ir-fr.amazon-adsystem.com/e/ir?t=dabz-21&amp;l=as2&amp;o=8&amp;a=178355181X" alt="" width="1" height="1" border="0" />
<a href="https://www.amazon.fr/gp/product/1119282012/ref=as_li_tl?ie=UTF8&amp;camp=1642&amp;creative=6746&amp;creativeASIN=1119282012&amp;linkCode=as2&amp;tag=dabz-21" rel="nofollow">Text Mining in Practice With R</a><img style="border: none !important; margin: 0px !important;" src="http://ir-fr.amazon-adsystem.com/e/ir?t=dabz-21&amp;l=as2&amp;o=8&amp;a=1119282012" alt="" width="1" height="1" border="0" />
<a href="https://www.amazon.fr/gp/product/B00RZK7UCE/ref=as_li_tl?ie=UTF8&amp;camp=1642&amp;creative=6746&amp;creativeASIN=B00RZK7UCE&amp;linkCode=as2&amp;tag=dabz-21" rel="nofollow">Text Mining: From Ontology Learning to Automated Text Processing Applications</a><img style="border: none !important; margin: 0px !important;" src="http://ir-fr.amazon-adsystem.com/e/ir?t=dabz-21&amp;l=as2&amp;o=8&amp;a=B00RZK7UCE" alt="" width="1" height="1" border="0" />
<a href="https://www.amazon.fr/gp/product/B008KZULQ0/ref=as_li_tl?ie=UTF8&amp;camp=1642&amp;creative=6746&amp;creativeASIN=B008KZULQ0&amp;linkCode=as2&amp;tag=dabz-21" rel="nofollow">Text Mining: Classification, Clustering, and Applications</a><img style="border: none !important; margin: 0px !important;" src="http://ir-fr.amazon-adsystem.com/e/ir?t=dabz-21&amp;l=as2&amp;o=8&amp;a=B008KZULQ0" alt="" width="1" height="1" border="0" />
<a href="https://www.amazon.fr/gp/product/1627058982/ref=as_li_tl?ie=UTF8&amp;camp=1642&amp;creative=6746&amp;creativeASIN=1627058982&amp;linkCode=as2&amp;tag=dabz-21" rel="nofollow">Phrase Mining from Massive Text and Its Applications</a><img style="border: none !important; margin: 0px !important;" src="http://ir-fr.amazon-adsystem.com/e/ir?t=dabz-21&amp;l=as2&amp;o=8&amp;a=1627058982" alt="" width="1" height="1" border="0" />
<a href="https://www.amazon.fr/gp/product/B005UQLIA0/ref=as_li_tl?ie=UTF8&amp;camp=1642&amp;creative=6746&amp;creativeASIN=B005UQLIA0&amp;linkCode=as2&amp;tag=dabz-21" rel="nofollow">Text Mining: Applications and Theory</a><img style="border: none !important; margin: 0px !important;" src="http://ir-fr.amazon-adsystem.com/e/ir?t=dabz-21&amp;l=as2&amp;o=8&amp;a=B005UQLIA0" alt="" width="1" height="1" border="0" />



