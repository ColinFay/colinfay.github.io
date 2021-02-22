---
layout: single
permalink: /open-source/
---

<link rel="stylesheet" type="text/css" href="/assets/css/osgridfolio.css">

<div class="row"> 
  <h2> <i class="fab fa-r-project"></i> - R Projects</h2>
</div> 

<div class="row"> 
  <h3> 
    <a href="https://github.com/ColinFay">
      <i class="fab fa-github"></i> /ColinFay 
    </a>
  </h3> 
  <div id = "colinthings" class = "drdre"></div>
</div>


<hr>

<div class="row"> 
  <h3> 
    <a href="https://github.com/Thinkr-open">
      <i class="fab fa-github"></i> /Thinkr-open 
    </a>
  </h3> 
  <div id = "thinkrthings"></div>
</div>

<hr>

<div class="row"> 
  <h2> <i class="fab fa-node-js"></i> - JavaScript & NodeJS Projects</h2>
</div>


<div class="row"> 
  <h3> 
    <a href="https://github.com/ColinFay">
      <i class="fab fa-github"></i> /ColinFay 
    </a>
  </h3> 
  <div id = "jsthings"></div>
</div>

<div class="row"> 
  <h2> <i class="fab fa-docker"></i> - Docker Projects</h2>
</div>



<div class="row"> 
  <h3> 
    <a href="https://github.com/ColinFay">
      <i class="fab fa-github"></i> /ColinFay 
    </a>
  </h3> 
  <div id = "dockerthings"></div>
</div>

<script src="/assets/js/github_repo.js"></script>

<script>
/*Colinfay*/
var repos = ["ColinFay/attempt", 
  "ColinFay/brochure", 
  "ColinFay/bubble", 
  "ColinFay/minifyr", 
  "ColinFay/crrry", 
  "ColinFay/noon", 
  "ColinFay/hexmake", 
  "ColinFay/glouton", 
  "ColinFay/dockerfiler", 
  "ColinFay/dockerstats", 
  "ColinFay/darkmode", 
  "ColinFay/nessy", 
  "ColinFay/chuck",  
  "ColinFay/feathericons", 
  "ColinFay/craneur", 
  "ColinFay/skeleton", 
  "ColinFay/geoloc",  
  "ColinFay/handydandy", 
  "ColinFay/fryingpane",
  ]
    
add_repos(repos, "colinthings")

/*thinkr*/
var repos = [
  "Thinkr-open/golem", 
  "Thinkr-open/shinipsum",
  "Thinkr-open/remedy",
  "Thinkr-open/fakir",
  "Thinkr-open/shinysnippets", 
  "Thinkr-open/testdown", 
  "Thinkr-open/frankenstein"
  ]

add_repos(repos, "thinkrthings")


/*nodejs*/

var repos = [
  "ColinFay/ronline",
  "ColinFay/osgridfolio",
  "ColinFay/hordes",
  "ColinFay/mdlinks"
  ]
  
add_repos(repos, "jsthings")

/*docker*/
var repos = [
  "ColinFay/r-ci", 
  "ColinFay/r-db", 
  "ColinFay/clientsdb", 
  "neo4j-rstats/neo4r-docker"
  ]

  
add_repos(repos, "dockerthings")

</script>
