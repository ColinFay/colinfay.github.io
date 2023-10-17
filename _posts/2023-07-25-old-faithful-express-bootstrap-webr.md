---
title: "The Old Faithful Geyser Data shiny app with webR, Bootstrap & ExpressJS"
post_date: 2023-07-25
layout: single
permalink: /old-faithful-express-bootstrap-webr/
categories: r-blog-en
output: jekyllthat::jekylldown
excerpt_separator: <!--more-->
---

This post is the second one of a series of post about webR:

+ [Using webR in an Express JS REST API](/calling-webr-from-expressjs/)
+ The Old Faithful Geyser Data shiny app with webR, Bootstrap & ExpressJS
+ [Preloading your R packages in webR in an Express JS API](/preloading-your-r-packages-in-webr-in-an-express-js-api/)
+ [Using my own R functions in webR in an Express JS API, and thoughts on building web apps with Node & webR](/using-own-functions-in-webr-node-js)

> Note: the first post of this series explaining roughly what webR is, I won't introduce it again here.

In this post, I'll attempt to recreate a version of the famous *Old Faithful Geyser Data* `{shiny}` app using `webR`, `Bootstrap` & `ExpressJS`.
(If you really don't know which app I'm talking about, it's [this one](https://gallery.shinyapps.io/001-hello/).)

## Introductory notes

Before starting, here are two notes regarding the app built in this post:

- this app could have been build in full "web mode" (no server required, just an HTML page), but this is not the approach I'm currently experimenting with.
Going full browser-based doesn't work for all cases, and most of the time with production apps you'll need some part of your code to be computed by the server (because of resources, because you'll connect to API with token, because you need access to DB with passwords, because you don't want the full data to be available in the brower, or many other good reason...).

- In order to recreate the app, my first approach was to try to draw the histogram in base R and send it back to the browser.
[boB has a great blogpost](https://rud.is/b/2023/03/18/the-road-to-ggplot2-in-webr-part-1-the-road-is-paved-with-good-base-r-plots/) about how to do exactly that, but after a lot of bad code and good 4 letter words, I realized there was no sane reason for me to display a base R plot instead of a JavaScript based one.
That's why I chose to return the data for the barplot (using the `cut()` function from R) and draw with [chart.js](https://www.chartjs.org/), instead of trying to display the "not so user friendly" base plot.

## Project init

Let's start by creating a new Express app:

```bash
mkdir express-webr-old-faithful
cd express-webr-old-faithful
npm init -y
# Installing the deps we'll need
npm i @r-wasm/webr express
# Creating a server, and the front page
touch index.js
touch index.html
```

## Server

Let's move to the server side first (`index.js` ).
We'll start by taking the file from the previous blog post, and modify it to:

- serve index.html on `/`
- create a route that returns the data of the bins for our histogram

Let's start with our code to init `webR`.

```javascript
'use strict';
const express = require("express")
// For serving the html
const path = require("path")
const app = express()
const { WebR } = require('@r-wasm/webr');

(async () => {
  globalThis.webR = new WebR();
  await globalThis.webR.init();
  // Given that we will reuse this value,
  // we assign it at launch
  await globalThis.webR.evalR('x <- faithful[, 2]')
  console.log("webR is ready");
  app.listen(3000, '0.0.0.0', () => {
    console.log('http://localhost:3000')
  })
})();
```

Then, an endpoint that serves `index.html`:

```javascript
app.get("/", (req, res) => {
  res.sendFile(path.join(__dirname, "index.html"))
})
```

And an endpoint that sends the bins for our plot, using ExpressJS parameter notation (`path/:n`).
The value is sent to webR via the `env` option of `evalR`

```javascript
app.get("/hist-data/:n", async (req, res) => {
  let result = await globalThis.webR.evalR(
    'table(cut(x, seq(min(x), max(x), length.out = n + 1)))',
    { env: { n: parseInt(req.params.n) } }
  );
  let output = await result.toJs();
  res.send(output)
})
```

Now that our backend is ready, let's check that we can now call it from the command line:

```bash
curl http://localhost:3000/hist-data/10
{"type":"integer","names":["(43,48.3]","(48.3,53.6]","(53.6,58.9]","(58.9,64.2]","(64.2,69.5]","(69.5,74.8]","(74.8,80.1]","(80.1,85.4]","(85.4,90.7]","(90.7,96]"],"values":[15,28,26,24,9,23,62,55,23,6]}
```

## Front

Now, time to build the front.

We'll start with the Boostrap boilerplate from <https://getbootstrap.com/docs/5.3/getting-started/introduction/#quick-start>.

> Note also that I've chosen (for simplicity's sake) to use the CDN version of the external deps, instead of installing them in my Node project, which would be what I would do in a normal context.

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Bootstrap demo</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-9ndCyUaIbzAi2FUVXJi0CjmCapSmO7SnpJef0486qhLnuZ2cdeRhO02iuK6FUUVM" crossorigin="anonymous">
  </head>
  <body>
    <h1>Hello, world!</h1>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js" integrity="sha384-geWF76RCwLtnZ8qwWowPQNguL3RmwHVBC9FhGdlKrxdiJJigb/j/68SIy3Te4Bkz" crossorigin="anonymous"></script>
  </body>
</html>
```

Let's change the title, and add:

- the range input
- a div to receive the chart

```html
<div class="container">
  <h1>Old Faithful Geyser Data</h1>
  <!-- Bootstrap grid system -->
  <div class="row align-items-start">
    <div class="col-4">
      <label for="customRange1" class="form-label">Number of bins:</label>
      <input type="range" class="form-range" id="customRange1" min=1 max=30 value=10>
      <div id="bins">Selected: 10</div>
    </div>
    <div class="col-8">
      <div>
        <!-- Where we'll get the chart drawn -->
        <canvas id="myChart"></canvas>
      </div>
    </div>
  </div>
</div>
```

In order to draw the graph, I'll rely on a dead simple (yet powerful) JavaScript lib called [Chart.js](https://www.chartjs.org/).
It has a great [bar chart](https://www.chartjs.org/docs/latest/charts/bar.html) graph that will work perfectly for our case.

Let's start by adding the lib with `<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>`.

We then need some JavaScript to:

- Initiate the chart at launch

```javascript
// https://colinfay.me/api-from-client-shiny/
// Default to 10 bins
fetch("hist-data/10")
      .then((data) =>{
        // Convert the data to json and
        // create a chart
        data.json().then((res) => {
          // Keeping a global object with the chart
          globalThis.chart = new Chart(
          // This is where the chart will go
          document.getElementById('myChart'), {
          type: 'bar',
          data: {
            // webR returns the names
            labels: res.names,
            datasets: [{
              label: "Histogram of waiting times",
              data: res.values
            }]
          }
        });
        })
        .catch((error) => {
          alert("Error catchin result from R")
        })
      })
      .catch((error) => {
        alert("Error catchin result from R")
      })
```

- Update the chart when the slider is moved

```javascript
    const update = function (n = 10) {
      fetch(`hist-data/${n}`).then((data) => {
        data.json().then((res) => {
          globalThis.chart.data.labels = res.names;
          globalThis.chart.data.datasets.forEach(dataset => {
            dataset.data = res.values;
          })
          globalThis.chart.update();
        })
      })
      document.querySelector('#bins').innerHTML = `Selected: ${n}`;

    }
document.querySelector('#customRange1').addEventListener(
  'change',
  function() { update(this.value); }
 );
```

And here it is!
You can see the app live at [srv.colinfay.me/express-webr-old-faithful](https://srv.colinfay.me/express-webr-old-faithful/).
You can find the code [here](https://github.com/ColinFay/webr-examples/tree/main/express-webr-old-faithful).

You can also try it with:

```bash
docker run -it -p 3000:3000 colinfay/express-webr-old-faithful
```