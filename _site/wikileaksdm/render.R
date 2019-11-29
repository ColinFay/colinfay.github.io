l <- c(
  "index.Rmd", 
  "mention_urls.Rmd", 
  "methodo.Rmd", 
  "timeline.Rmd", 
  "users.Rmd"
)
purrr::map(l, rmarkdown::render)
