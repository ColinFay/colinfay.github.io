---
title: "Use R & Git as a Workout planner"
post_date: 2020-04-20
layout: single
permalink: /r-git-workout-planner/
categories: r-blog-en
output: jekyllthat::jekylldown
excerpt_separator: <!--more-->
---

Over the years, I’ve been trying a bunch a different applications and
methods to stay motivated to workout. But every time it’s the same: at
some point the application is great but limited if you do not pay, or
the workouts are repetitive, or simply I can’t get into the habit of
using the application.

What if there were a solution that is free, where exercises can be
generated at random so that it’s not too repetitive, and that I can fit
into my “natural workflow” when it come to creating and keeping track of
tasks?

So here’s a new idea: what if I can use R to generate random workout,
and then use GitHub issues as a tracker and checklist?

> Note: obviously I’m neither a profesional athlete (in case you haven’t
> met me before), nor a professional trainer, so in case this needs to
> be said, please use these for recreational workouts, and with care
> (and of course at your own risk).

## Random workouts

First of all, I need a workout database, with the following elements:

  - type of workout (bodyweight/kettlebells/abs/dumbbells/resistance
    band…)
  - the description
  - a value to track the timing or number of repetitions
  - the unit of this value
  - a complexity factor so that I can plan harder workouts when I feel
    like it
  - something to say if it’s “outside friendly”: for example I can’t do
    jumping rope inside, nor some kettlebell movements

For now that I will just be doing it manually, maybe at some point I
will scrape an online resource, but that’s an idea for another blogpost.
The idea is to come with this kind of table:

``` r
tibble::tribble(
  ~type,        ~description,  ~val,   ~unit, ~complexity, ~inside,
  "Jumping rope", "Jumping Rope", 100, "jump", 1, FALSE,
  "Bodyweight",   "Plank", 45, "seconds", 1, TRUE 
)
```

``` 
# A tibble: 2 x 6
  type         description    val unit    complexity inside
  <chr>        <chr>        <dbl> <chr>        <dbl> <lgl> 
1 Jumping rope Jumping Rope   100 jump             1 FALSE 
2 Bodyweight   Plank           45 seconds          1 TRUE  
```

Given that I want to add manual exercises (the one I know how to do, and
like to do), I’ll do this manually in a CSV file.

``` r
worrkout::wk
```

    # A tibble: 27 x 7
       type    description      val unit    complexity inside pics                  
       <chr>   <chr>          <dbl> <chr>        <dbl> <lgl>  <chr>                 
     1 Jumpin… "Jumping Rope"   100 jump             1 FALSE  https://mir-s3-cdn-cf…
     2 Bodywe… "Plank"           45 seconds          1 TRUE   https://thumbs.gfycat…
     3 Bodywe… "Squat"           16 x                1 TRUE   https://thumbs.gfycat…
     4 Bodywe… "Lunge"           16 x / ea…          1 TRUE   https://media0.giphy.…
     5 Bodywe… "Single-Leg B…    16 x / ea…          1 TRUE   https://thumbs.gfycat…
     6 Bodywe… "Glute Bridge"    16 x / ea…          1 TRUE   https://thumbs.gfycat…
     7 Bodywe… "Plyo Lunge"      16 x / ea…          1 TRUE   https://media.giphy.c…
     8 Bodywe… "Mountain Cli…    16 x / ea…          1 TRUE   https://media1.tenor.…
     9 Kettle… "Russian Twis…    16 x                1 TRUE   https://thumbs.gfycat…
    10 Bodywe… "Leg Lift"        16 x                1 TRUE   https://thumbs.gfycat…
    # … with 17 more rows

Then, I’ll need a function to sample some of the exercises, repeat twice
(I like to do two cycles of the same series of exercises), then create
the text for the issue.

This text for the issue should look like this:

    + [ ] KettleBell - Russian Twist (16 x)
    
    <div align = 'center'><img src ='url' width = '400px'> </img></div>

So that way, I can check the ToDos, and also see a gif of the movement
(well, some gif are more for fun ;) )

``` r
generate_workout <- function(
  n_workout,
  complexity = 1, 
  outside = FALSE
){
  # Read the dataset, and remove its NA
  wk <- worrkout::wk
  wk <- tidyr::drop_na(wk, 1:6)
  
  # We want `n_workout`, which is 2 cycles of exercises
  wk <- dplyr::sample_n(wk, floor(n_workout / 2)) 
  wk <- dplyr::bind_rows(wk, wk)
  
  # If we want to get more difficulty
  wk$complexity <- wk$complexity * complexity
  
  # Generate the output
 body <- sprintf(
    "+ [ ] %s - %s (%s %s) \n\n <div align = 'center'><img src ='%s' width = '400px'> </img></div>",
    wk$type,
    wk$description,
    wk$val,
    wk$unit,
    wk$pics
  )
  paste0(body, collapse = "\n\n")
}
cat(generate_workout(4))
```

    + [ ] Bodyweight - Leg Lift (16 x) 
    
     <div align = 'center'><img src ='https://thumbs.gfycat.com/SickBrownIsabellinewheatear-max-1mb.gif' width = '400px'> </img></div>
    
    + [ ] KettleBell - Goblet squat (16 x) 
    
     <div align = 'center'><img src ='https://www.sport-equipements.fr/wp-content/uploads/2019/06/giphy.gif' width = '400px'> </img></div>
    
    + [ ] Bodyweight - Leg Lift (16 x) 
    
     <div align = 'center'><img src ='https://thumbs.gfycat.com/SickBrownIsabellinewheatear-max-1mb.gif' width = '400px'> </img></div>
    
    + [ ] KettleBell - Goblet squat (16 x) 
    
     <div align = 'center'><img src ='https://www.sport-equipements.fr/wp-content/uploads/2019/06/giphy.gif' width = '400px'> </img></div>

Let’s now push this to Github:

``` r
res <- gh::gh(
  "POST /repos/:owner/:repo/issues",
  owner = "ColinFay",
  repo = "workouts",
  title = sprintf(
    "Workout - %s", 
    Sys.Date()
  ), 
  assignee = "ColinFay", 
  body = generate_workout(16)
)
browseURL(res$html_url)
```

And, tadaaa 🎉.

![](/assets/img/worrkout.png)

Please reuse these functions just for fun and recreational workouts.

Find them at
[github.com/ColinFay/worrkout](https://github.com/ColinFay/worrkout)
