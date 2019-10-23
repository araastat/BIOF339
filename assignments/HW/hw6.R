#' ---
#' title: Homework 6 alternate solutions
#' author: Dr. Dasgupta
#' output: html_document
#' ---
#' 
#+ setup, include=F
library(tidyverse)
library(fs)
library(janitor)
library(openxlsx)
knitr::opts_chunk$set(message=F, warning=F)
#'
#' First we read the data into a list. Why? because we know we're going to process
#' all the datasets the same way, and we can use functional programming and loops to 
#' do it all efficiently without copy-pasting.
#+ imports
dirname <- 'data'
#dir_ls(dirname, glob='*.csv')

sites <- c('Brain','Colon','Esophagus','Lung','Oral')
fnames <- paste0(sites, '.csv')

dat1 <- rio::import_list(path(dirname, fnames)) %>% 
  map(janitor::clean_names)
#' What is `map` doing? It is applying the same function, here `janitor::clean_names`, 
#' to each element of the list, which is a list of data.frames. Similarly
#+ splitting
dat1_both <- map(dat1, select, year_of_diagnosis, ends_with("both_sexes"))
dat1_male <- map(dat1, select, year_of_diagnosis, ends_with('_males'))
dat1_female <- map(dat1, ~select(., year_of_diagnosis, ends_with('females')))
#' This creates lists of datasets, just for both sexes, males and females, where each 
#' element of the list comes from each site
#' 
#' We want to do some re-naming, so that when we merge the datasets, we have unique column
#' names. This is harder to do using `map`, so we use a `for`-loop, instead. 
for(i in 1:length(dat1_both)){ # Note all the lists are the same size, so this works
  dat1_both[[i]] <- dat1_both[[i]] %>% set_names(str_replace(names(dat1_both[[i]]), 
                                                             'both_sexes',
                                                             names(dat1_both)[i]))
  dat1_male[[i]] <- dat1_male[[i]] %>% set_names(str_replace(names(dat1_male[[i]]), 
                                                             'males',
                                                             names(dat1_male)[i]))
  dat1_female[[i]] <- dat1_female[[i]] %>% set_names(str_replace(names(dat1_female[[i]]), 
                                                             'females',
                                                             names(dat1_female)[i]))
  
}
#' Now we can join them. In the homework, you did this sequentially. However there are
#' programming tricks that make this much easier. The function `Reduce` is one such. It
#' repeatedly applies a function with two arguments successively to elements of a list. 
#+ reduce
dat2_both <- Reduce(left_join, dat1_both)
dat2_male <- Reduce(left_join, dat1_male)
dat2_female <- Reduce(left_join, dat1_female)
#' We then re-form a list of datasets, since we will be doing some common processing again
#+ munging
dat2 <- list('both' = dat2_both, 'male' = dat2_male, 'female'=dat2_female)
for(i in 1:length(dat2)){
  names(dat2[[i]]) <- str_replace(names(dat2[[i]]), 'all_races','allraces')
  dat2[[i]] <- mutate_at(dat2[[i]], vars(-year_of_diagnosis), as.numeric)
}
dat3 <- map(dat2, function(d) d %>% 
              slice(-1) %>% 
              gather(variable, rate, -year_of_diagnosis) %>% 
              separate(variable, c('race','site'), sep='_', extra='merge') %>% 
              mutate(year_of_diagnosis = as.numeric(year_of_diagnosis)))
#' Now it turns out that you can do the graphs in a loop, to create all the graphs in 
#' one go. This method will suffice if you annotate the graphs properly.
#+ graphs
for(i in 1:length(dat3)){
  print(ggplot(dat3[[i]] %>% filter(race=='allraces'),
         aes(x = year_of_diagnosis, y = rate, color=site)) +
    geom_point() +
      labs(title = str_to_title(names(dat3)[i])))
  plt1 <- ggplot(dat3[[i]] %>% filter(race=='whites'),
                 aes(x = year_of_diagnosis, y = rate, color=site)) + 
    geom_point() + 
    labs(main = str_to_title(names(dat3)[i]))
  plt2 <- ggplot(dat3[[i]] %>% filter(race=='blacks'),
                 aes(x = year_of_diagnosis, y = rate, color=site)) + 
    geom_point()
  print(cowplot::plot_grid(plt1, plt2, nrow=1, labels = c('Whites','Blacks')) )
}
#'
