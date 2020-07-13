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

Info: - the `POSTGRES_DB` used is `clients` - the `POSTGRES_PASSWORD` is
`verysecretwow` - the `POSTGRES_USER` is `superduperuser`

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
  score                               title             name       date
1     5                      Fantastic Item   Karolyn Wunsch 2003-01-02
2     4            Easy to Use, Great Value  Wayland Langosh 2008-06-06
3     4                      It works well!  Fed Oberbrunner 1989-07-22
4     3                        Meets a need        Lora Yost 1976-04-13
5     4 Ion TTUSB Turntable with USB Record Valentina Harvey 1986-01-28
```

``` r
dbClearResult(res)

res <- dbSendQuery(con, "SELECT title, name, date FROM clients WHERE date = '1998-05-12' LIMIT 10")
dbFetch(res)
```

``` 
                                title             name       date
1                      underrated art  Burgess Kuhlman 1998-05-12
2                      Great product!   Madelyn Bailey 1998-05-12
3         Disappointing, not correct.      Scott Walsh 1998-05-12
4             The turtle says it all! Magdalen Strosin 1998-05-12
5            I took the TEAS and NLN.    Rosie Bradtke 1998-05-12
6                           Terrible.   Lita Marquardt 1998-05-12
7               Harlan County History   Clemon Effertz 1998-05-12
8  A flawed book, but a good subject.  Amey Rutherford 1998-05-12
9                   Worth every penny   Debrah Keebler 1998-05-12
10             A light enjoyable read Dwaine Schneider 1998-05-12
```

``` r
dbClearResult(res)

dbDisconnect(con)
```

And then stop the db.

``` bash
docker stop clientsdb 
```
