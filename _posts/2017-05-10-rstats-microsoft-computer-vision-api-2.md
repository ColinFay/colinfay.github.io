---
title: "#RStats et Microsoft Computer Vision"

post_date: 2017-05-10 14:00:58
post_excerpt: ""
layout: single
permalink: /rstats-microsoft-computer-vision-api-2/
published: true
categories : r-blog-fr
tags: [r, justforfun]
image: /wp-content/uploads/2017/05/vote-fr.jpg
---

## Exploration des photos de profils des twittos #RStats avec l'API Microsoft Computer Vision.

#----#

Ce billet de blog s'inspire du travail de Maelle Salmon avec <a href="http://www.masalmon.eu/2017/03/19/facesofr/" target="_blank" rel="noopener noreferrer">Faces of #RStats twitter</a> et d'un article sur Data Bzh utilisant l'API Microsoft Computer Vision pour examiner d'anciennes <a href="http://data-bzh.fr/photographies-fonds-de-la-guerre-14-18-en-bretagne/" target="_blank" rel="noopener noreferrer">photos de Bretagne</a> .
### Microsoft Computer Vision
Cette <a href="https://www.microsoft.com/cognitive-services/en-us/computer-vision-api" target="_blank" rel="noopener noreferrer">API</a> est utilisée pour décrire et étiqueter automatiquement une image. Voici comment vous pouvez l'utiliser avec R, avec un jeu de données regroupant des images de profils Twitter.
### Les visages #RStats — Étiquetage automatique
Dans cet article, vous trouverez un tuto sur comment obtenir des photos de profil de Twitter et les étiqueter automatiquement avec Microsoft Computer Vision.
#### Collecter les données
```r 
library(tidyverse)
library(rtweet)
library(httr)
library(jsonlite)
token <- create_token( app = "XX", consumer_key = "XXX", consumer_secret = "XX
users <- search_users(q= '#rstats',
                      n = 1000,
                      parse = TRUE) %>%
  unique()
```
_Note: J'ai ici anonymisé mes API keys._
Maintenant, utilisons la colonne `profile_image_url` pour obtenir l'url des photos de profil.

D'abord, cette variable a besoin d'être nettoyée : les URL contiennent un paramètre _normal_, créant des images 48x48. L'API Microsoft a besoin d'une résolution minimum de 50x50, nous devons donc nous débarrasser de ce paramètre.

```r 
users$profile_image_url <- gsub("_normal", "", users$profile_image_url)
```
#### Interroger l'API  Microsoft
D'abord, inscrivez-vous sur <a href="https://www.microsoft.com/cognitive-services/en-us/computer-vision-api" target="_blank" rel="noopener noreferrer">Microsoft API service</a>, et lancez un essai gratuit. Ce compte gratuit est limité: vous ne pouvez faire que 5 000 appels par mois et 20 par minute. Mais c'est bien assez pour notre cas (478 images à regarder).
```r 
users_api <- lapply(users[,25],function(i, key = "") {
  request_body <- data.frame(url = i)
  request_body_json <- gsub("\\[|\\]", "", toJSON(request_body, auto_unbox = "TRUE"))
  result <- POST("https://api.projectoxford.ai/vision/v1.0/analyze?visualFeatures=Tags,Description,Faces,Categories",
                 body = request_body_json,
                 add_headers(.headers = c("Content-Type"="application/json","Ocp-Apim-Subscription-Key"="XXX")))
  Output <- content(result)
  if(length(Output$description$tags) != 0){
    cap <- Output$description$captions
  } else {
    cap <- NA
  }
  if(length(Output$description$tags) !=0){
    tag <-list(Output$description$tags)
  }
  d <- tibble(cap, tag)
  Sys.sleep(time = 3)
  return(d)
})%>%
  do.call(rbind,.)
```
_Remarque: J'ai (à nouveau) caché ma clé API._
_Ce code peut prendre un certain temps à exécuter, car il contient un appel à la fonction Sys.sleep._ Pour en savoir plus, <a href="http://colinfay.me/rstats-api-calls-sys-sleep/" target="_blank" rel="noopener noreferrer">lire ce billet</a>.

#### Créer des tibbles
Maintenant, j'ai un tibble avec une colonne contenant les listes de légendes et de score de confiance, et une colonne avec les listes des balises associées à chaque image.
```r 
users_cap <- lapply(users_api$cap, unlist) %>%
  do.call(rbind,.) %>%
  as.data.frame() 
users_cap$confidence <- as.character(users_cap$confidence) %>%
  as.numeric()
users_tags <- unlist(users_api$tag) %>%
  data.frame(tag = .)
```
### Visualisation
Chaque légende est donnée avec un score de confiance.
```r 
ggplot(users_cap, aes(as.numeric(confidence))) +
  geom_histogram(fill = "#b78d6a", bins = 50) + 
  xlab("Confidence") + 
  ylab("") + 
  labs(title = "Faces of #RStats - Captions confidence", 
       caption="http://colinfay.me") + 
  theme_light()
```
<a href="/assets/img/blog/rstats-caption-confidence.png"><img class="size-full wp-image-1583" src="/assets/img/blog/rstats-caption-confidence.png" alt="" width="1000" height="500" /></a> Cliquez pour zoomer

Il semble que les scores de confiance pour les légendes ne soient pas très forts. 

Regardons les légendes et les balises les plus fréquentes.
```r 
users %>%
  group_by(text)%>%
  summarize(somme = sum(n())) %>%
  arrange(desc(somme))%>%
  na.omit() %>%
  .[1:25,] %>%
  ggplot(aes(reorder(text, somme), somme)) +
  geom_bar(stat = "identity",fill = "#b78d6a") +
  coord_flip() +
  xlab("") + 
  ylab("") + 
  labs(title = "Faces of #RStats - Captions", 
       caption="http://colinfay.me") +   
  theme_light()
```
<a href="/assets/img/blog/rstats-captions-users.png"><img class="size-full wp-image-1580" src="/assets/img/blog/rstats-captions-users.png" alt="" width="800" height="400" /></a> Cliquez pour zoomer

Eh bien ... Je ne suis pas sûr qu'il y ait tant de passionnés de surf et de skate dans notre liste, mais soit...
```r 
users_tags %>%
  group_by(tag)%>%
  summarize(somme = sum(n())) %>%
  arrange(desc(somme))%>%
  .[1:25,] %>%
  ggplot(aes(reorder(tag, somme), somme)) +
  geom_bar(stat = "identity",fill = "#b78d6a") +
  coord_flip() +
  xlab("") + 
  ylab("") + 
  labs(title = "Faces of #RStats - Tags", 
       caption="http://colinfay.me") +   
  theme_light()


```
<a href="/assets/img/blog/rstats-tags.png"><img class="aligncenter size-full wp-image-1584" src="/assets/img/blog/rstats-tags.png" alt="" width="1000" height="500" /></a>

## Quelques vérifications
Jetons un coup d’œil à l'image avec le score de confiance le plus élevé, avec la légende que l'API lui a donnée.

<a href="/assets/img/blog/9mJTF0PO.jpeg"><img class="size-full wp-image-1459" src="/assets/img/blog/9mJTF0PO.jpeg" alt="" width="300" height="300" /></a> 

A man wearing a suit and tie — 0.92 confidence.

Il n'a pas de cravate, mais l'API a bien saisi le reste.

Et maintenant, juste pour le plaisir, la légende avec le score de confiance le plus bas :

<a href="/assets/img/blog/czR2-o0M.jpg"><img class="size-full wp-image-1460" src="/assets/img/blog/czR2-o0M.jpg" alt="" width="300" height="300" /></a> 

A close up of two giraffes near a tree - 0.02 confidence

Bien vu ;)

Pour une vérification plus plus systémique, regardons un collage d'images, réalisé à partir des légendes les plus fréquentes.
<p style="text-align: right;">_Remarque: afin de se concentrer sur les détails des images et de se débarrasser du genre des légendes, j'ai remplacé "man / woman / men / womens" par "persoe / persons" dans l'ensemble de données, avant de créer ces collages. _</p>


<a href="/assets/img/blog/caption_man_skatepark.jpg"><img class="size-large wp-image-1533" src="/assets/img/blog/caption_man_skatepark-1024x1024.jpg" alt="" width="840" height="840" /></a> 

A person on a surf board in a skate park

&nbsp;

<a href="/assets/img/blog/smiling_camera.jpg"><img class="size-large wp-image-1556" src="/assets/img/blog/smiling_camera-1024x514.jpg" alt="" width="840" height="422" /></a> 

A person is smiling at the camera - Confidence mean : 0.54

&nbsp;

<a href="/assets/img/blog/caption_girafe.jpg"><img class="size-large wp-image-1535" src="/assets/img/blog/caption_girafe-1024x514.jpg" alt="" width="840" height="422" /></a> 

A close up of two giraffes near a tree — Confidence mean : 0.0037

&nbsp;

<a href="/assets/img/blog/mosaic_glasses.jpg"><img class="size-large wp-image-1557" src="/assets/img/blog/mosaic_glasses-1024x514.jpg" alt="" width="840" height="422" /></a> A person wearing glasses looking at the camera

Les premier et troisième collages sont clairement erronés sur les légendes. Mais, nous pouvons voir que le score de confiance y est très bas. Le deuxième et le quatrième, cependant, semblent être plus précis. Peut-être que nous devons essayer à nouveau avec d'autres images, juste pour être sûr ... Mais ça sera pour une autre fois 😉



