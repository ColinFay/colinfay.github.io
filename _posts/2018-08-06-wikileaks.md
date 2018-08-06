---
title: "Wrangling Wikileaks DMs"
post_date: 2018-07-30
layout: single
permalink: /wikileaks/
categories: r-blog-en
output: jekyllthat::jekylldown
excerpt_separator: <!--more-->
---

Using R to turn raw data into browsable and reusable content.

<!--more-->

## About

On the 29th of July 2018, Emma Best published on her website the copy of
11k+ wikileaks Twitter DM :
<https://emma.best/2018/07/29/11000-messages-from-private-wikileaks-chat-released/>

To be honnest, I’m not really interested in the content of this dataset.
What really interested me is that it’s **raw data** (copied and pasted
text) waiting to be parsed, and that I could **use R to turn these
elements into a reusable and browsable content**.

## The results

Here are the links to the pages I’ve created with R from this dataset:

  - [Home](https://colinfay.me/wikileaksdm/index.html) has the full
    dataset, to search and download.
  - [Timeline](https://colinfay.me/wikileaksdm/timeline.html) has a
    series of time-related content: notably DMs by years, and daily
    count of DMs.
  - [Users](https://colinfay.me/wikileaksdm/users.html) holds the
    dataset for each users.
  - [mentions\_urls](https://colinfay.me/wikileaksdm/mention_urls.html)
    holds the extracted mentions and urls
  - [methodo](https://colinfay.me/wikileaksdm/methodo.html) contains the
    methodology used for the data wrangling

## Methodology

### Extracting the content

As I wanted to use the data offline (and not re-download it each time I
compile the outputs), I’ve first extracted and saved the dataset as a
.txt. You can now see it at <https://colinfay.me/wikileaksdm/raw.txt>.

Here is the code
    used:

``` r
library(tidyverse)
```

    ## ── Attaching packages ────────────────────────────────────────── tidyverse 1.2.1 ──

    ## ✔ ggplot2 3.0.0     ✔ purrr   0.2.5
    ## ✔ tibble  1.4.2     ✔ dplyr   0.7.5
    ## ✔ tidyr   0.8.1     ✔ stringr 1.3.1
    ## ✔ readr   1.1.1     ✔ forcats 0.3.0

    ## ── Conflicts ───────────────────────────────────────────── tidyverse_conflicts() ──
    ## ✖ dplyr::filter() masks stats::filter()
    ## ✖ dplyr::lag()    masks stats::lag()

``` r
library(rvest)
```

    ## Loading required package: xml2

    ## 
    ## Attaching package: 'rvest'

    ## The following object is masked from 'package:purrr':
    ## 
    ##     pluck

    ## The following object is masked from 'package:readr':
    ## 
    ##     guess_encoding

``` r
# Reading the page
doc <- read_html("https://emma.best/2018/07/29/11000-messages-from-private-wikileaks-chat-released/")
# Extracting the paragraphs
doc <- doc %>% 
  # Getting the p
  html_nodes("p") %>%
  # Getting the text
  html_text()

# Removing the empty lines
doc <- doc[! nchar(doc)  == 0]
# Lines 1 to 9 are the content of the blogpost, not the content of the conversation. 
doc[1:9]
```

    ## [1] "“Objectivity is short-hand for not having a significant pre-conceived agenda, eliding facts the audience would be interested in, or engaging in obvious falsehoods.” ~ WikiLeaks"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
    ## [2] "Presented below are over 11,000 messages from the WikiLeaks + 10 chat, from which only excerpts have previously been published."                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
    ## [3] "The chat is presented nearly in its entirety, with only a handful redactions made to protect the privacy and personal information of innocent, third parties as well as the already public name of an individual who has sent hate mail, made legal threats and who the source for the DMs considers a threat. It is at the request of the source that Mark’s full name is redacted, leaving only his first name and his initials (which he specified is alright). Though MGT’s full name is already public and easily discoverable, the source’s wishes are being respected. Beyond this individual, the redactions don’t include any information that’s relevant to understanding WikiLeaks or their activities."
    ## [4] "The chat log shows WikiLeaks’ private attitudes, their use of FOIA laws, as well as discussions about WikiLeaks’ lobbying and attempts to “humiliate” politicians, PR and propaganda efforts (such as establishing a “medium term truth” for “phase 2”), troll operations, attempts to engineer situations where WikiLeaks would be able to sue their critics, and in some instances where WikiLeaks helped direct lawsuits filed by third parties or encouraged criminal investigations against their opponents. In some instances, the chats are revealing. In others, they show a mundane consistency with WikiLeaks’ public stances. A few are provocative and confounding."                                   
    ## [5] "The extract below was created using DMArchiver, and is presented as pure text to make it easier to search and to provide as much metadata as possible (i.e. times as well as dates). The formatting is presented as-is, and shows users’ display names rather than their twitter handles. (Note: Emmy B is @GreekEmmy, not the author.)"                                                                                                                                                                                                                                                                                                                                                                           
    ## [6] "CW: At various points in the chat, there are examples of homophobia, transphobia, ableism, sexism, racism, antisemitism and other objectionable content and language. Some of these are couched as jokes, but are still likely to (and should) offend, as a racist or sexist jokes doesn’t cease to be racist or sexist because of an expected or desired laugh. Attempts to dismiss of these comments as “ironic” or “just trolling” merely invites comparisons to 4chan and ironic nazis. These comments, though offensive, are included in order to present as full and complete a record as possible and to let readers judge the context, purpose and merit of these comments for themselves."                
    ## [7] " "                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
    ## [8] "If any current or former staffers, volunteers or hackers wants to add to my growing collection of leaks from within #WikiLeaks, please reach out. DMs are open and I’m EmmaBest on Wire."                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
    ## [9] "— Emma Best (\u1d1c//ғ\u1d0f\u1d1c\u1d0f) \U0001f3f3️‍\U0001f308 (@NatSecGeek) June 28, 2018"

``` r
doc[10]
```

    ## [1] "[2015-05-01 13:52:11] <noll> group Dm on Wls related trolls activity, incoming events & general topics."

``` r
# Removing these lines:
doc <- doc[10:length(doc)]
```

And then simply save it as a txt:

``` r
write(doc, "raw.txt")
```

I can now easily reaccess it.

``` r
res_raw <- read.delim("https://colinfay.me/wikileaksdm/raw.txt", 
                      sep = "\n", header = FALSE) %>% 
  # Turning the character vector into a tibbe
  as.tibble() %>% 
  # Renaming the V1 columné
  rename(value = V1)
res_raw
```

    ## # A tibble: 11,377 x 1
    ##    value                                                                   
    ##    <fct>                                                                   
    ##  1 [2015-05-01 13:52:11] <noll> group Dm on Wls related trolls activity, i…
    ##  2 [2015-05-01 13:53:39] <WikiLeaks> There’s a race on now to ‘spoil’ our …
    ##  3 [2015-05-01 13:55:02] <WikiLeaks> Greenberg, who palled up with the ope…
    ##  4 [2015-05-01 13:55:53] <WikiLeaks> ..stripped the hostility. We’re putti…
    ##  5 [2015-05-01 13:56:03] <WikiLeaks> suppressed.                           
    ##  6 [2015-05-01 14:01:26] <noll> yes, both Wired & Verge contained DDB’s li…
    ##  7 [2015-05-01 14:02:37] <noll> – cyber attacks. must be one of, if not th…
    ##  8 [2015-05-01 14:03:55] <WikiLeaks> Greenberg is a partisan. Fraudulent t…
    ##  9 [2015-05-01 14:29:48] <noll> [Tweet] https://twitter.com/m_cetera/statu…
    ## 10 [2015-05-01 14:32:09] <WISE Up Action> Hi all. More comfortable discuss…
    ## # ... with 11,367 more rows

### Cleaning the data

DMs have a specific structure: `[date hour] <author> text`, except for
one “author”, `<DMConversationEntry>`, which is the meta-information
about the conversation (renaming of the channel, user joining and
leaving, etc). In order to tidy the format, let’s add
`<DMConversationEntry>` as an author.

``` r
res <- res_raw %>% 
  mutate(value = str_replace_all(value, 
                                 "\\[DMConversationEntry\\]",
                                 "<DMConversationEntry>")) 
```

Also I’ll remove, the last entry of the corpus, which doesn’t fit the
conversation format:

``` r
res[nrow(res),]
```

    ## # A tibble: 1 x 1
    ##   value                             
    ##   <chr>                             
    ## 1 [LatestTweetID] 931704226425856001

``` r
res <- filter(res, ! str_detect(value, "931704226425856001"))
```

Some messages are splitted between lines. These lines don’t start with a
date (they are the middle of a DM). I’ll then paste the content of these
lines at the end of the line before.

Here is an example with lines 93 &
94:

|                                                                                                        value |
| -----------------------------------------------------------------------------------------------------------: |
| “\[2015-05-02 14:12:27\] <WISE Up Wales> OK, thanks H. Security issues were about who was on the list then?” |
|                                 “Never quite know who you’re dealing with online I guess. I don’t, anyway\!” |

Here, 94 will be pasted at the end of 93 and removed.

Let’s loop this:

``` r
for (i in nrow(res):1){
  if (!grepl(pattern = "\\[.{4}-.{2}-.{2} .{2}:.{2}:.{2}\\]|DMConversationEntry", res[i,])){
    res[i-1,] <- paste(res[i-1,], res[i,])
  }
}
# Remove lines with no date or no DMConversationEntry
res <- res %>% 
  mutate(has_date = str_detect(value, pattern = "\\[.{4}-.{2}-.{2} .{2}:.{2}:.{2}\\]|DMConversationEntry")) %>%
  filter(has_date) %>%
  select(-has_date)
```

### Extract key elements

We’ll now need to split the content in three: `user`, `date`, and
`text`.

My first try was with :

``` r
res <- res %>%
  extract(
    value,
    c("date", "user", "text"), 
    regex = "<([a-zA-Z0-9 ]*)> \\[(.{4}-.{2}-.{2} .{2}:.{2}:.{2})\\] (.*)"
    )
```

But that didn’t fit well: the `DMConversationEntry` has no date (I will
fill them later), so I need a NA here, hence the three steps process:

``` r
res <- res %>%
  extract(value,"user", regex = "<([a-zA-Z0-9 ]*)>", remove = FALSE) %>%
  extract(value,"date", regex = "\\[(.{4}-.{2}-.{2} .{2}:.{2}:.{2})\\] .*", remove = FALSE) %>%
  extract(value, "text", regex = "<[a-zA-Z0-9 ]*> (.*)", remove = FALSE) %>%
  select(-value)
```

When date is missing, it’s because it’s a `DMConversationEntry`. Let’s
verify that:

``` r
res %>% 
  filter(user == "DMConversationEntry") %>%
  summarize(nas = sum(is.na(date)), 
            nrow = n())
```

    ## # A tibble: 1 x 2
    ##     nas  nrow
    ##   <int> <int>
    ## 1    20    20

In order to have a date here, we will fill this with the directly
preceeding date:

``` r
res <- fill(res, date)
```

## Saving data

### Global

``` r
write_csv(res, "wikileaks_dm.csv")
```

### Year

Find the min and max years:

``` r
range(res$date)
```

    ## [1] "2015-05-01 13:52:11" "2017-11-10 04:30:46"

Filter and save a csv for each year:

``` r
walk(2015:2017, 
    ~ filter(res, lubridate::year(date) == .x) %>%
    write_csv(glue::glue("{.x}.csv"))
    )
```

### User

Filter and save a csv for each user:

``` r
walk(unique(res$user), 
    ~ filter(res, user == .x) %>%
    write_csv(glue::glue("user_{make.names(.x)}.csv"))
    )
```

### Counting users participation

``` r
res %>%
  count(user, sort = TRUE) %>%
  write_csv("user_count.csv")
```

### Counting activity by days

``` r
res %>%
  mutate(date = lubridate::ymd_hms(date), 
         date = lubridate::date(date)) %>% 
  count(date) %>%
  write_csv("daily.csv")
```

### Adding extra info

Extracting all the mentions (`@something`):

``` r
mentions <- res %>% 
  mutate(mention = str_extract_all(text, "@[a-zA-Z0-9_]+")) %>%
  unnest(mention) %>% 
  select(mention, everything())
write_csv(mentions, "mentions.csv")

# Count them

mentions %>%
  count(mention, sort = TRUE) %>%
  write_csv("mentions_count.csv")
```

Extracting all the urls (`http(s)`something):

``` r
urls <- res %>% 
  mutate(url = str_extract_all(text, "http.+")) %>%
  unnest() %>% 
  select(url, everything())
write_csv(urls, "urls.csv")
```

### Adding JSON format

I’ve also chosen to export JSON format of the csv.

``` r
list.files(pattern = "csv") %>%
  walk(function(x) {
    o <- read_csv(x)
    jsonlite::write_json(
      o,
      path = glue::glue("{tools::file_path_sans_ext(x)}.json")
    )
  })
dir.create("json")
list.files(pattern = "json") %>%
  walk(function(x){
    file.copy(x, glue::glue("json/{x}"))
    unlink(x)
  })
```

## Building a website with Markdown and GitHub

Here’s a list of random elements from the process of building these
pages with R.

### Hosting

My website in hosted on
[GitHub](https://github.com/ColinFay/colinfay.github.io), with the home
url (colinfay.me) pointing to the root of this repo. If I create a new
folder `pouet`, and put inside this folder a file called `index.html`, I
can then go to colinfay.me/pouet, and get a new website from there. As
the wikileaks extraction already had its own repo, I’ve chosen to list
this repo <https://github.com/ColinFay/wikileaksdm> as a submodule of my
website’s repo.

More about submodules:
<https://git-scm.com/book/en/v2/Git-Tools-Submodules>

Inside this wikileaksdm project, I gathered all the data, an `index.Rmd`
which will be used as a homepage, and other Rmd for other pages. Each
are compiled as html.

### Styling the pages

Markdown default style is nice, but I wanted something different. This
is why I used `{markdowntemplates}`, with the skeleton template. The
yaml looks like:

    ---
    title: "Wikileaks Twitter DM - Home"
    author: '@_colinfay'
    date: "2018-08-06"
    fig_width: 10
    fig_height: 4 
    navlink: "[Wikileaks Twitter DM](https://colinfay.me/wikileaksdm)"
    og:
      type: "article"
      title: "Wikileaks Twitter DM"
    footer:
      - content: '<a href="https://colinfay.me">colinfay.me</a> • <a href="https://twitter.com/_ColinFay">@_colinfay</a><br/>'
    output: markdowntemplates::skeleton
    ---

Here, you can see some new things: footer content, og for open graph
data, and navlink for the content of the header.

### Include the same markdown content several time

All the pages have the same intro content, so I can use
`shiny::includeMarkdown` to include it on each page (this way, I’ll only
need to update the content once if needed). Put ot between backticks
with an `r`, and the markdown is integrated at compilation time as html.

See here, line 21:
<https://raw.githubusercontent.com/ColinFay/wikileaksdm/master/index.Rmd>

### Include font awesome icons

Before every link, there is a:
<svg style="height:0.8em;top:.04em;position:relative;" viewBox="0 0 512 512"><path d="M216 0h80c13.3 0 24 10.7 24 24v168h87.7c17.8 0 26.7 21.5 14.1 34.1L269.7 378.3c-7.5 7.5-19.8 7.5-27.3 0L90.1 226.1c-12.6-12.6-3.7-34.1 14.1-34.1H192V24c0-13.3 10.7-24 24-24zm296 376v112c0 13.3-10.7 24-24 24H24c-13.3 0-24-10.7-24-24V376c0-13.3 10.7-24 24-24h146.7l49 49c20.1 20.1 52.5 20.1 72.6 0l49-49H488c13.3 0 24 10.7 24 24zm-124 88c0-11-9-20-20-20s-20 9-20 20 9 20 20 20 20-9 20-20zm64 0c0-11-9-20-20-20s-20 9-20 20 9 20 20 20 20-9 20-20z"/></svg>.

This could have been done with CSS, but I’ve used the `{fontawesome}`
package, also between backticks and with an `r`, to include them.

See here, line 33:
<https://raw.githubusercontent.com/ColinFay/wikileaksdm/master/index.Rmd>

### Page content

All the pages include interactive elements, and a static plot.
Interactive tables have been rendered with the `{DT}` package, and the
timeline with `{dygraphs}`. Under each dygraph, there is a static plot
made with `{ggplot2}`. In order to organise this two plots (interactive
and none), the second plot is put inside a `<details>` HTML tag. This
allows to create a foldable content inside the page.

See: <https://twitter.com/_ColinFay/status/1022836135452663809>

### Prefilling functions

I use `dygraph` and `datatable` several times, with the same defaut
arguments (e.g `extensions = "Buttons",options = list(scrollX = TRUE,
dom = "Bfrtip", buttons = c("copy", "csv")`). As I didn’t want to retype
these elements each time, I’ve called `purrr::partial` on it:

``` r
dt <- partial(
  datatable,
  extensions = "Buttons",
  options = list(
    scrollX = TRUE, 
    dom = "Bfrtip", 
    buttons = c("copy", "csv")
    )
)
```

This new `dt` function is then used as the defaut `datatable` rendering.

## Read more

If you want to read the code and discover the content, feel free to
browse the website and the github repo:

  - [Website](https://colinfay.me/wikileaksdm)
  - [GitHub repo](https://github.com/ColinFay/wikileaksdm)
