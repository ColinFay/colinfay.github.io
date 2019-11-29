# wikileaks

On the 29th of may, 11K+ raw DMS from Wikileaks has been published online in raw format. 

Here is <https://emma.best/2018/07/29/11000-messages-from-private-wikileaks-chat-released/> in a csv format, with other tranformed datasets

## List of all DMs

[wikileaks_dm.csv](wikileaks_dm.csv)

A dataset with 3 columns: 

+ text: extracted text 
+ date: date of the tweet
+ user: user who sent the tweet

## DMS by year 

[2015.csv](2015.csv)

[2016.csv](2016.csv)

[2017.csv](2017.csv)

## DMs by users

[user_Bean.csv](user_Bean.csv)

[user_Cabledrum.csv](user_Cabledrum.csv)

[user_DMConversationEntry.csv](user_DMConversationEntry.csv)

[user_Emmy.B.csv](user_Emmy.B.csv)

[user_LibertarianLibrarian.csv](user_LibertarianLibrarian.csv)

[user_M.csv](user_M.csv)

[user_Matt.Watt.csv](user_Matt.Watt.csv)

[user_noll.csv](user_noll.csv)

[user_SAWC.Sydney.csv](user_SAWC.Sydney.csv)

[user_voidiss.csv](user_voidiss.csv)

[user_WikiLeaks.Press.csv](user_WikiLeaks.Press.csv)

[user_WikiLeaks.Task.Force.csv](user_WikiLeaks.Task.Force.csv)

[user_WikiLeaks.csv](user_WikiLeaks.csv)

[user_WISE.Up.Action.csv](user_WISE.Up.Action.csv)

[user_WISE.Up.Wales.csv](user_WISE.Up.Wales.csv)

## Count of user interactions

[user_count.csv](user_count.csv)

## Count of daily tweets

[daily.csv](daily.csv)

## Mentions

Tweets that contains a mention to a Twitter account: 

[mentions.csv](mentions.csv)

Count of the mentions:

[mentions_count.csv](mentions_count.csv)

## Urls

Extracted links, (starting with `http`)

[urls.csv](urls.csv)

# Methodology 

Everything has been done in R. 

Methodology is described in [methodo.Rmd](methodo.Rmd)

## Packages used: 

The packages used include : 

### ⚒ Wrangling:

📦 {dplyr}: https://github.com/tidyverse/dplyr

📦 {rvest}: https://github.com/hadley/rvest

📦 {stringr}: https://github.com/tidyverse/stringr

📦 {lubridate}: https://github.com/tidyverse/lubridate

📦 {tidyr}: https://github.com/tidyverse/tidyr

📦 {purrr}: https://github.com/tidyverse/purrr

📦 {readr}: https://github.com/tidyverse/readr

### 🎨 Web Page (the above, plus) :

📦 {fontawesome}: https://github.com/rstudio/fontawesome

📦 {DT}: https://github.com/rstudio/DT

📦 {dygraphs}: https://github.com/rstudio/dygraphs

📦 {ggplot2}: https://github.com/tidyverse/readr

📦 {markdowntemplates}: https://github.com/hrbrmstr/markdowntemplates

📦 {knitr}: https://github.com/yihui/knitr

📦 {markdown}: httprs://github.com/rstudio/rmarkdown