#' ---
#' title: Exploring penguins
#' author: Abhijit
#' date: "`r format(Sys.Date(), '%B %d, %Y')`"
#' output: 
#'     html_document:
#'         theme: cerulean
#' ---
#' 
#' # Exploring the penguins dataset
#' 
#' The following is relative frequencies of the different species of penguins
#+ message=FALSE, warning=FALSE, echo=FALSE

library(palmerpenguins)
library(tidyverse)
library(janitor)

tabyl(penguins, species) %>% 
  adorn_pct_formatting() %>% 
  knitr::kable() 
