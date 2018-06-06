---
ID: 1164
title: 'All I want for Christmas is a #Dataviz'

post_date: 2016-12-23 17:44:55
post_excerpt: ""
layout: single
permalink: /all-i-want-for-christmas-is-a-dataviz/
published: true
categories : r-blog-fr
tags: [r, justforfun]
---
## Avant de vous lancer dans le marathon de repas de Noël, deux visualisations de données tirées de l'API lastfm... pour la requête "Christmas" !
#----#

### Allô LastFM
La première étape ? Créer un compte sur l’API LastFM, afin d’obtenir une clé d'accès. Une fois cette suite de caractères en poche, direction les requêtes avec R.

Commençons par charger les packages que nous allons utiliser :

```r 
library(tidyverse)
library(scales)
library(data.table)
library(magrittr)
```
Les trois paramètres de départ sont :

```r 
#Le terme de recherche
query <- "christmas"
#La clé API (cachée ici)
apikey <- "XXX"
#L'index des pages de l'API, qui s'incrémentera au fur et à mesure des requêtes
x <- 0
```
Ensuite, nous entrons l’url de recherche. La recherche est limitée à 1000 résultats, et est divisible en pages avec l’argument `&page=`.

```r 
url <- paste0("http://ws.audioscrobbler.com/2.0/?method=track.search&amp;track=", 
              query,"&amp;api_key=", apikey, "&amp;format=json","&amp;page=", x)
```

Création d’une liste pour recevoir les résultats des requêtes, et requête sur la première page (index = 0).

```r 
dl <- list()
dl2 <- httr::GET(url)$content %>%
  rawToChar() %>% 
  rjson::fromJSON()
dl2 <- dl2$results$trackmatches$track
dl <- c(dl,dl2)
```
Bouclons sur toutes les pages qui renvoient des résultats :
```r 
repeat{
  x <- x+1
  url <- paste0("http://ws.audioscrobbler.com/2.0/?method=track.search&amp;track=", 
                query,"&amp;api_key=", apikey, "&amp;format=json","&amp;limit=", 1000, "&amp;page=", x)
  dl2 <- httr::GET(url)$content %>%
    rawToChar() %>% 
    rjson::fromJSON()
  dl2 <- dl2$results$trackmatches$track
  dl <- c(dl, dl2)
  if(length(dl2) == 0){
    break
  }
}
```
Et enfin, créons le data.frame de résultats :
```r 
songs <- lapply(dl, function(x){
  data.frame(name = x$name, 
             artist = x$artist, 
             listeners = as.numeric(x$listeners))
}) %>%
  do.call(rbind, .) %>% 
  arrange(listeners)
```


### And now, let’s see!
Commençons par afficher les 5 titres écoutés par le plus d’utilisateurs :

```r 
songs <- as.data.table(songs)
songs <- songs[, .(listeners = mean(listeners)), by = .(name,artist)]
songs[1:15,] %>%
ggplot(aes(x = reorder(name, listeners), y = listeners)) +
  geom_bar(stat = "identity", fill = "#d42426") +
  geom_text(data = songs[1:15,], aes(label= artist), size = 5, nudge_y = -sd(songs$listeners[1:15])/2) + 
  coord_flip() + 
  xlab("") +
  ylab("Volumes d'utilisateurs ayant écouté ce titre") +
  scale_y_continuous(labels = comma) +
  labs(title = "15 titres les plus populaires sur lastfm pour la requête Christmas", 
       subtitle = " ",
       caption = "http://colinfay.me") + 
  theme(axis.text=element_text(size=10),
        axis.title=element_text(size=15),
        title=element_text(size=18),
        plot.title=element_text(margin=margin(0,0,20,0), size=18),
        axis.title.x=element_text(margin=margin(20,0,0,0)),
        axis.title.y=element_text(margin=margin(0,20,0,0)),
        legend.text=element_text(size = 12),
        plot.margin=margin(20,20,20,20), 
        panel.background = element_rect(fill = "white"), 
        panel.grid.major = element_line(colour = "grey"))
```
<a href="/assets/img/blog/songs-last-fm-christmas.jpeg"><img class="aligncenter size-large wp-image-1186" src="/assets/img/blog/songs-last-fm-christmas-1024x512.jpeg" alt="songs-last-fm-christmas" width="809" height="405" /></a>(cliquez pour zoomer)

Quant aux artistes les plus présents :
```r 
songs$artist %>%
  table() %>%
  as.data.frame() %>%
  arrange(desc(Freq)) %>%
  head(15) %>%
ggplot(aes(x = reorder(., Freq), y = Freq)) +
  geom_bar(stat = "identity", fill = "#d42426") +
  coord_flip() + 
  xlab("") +
  ylab("Volume de titres de l'artiste") +
  scale_y_continuous(labels = comma) +
  labs(title = "15 artistes les plus présents sur lastfm pour la requête Christmas", 
       subtitle = " ",
       caption = "http://colinfay.me") + 
  theme(axis.text=element_text(size=10),
        axis.title=element_text(size=15),
        title=element_text(size=18),
        plot.title=element_text(margin=margin(0,0,20,0), size=18),
        axis.title.x=element_text(margin=margin(20,0,0,0)),
        axis.title.y=element_text(margin=margin(0,20,0,0)),
        legend.text=element_text(size = 12),
        plot.margin=margin(20,20,20,20), 
        panel.background = element_rect(fill = "white"), 
        panel.grid.major = element_line(colour = "grey"))
```
![](/assets/img/blog/artist-christmas-lastfm.jpeg)

Et sur ce… joyeux Noël !

<a title="" href="/assets/img/blog/b546c88a28a7c2423d2a32bc85d1f106.gif"><img class="aligncenter size-full wp-image-1182" title="" src="/assets/img/blog/b546c88a28a7c2423d2a32bc85d1f106.gif" alt="Nightmare before christmas" width="500" height="301" /></a>





