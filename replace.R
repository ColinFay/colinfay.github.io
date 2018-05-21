l <- list.files(pattern = ".md", path = "_posts", full.names = TRUE)
rpl <- function(doc){
  s <- readLines(doc)
  s <- stringr::str_replace_all(s, "author: colin_fay", "")
  write(s, doc)
}

purrr::map(l, rpl)
