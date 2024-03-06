---
title: "webrcli & spidyr: A starter pack for building NodeJS projects with webR inside"
post_date: 2024-11-24
layout: single
permalink: /webrcli-and-spidyr/
categories: r-blog-en
output: jekyllthat::jekylldown
excerpt_separator: <!--more-->
---

This post is the sixth one of a series of post about webR:

+ [Using webR in an Express JS REST API](https://colinfay.me/calling-webr-from-expressjs/)
+ [The Old Faithful Geyser Data shiny app with webR, Bootstrap & ExpressJS](https://colinfay.me/old-faithful-express-bootstrap-webr/)
+ [Preloading your R packages in webR in an Express JS API](https://colinfay.me/preloading-your-r-packages-in-webr-in-an-express-js-api/)
+ [Using my own R functions in webR in an Express JS API, and thoughts on building web apps with Node & webR](https://colinfay.me/using-own-functions-in-webr-node-js/)
+ [Rethinking webR package & functions preloading with webR 0.2.2](https://colinfay.me/rethinking-packages-and-functions-preloading-in-webr-0.2.2/)
+ A starter pack for building NodeJS projects with webR inside

> Note: the first post of this series explaining roughly what `webR` is, I won't introduce it again here.

## Again, a new project?

Most of the previous posts have been about poking around with `webR` inside NodeJS, but nothing stable on how to build an app.

That's something I'm trying to change.
Based on the experience gathered building apps in R (in `{shiny}` with `{golem}`) and in JavaScript, I've tried to come up with a solution for a starter kit for building what I think will be the perfect skeleton for `webR`/`NodeJS` project.

The idea is to have one project with inside:

- One R package
- One JS app
- A tool that brings the R package into the NodeJS app and allow to use the R functions inside JavaScript

This skeleton needed a toolkit to perform the following task:

1️⃣ From a cli point of view:

- init the project with a specific skeleton
- allow to install packages from the `webr `CRAN to a local `webr` library, in the spirit of [previous post](https://colinfay.me/rethinking-packages-and-functions-preloading-in-webr-0.2.2/).
- allow to install the deps from a DESCRIPTION file

2️⃣ From a NodeJS point of view:

- Load the packages downloaded in a local `webr` library
- Create an interface to load and manipulate the functions from a package downloaded from CRAN, and use them in JS.
- Same but with a local package folder

For the function manipulation mechanism, I wanted something that would allow to think in terms of `pkg::fun()` but in JavaScript, which would translate as `pkg.fun()` in your Node app.
Something I had implemented in another old NodeJS module called [hordes](https://github.com/ColinFay/hordes), which I can now safely deprecate in favor of the following tools.

The reasoning being: the R dev writes a standalone package that exports an `xyz` function, then the web team can load this package, and launch `xyz()` without writing any R code.

## webrcli & spidyr

So, here comes [webrcli](https://www.npmjs.com/package/webrcli) and [spidyr](https://www.npmjs.com/package/spidyr).

❗️ Please note that these tools are work in progress and has been used very few times and only for example apps, will need a lot of bug fixes and documentation, so if ever you plan on using it be indulgent, and report any bug or feature request ❗️

### Project init

These packages are made to be used together, and here is an example of how to use them:

```bash
# Global installing webrcli
npm install -g webrcli
# Init a webrcli project
cd /tmp
webrcli init webrspongebob
```

```
👉 Initializing project ----
(This may take some time, please be patient)
👉 Copying template ----
👉 Installing {pkgload} ----
✅ {pkgload} downloaded and extracted ----

✅ {cli} downloaded and extracted ----

✅ {crayon} downloaded and extracted ----

✅ {desc} downloaded and extracted ----

✅ {fs} downloaded and extracted ----

✅ {glue} downloaded and extracted ----

✅ {pkgbuild} downloaded and extracted ----

✅ {rlang} downloaded and extracted ----

✅ {rprojroot} downloaded and extracted ----

✅ {withr} downloaded and extracted ----

✅ {R6} downloaded and extracted ----

✅ {callr} downloaded and extracted ----

✅ {processx} downloaded and extracted ----

✅ {ps} downloaded and extracted ----
```

The project is now created, let's move into it.

```bash
cd ./webrspongebob
tree -L 1
```

```
.
├── index.js
├── node_modules
├── package-lock.json
├── package.json
├── rfuns
└── webr_packages

4 directories, 3 files
```

Here is how it's organized:

+ `index.js` is the main file for the app, `node_modules` the standard folder for the node deps
+ `package-lock.json` / `package.json` are standard Node metadata files
+ `rfuns` contains the R package that will be added to the NodeJS app
+ `webr_packages` contains the R dependencies

We can launch the app with `node index.js` and it will output:

```
node index.js
👉 Loading WebR ----
👉 Loading R packages ----
ℹ Loading rfuns
[ 'Hello, world!' ]
✅ Everything is ready
```

Let's dive a bit inside the `index.js`:

```javascript
const path = require('path');
const { WebR } = require('webr');
const { loadPackages, LibraryFromLocalFolder } = require('spidyr');

const rfuns = new LibraryFromLocalFolder("rfuns");


(async () => {

  console.log("👉 Loading WebR ----");
  globalThis.webR = new WebR();
  await globalThis.webR.init();

  console.log("👉 Loading R packages ----");

  await loadPackages(
    globalThis.webR,
    path.join(__dirname, 'webr_packages')
  )

  await rfuns.mountAndLoad(
    globalThis.webR,
    path.join(__dirname, 'rfuns')
  );

  const hw = await rfuns.hello_world()

  console.log(hw.values);

  console.log("✅ Everything is ready!");

})();
```

Here are the bits that are specific to a `spidyr` project:

```javascript
const rfuns = new LibraryFromLocalFolder("rfuns");
```

This function will take a local folder containing an R package, and load the functions from this package into the `rfuns` object.
Here, for example, our R package contains one R function, `hello_world()`, it will then be available in NodeJS as `rfuns.hello_world()` once the `mountAndLoad` function is called.

```javascript
await loadPackages(
  globalThis.webR,
  path.join(__dirname, 'webr_packages')
)

await rfuns.mountAndLoad(
  globalThis.webR,
  path.join(__dirname, 'rfuns')
);
```

The first bit loads the `webr_packages` folder, containing all the R dependencies, then the second bit mount the local folder into the `webR` file system and load the functions.

Finally, `const hw = await rfuns.hello_world()` calls the function from the R package, and its value is `console.log`ed just after that.

### With a CRAN package

And now, how do I load a CRAN package? For example, let's say I want to use `{spongebob}` in my app?

First, let's install `{spongebob}` via `webrcli` :

```bash
webrcli install spongebob
```

```
✅ {spongebob} downloaded and extracted ----
```

Then, let's update our `index.js`:

```javascript
const path = require('path');
const { WebR } = require('webr');
const { loadPackages, LibraryFromLocalFolder, Library } = require('spidyr');

const rfuns = new LibraryFromLocalFolder("rfuns");
const spongebob = new Library("spongebob");

(async () => {

  console.log("👉 Loading WebR ----");
  globalThis.webR = new WebR();
  await globalThis.webR.init();

  console.log("👉 Loading R packages ----");

  await loadPackages(
    globalThis.webR,
    path.join(__dirname, 'webr_packages')
  )

  await rfuns.mountAndLoad(
    globalThis.webR,
    path.join(__dirname, 'rfuns')
  );

  await spongebob.load(
    globalThis.webR
  );

  const hw = await rfuns.hello_world()

  console.log(hw.values);

  const said = await spongebob.tospongebob("hello from spongebob")

  console.log(said.values)

  console.log("✅ Everything is ready!");;

})();
```

Here:

+ `const spongebob = new Library("spongebob");` will create a lib, ready to mount a package
+ `await spongebob.load(globalThis.webR)` will load all the functions from the `{spongebob}` package
+ `const said = await spongebob.tospongebob("hello from spongebob")` will run the `spongebob::tospongebob()` R function

Then :

```bash
node index.js
```

```
👉 Loading WebR ----
👉 Loading R packages ----
ℹ Loading rfuns
[ 'Hello, world!' ]
[ 'helLo fROm spONgEbOb' ]
✅ Everything is ready!
```

## Some random notes

The `webrspongebob` example is available at <https://github.com/ColinFay/webrspongebob>

### About the current implementation

- Right now I'm not really sure how this handles the infix function like `%>%` for example. That being said, this might not be a function you'd want to use in the current way of building things.

- The exported functions are read via `getNamespaceExports("pkg")` and `getExportedValue("pkg", "fun")`, if ever this is not the perfect way to do this in base R but I'll be happy to find some other ways to do this.

- `webrcli` and `spidyr` both encapsulate code run in `webR`, especially `webrcli` which has an [R script](https://github.com/ColinFay/webrcli/blob/main/rpkg/R/get_list_of_tar_gz_dependencies_for_package.R) which is sourced and run in a `webR` instance.

### Future

Please do try these tools. I would be very happy to have your feedback on the philosophy, and on the general workflow.

If ever you find a bug or have an idea, feel free to open issues.