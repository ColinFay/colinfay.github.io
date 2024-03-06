---
title: "Using webR in an Express JS REST API"
post_date: 2023-07-04
layout: single
permalink: /calling-webr-from-expressjs/
categories: r-blog-en
output: jekyllthat::jekylldown
excerpt_separator: <!--more-->
---

This post is the second one of a series of post about webR:

+ Using webR in an Express JS REST API
+ [The Old Faithful Geyser Data shiny app with webR, Bootstrap & ExpressJS](https://colinfay.me/old-faithful-express-bootstrap-webr/)
+ [Preloading your R packages in webR in an Express JS API](https://colinfay.me/preloading-your-r-packages-in-webr-in-an-express-js-api/)
+ [Using my own R functions in webR in an Express JS API, and thoughts on building web apps with Node & webR](https://colinfay.me/using-own-functions-in-webr-node-js)
+ [Rethinking webR package & functions preloading with webR 0.2.2](https://colinfay.me/rethinking-packages-and-functions-preloading-in-webr-0.2.2/)
+ [webrcli & spidyr: A starter pack for building NodeJS projects with webR inside](https://colinfay.me/webrcli-and-spidyr/)

> Note: webR and the tools I've been writing are moving fast and if you're reading this from the future, some of the things here might be obsolete.

## webR? wat again?

As described in the [doc](https://docs.r-wasm.org/webr/latest/):

> WebR is a version of the statistical language R compiled for the browser and Node.js using WebAssembly, via Emscripten.

In this post, I won't go into details into what `webR` is, as if you want to know more, you'll probably get a better understanding by going through the documentation.

But if like a normal person you don't read the doc, let's sum up what `webR` is.
Simply put, `WebAssembly` (shorten wasm) is a format that can be used to encode a programming language to something that can then be called from a JavaScript runtime (in the browser or in NodeJS).
Schematically, you take one language, you translate it to wasm, and the output can be read and used from JavaScript.

If you still have no idea what wasm is but want to get a better grasp on what it is, I suggest reading [this blogpost](https://www.jesuisundev.com/en/understand-webassembly-in-5-minutes/) that really sums it well, especially this quote:

> WASM is a way to use non-Javascript code and run it in your browser.

I also suggest reading the blogposts by [boB](https://rud.is/b/) on the subject.

The rest of this post assume that you understand what wasm & `webR` are.

## Playing with webR

I've been interested with WebAssembly for a while now, and can remember talking about it late during the night at R conferences around 2018 and 2019... but that's a story for another time 😅

Today's story is about exploring how to build tools in JavaScript that will call `webR`.

I'll try to document my experimentations, and this post is the first one of a series that I hope I'll find time to continue over the summer.

## Hello World! - Creating an API where we call webR

I'll start with a simple [Express JS](https://expressjs.com/) REST API that uses webR to run R code.

```bash
# Initiating a projet and opening it with VSCode
mkdir webrexpresshelloworld
code webrexpresshelloworld

# Quick init of a node project
npm init -y
touch index.js
npm install express
```

We'll now install the webR nodejs package

```bash
npm i @r-wasm/webr
```

And now, let's move to our index.js file.
We'll start with the basics of Express JS: creating the `app` object.

```javascript
// Creating the express app
const app = require('express')()
```

Then, we'll import `WebR` from `@r-wasm/webr`.

```javascript
// importing the `WebR` class inside the runtime
const { WebR } = require('@r-wasm/webr');
```

We'll now be initiating the webR session by:
- creating an instance of webR
- binding it to `globalThis` so that it's available everywhere
- calling the `init` method
- Once `webR` is ready, we'll launch the `app`

As webR communicates via the worker thread asynchronously, we need to use `async`/`await`.

```javascript
(async () => {
  globalThis.webR = new WebR();
  await globalThis.webR.init();
  console.log("webR is ready");
  // Starting the express app
  // only after webR is ready
  app.listen(3000, () => {
    console.log('http://localhost:3000')
  })
})();
```

Finally, we add a route that returns an hello world:

```javascript
// Creating a route for the express app
// that will return a titleCase hello world from r
app.get('/', async (req, res) => {
  // Evaluating the R code inside the R worker
  let result = await globalThis.webR.evalR('tools::toTitleCase("hello from r!")');
  // Converting the result to a JS object
  let output = await result.toJs();
  // Sending the result back to the client,
  // (webR outputs an object with types/names/values
  // and here we only want the values)
  res.send(output.values)
});
```

And now, let's run our app!

```bash
node index.js
```

You can find the code [here](https://github.com/ColinFay/webr-examples/tree/main/express-webr-hello-world), and see it live at [srv.colinfay.me/express-webr-hello-world](https://srv.colinfay.me/express-webr-hello-world).

You can also try it with

```bash
docker run -it -p 3000:3000 colinfay/express-webr-hello-world
```