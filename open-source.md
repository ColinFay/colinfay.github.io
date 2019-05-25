---
layout: single
permalink: /open-source/
---

<div class="row"> 
  <h2> <i class="fab fa-r-project"></i></h2>
</div> 

<div class="row"> 
  <h3> 
    <a href="https://github.com/ColinFay">
      <i class="fab fa-github"></i> /ColinFay 
    </a>
  </h3> 
  <div id = "colinthings"></div>
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
  <h2> <i class="fab fa-node-js"></i> </h2>
</div>


<div class="row"> 
  <h3> 
    <a href="https://github.com/ColinFay">
      <i class="fab fa-github"></i> /ColinFay 
    </a>
  </h3> 
  <div id = "nodejsthings"></div>
</div>

<script src="/assets/js/github_repo.js"></script>

<script>
/*Colinfay*/
var repos = ["attempt", "proustr", "backyard", "dockerfiler", "argh", "nessy", "tidystringdist",  "feathericons", "craneur", "skeleton", "geoloc",  "handydandy", "fryingpane", "wtfismyip"]

for (var i = 0; i < repos.length; i++){
  add_repo("ColinFay", repos[i], "colinthings", "package")
}

/*thinkr*/
var repos = ["golem", "shinipsum", "remedy", "fakir", "shinysnippets", "testdown", "frankenstein"]

for (var i = 0; i < repos.length; i++){
  add_repo("Thinkr-open", repos[i], "thinkrthings", "package")
}

/*nodejs*/
var repos = ["ronline"]

for (var i = 0; i < repos.length; i++){
  add_repo("ColinFay", repos[i], "nodejsthings", "web")
}

</script>
