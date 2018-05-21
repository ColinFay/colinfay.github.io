---
ID: 1433
title: 'Une heatmap avec R et ggplot2'

post_date: 2017-03-19 20:28:24
post_excerpt: ""
layout: single
permalink: /heatmap-avec-r-et-ggplot2/
published: true
tags: [tidyverse]
categories : r-blog-fr
---
## Un court tutorial sur les heatmaps avec R, inspirés d'articles sur databzh.
<!--more-->

L'idée de cet article prend racine dans deux billets sur Data Bzh :
- <a href="http://data-bzh.fr/trafic-web-site-rennes-metropole-2016/">Trafic du site web de Rennes Metropole en 2016</a>
- <a href="http://data-bzh.fr/prenoms-bretagne-1900-aujourdhui/">Les prénoms en Bretagne, de 1900 à aujourd'hui</a>

Dans ce court post, retrouvez le déroulement de la création d'une heatmap d'un prénom par année et par département. Le jeu de données est disponible sur <a href="https://www.data.gouv.fr/fr/datasets/fichier-des-prenoms-edition-2016/">data.gouv</a>. Il a été téléchargé et unzippé en dehors de R.

## Loading

```r 
library(tidyverse)
## Loading tidyverse: ggplot2
## Loading tidyverse: tibble
## Loading tidyverse: tidyr
## Loading tidyverse: readr
## Loading tidyverse: purrr
## Loading tidyverse: dplyr

name <- read.table("/home/colin/Téléchargements/dpt2015.txt", stringsAsFactors = FALSE, sep = "\t", encoding = "latin1", header = TRUE, col.names = c("sexe","prenom","annee","dpt","nombre")) %>%
  na.omit()
name$annee <- as.Date(name$annee, "%Y")
```
Nous avons maintenant un jeu de données propre, avec les noms et les départements.

### Heatmap
Une heatmap se crée le geom `geom_tile` de `ggplot2`. Voici sa construction étape par étape.

```r 
choix <- "COLIN"
name %>%
  #Filtre par nom
  filter(prenom == choix) %>%
  
  #Groupe par année et département
  group_by(annee, dpt) %>%
  
  #Résumé de l'effectif par année et département
  summarise(somme = sum(nombre)) %>%
  
  #Suppression des NA
  na.omit() %>% 
  
  #Initialisation de ggplot
  ggplot(aes(annee, dpt, fill = somme)) +
  
  #THE MAN OF THE HOUR
  geom_tile() +
  
  #Échelle
  scale_x_date(limits =  c(lubridate::ymd("1900-01-01"), lubridate::ymd("2015-01-01"))) +
  
  #Et deux trois paillettes pour rendre le tout plus joli
  xlab("Année") +
  ylab("Département") +
  labs(title = paste0("Apparition du prénom ", tolower(choix)," par département, 1900-2015")) + 
  theme_minimal()
```

<a href="/assets/img/blog/names-colin.png"><img class="aligncenter size-full wp-image-1587" src="/assets/img/blog/names-colin.png" alt="Colin par département" width="1000" height="500" /></a>

Oui, c'est aussi simple que ça. Essayons avec un autre prénom.

(Bien sûr, vous pouvez choisir une autre échelle pour les couleurs.)
```r 
choix <- "ELISABETH"
name %>%
  filter(prenom == choix) %>%
  group_by(annee, dpt) %>%
  summarise(somme = sum(nombre)) %>%
  na.omit() %>% 
  ggplot(aes(annee, dpt, fill = somme)) +
  geom_tile() +
  scale_x_date(limits =  c(lubridate::ymd("1900-01-01"), lubridate::ymd("2015-01-01"))) +
  #Changer l'échelle de couleurs
  scale_fill_gradient(low = "#E18C8C", high = "#973232") +
  xlab("Année") +
  ylab("Département") +
  labs(title = paste0("Apparition du prénom ", tolower(choix)," par département, 1900-2015")) + 
  theme_minimal()

```
<a href="/assets/img/blog/prenom-elisabeth-rstats.png"><img class="aligncenter size-full wp-image-1589" src="/assets/img/blog/prenom-elisabeth-rstats.png" alt="Elisabeth prénom" width="1000" height="500" /></a>

Simple, n'est-ce pas !
