---
title: "webrcli & spidyr: What's new"
post_date: 2024-07-10
layout: single
permalink: /webrcli-and-spidyr-whats-new/
categories:
  - r-blog-en
  - webr
output: jekyllthat::jekylldown
excerpt_separator: <!--more-->
---

This post is the seventh one of a series of post about webR:

+ [Using webR in an Express JS REST API](https://colinfay.me/calling-webr-from-expressjs/)
+ [The Old Faithful Geyser Data shiny app with webR, Bootstrap & ExpressJS](https://colinfay.me/old-faithful-express-bootstrap-webr/)
+ [Preloading your R packages in webR in an Express JS API](https://colinfay.me/preloading-your-r-packages-in-webr-in-an-express-js-api/)
+ [Using my own R functions in webR in an Express JS API, and thoughts on building web apps with Node & webR](https://colinfay.me/using-own-functions-in-webr-node-js/)
+ [Rethinking webR package & functions preloading with webR 0.2.2](https://colinfay.me/rethinking-packages-and-functions-preloading-in-webr-0.2.2/)
+ [A starter pack for building NodeJS projects with webR inside](https://colinfay.me/webrcli-and-spidyr/)
+ [webrcli & spidyr: What's new](https://colinfay.me/webrcli-and-spidyr-whats-new/)

> Note: the first post of this series explaining roughly what `webR` is, I won't introduce it again here.

In this blogpost, you'll find some updates about some recent changes made in `webrcli` & `spidyr`.

## What webrcli & spidy wants to achieve

In a nutshell, the goal of `webrcli` & `spidyr` is to provide an interface for bringing your R functions inside a NodeJS runtime.

Think of it as something that wants to achieve the following interation:

- An R dev writes, builds and shares a package called `{rfuns}`, which contains a function called `hello_world()`

- A NodeJS dev takes this package, can call it with `rfuns.hello_world()`, access and manipulate the results with JavaScript.

![](/assets/img/js-call-r.png)

## An important note

With `webR` & the tools described below, there is no R session running while the NodeJS app is running. `spidyr` imports an R function __converted to a native JS__.
`rfuns.hello_world` does not call an R session running somewhere else.

That also means that if you build a container containing the app, you don't need to install R in it. It's a NodeJS app.

Below are some updates recently made to both `webrcli` & `spidyr`.

## Making the template code smaller

When drafting the first code of `webrcli` & `spidyr`, I focused on providing a minimal template for an `index.js` loading your R functions, contained in a subdirectory inside your node project.

This worked, but might have been a bit complex to grasp. Provided you don't change the default names of the folders (in that case you'll need to modify the default parameters), the new default `index.js` look like this:

```javascript
const {
  initSpidyr,
  mountLocalPackage
} = require('spidyr');

(async () => {

  await initSpidyr()

  const rfuns = await mountLocalPackage("./rfuns");

  const hw = await rfuns.hello_world()

  console.log(hw.values);

  console.log("✅ Everything is ready!");
})();
```

This minimal template makes it easier to read and understand what the code does. Note that you'll get this template if you run `webrcli init myproject`.

Let's decompose what this code does :

- `await initSpidyr()` will create an object called `spidyr_webR` stored as `globalThis.spidyr_webR`, `init()` it (as in `webr.init()`), and load the packages contained in the `./webr_packages` folder inside your project dir, the one containing the packages installed with `webrcli install`.

- `const rfuns = await mountLocalPackage("./rfuns");` will take the R package contained in `./rfuns`, load it into the webR instance (`spidyr_webR`), recursively get all the exported functions from your package, and store them inside the `rfuns` object.

- `const hw = await rfuns.hello_world()` will call the `hello_world()` function from `{rfuns}`. The values are then `console.log`ed.

## `new Library()` is now `library()`

Calling a package is now `const spongebob = library("spongebob")` instead of the previous approach which was `const spongebob = new Library("spongebob");await spongebob.load(globalThis.webR);`

## Better installation from package.json & `DESCRIPTION`

The previous version of `webrcli` did not stored nor re-installed the R package installed in the project, meaning that if you git cloned a project, you had to guess what R packages to re-install.

Now, a project initiated with `webrcli` will store all the packages installed with `webrcli install` inside the `package.json` file.
Then, when running the `npm install` command, the R packages will also be redownloaded.

You can also installed a series of packages based on a `DESCRIPTION` file with `webrcli installFromDesc`.

## Other tools

- `shareEnv` allows to __copy__ one, several or all env var from node to the webR instance.

## Workflow summary

- `webrcli init myproject` will create a project skeleton at `./myproject`

- `webrcli install spongebob` will download the version of `{spongebob}` compiled for `webR`, and add it to `./webr_packages`.

- You can then modify you R code with your own functions.

- Call your R function from `rfuns.xyz()` in Node

- Run with `npm start`

![](/assets/img/webrcli-init.png)

## Please do give it a shot

I think I've been the only user for now 😅, so please do try these and let me know what you think.

## Future works

Here are what I plan on working in the upcoming weeks:

- `webrcli init` should allow for specifying a `webr` version from npm [issue 17](https://github.com/ColinFay/webrcli/issues/17)

- `initSpidyr` should allow to pass params to `webR.init()` [issue 12](https://github.com/ColinFay/spidyr/issues/12)

- Allow to install from `r-universe`, something like `webrcli installFromRUniverse` [issue 16](https://github.com/ColinFay/webrcli/issues/16).
Probably in the future it will be merged to `webrcli install` and we'll have a way to guess what the user wants based on the input.

- A small converter from R named list to JS objects [Issue 3](https://github.com/ColinFay/spidyr/issues/3)

- More documentation, and probably documenting the conversion of an existing `{shiny}` app to a `spidyr` based one.

