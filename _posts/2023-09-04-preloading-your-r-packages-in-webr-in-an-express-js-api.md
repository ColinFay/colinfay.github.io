---
title: "Preloading your R packages in webR in an Express JS API"
post_date: 2023-09-07
layout: single
permalink: /preloading-your-r-packages-in-webr-in-an-express-js-api/
categories: r-blog-en
output: jekyllthat::jekylldown
excerpt_separator: <!--more-->
---

This post is the third one of a series of post about webR:

+ [Using webR in an Express JS REST API](/calling-webr-from-expressjs/)
+ [The Old Faithful Geyser Data shiny app with webR, Bootstrap & ExpressJS](/old-faithful-express-bootstrap-webr/)
+ Preloading your R packages in webR in an Express JS API

> Note: the first post of this series explaining roughly what webR is, I won't introduce it again here.

> Note 2 (or Disclaimer): this is kind of a long post that get into the weeds of package installation and library structure

## The problem

In the two last posts, I've been deploying two REST APIs that use functions from the base distribution of R:

+ `tools::toTitleCase()` in <a href = "https://srv.colinfay.me/express-webr-hello-world" target = "_blank">express-webr-hello-world</a>
+ `cut()` & `faithful` for <a href = "https://srv.colinfay.me/express-webr-old-faithful/" target = "_blank">express-webr-old-faithful</a>

One of the strengths of the R ecosystem is its extensive list of contributed packages: a wide collection of code written by R nerds from all over the world.
It would be unfortunate to use `webR` to create a web applications or API without taking advantage of this extensive library of packages: R wouldn't be R without its packages.

Yet, bringing packages to `webR` is not that simple: it's a distribution of R compiled for WASM, and you can't just install a package from any CRAN repo.

Thankfully we don't need to scratch our head too much anymore: the `webR` team has precompiled more than 18000 (at the time of writing this post) packages that we can install by simply calling `webr::install()` inside the `webR` instance.

That's awesome, but there's an issue with that: you can only install it from the `webR` JavaScript object
As far as I know, there is no way to download them beforehand and upload them to the `webR` filesystem, as I reported in <a href = "https://github.com/r-wasm/webr/issues/260" target = "_blank">this issue</a>.
(Note: at the time of writing these lines, there has been some discussion on the GH issue, but there is at the moment no native, efficient way to do what I want to do 😅 — there might be one though if you're reading this post in the future).

That means that every time the API is launched, `webR` has to download and reinstall the packages, as shown by this simple example:

```javascript
const app = require('express')()
const { WebR } = require('webr');

(async () => {
  globalThis.webR = new WebR();
  await globalThis.webR.init();
  await globalThis.webR.installPackages(['attempt'])
  app.listen(3000, '0.0.0.0', () => {
    console.log('http://localhost:3000')
  })
})();


app.get('/', async (req, res) => {
  res.send("hello")
});
```

If I launch the app twice, the packages are downloaded twice 👇

```bash
$ node index.js
webR is ready
Downloading webR package: rlang

Downloading webR package: attempt

http://localhost:3000

$ node index.js
webR is ready
Downloading webR package: rlang

Downloading webR package: attempt

http://localhost:3000
```

This approach is definitely suboptimal: imagine having to reinstall packages every time you `source()` an R script, instead of benefiting from pre-installed packages in your lib.
That's kind of what is happening right now in this `webR` example.

Sure, it works, but it means that:

- I'm downloading the (same) packages every time the app is launched, which feels weird
- If I have a lot of packages, it would take a lot of time every time
- I can't deploy this on a service that has no access to internet
- I can't build my app just as any other language does: by relying on pre-downloaded /pre-installed modules
- I can't benefit from caching the package installation in a Docker layer

So, faced with something I needed but didn't find, I behave like any other software engineer: I built my own solution to pre-load R packages in `webR`, without having to re-download them every time.
The rest of this blogpost explains this process.

## Preloading R packages in my ExpressJS/webR API

### Building the R lib

If you look at the internal of the folder on your computer that contains your packages (which is at `.libPaths()`), you'll see that it's a series of folders with a bunch of files.
Whenever you load R and call `library()`, it looks there to load the code.

Inside these folders (you can have several lib), you'll find unzipped archives, downloaded from a repository (or installed from git/developed locally).
These packages, at installation time, possibly performed some build and compilation, depending on the package and the OS you're on.
I won't go into the details of this here, as the packages for webR have been pre-compiled, meaning that you simply have to download the tar file, and unarchive it at the correct place.
In other words, the content of this archive is exactly what you'll find in the library folder, and there is nothing to compile/install again.

Keeping this in mind, the first thing to do then is to create a folder that will contain all the folders and files necessary to load a package.
In other words, if I want to use `{dplyr}`, I need to find a way to download the pre-compiled version of `{dplyr}` and all its dependencies from `https://repo.r-wasm.org/`, and untar them into the folder I wanna use inside my project.

R has a weird way of managing packages, and if ever you want to hear me monologue, catch me at a conference and ask me to talk about this for 30 minutes (just kidding, it will probably last one hour).
I won't go into details about how it works and why it's weird, but here are some issues I've been facing for my current task:

- By default R will not reinstall the dependencies if they are already installed on the machine. Which is great, but not in my case (I want the destination folder to contain the entire dependency tree). In other words, if I do `install.packages("dplyr", lib="webr_packages")`, R will only download the packages that are not already on my computer.

- There is no (sane) way to avoid the default library. So basically unless you're ready to write hacky code that will override the library environments and stuff, R will always look into the default lib. There is an old issue on the <a href = "https://github.com/r-lib/withr/issues/122" target = "_blank">`{withr}` repo </a> if you want to look into this, but basically the idea is that avoiding default lib is quite a challenge.

- That means that if I try to do something as simple as `install.packages("dplyr", lib="webr_packages", repos = "https://repo.r-wasm.org/")`, it will only install `{dplyr}`, given that all the other dependencies already exist on my machine :

```r
> setwd(tempdir())
> dir.create("webr_packages")
> install.packages("dplyr", lib="webr_packages", repos = "https://repo.r-wasm.org/")
# [...TRUNCATED]
* DONE (dplyr)
> list.files("webr_packages/")
[1] "dplyr"
```

I've tried the following:

+ Hacking `.lib.loc` as suggest by Andrie <a href = "https://stackoverflow.com/a/36873741">here</a>, but it comes with a series of challenges like not having access to other packages and having to reinstall them and load them to the webR FileSystem which is not what I wanted.

+ Using `{renv}` but it feels a bit overkill for what I'm trying to do: download a bunch of zip files from the internet and unzip them in the correct folder. Also, `{renv}` failed to parse the dep tree in a NodeJS project for some reasons.

So I've ended up with my own R script, inspired by the internal of `install.packages` and `webr::install` (<a href = "https://blog.codinghorror.com/learn-to-read-the-source-luke/">Read the source, Luke</a>).
I've first explored a version with `{pak}` and `{pkgdepends}`, but ended up using a base solution so that I don't have to install anything in the Docker container.

```r
#!/usr/bin/env Rscript

# This script only works if you pass it at least one arg
if (is.na(commandArgs(trailingOnly = TRUE)[1])) {
  stop("This script requires at least one argument")
} else {
  pk_to_install <- commandArgs(trailingOnly = TRUE)[1]
}

# If no second value, defaulting to webr_packages
if (is.na(commandArgs(trailingOnly = TRUE)[2])) {
  path_to_installation <- "./webr_packages"
} else {
  path_to_installation <- commandArgs(trailingOnly = TRUE)[2]
}

# Build the repos url
repos <- sprintf(
  "https://repo.r-wasm.org/bin/emscripten/contrib/%s.%s",
  # Get major R version
  R.version$major,
  substr(R.version$minor, 1, 1)
)

deps <- unique(
  unlist(
    use.names = FALSE,
    tools::package_dependencies(
      recursive = TRUE,
      pk_to_install
    )
  )
)

# Now the package list
pkg_deps <- c(
  pk_to_install,
  deps
)

# I don't want to re-download things so I'm listing all the already
# downloaded folders
already_installed <- list.files(
  path_to_installation
)

# Getting the list of available package
info <- utils::available.packages(contriburl = repos)

# Now we can install
for (pkg in pkg_deps){
  # Don't redownload things
  if (pkg %in% already_installed) {
    message("Package ", pkg, " already installed")
    next
  }
  # Not available: either it's not on the repo or it's included
  # in the base distribution of R
  if (!(pkg %in% info[, "Package"])) {
    message("Package {", pkg, "} not found in repo (unavailable or is base package)")
    next
  }
  message("Installing ", pkg)
  # Name of the targz, should be on the form of pkg_version.this.that.tgz
  targz_file <- paste0(pkg, "_", info[info[, "Package"] == pkg, "Version"], ".tgz")
  # Location of file on the repo
  url <- paste0(repos, "/", targz_file)
  # Download the file and untar the archive on the local lib
  tmp <- tempfile(fileext = ".tgz")
  download.file(url, destfile = tmp)
  untar(tmp, exdir = path_to_installation)
  unlink(tmp)
}

message("Done")
```

And now, let's try this:

```bash
mkdir webr_packages
script tools/installR.r attempt
✔ Loading metadata database ... done
Installing attempt
trying URL 'https://repo.r-wasm.org/bin/emscripten/contrib/4.3/attempt_0.3.1.tgz'
Content type 'application/x-tar' length 93561 bytes (91 KB)
==================================================
downloaded 91 KB

Installing rlang
trying URL 'https://repo.r-wasm.org/bin/emscripten/contrib/4.3/rlang_1.1.1.tgz'
Content type 'application/x-tar' length 1062482 bytes (1.0 MB)
==================================================
downloaded 1.0 MB

Done

Rscript -e "fs::dir_tree('webr_packages')"
webr_packages
├── attempt
│   ├── DESCRIPTION
│   ├── INDEX
│   ├── LICENSE
│   ├── Meta
│   │   ├── Rd.rds
│   │   ├── features.rds
│   │   ├── hsearch.rds
│   │   ├── links.rds
│   │   ├── nsInfo.rds
│   │   ├── package.rds
│   │   └── vignette.rds
│   ├── NAMESPACE
│   ├── NEWS.md
│   ├── R
│   │   ├── attempt
│   │   ├── attempt.rdb
│   │   └── attempt.rdx
│   ├── doc
│   │   ├── a_intro_attempt.R
│   │   ├── a_intro_attempt.Rmd
│   │   ├── a_intro_attempt.html
│   │   ├── b_try_catch.R
│   │   ├── b_try_catch.Rmd
│   │   ├── b_try_catch.html
│   │   ├── c_adverbs.R
│   │   ├── c_adverbs.Rmd
│   │   ├── c_adverbs.html
│   │   ├── d_if.R
│   │   ├── d_if.Rmd
│   │   ├── d_if.html
│   │   ├── e_conditions.R
│   │   ├── e_conditions.Rmd
│   │   ├── e_conditions.html
│   │   └── index.html
│   ├── help
│   │   ├── AnIndex
│   │   ├── aliases.rds
│   │   ├── attempt.rdb
│   │   ├── attempt.rdx
│   │   └── paths.rds
│   └── html
│       ├── 00Index.html
│       └── R.css
└── rlang
    ├── DESCRIPTION
    ├── INDEX
    ├── LICENSE
    ├── Meta
    │   ├── Rd.rds
    │   ├── features.rds
    │   ├── hsearch.rds
    │   ├── links.rds
    │   ├── nsInfo.rds
    │   └── package.rds
    ├── NAMESPACE
    ├── NEWS.md
    ├── R
    │   ├── rlang
    │   ├── rlang.rdb
    │   └── rlang.rdx
    ├── backtrace-ver
    ├── help
    │   ├── AnIndex
    │   ├── aliases.rds
    │   ├── figures
    │   │   ├── lifecycle-archived.svg
    │   │   ├── lifecycle-defunct.svg
    │   │   ├── lifecycle-deprecated.svg
    │   │   ├── lifecycle-experimental.svg
    │   │   ├── lifecycle-maturing.svg
    │   │   ├── lifecycle-questioning.svg
    │   │   ├── lifecycle-retired.svg
    │   │   ├── lifecycle-soft-deprecated.svg
    │   │   ├── lifecycle-stable.svg
    │   │   ├── lifecycle-superseded.svg
    │   │   └── logo.png
    │   ├── paths.rds
    │   ├── rlang.rdb
    │   └── rlang.rdx
    ├── html
    │   ├── 00Index.html
    │   └── R.css
    └── libs
        └── rlang.so
```

Woot woot, seems to work 🎉.

### Moving everything to the webR lib when the API is launched

And now, challenge number two: rebuilding this library in the `webR` filesystem.

`webR` has an interface to WASM filesystem (aka Emscripten Virtual File System), exposed via `FS` (<a href = "https://docs.r-wasm.org/webr/latest/api/js/interfaces/WebR.WebRFS.html">doc is here</a>).
This interface allows to create a directory and write a file, which are the two things we want to do here:

- Create the package folders/subfolders
- Copy the files from the local machine (contained in a `./webr_packages` folder) into the `webR` filesystem when launching the Node API.

#### Creating the directory tree

Creating a directory tree is not an easy task — it implies recursive function, keeping track of parents, and other weird things.
R has `list.files(recursive = TRUE)` and we should be VERY happy about it: I looked on the internet and apparently there is no native way to do that in Node, you have to do it by hand.

As any sane modern JavaScript developer would do, I asked chatGPT to do it for me.
It took me several iterations before getting the exact answer I was looking for but here it is:

```javascript
const fs = require('fs');
const path = require('path');

// comments are mine

// Recursive function to get files, thank you chatGPT
function getDirectoryTree(dirPath, currentPath = '') {
  // Get a list of all the files/folders in the currently inspected folder
  const items = fs.readdirSync(path.join(dirPath, currentPath));
  // output
  const tree = [];

  // Looping on all the files/folders
  for (const item of items) {
    // Inspecting the item
    const itemPath = path.join(dirPath, currentPath, item);
    const isDirectory = fs.statSync(itemPath).isDirectory();
    const relativePath = path.join(currentPath, item);

    if (isDirectory) {
      // If it's a directory, we'll go inside and repeat the
      // current mechanism
      const subtree = getDirectoryTree(dirPath, relativePath);
      // pushing the current item, and its subtree
      tree.push({ path: relativePath, type: 'directory' });
      tree.push(...subtree);
    } else {
      tree.push({ path: relativePath, type: 'file' });
    }
  }
  // Getting the tree
  return tree;
}
```

Here is what it looks like on our `./webr_packages` folder from before:

```javascript
> getDirectoryTree("webr_packages")
[
  { path: 'attempt', type: 'directory' },
  { path: 'attempt/DESCRIPTION', type: 'file' },
  { path: 'attempt/INDEX', type: 'file' },
  { path: 'attempt/LICENSE', type: 'file' },
  { path: 'attempt/Meta', type: 'directory' },
  { path: 'attempt/Meta/Rd.rds', type: 'file' },
  { path: 'attempt/Meta/features.rds', type: 'file' },
  { path: 'attempt/Meta/hsearch.rds', type: 'file' },
  { path: 'attempt/Meta/links.rds', type: 'file' },
  { path: 'attempt/Meta/nsInfo.rds', type: 'file' },
  { path: 'attempt/Meta/package.rds', type: 'file' },
  { path: 'attempt/Meta/vignette.rds', type: 'file' },
  { path: 'attempt/NAMESPACE', type: 'file' },
  { path: 'attempt/NEWS.md', type: 'file' },
  { path: 'attempt/R', type: 'directory' },
  { path: 'attempt/R/attempt', type: 'file' },
  { path: 'attempt/R/attempt.rdb', type: 'file' },
  { path: 'attempt/R/attempt.rdx', type: 'file' },
  { path: 'attempt/doc', type: 'directory' },
  { path: 'attempt/doc/a_intro_attempt.R', type: 'file' },
  { path: 'attempt/doc/a_intro_attempt.Rmd', type: 'file' },
  { path: 'attempt/doc/a_intro_attempt.html', type: 'file' },
  { path: 'attempt/doc/b_try_catch.R', type: 'file' },
  { path: 'attempt/doc/b_try_catch.Rmd', type: 'file' },
  { path: 'attempt/doc/b_try_catch.html', type: 'file' },
  { path: 'attempt/doc/c_adverbs.R', type: 'file' },
  { path: 'attempt/doc/c_adverbs.Rmd', type: 'file' },
  { path: 'attempt/doc/c_adverbs.html', type: 'file' },
  { path: 'attempt/doc/d_if.R', type: 'file' },
  { path: 'attempt/doc/d_if.Rmd', type: 'file' },
  { path: 'attempt/doc/d_if.html', type: 'file' },
  { path: 'attempt/doc/e_conditions.R', type: 'file' },
  { path: 'attempt/doc/e_conditions.Rmd', type: 'file' },
  { path: 'attempt/doc/e_conditions.html', type: 'file' },
  { path: 'attempt/doc/index.html', type: 'file' },
  { path: 'attempt/help', type: 'directory' },
  { path: 'attempt/help/AnIndex', type: 'file' },
  { path: 'attempt/help/aliases.rds', type: 'file' },
  { path: 'attempt/help/attempt.rdb', type: 'file' },
  { path: 'attempt/help/attempt.rdx', type: 'file' },
  { path: 'attempt/help/paths.rds', type: 'file' },
  { path: 'attempt/html', type: 'directory' },
  { path: 'attempt/html/00Index.html', type: 'file' },
  { path: 'attempt/html/R.css', type: 'file' },
  { path: 'rlang', type: 'directory' },
  { path: 'rlang/DESCRIPTION', type: 'file' },
  { path: 'rlang/INDEX', type: 'file' },
  { path: 'rlang/LICENSE', type: 'file' },
  { path: 'rlang/Meta', type: 'directory' },
  { path: 'rlang/Meta/Rd.rds', type: 'file' },
  { path: 'rlang/Meta/features.rds', type: 'file' },
  { path: 'rlang/Meta/hsearch.rds', type: 'file' },
  { path: 'rlang/Meta/links.rds', type: 'file' },
  { path: 'rlang/Meta/nsInfo.rds', type: 'file' },
  { path: 'rlang/Meta/package.rds', type: 'file' },
  { path: 'rlang/NAMESPACE', type: 'file' },
  { path: 'rlang/NEWS.md', type: 'file' },
  { path: 'rlang/R', type: 'directory' },
  { path: 'rlang/R/rlang', type: 'file' },
  { path: 'rlang/R/rlang.rdb', type: 'file' },
  { path: 'rlang/R/rlang.rdx', type: 'file' },
  { path: 'rlang/backtrace-ver', type: 'file' },
  { path: 'rlang/help', type: 'directory' },
  { path: 'rlang/help/AnIndex', type: 'file' },
  { path: 'rlang/help/aliases.rds', type: 'file' },
  { path: 'rlang/help/figures', type: 'directory' },
  { path: 'rlang/help/figures/lifecycle-archived.svg', type: 'file' },
  { path: 'rlang/help/figures/lifecycle-defunct.svg', type: 'file' },
  { path: 'rlang/help/figures/lifecycle-deprecated.svg', type: 'file' },
  { path: 'rlang/help/figures/lifecycle-experimental.svg',type: 'file'},
  { path: 'rlang/help/figures/lifecycle-maturing.svg', type: 'file' },
  { path: 'rlang/help/figures/lifecycle-questioning.svg',type: 'file'},
  { path: 'rlang/help/figures/lifecycle-retired.svg', type: 'file' },
  { path: 'rlang/help/figures/lifecycle-soft-deprecated.svg',type: 'file'},
  { path: 'rlang/help/figures/lifecycle-stable.svg', type: 'file' },
  { path: 'rlang/help/figures/lifecycle-superseded.svg', type: 'file' },
  { path: 'rlang/help/figures/logo.png', type: 'file' },
  { path: 'rlang/help/paths.rds', type: 'file' },
  { path: 'rlang/help/rlang.rdb', type: 'file' },
  { path: 'rlang/help/rlang.rdx', type: 'file' },
  { path: 'rlang/html', type: 'directory' },
  { path: 'rlang/html/00Index.html', type: 'file' },
  { path: 'rlang/html/R.css', type: 'file' },
  { path: 'rlang/libs', type: 'directory' },
  { path: 'rlang/libs/rlang.so', type: 'file' }
]
```

> Note: I need all the folders and subfolders, for example rlang/libs and rlang/libs/rlang.so, because I haven't found a way to do a recursive mkdir in webR, and had to create all children level by level.

🚀 Yeay 🚀

Now I have a JavaScript object I can use to move my `./webr_packages` library to a `webR` instance library.

Let's write a function for that (no need for chatGPT here 😅):

```javascript
async function loadPackages(webR, dirPath){
  // Our function from before
  const files = getDirectoryTree(
    dirPath
  )
  for await (const file of files) {
    // If the entry is a directory, we'll
    // call mkdir
    if (file.type === 'directory') {
      await globalThis.webR.FS.mkdir(
        `/usr/lib/R/library/${file.path}`,
      );
    } else {
    // case 2, the entry is a file, then we can use fs.readFileSync
    // That will return a ArrayBuffer that can be directly passed
    // to webR.FS.writeFile
      const data = fs.readFileSync(`webr_packages/${file.path}`);
      await globalThis.webR.FS.writeFile(
        `/usr/lib/R/library/${file.path}`,
        data
      );
    }
  }
}
```

Now we have our whole process:

- downloading the precompiled packages
- listing the dir tree in Node
- bringing everything into the `webR` filesystem

🚀 Yeay (bis) 🚀

To make things simple, I have put these into a node package, at <a href = "https://www.npmjs.com/package/webrtools" target = "_blank">npmjs.com/package/webrtools</a>.

### Bringing everything together

Workflow for building the app:

```bash
cd webr-example
mkdir webr-preloadr
cd webr-preloadr
npm init -y
npm install express webr webrtools
Rscript ./node_modules/webrtools/r/install.R dplyr
touch index.js
```

Then :

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

  console.log("📦 Packages written to webR 📦");

  const res = await globalThis.webR.FS.lookupPath("/usr/lib/R/library");
  console.log(res)

  await globalThis.webR.evalR("library(dplyr)");
  app.listen(3000, '0.0.0.0', () => {
    console.log('http://localhost:3000')
  })
})();


app.get('/', async (req, res) => {
  let result = await globalThis.webR.evalR('sample_n(mtcars, 10)');
  let output = await result.toJs();
  res.send(output.values)
});
```

```bash
node index.js
```

And in another console:

```bash
$ curl http://localhost:3000
[{"type":"double","names":null,"values":[21,24.4,14.3,32.4,18.7,17.8,22.8,10.4,30.4,21.4]},{"type":"double","names":null,"values":[6,4,8,4,8,6,4,8,4,4]},{"type":"double","names":null,"values":[160,146.7,360,78.7,360,167.6,108,460,75.7,121]},{"type":"double","names":null,"values":[110,62,245,66,175,123,93,215,52,109]},{"type":"double","names":null,"values":[3.9,3.69,3.21,4.08,3.15,3.92,3.85,3,4.93,4.11]},{"type":"double","names":null,"values":[2.62,3.19,3.57,2.2,3.44,3.44,2.32,5.424,1.615,2.78]},{"type":"double","names":null,"values":[16.46,20,15.84,19.47,17.02,18.9,18.61,17.82,18.52,18.6]},{"type":"double","names":null,"values":[0,1,0,1,0,1,1,0,1,1]},{"type":"double","names":null,"values":[1,0,0,1,0,0,1,0,1,1]},{"type":"double","names":null,"values":[4,4,3,4,3,4,4,3,4,4]},{"type":"double","names":null,"values":[4,2,4,1,2,4,1,4,2,2]}]
```

🚀 Yeay (ter) 🚀

### And now for the Dockerfile

```Dockerfile
FROM r-base:4.3.1

# Create app directory
WORKDIR /usr/src/app

RUN apt update && \
  apt install nodejs npm -y

COPY package*.json ./

RUN npm install

RUN Rscript ./node_modules/webrtools/r/install.R dplyr

COPY . .

EXPOSE 3000

CMD [ "node", "index.js" ]
```

You can find the code [here](https://github.com/ColinFay/webr-examples/tree/main/webr-preloadr), and see it live at [srv.colinfay.me/webr-preloadr](https://srv.colinfay.me/webr-preloadr/).

You can also try it with

```bash
docker run -it -p 3000:3000 colinfay/webr-preloadr
```

## Final notes

### Should I use it in prod?

Probably not — for now it's more of an experiment than a real bullet-proof approach.
But if you're a reader from the future, many things may have happen, and maybe the `webrtools` node module is now prod ready.
Who knows!

### Further work

After some discussion on the issue on the `webR` repo, it seems that a promising path to do what I'd like to do is to use the <a href = "https://emscripten.org/docs/api_reference/Filesystem-API.html#FS.mount" target = "_blank">`FS.mount` interface from WASM</a>, but it needs to be expose by `webR`.
Keep an eye on the repo!

Finally, I'm a bit displeased with writing the installR fun in R and having to install R in the `Dockerfile` to do it, so I should probably re-write it in full NodeJS.
We could read the package tree in R with `webR` and then download/untar with Node.

Food for thoughts.