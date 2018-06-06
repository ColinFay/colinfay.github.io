---
layout: single
title: "Playing with #RStats and Microsoft Computer Vision API"
published: true

comments: false
date: 2017-04-02 21:40:58
tags: [r, justforfun]
permalink: /playing-with-rstats-and-microsoft-computer-vision-api/
image:
    feature: microsoft_api.jpg
categories : r-blog-en
---

## Playing around with the faces of #RStats and Microsoft Computer Vision API.


This blogpost is inspired by the work of Maelle Salmon with <a href="http://www.masalmon.eu/2017/03/19/facesofr/" target="_blank" rel="noopener noreferrer">Faces of #RStats twitter</a>, and an article on Data Bzh using Microsoft Computer Vision API to look into <a href="http://data-bzh.fr/photographies-fonds-de-la-guerre-14-18-en-bretagne/" target="_blank" rel="noopener noreferrer">old pictures of Brittany</a>.
### Microsoft Computer Vision
This <a href="https://www.microsoft.com/cognitive-services/en-us/computer-vision-api" target="_blank" rel="noopener noreferrer">API</a> is used to retrieved description and tags for an image. Here is how you can use it with R to get information about Twitter profil pictures.
### The Faces of #RStats — Automatic labelling
In this blogpost, I'll describe how to get profil pics from Twitter, and label them with Microsoft Computer Vision.
#### Collecting data
```r 
library(tidyverse)
library(rtweet)
library(httr)
library(jsonlite)
token <- create_token( app = "XX", consumer_key = "XXX", consumer_secret = "XX")
users <- search_users(q= '#rstats',
                      n = 1000,
                      parse = TRUE) %>%
  unique()
```
_Note: I've (obviously) hidden the access token to my twitter app._
From there, I’ll use the `profile_image_url` column to get the url to the profile picture.

First, this variable will need some cleansing : the urls contain a __normal_ parameter, creating 48x48 images. The Microsoft API needs at least a 50x50 resolution, so we need to get rid of this.
```r 
users$profile_image_url <- gsub("_normal", "", users$profile_image_url)
```
#### Calling on Microsoft API
First, get a subscritpion on the <a href="https://www.microsoft.com/cognitive-services/en-us/computer-vision-api" target="_blank" rel="noopener noreferrer">Microsoft API service</a>, and start a free trial. This free account is limited: you can only make 5,000 calls per month, and 20 per minute. But that’s far from enough for our case (478 images to look at).
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
_Note : I've (again) hidden my API key._
__Also, this code may take a while to execute, as I've inserted a Sys.sleep function._ To know more about the reason why, <a href="http://colinfay.me/rstats-api-calls-and-sys-sleep/" target="_blank" rel="noopener noreferrer">read this blogpost</a>. _

#### Creating tibbles
Now I have a tibble with a column containing lists of captions &amp; confidence, and a column with lists of the tags associated with each picture. Let’s split this.
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
Each caption is given with a confidence score.
```r 
ggplot(users_cap, aes(as.numeric(confidence))) +
  geom_histogram(fill = "#b78d6a", bins = 50) + 
  xlab("Confidence") + 
  ylab("") + 
  labs(title = "Faces of #RStats - Captions confidence", 
       caption="http://colinfay.me") + 
  theme_light()
```
<a href="/assets/img/blog/rstats-caption-confidence.png"><img class="size-full wp-image-1583" src="/assets/img/blog/rstats-caption-confidence.png" alt="" width="1000" height="500" /></a> 

Click to zoom

It seems that the confidence scores for the captions are not very strong. Well, let’s nevertheless have a look at the most frequent captions and tags.
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
<a href="/assets/img/blog/rstats-captions-users.png"><img class="size-full wp-image-1580" src="/assets/img/blog/rstats-captions-users.png" alt="" width="800" height="400" /></a> 

Click to zoom

Well... I'm not sure there are so many surf and skate aficionados in the R world, but ok...
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
## <a href="/assets/img/blog/rstats-tags.png"><img class="aligncenter size-full wp-image-1584" src="/assets/img/blog/rstats-tags.png" alt="" width="1000" height="500" /></a>
## Some checking
Let’s have a look at the picture with the highest confidence score, with the caption the API gave it.

<a href="/assets/img/blog/9mJTF0PO.jpeg"><img class="size-full wp-image-1459" src="/assets/img/blog/9mJTF0PO.jpeg" alt="" width="300" height="300" /></a> 

A man wearing a suit and tie — 0.92 confidence.

He hasn't got a tie, but the APi got it quite right for the rest.

And now, just for fun, let's have a look at the caption with the lowest confidence score :

<a href="/assets/img/blog/czR2-o0M.jpg"><img class="size-full wp-image-1460" src="/assets/img/blog/czR2-o0M.jpg" alt="" width="300" height="300" /></a> 

A close up of two giraffes near a tree - 0.02 confidence

This one is fun, so, no hard feeling Microsoft API!

On a more systemic note, let's have a look at a collage of pictures, for the most frequent captions.
_Note: in order to focus on the details of the pictures, and get rid of the genderization of the captions, I've replaced "man/woman/men/womens" by "person/persons" in the dataset, before making these collages. _

<a href="/assets/img/blog/caption_man_skatepark.jpg"><img class="size-large wp-image-1533" src="/assets/img/blog/caption_man_skatepark-1024x1024.jpg" alt="" width="840" height="840" /></a> 

A person on a surf board in a skate park

<a href="/assets/img/blog/smiling_camera.jpg"><img class="size-large wp-image-1556" src="/assets/img/blog/smiling_camera-1024x514.jpg" alt="" width="840" height="422" /></a> 

A person is smiling at the camera - Confidence mean : 0.54

<a href="/assets/img/blog/caption_girafe.jpg"><img class="size-large wp-image-1535" src="/assets/img/blog/caption_girafe-1024x514.jpg" alt="" width="840" height="422" /></a> 

A close up of two giraffes near a tree — Confidence mean : 0.0037

<a href="/assets/img/blog/mosaic_glasses.jpg"><img class="size-large wp-image-1557" src="/assets/img/blog/mosaic_glasses-1024x514.jpg" alt="" width="840" height="422" /></a> 

A person wearing glasses looking at the camera

The first and third collages are clearly wrong about the captions. Yet we can see the confidence score is wery low. The second and fourth, though, seems to be more acurate. Maybe we need to try again with other pictures, just to be sure... Maybe another time ;)






