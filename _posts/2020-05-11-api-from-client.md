---
title: "Fetch API Results from the Browser and send them to Shiny"
post_date: 2020-05-11
layout: single
permalink: /api-from-client-shiny/
categories: r-blog-en
output: jekyllthat::jekylldown
excerpt_separator: <!--more-->
---

How to fetch API results from client-side in a Shiny app and send them
to R.

## Why on earth?

Good question\! Why on earth would you want your Shiny application to
make API requests from the User Interface (i.e. from the browser)? Right
now, if your application makes API calls, chances are that you have
being doing them straight from R, and that it works pretty well. But in
some cases it might not be the correct implementation, notably if the
API limits requests based on an IP and your application gets a lot of
traffic. For example, Brewdog’s [PUNK API](https://punkapi.com/) limits
to one call per IP per second. In that scenario, if the calls are made
from the server, you will only be able to serve one call per second, and
if your users do a lot of API call at the same time, they will be slowed
down, as the server’s IP is limited to 1 call per second. On the other
end, if the API call is made from the users’ browsers, the server IP is
no longer limited: each user has its own limitation.

## How to

You can write API calls using the `fetch()` JavaScript function. It can
then be used inside a Shiny JavaScript handler, or as a response to a
DOM event (for example, with `tags$button("Get Me One!", onclick =
"get_rand_beer()")`, as we will see below).

Here is the general skeleton, that would work when the API does not need
authentication and returns JSON.

  - Inside JavaScript (here, we create a function that will be available
    on an `onclick` event)

<!-- end list -->

``` javascript
// JAVASCRIPT FUNCTION DEFINITION
const get_rand_beer = () => {
    // FETCHING THE API DATA
    fetch("https://api.punkapi.com/v2/beers/random")
      // DEFINE WHAT HAPPENS WHEN JAVASCRIPT RECEIVES THE DATA
      .then((data) =>{
        // CONVERT THE DATA TO JSON
        data.json().then((res) => {
          // SEND THE JSON TO R
          Shiny.setInputValue("beer", res, {priority: 'event'})
        })
        // DEFINE WHAT HAPPENS WHEN THERE IS AN ERROR TURNING DATA TO JSON
        .catch((error) => {
          alert("Error catchin result from API")
        })
      })
      // DEFINE WHAT HAPPENS WHEN THERE IS AN ERROR FETCHING THE API
      .catch((error) => {
        alert("Error catchin result from API")
      })
  };
```

  - Observe the event in your server:

<!-- end list -->

``` r
observeEvent( input$beer , {
  # Do things with input$beer
})
```

And here it is, when the users click on the button, the API calls will
be made from their browser, and then sent back to the server.

Note that the data shared between R and JavaScript is serialized to
JSON, so you will have to manipulate that format once you receive it in
R.

See an example at
[ColinFay/punkapi](https://github.com/ColinFay/punkapi)
