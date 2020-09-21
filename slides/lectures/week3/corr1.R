library(tidyverse)
library(gganimate)

set.seed(100)
theta = rep(c(pi/4, runif(99, 0, 2*pi)),20)
r = rep(1, length(theta))
r[1 + (0:19)*100] = 1:20
d = tibble(theta = theta, r = r, indx = rep(1:20, rep(100,20))) %>% 
  mutate( x= r*cos(theta), y = r*sin(theta)) %>% 
  group_by(indx) %>% 
  mutate(crr = round(cor(x, y),2)) %>% 
  ungroup()

anim1 <- ggplot(d, aes(x , y))+
  geom_point() + 
  geom_text(aes(x = 3, y = 10, group=indx, label=paste('Correlation =', crr)),
            size = 6)+
  theme_classic()+
  # stat_cor(aes(label=..r.label..), label.x=0, label.y=10) + 
  transition_time(indx)

anim_save('anim/corr1.gif', animation = anim1)

