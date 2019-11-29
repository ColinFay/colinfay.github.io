library(glue)
library(tidyverse)
library(lubridate)
library(fontawesome)
library(DT)
dt <- partial(datatable,
              extensions = "Buttons",
              options = list(scrollX = TRUE, dom = "Bfrtip", buttons = c("copy", "csv"))
)

colours <- c(
  "#973232", "#1E5B5B", "#6D8D2F", "#287928",
  "#E18C8C", "#548787", "#B8D283", "#70B470",
  "#B75353", "#326E6E", "#8CAA4E", "#439243",
  "#711515", "#0D4444", "#4D6914", "#115A11",
  "#490101", "#012C2C", "#2E4401", "#013A01"
)

library(dygraphs)
dg <- function(x, main, col = 1, fillGraph = TRUE) {
  r <- x %>%
    count(date(date)) %>%
    rename(date = `date(date)`)
  rownames(r) <- r$date
  r %>%
    select(n) %>%
    dygraph(main = main, width = "100%") %>%
    dyRangeSelector(height = 40) %>%
    dyOptions(colors = colours[col], fillGraph, fillAlpha = 0.7)
}

ggcount <- function(x, main, col = 1) {
  x %>%
    count(date(date)) %>%
    rename(date = `date(date)`) %>%
    ggplot() +
    aes(date, n) +
    geom_line(color = colours[col]) +
    geom_area(fill = colours[col], alpha = 0.7) +
    labs(
      title = main,
      subtitle = "Data via Emma Best - https://emma.best",
      x = "Date",
      y = "Number of DMs"
    ) + 
    th()
}

th <- function(axis.text = element_text(size = 10),
               axis.title = element_text(size = 15),
               title = element_text(size = 20),
               plot.subtitle = element_text(size = 10),
               plot.title = element_text(margin = margin(0, 0, 20, 0), size = 18, hjust = .5),
               axis.title.x = element_text(margin = margin(20, 0, 0, 0)),
               axis.title.y = element_text(margin = margin(0, 20, 0, 0)),
               legend.text = element_text(size = 10),
               plot.margin = margin(10, 10, 10, 10),
               panel.background = element_rect(fill = "white"),
               panel.grid.major = element_line(colour = "grey"),
               text = element_text(family = "Arimo"),
               ...) {
  theme_minimal() +
    theme(
      axis.text = axis.text,
      axis.title = axis.title,
      title = title,
      plot.title = plot.title,
      plot.subtitle = plot.subtitle,
      axis.title.x = axis.title.x,
      axis.title.y = axis.title.y,
      legend.text = legend.text,
      plot.margin = plot.margin,
      panel.background = panel.background,
      panel.grid.major = panel.grid.major,
      text = text,
      ...
    )
}

fdt <- function(user){
  read_csv(glue("user_{user}.csv")) %>% 
    dt
}

fdg <- function(user, col){
  read_csv(glue("user_{user}.csv")) %>% 
    dg(main = glue("DM for {user}"), col = col)
}

ggcount_user <- function(user, main, col = 1) {
  read_csv(glue("user_{user}.csv")) %>%
    count(date(date)) %>%
    rename(date = `date(date)`) %>%
    ggplot() +
    aes(date, n) +
    geom_line(color = colours[col]) +
    geom_area(fill = colours[col], alpha = 0.7) +
    labs(
      title = glue("DM for {user}"),
      subtitle = "Data via Emma Best - https://emma.best",
      x = "Date",
      y = "Number of DMs"
    ) + 
    th()
}