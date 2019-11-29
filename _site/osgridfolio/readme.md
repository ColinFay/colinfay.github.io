# osgridfolio

A dead simple grid portfolio to display your GitHub project. 

To add this grid porfolio, add a div with an id that will receive the portfolio, then call `add_repos(repos, "ID")` to fill it.

You'll need to add the `osgridfolio.css` and `osgridfolio.js` files to your page.

```
<head>
  <meta charset="utf-8">
  <title></title>
  <meta name="author" content="">
  <meta name="description" content="">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" type="text/css" href="osgridfolio.css">
</head>

<body>

  <p>Hello, world!</p>
  
  <div id = "colinthings"></div>

  <script src="osgridfolio.js"></script>
  <script>
    var repos = ["ColinFay/attempt", 
    "ColinFay/proustr", 
    "ColinFay/backyard", 
    "ColinFay/dockerfiler", 
    "ColinFay/argh", 
    "ColinFay/nessy", 
    "ColinFay/tidystringdist",  
    "ColinFay/feathericons", 
    "ColinFay/craneur", 
    "ColinFay/skeleton", 
    "ColinFay/geoloc",  
    "ColinFay/handydandy", 
    "ColinFay/fryingpane", 
    "ColinFay/wtfismyip"]
    
    add_repos(repos, "colinthings")
  </script>
</body>

</html>
```

## Under MIT Licence