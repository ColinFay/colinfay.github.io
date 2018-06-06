---
ID: 1705
title: "Cartographier le second tour français avec R"

post_date: 2017-05-08 18:08:31
post_excerpt: ""
layout: single
permalink: /cartographier-second-tour-francais-r/
published: true
tags: [r]
categories: r-blog-fr
---
## Aperçu du vote au second tour en France, via des cartes réalisées avec R. 
### Le jeu de données
Le dataset utilisé ici est disponible sur data.gouv : <a href="https://www.data.gouv.fr/fr/datasets/election-presidentielle-des-23-avril-et-7-mai-2017-resultats-du-2eme-tour-2/" target="_blank" rel="noopener noreferrer">Election présidentielle des 23 avril et 7 mai 2017 - Résultats du 2ème tour</a>. Pour une meilleur compatibilité, j'ai manuellement converti le fichier xls en csv.
### Charger les librairies et les données
Chargeons ce jeu de données, ainsi que la carte de France disponible nativement avec ggplot2.
```r
library(tidyverse)
library(stringr)
library(stringi)
result <- read_csv2("Presidentielle_2017_Resultats_Communes_Tour_2.csv")
map <- map_data("france")
```

### Nettoyage des données

Avant de représenter les résultats sur une carte, nous devons commencer par transformer et nettoyer le data.frame.

```r
result <- result %>%
  group_by(`Libellé du département`) %>%
  summarise(tot_vot = sum(Exprimés), 
            tot_blanc = sum(Blancs),
            pourcentage_blanc = tot_blanc / sum(Votants) * 100, 
            tot_abs = sum(Abstentions), 
            pourcentage_abs = tot_abs / sum(Inscrits)* 100,
            tot_macron = sum(Voix), 
            tot_lepen = sum(Voix_1), 
            pourcentage_macron = tot_macron / tot_vot * 100, 
            pourcentage_lepen = tot_lepen / tot_vot * 100) 
names(result)[1] <- "region"
result$region <- stri_trans_general(result$region, "Latin-ASCII") %>%
  str_replace_all("Cote-d'Or", "Cote-Dor") %>%
  str_replace_all("Cotes-d'Armor", "Cotes-Darmor") %>%
  str_replace_all("Corse-du-Sud", "Corse du Sud") %>%
  str_replace_all("Val-d'Oise", "Val-Doise") %>%
  str_replace_all("Corse-du-Sud", "Corse du Sud")
```
Nous voici avec un tableau contenant les chiffres clés par département, obtenu à partir des résultats par commune. Le nom de la première colonne a été modifié, afin de coller à l'étiquetage `region` du tableau `map`. La suite de remplacement de caractères est due à la notation anglaise de `map` — une transformation a été indispensable pour effectuer la jointure correctement.

```r
result_map <- left_join(x = map[,-6], y = result)
```
### Visualisation

Projetons maintenant nos différentes variables avec R. Ici, c'est l'argument `scale_fill_` qui va gérer l'échelle de couleurs utilisée pour chaque carte.

```r
map_theme <- theme(title=element_text(),
                   plot.title=element_text(margin=margin(20,20,20,20), size=18, hjust = 0.5),
                   axis.text.x=element_blank(),
                   axis.text.y=element_blank(),
                   axis.ticks=element_blank(),
                   axis.title.x=element_blank(),
                   axis.title.y=element_blank(),
                   panel.grid.major= element_blank(), 
                   panel.background= element_blank()) 

ggplot(result_map, aes(long,lat, group = group, fill = pourcentage_blanc)) +
  geom_polygon() +
  coord_map() +
  scale_fill_gradient(name = "Pourcentage votes blancs") +
  labs(x = "", 
       y = "", 
       title = "Pourcentage de votes blancs au second tour des présidentielles 2017", 
       subtitle = "Données via data.gouv",
       caption = "http://colinfay.me") +
  map_theme
```
<a href="/assets/img/blog/second-tour-blanc.png"><img class="aligncenter size-full wp-image-1716" src="/assets/img/blog/second-tour-blanc.png" alt="blancs du second tour" width="1000" height="500" /></a>

```r
ggplot(result_map, aes(long,lat, group = group, fill = pourcentage_abs)) +
  geom_polygon() +
  coord_map() +
  scale_fill_gradient2(name = "Pourcentage Abstention") +
  labs(x = "", 
       y = "", 
       title = "Pourcentage d'abstention au second tour des présidentielles 2017", 
       subtitle = "Données via data.gouv",
       caption = "http://colinfay.me") +
  map_theme 
```
<a href="/assets/img/blog/abstention-second-tour.png"><img class="aligncenter size-full wp-image-1717" src="/assets/img/blog/abstention-second-tour.png" alt="abstention second tour" width="1000" height="500" /></a>

```r
ggplot(result_map, aes(long,lat, group = group, fill = pourcentage_macron)) +
  geom_polygon() +
  coord_map() +
  scale_fill_gradientn(colours = c("yellow","red"), name = "Pourcentage E. Macron") +
  labs(x = "", 
       y = "", 
       title = "Résultats de E. Macron au second tour des présidentielles 2017", 
       subtitle = "Données via data.gouv",
       caption = "http://colinfay.me") +
  map_theme 
```
<a href="/assets/img/blog/macron.png"><img class="aligncenter size-full wp-image-1725" src="/assets/img/blog/macron.png" alt="macron second tour" width="1000" height="500" /></a>

```r
ggplot(result_map, aes(long,lat, group = group, fill = pourcentage_lepen)) +
  geom_polygon() +
  coord_map() +
  scale_fill_gradientn(colours = terrain.colors(10), name = "Pourcentage M. Le Pen") +
  labs(x = "", 
       y = "", 
       title = "Résultats de M. Le Pen au second tour des présidentielles 2017", 
       subtitle = "Données via data.gouv",
       caption = "http://colinfay.me") +
  map_theme
```
<a href="/assets/img/blog/mlp.png"><img class="aligncenter size-full wp-image-1724" src="/assets/img/blog/mlp.png" alt="Votes pour Marine Le Pen au second tour" width="1000" height="500" /></a>






