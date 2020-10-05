#' # Exploring the penguins dataset
#' 
#' The following is relative frequencies of the different species of penguins

library(palmerpenguins)
library(tidyverse)
library(janitor)

tabyl(penguins, species)
