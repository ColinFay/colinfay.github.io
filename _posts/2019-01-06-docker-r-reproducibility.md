---
title: "An Introduction to Docker for R Users"
post_date: 2019-01-06
layout: single
permalink: /docker-r-reproducibility/
categories: r-blog-en
output: jekyllthat::jekylldown
excerpt_separator: <!--more-->
---

A quick introduction on using Docker for reproducibility in R.

<!--more-->

> Disclaimer: this blog post is an introduction to Docker for beginners,
> and will takes some shortcuts ;)

## What is Docker?

Docker is “a computer program that performs operating-system-level
virtualization, also known as ‘containerization’”
[Wikipedia](https://en.wikipedia.org/wiki/Docker_\(software\)). As any
first line of a Wikipedia article about tech, this sentence is obscure
to anyone not already familiar with the content of the article.

So, to put it more simply, **Docker is a program that allows to
manipulate (launch and stop) multiple operating systems (called
containers) on your machine (your machine will be called the host)**.
Just imagine having 10 RaspberryPi with different flavors of Linux, each
focused on doing one simple thing, that you can turn on and off whenever
you need to ; but all of this happens on your computer.

## Why Docker & R?

Docker is designed to enclose environments inside an image / a
container. What this allows, for example, is to have a Linux machine on
a Macbook, or a machine with R 3.3 when your main computer has R 3.5.
Also, this means that **you can use older versions of a package for a
specific task, while still keeping the package on your machine
up-to-date**.

This way, you can “solve” dependencies issues: if ever you are afraid
dependencies will break your analysis when packages are updated, build a
container that will **always** have the software versions you desire: be
it Linux, R, or any package.

## Docker images vs Docker containers

On your machine, you’re going to need two things: images, and
containers. **Images are the definition of the OS, while the containers
are the actual running instances of the images**. You’ll need to install
the image just once, while the containers are to be launched whenever
you need this instance. And of course, multiple containers of the same
images can be run at the same time.

To compare with R, this is the same principle as installing vs loading a
package: a package is to be downloaded once, while it has to be launched
every time you need it. And a package can be launched in several R
sessions at the same time easily.

So to continue with this metaphore: we’re **building** an image when
we’re `install.packages()`, and we **run** the image when we
`library()`.

## Dockerfile

A Docker image is built from a `Dockerfile`. This file is the
configuration file, and describes several things: from what previous
docker image you are building this one, how to configure the OS, and
what happens when you `run` the container. In a sense, it’s a little bit
like the `DESCRIPTION` + `NAMESPACE` files of an R package, which
describes which are the dependencies to your package, gives meta
information, and states which functions and data are to be available to
the users `library()`ing the package.

So, let’s build a **very basic** `Dockerfile` for R, focused on
reproducibility. The idea is this one: I have today an analysis that
works (for example contained in a `.R` file), and I want to be sure this
analysis will always work in the future, regardless of any update to the
packages used.

So first, create a folder for your analysis, and a Dockerfile:

    mkdir ~/mydocker
    cd ~/mydocker
    touch Dockerfile

And let’s say this is the content of the analysis we want to run, called
`myscript.R`, and located in the `~/mydocker` folder:

``` r
library(tidystringdist)
df <- tidy_comb_all(iris, Species)
p <- tidy_stringdist(df)
write.csv(p, "p.csv")
```

### `FROM`

Every `Dockerfile` starts with a `FROM`, which describes what image we
are building our image from. There are a lot of official images, and you
can also build from a local one.

This `FROM` is, in a way, describing the dependency of your image ; just
as in R, when building a package, you always rely on another package (be
it only the `{base}` package).

If you’re going for an R based image, Dirk Eddelbuettel & Carl Boettiger
are maintaining [rocker](https://hub.docker.com/u/rocker), a collection
of Docker images for R you can use. The basic image is `rocker/r-base`,
but what we want is our image to be reproducible: that is to say to
rerun the exact same way anytime we run it. For this, we’ll be using
`rocker/r-ver`, which are Docker images containing fixed version of R
(back to 3.1.0), and that you can run as if from a specific date (thanks
to [Dirk Eddelbuettel](http://dirk.eddelbuettel.com/) for pointing that
to me).

So what we’ll do is look up for the image corresponding to the R version
we want. You can get your current R Version with:

``` r
R.Version()$version.string
```

    ## [1] "R version 3.4.4 (2018-03-15)"

So, let’s start the `Dockerfile` with:

    FROM rocker/r-ver:3.4.4

### `RUN`

Once we’ve got that, we’ll add some `RUN` statements: these are commands
which mimic command line commands. we’ll create a directory to receive
our analysis.

    FROM rocker/r-ver:3.4.4
    
    RUN mkdir /home/analysis

### Install our package

The command to make R execute something, from the terminal, is `R -e "my
code"`. Let’s use it to install our script dependencies, but from a
specific date. We’ll mimic the way `rocker/r-ver` works when building
from a specific date: setting the `options("repos")` to this specific
date, using the MRAN image: in other word, using a repo url like
`https://mran.microsoft.com/snapshot/1979-01-01`.

    FROM rocker/r-ver:3.4.4
    
    RUN mkdir /home/analysis
    
    RUN R -e "options(repos = \
      list(CRAN = 'http://mran.revolutionanalytics.com/snapshot/2019-01-06/')); \
      install.packages('tidystringdist')"

### Aside : making it more programmable with `ARG`

In our last `Dockerfile`, the date can’t be modified at build time -
something we can change if we use an `ARG` variable, that will be set
when we’ll do `docker build`, with `--build-arg WHEN=`

``` 
FROM rocker/r-ver:3.4.4

ARG WHEN

RUN mkdir /home/analysis

RUN R -e "options(repos = \
  list(CRAN = 'http://mran.revolutionanalytics.com/snapshot/${WHEN}')); \
  install.packages('tidystringdist')"

```

Here, the `{tidystringdist}` that will be installed in the machine will
be the one from the date we will specify when building the container,
even if we build this image in one year, or two, or four.

### `COPY`

Now, I need to get the script for my analysis from my machine (host) to
the container. For that, we’ll need to use `COPY localfile
pathinthecontainer`. Note that here, the `myscript.R` has to be in the
same folder as the `Dockerfile` on your computer.

    FROM rocker/r-ver:3.4.4
    
    ARG WHEN
    
    RUN mkdir /home/analysis
    
    RUN R -e "options(repos = \
      list(CRAN = 'http://mran.revolutionanalytics.com/snapshot/${WHEN}')); \
      install.packages('tidystringdist')"
    
    COPY myscript.R /home/analysis/myscript.R

### `CMD`

Now, `CMD`, which the command to be run every time you’ll launch the
docker. What we want is `myscript.R` to be sourced.

    FROM rocker/r-ver:3.4.4
    
    ARG WHEN
    
    RUN mkdir /home/analysis
    
    RUN R -e "options(repos = \
      list(CRAN = 'http://mran.revolutionanalytics.com/snapshot/${WHEN}')); \
      install.packages('tidystringdist')"
    
    COPY myscript.R /home/analysis/myscript.R
    
    CMD R -e "source('/home/analysis/myscript.R')"

## Build, and run

### Build

Remember what we want: an image that will, ad vitam aeternam, run an
analysis as if we were still today. To do this, we’ll use the
`--build-arg WHEN=` argument for the `docker build`. Just after the `=`,
put the date you want your analysis to be run from.

Now, go and build your image. From your terminal, in the directory where
the Dockerfile is located, run:

    docker build --build-arg WHEN=2019-01-06 -t analysis .

`-t name` is the name of the image (here analysis), and `.` means it
will build the `Dockerfile` in the current working directory.

### `run`

Then, just launch with:

    docker run analysis 

And your analysis will be run 🎉\!

## Export container content

One thing to do now: you want to access what is created by your analysis
(here `p.csv`) outside your container ; i.e, on the host. Because yes,
as for now, everything that happens in the container stays in the
container. **So what we need is to make the docker container share a
folder with the host. For this, we’ll use what is called Volume, which
are (roughly speaking), a way to tell the Docker container to use a
folder from the host as a folder inside the container**.

That way, everything that will be created in the folder by the container
will persist after the container is turned off. To do this, we’ll use
the -v flag when running the container, with
`path/from/host:/path/in/container`. Also, create a folder to receive
the results in both :

    FROM rocker/r-ver:3.4.4
    
    ARG WHEN
    
    RUN mkdir /home/analysis
    
    RUN R -e "options(repos = \
      list(CRAN = 'http://mran.revolutionanalytics.com/snapshot/${WHEN}')); \
      install.packages('tidystringdist')"
    
    COPY myscript.R /home/analysis/myscript.R
    
    CMD cd /home/analysis \
      && R -e "source('myscript.R')" \
      && mv /home/analysis/p.csv /home/results/p.csv

    mkdir ~/mydocker/results 
    docker run -v ~/mydocker/results:/home/results  analysis 

Wait for the computation to be done, and…

    ls ~/mydocker/results  
    p.csv

🤘

## What to do next?

So now, every time you’ll launch this Docker image, the analysis will be
performed and you’ll get the result back. With no problem of
dependencies: the packages will always be installed from the day you
desire. Although, this can be a little bit long to run as the packages
are installed each time you run the container. But as I said in the
Disclaimer, this is a basic introduction to Docker, R and
reproducibility, so the goal was more to get beginners on board with
Docker :)

Other things you can do would be:

  - Use `remotes::install_version()` if you want your analysis to be
    based on package version instead of a time based installation.

<!-- end list -->

    FROM rocker/r-ver:3.4.4
    
    RUN R -e "install.packages('remotes'); \
      remotes::install_version('tidystringdist', '0.1.2')"
    
    ...

  - Use the Volume trick to bring data **into** your container, so that
    any data will be analysed in the very same environment.

And other cool stuffs, but that’s for another blog post ;)

## Know more about Docker

Some resources:

  - [rocker official website](https://www.rocker-project.org/)
  - [An Introduction to Rocker: Docker Containers for
    R](https://journal.r-project.org/archive/2017/RJ-2017-065/index.html)
  - [Noam Ross - Docker for the
    UseR](https://github.com/noamross/nyhackr-docker-talk)
  - [Production-ready R: Getting started with R and
    docker](https://www.youtube.com/watch?v=lfG8cTqRRNA)
  - [Applications with R and
    Docker](https://www.youtube.com/watch?v=JOIKy_89c-o)
  - [Docker for beginners](https://docker-curriculum.com/)

Reading list:

  - [Docker: Up & Running: Shipping Reliable Containers in
    Production](https://amzn.to/2VWfXs6)
  - [Docker in Practice](https://amzn.to/2wqpNZ0)
  - [Using Docker: Developing and Deploying Software with
    Containers](https://amzn.to/2wqiIaQ)
  - [Building Microservices: Designing Fine-Grained
    Systems](https://amzn.to/2WfsoV3)
