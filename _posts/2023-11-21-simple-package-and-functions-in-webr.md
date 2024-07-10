---
title: "Rethinking packages & functions preloading in webR 0.2.2"
post_date: 2023-11-24
layout: single
permalink: /rethinking-packages-and-functions-preloading-in-webr-0.2.2/
categories:
  - r-blog-en
  - webr
output: jekyllthat::jekylldown
excerpt_separator: <!--more-->
---

This post is the fifth one of a series of post about webR:

+ [Using webR in an Express JS REST API](https://colinfay.me//calling-webr-from-expressjs/)
+ [The Old Faithful Geyser Data shiny app with webR, Bootstrap & ExpressJS](https://colinfay.me//old-faithful-express-bootstrap-webr/)
+ [Preloading your R packages in webR in an Express JS API](https://colinfay.me//preloading-your-r-packages-in-webr-in-an-express-js-api/)
+ [Using my own R functions in webR in an Express JS API, and thoughts on building web apps with Node & webR](https://colinfay.me/using-own-functions-in-webr-node-js/)
+ Rethinking webR package & functions preloading with webR 0.2.2
+ [webrcli & spidyr: A starter pack for building NodeJS projects with webR inside](https://colinfay.me/webrcli-and-spidyr/)

> Note: the first post of this series explaining roughly what webR is, I won't introduce it again here.

When I wrote my blogpost about [Preloading your R packages in webR in an Express JS API](/preloading-your-r-packages-in-webr-in-an-express-js-api/), I mentioned that there was no native way to preload things in the webR filesystem — meaning that you had to reinstall all the R packages whenever the app was launched (and reported it in a [Github issue](https://github.com/r-wasm/webr/issues/260)).
This also meant that I couldn't easily take my own functions and run them in the webR environment, as described in [Using my own R functions in webR in an Express JS API, and thoughts on building web apps with Node & webR](/using-own-functions-in-webr-node-js).
These needs made me write the [webrtools](https://www.npmjs.com/package/webrtools) NodeJS package, to do just that:

- Download the R packages compiled for webR, to a local folder
- Bundle them in the webR lib (by reading the folder tree and reproducing it in webR filesystem)
- Load your local package to access its functions in webR

The last webR version now exposes Emscripten's `FS.mount`, so this makes the process easier, as there is now no need to read the file tree and recreate it: the folder from the server can be mounted into webR filesystem.

That implied some rework (now integrated to `webrtools`) :

- Use `webR.FS.mkdir` to create a local lib: the module can't mount the package library into the libPath as is, because it would overwrite the already bundled library (in other words, if you mount into a folder that is not empty, the content from the server overwrites the content from webR).
- Use `webR.FS.mount` to mount the local directory into the newly created library
- Ensure that this new library is in the libPath()

Here is the new code for `loadPackages`, bundled into `webrtools`:

```javascript
async function loadPackages(webR, dirPath, libName = "webr_packages") {
  // Create a custom lib so that we don't have to worry about
  // overwriting any packages that are already installed.
  await webR.FS.mkdir(`/usr/lib/R/${libName}`)
  // Mount the custom lib
  await webR.FS.mount("NODEFS", { root: dirPath }, `/usr/lib/R/${libName}`);
  // Add the custom lib to the R search path
  await webR.evalR(`.libPaths(c('/usr/lib/R/${libName}', .libPaths()))`);
}
```

I've also decided to deprecate the `loadFolder` function, as it is now native with `webR.FS.mkdir` + `webR.FS.mount`.

So here is a rewrite of the app from [Using my own R functions in webR in an Express JS API, and thoughts on building web apps with Node & webR](/using-own-functions-in-webr-node-js/).

```javascript
const app = require('express')()
const path = require('path');
const { loadPackages } = require('webrtools');
const { WebR } = require('webr');

(async () => {
  globalThis.webR = new WebR();
  await globalThis.webR.init();

  console.log("🚀 webR is ready 🚀");

  await loadPackages(
    globalThis.webR,
    path.join(__dirname, 'webr_packages')
  )

  await globalThis.webR.FS.mkdir("/home/rfuns")

  await globalThis.webR.FS.mount(
    "NODEFS",
    {
      root: path.join(__dirname, 'rfuns')
    },
    "/home/rfuns"
  )

  console.log("📦 Packages written to webR 📦");

  // see https://github.com/r-wasm/webr/issues/292
  await globalThis.webR.evalR("options(expressions=1000)")
  await globalThis.webR.evalR("pkgload::load_all('/home/rfuns')");

  app.listen(3000, '0.0.0.0', () => {
    console.log('http://localhost:3000')
  })

})();

app.get('/', async (req, res) => {
  let result = await globalThis.webR.evalR(
    'unique_species()'
  );
  try {
    let js_res = await result.toJs()
    res.send(js_res.values)
  } finally {
    webR.destroy(result);
  }

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

Full code is at [ColinFay/webr-examples/](https://github.com/ColinFay/webr-examples/tree/main/webr-preload-funs).

Further exploration to be done: webR now bundles a way to package a file system in a file, which can then be downloaded and mounted into the runtime, as described [here](https://docs.r-wasm.org/webr/latest/mounting.html#emscripten-filesystem-images).
This might come handy for our current structure, but I'll have to explore it a bit more.