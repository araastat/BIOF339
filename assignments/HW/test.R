library(tidyverse)
library(survival)

map_df(pbc %>% select_if(is.numeric), function(x) length(unique(x[!is.na(x)]))) %>% 
  gather(variable, N) %>% 
  filter(N==2) %>% 
  pull(variable) -> convert_to_factor
  

pbc1 <- pbc %>% 
  mutate(id = as.character(id)) %>% 
  mutate(status = as.character(status)) %>% 
  mutate(status = recode(status, '0'='censored','1'='transplant','2'='dead')) %>% 
  mutate_at(vars(convert_to_factor), as.factor) %>% 
  mutate_at(vars(ascites,hepato, spiders), function(x) recode_factor(x, '0'='absent','1'='present'))
  
