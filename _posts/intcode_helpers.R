library(magrittr)
library(zeallot)
parse_opcode <- function(vec, pos){
  code <- vec[pos]
  op_code <- stringr::str_pad(
    as.character(code), 
    5, 
    side = "left", "0"
  ) %>% strsplit(split = "")
  op_code <- op_code[[1]] %>% 
    setNames(letters[1:5])
  list(
    op_code = paste0(
      op_code[4:5], 
      collapse = ""
    ) %>% as.numeric(), 
    c = op_code["c"],
    b = op_code["b"], 
    a = op_code["a"]
  ) %>%
    one_two_three(
      vec, 
      pos
    )
}

one_two_three <- function(res, vec, pos){
  if (res$c == "0"){
    one <- vec[vec[pos + 1] + 1]
  } else {
    one <- vec[pos + 1] 
  } 
  if (res$b == "0"){
    two <- vec[vec[pos + 2] + 1]
  } else {
    two <- vec[pos + 2] 
  } 
  if (res$a == "0"){
    three <- vec[pos + 3] + 1
  } else {
    three <- vec[pos + 3]
  } 
  list(
    res$op_code,
    one, 
    two, 
    three
  )
}