---
title: "Using my own R functions in webR in an Express JS API, and thoughts on building web apps with Node & webR"
post_date: 2023-10-17
layout: single
permalink: /using-own-functions-in-webr-node-js/
categories: r-blog-en
output: jekyllthat::jekylldown
excerpt_separator: <!--more-->
---

This post is the fourth one of a series of post about webR:

+ [Using webR in an Express JS REST API](/calling-webr-from-expressjs/)
+ [The Old Faithful Geyser Data shiny app with webR, Bootstrap & ExpressJS](/old-faithful-express-bootstrap-webr/)
+ [Preloading your R packages in webR in an Express JS API](/preloading-your-r-packages-in-webr-in-an-express-js-api/)
+ Using my own R functions in webR in an Express JS API, and thoughts on building web apps with Node & webR

> Note: the first post of this series explaining roughly what webR is, I won't introduce it again here.

## The problem

Ok, so now that we have our webR / NodeJS machinery up and running, let's try something more interesting: use our own R functions inside `webR`.

How can I do that?

There are at least three ways I could think of:

1️⃣ Writing a function inside the JS code to define a function, something like :

```javascript
await globalThis.webR.evalR("my_fun <- function(x){...}");
```

But that doesn't check what I would expect from something I'll use in prod and I'm pretty sure you don't need me to detail why 😅

- ❌ Well organized
- ❌ Documented
- ❌ Tested
- ❌ Safely installable

2️⃣ Simply create an R script and source it. Something like:

```javascript
const fs = require('fs');
const path = require('path');
const script = path.join(__dirname, 'script.R')
const data = fs.readFileSync(script);
await globalThis.webR.FS.writeFile(
  "/home/web_user/script.R",
  data
);
await globalThis.webR.evalR("source('/home/web_user/script.R')");
```

That's a bit better, we can at least organize our code in a script and it will be:

- ✅ Well organized (more or less)
- ✅ Documented (more or less)
- ❌ Tested
- ❌ Safely installable

3️⃣ I bet you saw me coming, the best way let's put stuff into an R package, so that we can check all the boxes.

- ✅ Well organized
- ✅ Documented
- ✅ Tested
- ✅ Safely installable

Jeroen has written a [Docker image](https://github.com/r-universe-org/build-wasm) to compile an R package to WASM, but I was looking for something that wouldn't involve compiling via a docker container every time I make a change on my R package (even if that does sound appealing, I'm pretty sure this wouldn't make for a seamless workflow).

So here is what I'm thinking should be a well structured NodeJS / WebR app:

- Putting all the web stuff inside the NodeJS app, because, well, NodeJS is really good at doing that.
- Putting all the "business logic", data-crunching, modeling stuff (and everything R is really good at) into an R package.
- load webR, write my R package to the webR file system, and `pkgload::load_all()` it into webR.

That way, I can enjoy the best of both worlds:

-  NodeJS is really good at doing web related things, and there are plenty of ways to test and deploy the code.
- And same goes for the R package: if you're reading my blog I'm pretty sure I don't need to convince you of why packages are the perfect tool for sharing production code.

## The how

Let's start by creating our project:

```bash
mkdir webr-preload-funs
cd webr-preload-funs
npm init -y
touch index.js
npm install express webr
R -e "usethis::create_package('rfuns', rstudio = FALSE)"
```

Let's now create a simple function :

```r
> usethis::use_r("sw")
```

```r
#' @title Star Wars by Species
#' @description Return a tibble of Star Wars characters by species
#' @import dplyr
#' @export
#' @param species character
#' @return tibble
#' @examples
#' star_wars_by_species("Human")
#' star_wars_by_species("Droid")
#' star_wars_by_species("Wookiee")
#' star_wars_by_species("Rodian")
star_wars_by_species <- function(species){
  dplyr::starwars |>
    filter(species == {{species}})
}
```

We can now add `{dplyr}` and `{pkgload}` to our `DESCRIPTION` (we'll need `{pkgload}` to `load_all()` the package).

```r
usethis::use_package("dplyr")
usethis::use_package("pkgload")
devtools::document()
```

Now that we have a package skeleton, we'll have to upload it to webR.

As described in the previous post, I've started a `webrtools` NodeJS module, which will contains function to play with webR.
Before this post, it had one function, `loadPackages`, that was used to build a webR dependency library (see [Preloading your R packages in webR in an Express JS API](https://colinfay.me/preloading-your-r-packages-in-webr-in-an-express-js-api/) for more info).

We'll need to add two features :

- Install deps from DESCRIPTION (not just a package name), so a wrapper around the `Rscript ./node_modules/webrtools/r/install.R dplyr` from before
- Copy the package folder in NodeJS, so a more generic version of `loadPackages`, that can load any folder to the webR filesystem.

First, in R, we'll need to read the `DESCRIPTION` and build the lib:

```r
download_packs_and_deps_from_desc <- function (
  description,
  path_to_installation = "./webr_packages"
)
{
    if (!file.exists(description)) {
        stop("DESCRIPTION file not found")
    }
    deps <- desc::desc_get_deps(description)
    for (pak in deps$package) {
        webrtools::download_packs_and_deps(pak, path_to_installation = path_to_installation)
    }
}
```

> Note: the code of `webrtools::download_packs_and_deps()` is a wrapper around the R code described in [Preloading your R packages in webR in an Express JS API](/preloading-your-r-packages-in-webr-in-an-express-js-api/)

And in Node, we'll rework our `loadPackages` and split it into two functions --- one to load into any folder, and one to load into the package library:

```javascript
async function loadFolder(webR, dirPath, outputdir = "/usr/lib/R/library") {
  const files = getDirectoryTree(
    dirPath
  )
  for await (const file of files) {
    if (file.type === 'directory') {
      await globalThis.webR.FS.mkdir(
        `${outputdir}/${file.path}`,
      );
    } else {
      const data = fs.readFileSync(`${dirPath}/${file.path}`);
      await globalThis.webR.FS.writeFile(
        `${outputdir}/${file.path}`,
        data
      );
    }
  }
}

async function loadPackages(webR, dirPath) {
  await loadFolder(webR, dirPath, outputdir = "/usr/lib/R/library");
}
```

## The end app

We now have everything we need!

```
npm i webrtools@0.0.2
Rscript ./node_modules/webrtools/r/install_from_desc.R $(pwd)/rfuns/DESCRIPTION
```

And now, to our index.js

```javascript
const app = require('express')()
const path = require('path');
const { loadPackages, loadFolder } = require('webrtools');
const { WebR } = require('webr');

(async () => {
  globalThis.webR = new WebR();
  await globalThis.webR.init();

  console.log("🚀 webR is ready 🚀");

  await loadPackages(
    globalThis.webR,
    path.join(__dirname, 'webr_packages')
  )

  await loadFolder(
    globalThis.webR,
    path.join(__dirname, 'rfuns'),
    "/home/web_user"
  )

  console.log("📦 Packages written to webR 📦");

  // see https://github.com/r-wasm/webr/issues/292
  await globalThis.webR.evalR("options(expressions=1000)")
  await globalThis.webR.evalR("pkgload::load_all('/home/web_user')");

  app.listen(3000, '0.0.0.0', () => {
    console.log('http://localhost:3000')
  })

})();

app.get('/', async (req, res) => {
  let result = await globalThis.webR.evalR(
    'unique(dplyr::starwars$species)'
  );
  let js_res = await result.toJs()
  res.send(js_res.values)
})


app.get('/:n', async (req, res) => {
  let result = await globalThis.webR.evalR(
    'star_wars_by_species(n)',
    { env: { n: req.params.n } }
    );
  try {
    const result_js = await result.toJs();
    res.send(result_js)
  } finally {
    webR.destroy(result);
  }
});
```

Let's now try from another terminal:

```bash
curl http://localhost:3000
```

```
["Human","Droid","Wookiee","Rodian","Hutt","Yoda's species","Trandoshan","Mon Calamari","Ewok","Sullustan","Neimodian","Gungan",null,"Toydarian","Dug","Zabrak","Twi'lek","Vulptereen","Xexto","Toong","Cerean","Nautolan","Tholothian","Iktotchi","Quermian","Kel Dor","Chagrian","Geonosian","Mirialan","Clawdite","Besalisk","Kaminoan","Aleena","Skakoan","Muun","Togruta","Kaleesh","Pau'an"]
```


```bash
curl http://localhost:3000/Rodian
```

```
{"type":"list","names":["name","height","mass","hair_color","skin_color","eye_color","birth_year","sex","gender","homeworld","species","films","vehicles","starships"],"values":[{"type":"character","names":null,"values":["Greedo"]},{"type":"integer","names":null,"values":[173]},{"type":"double","names":null,"values":[74]},{"type":"character","names":null,"values":[null]},{"type":"character","names":null,"values":["green"]},{"type":"character","names":null,"values":["black"]},{"type":"double","names":null,"values":[44]},{"type":"character","names":null,"values":["male"]},{"type":"character","names":null,"values":["masculine"]},{"type":"character","names":null,"values":["Rodia"]},{"type":"character","names":null,"values":["Rodian"]},{"type":"list","names":null,"values":[{"type":"character","names":null,"values":["A New Hope"]}]},{"type":"list","names":null,"values":[{"type":"character","names":null,"values":[]}]},{"type":"list","names":null,"values":[{"type":"character","names":null,"values":[]}]}]}
```

Yeay 🎉 .

You can find the code [here](https://github.com/ColinFay/webr-examples/tree/main/webr-preload-funs), and see it live at [srv.colinfay.me/webr-preload-funs/](https://srv.colinfay.me/webr-preload-funs/Rodian).

You can also try it with

```bash
docker run -it -p 3000:3000 colinfay/webr-preload-funs
```