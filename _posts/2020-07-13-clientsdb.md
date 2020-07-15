---
title: "clientsdb - A docker image with clients comments"
post_date: 2020-07-13
layout: single
permalink: /clients-db/
categories: r-blog-en
output: jekyllthat::jekylldown
excerpt_separator: <!--more-->
---

Have you ever been looking for a ready to use database while doing
training? Search no more, this docker is an image with a client review
database dropped inside a postgres, to be used for teaching.

## About the dataset

The titles and comments are extracted from this [Google
Drive](https://drive.google.com/drive/folders/0Bz8a_Dbh9Qhbfll6bVpmNUtUcFdjYmF2SEpmZUZUcVNiMUw1TWN6RDV3a0JHT3kxLVhVR2M)
link that contains “amazon\_review\_full\_csv.tar.gz”, which I
discovered on the [Amazon review
database](https://www.kaggle.com/bittlingmayer/amazonreviews) Kaggle
page. Then the two columns date and name being randomly generated in R.

Here is the coded used to generate the full table:

``` r
library(data.table)
dataset <- fread("data/train.csv", header = FALSE, sep = ",")
names(dataset) <- c("score", "title", "comment")

nms <- paste(
  sample(charlatan:::person_en_us$first_names, nrow(dataset), TRUE), 
  sample(charlatan:::person_en_us$last_names, nrow(dataset), TRUE)
)

date <- sample(0:as.numeric(as.POSIXct("2010-01-01")), nrow(dataset), TRUE)
date <- as.POSIXct(date, origin = "1970-01-01")

dataset[
  , `:=`(
    score = NULL,
    name = nms, 
    date = date
  )
]   

data.table::fwrite(dataset, "datasetwithusers.csv")
```

## Launch and use

The main purpose of this image is to provide a “real life” tool for
teaching databases use.

Info:

  - the `POSTGRES_DB` used is `clients`
  - the `POSTGRES_PASSWORD` is `verysecretwow`
  - the `POSTGRES_USER` is `superduperuser`

To launch the db, do:

``` bash
# Might take some time to warm up
docker run --rm -d -p 5432:5432 --name clientsdb colinfay/clientsdb:latest
```

Then, for example from R:

``` r
library(DBI)

con <- dbConnect(
  RPostgres::Postgres(),
  dbname = 'clients', 
  host = 'localhost',
  port = 5432, 
  user = 'superduperuser',
  password = 'verysecretwow'
)

dbListTables(con)
```

    [1] "clients"

``` r
res <- dbSendQuery(con, "SELECT score, title, name, date FROM clients LIMIT 5")
dbFetch(res)
```

``` 
  score                                                              title
1     4                                             bastante bueno...,,,OK
2     4                                                    underrated !!!!
3     5 HENRY MANCINI'S MUSICAL SCORING IS A HIT, ALONG WITH SOLID SCRIPTS
4     3                                                     Jury Still Out
5     1                                              Complete release info
                name       date
1        Yareli Koch 1992-01-21
2      Lyle Turcotte 1984-10-25
3 Luvenia Vandervort 1975-04-18
4       Diego Walter 2001-12-25
5   Jaron Jakubowski 1998-05-12
```

``` r
dbClearResult(res)

res <- dbSendQuery(con, "SELECT title, name, date FROM clients WHERE date = '1998-05-12' LIMIT 10")
dbFetch(res)
```

``` 
                                     title             name       date
1                    Complete release info Jaron Jakubowski 1998-05-12
2            Fun but extremely poor made!!      Velvet Hand 1998-05-12
3       Boring if work in the industry....      Sol Gerlach 1998-05-12
4                       our state magazine  Zebulon Reichel 1998-05-12
5                              Loin cloth?    Linwood Beier 1998-05-12
6                                 The Best     Ceola Heaney 1998-05-12
7                         My favorite book      Eura Jacobs 1998-05-12
8           ok story from the hartnell era    Raphael Moore 1998-05-12
9              Couldn't put the book down!    Capitola Huel 1998-05-12
10 car essential oil diffuser - great gift        Elwyn Von 1998-05-12
```

``` r
dbClearResult(res)

dbDisconnect(con)
```

And then stop the db.

``` bash
docker stop clientsdb 
```
