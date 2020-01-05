---
title: "chuck — A training tool for deploying Shiny Apps"
post_date: 2020-01-05
layout: single
permalink: /chuck-deployment-shiny-docker-kubernetes/
categories: r-blog-en
output: jekyllthat::jekylldown
excerpt_separator: <!--more-->
---

`chuck` is a small app you can use as a training tool for deploying
Shiny applications.

### Why?

In late December the ThinkR team followed a three day workshop on
Kubernetes, which was the opportunity for us to receive a proper
training on how to deploy apps to Kube. One challenging thing for this
training was to find an app that was useful for toying around: the *Old
Faithful Geyser Data* app is nice when you start Shiny, but it lacks
what you’d expect a production Shiny app to have. For example, it
doesn’t have any external inputs, it isn’t plugged into any db, and of
course you don’t have any feedback about the context of the application
(server information, R session info, etc.)

## And here comes `chuck`

`chuck` is a small, relatively funny Shiny app that contains some
features that can be used to train your skills when it comes to
deploying Shiny apps with Docker and Kubernetes.

<div data-align="center">

<img src = "/assets/img/chuck1.png" width = "800px">

</div>

Let me describe the infrastructure of this app:

  - This app takes a random “Chuck Norris Fact” from the *icndb*
    website, aka the Internet Chuck Norris Data Base
    <http://www.icndb.com/>, so the container launching your Shiny app
    needs to have access to the internet.
  - This app needs to be connected to a Mongo DB database, so you also
    need to handle the access to this DB.
  - Database info is printed to R so you have something to look for in
    the Docker & Kube logs.
  - As it relies on `{mongolite}`, it has system requirements.
  - The connection parameters are passed through environment variables,
    so you can also play with these ones either in Docker, or in Kube
    with Environment variables, configMap or Secrets.
  - On the app, you can chose to “save” or “skip” when a joke is
    randomly shown. If you chose save, it’s saved inside the mongo
    database. You can see the number of elements registered in the mongo
    collection + the info about the db. That allows you to play with
    mongo collection and database name, storage systems (keep the db
    content when the app / docker / pods are closed), etc.
  - The “Show R Session” and “Server wtfismyip” respectively run
    `utils::sessionInfo()` and
    `jsonlite::read_json("https://wtfismyip.com/json")` and prints the
    output inside the modals, so you can retrieve info about the R
    session the app is run in, and about the location of the server.

<div data-align="center">

<img src = "/assets/img/chuck2.png" width = "800px">

</div>

## Find `chuck`

You can find chuck on my GitHub at: <https://github.com/ColinFay/chuck>

You’ll find the app in the `chuck/` folder. It’s a rather basic Shiny
App built with `{golem}` so nothing fancy here.

The `Dockerfile` at the root of the project is the one used to build the
container for <https://hub.docker.com/repository/docker/colinfay/chuck>.
As you can see, it contains a series of environment variables which are
used inside the Shiny App to connect to mongo. It defaults to serving on
port 3838 but that can also be set by an env variable.

If you don’t want to go into too much trouble, you can simply run:

    docker pull colinfay/chuck:0.2.0
    docker pull mongo:3.4 
    
    docker network create chucknet
    
    docker run -v $(pwd)/db:/data/db -p 27017:27017 \
      -d --name mongo --net chucknet mongo:3.4
    
    docker run -e MONGOPORT=27017 -e MONGOURL=mongo \
      -e MONGODB=pouet -e MONGOCOLLECTION=pouet -p 3838:3838 \
      --name chuck --net chucknet -d colinfay/chuck \
      && sleep 5 && open http://localhost:3838

In the `kube/` folder, you’ll find the YAMLs used during the training to
deploy the app with minikube. If you’re in minikube right now, you’ll
probably just have to `git clone` and `kubectl apply -f chuck/` to get
this running. This folder contains three yaml files for the mongo
database: one for the deployment, one for the persistent volume claim,
and one for the service.

The shiny app has more files: one for the deployment and one for the
service (classical), and also a configMap and a secret, which are mainly
used as an example for practicing these features. The ingress was there
to help exposing the app to the world during the training, but you might
want to use other configs for your platform (for example, I had to use
another method for Google Cloud Engine).

The main goal is to have something to exercise your skills, so maybe
you’d want to write your own Dockerfile & kube YAMLs.

And remember,

> No statement can catch the ChuckNorrisException.
