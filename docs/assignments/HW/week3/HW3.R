pacman::p_load(char = c('tidyverse', 'rio'))

sites <- c('brain','colon','esophagus','lung', 'oral')
files <- file.path(here(),'data', 
                   paste0(str_to_title(sites),'.csv'))

d <- import_list(files, skip=4)

for(i in 1:length(d)){
  assign(str_to_lower(names(d)[i]), d[[i]])
}

map_df(d, dim) %>% 
  mutate(N = c('Rows','Columns')) %>% 
  relocate(N) %>% 
  knitr::kable()

both_sexes <- map(d, select, `Year of Diagnosis`, ends_with('Sexes'))
males <- map(d, select, `Year of Diagnosis`, ends_with('Males', ignore.case = FALSE))
females <- map(d, select, `Year of Diagnosis`, ends_with('Females'))

for(i in 1:length(both_sexes)){
  names(both_sexes[[i]]) <- str_replace(names(both_sexes[[i]]),
                                        'Both Sexes', 
                                        str_to_lower(names(both_sexes)[i]))
  
}

both_sexes <- map2(both_sexes, names(both_sexes), ~.x %>% 
       set_names(str_replace(names(.x), 'Both Sexes', 
                             str_to_lower(.y))))
males <- map2(both_sexes, names(both_sexes), ~.x %>% 
                     set_names(str_replace(names(.x), 
                                           'Males', 
                                           str_to_lower(.y))))
females <- map2(both_sexes, names(both_sexes), ~.x %>% 
                set_names(str_replace(names(.x), 
                                      'Females', 
                                      str_to_lower(.y))))

# Reduce / purrr::reduce

both_sexes_reduced <- Reduce(left_join, both_sexes)
both_sexes_reduced2 <- reduce(both_sexes, left_join)

both_sexes_reduced <- both_sexes_reduced %>% 
  slice(-1) %>% 
  mutate(across(everything(), as.numeric)) %>% 
  pivot_longer(names_to = 'race_site', 
               values_to = 'rate',
               cols = c(-`Year of Diagnosis`)) %>% 
  separate(race_site, c('race','site'), sep=',')
plt1 <- both_sexes_reduced %>% filter(race=='All Races') %>% 
  ggplot(aes(x = `Year of Diagnosis`, y  = rate, color = site))+
  geom_line()

plt2 <- both_sexes_reduced %>% filter(race=='Whites') %>% 
  ggplot(aes(x = `Year of Diagnosis`, y  = rate, color = site))+
  geom_line()
plt3 <- both_sexes_reduced %>% filter(race=='Blacks') %>% 
  ggplot(aes(x = `Year of Diagnosis`, y  = rate, color = site))+
  geom_line()

library(patchwork)

(plt1+ggtitle('Both sexes')) / ((plt2 + ggtitle('Males')) + (plt3+ggtitle('Females')))

library(ggpubr)
composite1 <-  ggarrange(plt2, plt3, nrow=1)
ggarrange(plt1, composite1, ncol=1)
