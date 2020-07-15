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
database dropped inside a postgre, to be used for teaching.

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
  score                                 title             name       date
1     3                    more like funchuck       Shep Hills 1993-04-01
2     5                             Inspiring Tremayne Effertz 1975-02-07
3     5 The best soundtrack ever to anything.     Trae Schultz 1974-03-12
4     4                      Chrono Cross OST  Johnny Prohaska 1987-02-03
5     5                   Too good to be true   Arnett Denesik 1994-12-31
```

``` r
dbClearResult(res)

res <- dbSendQuery(con, "SELECT title, name, date FROM clients WHERE date = '1998-05-12' LIMIT 10")
dbFetch(res)
```

``` 
                                                       title
1                                    Shower Filter Cartridge
2                           Clay's Voice Should Be the Music
3                                        ""Laugh Out Loud""?
4                              delightful literary biography
5                                         Bill Cosby Himself
6  Spock's Beard - June, Came Upon Us Much Too Soon.........
7                          Good, but I Was Hoping for Better
8                                             Golf bag watch
9                                        History by Accident
10                                     Complete release info
                   name       date
1      Shaquana Lockman 1998-05-12
2     Erlene McCullough 1998-05-12
3            Tomie Mohr 1998-05-12
4         Trayvon Ratke 1998-05-12
5       Enriqueta Walsh 1998-05-12
6  Nathalia Satterfield 1998-05-12
7          Alijah Mayer 1998-05-12
8       Raymon Bernhard 1998-05-12
9         Perley Ernser 1998-05-12
10     Jaron Jakubowski 1998-05-12
```

``` r
dbClearResult(res)

dbDisconnect(con)
```

And then stop the db.

``` bash
docker stop clientsdb 
```
