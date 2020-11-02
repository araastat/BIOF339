# Grading for Fall 2020a
pacman::p_load(char=c('tidyverse','readxl', 'fs'))

gradesheet <- path('~/Downloads', 'BIOF339_Fall2020a.xlsx')
grades <- read_excel(gradesheet, sheet='Sheet1') %>% 
  select(Student, ID, `SIS Login ID`,
         `Homework 1 (4551)`:Discussion)

grades <- grades %>% 
  mutate(Homework1 = pmax(`Homework 1 (4550)`, `Homework 1 (4551)`, na.rm=T)) %>% 
  relocate(Homework1, .after=`SIS Login ID`) %>% 
  select(-`Homework 1 (4551)`, -`Homework 1 (4550)`) %>% 
  mutate(Discussion = str_squish(Discussion)) %>% 
  mutate(Discussion = case_when(
    Discussion=='x' ~ 10,
    Discussion %in% c('xx','xxx') ~ 20,
    Discussion == '20' ~ 20,
    TRUE ~ 0
  )) %>% 
  set_names(c('student','id','login_id','hw1','hw2','hw3','hw4','hw5','hw6','project','discussion'))

grades <- grades %>% 
  mutate(across(hw1:discussion,
                ~100*./(.[1]))) %>% 
  filter(id != 7826) %>% 
  filter(!is.na(id)) %>% 
  mutate(across(hw1:discussion, ~replace_na(., 0)))


hws <- grades %>% 
  pivot_longer(cols = starts_with('hw'),
               names_to = 'homework',
               values_to = 'hw') %>% 
  group_by(student) %>% 
  slice_max(hw, n=4) %>% 
  mutate(hw = median(hw)) %>% 
  ungroup() %>% 
  select(-homework) %>% 
  distinct()

hws <- hws %>% 
  mutate(total = 0.5*hw + 0.3*project + 0.2*discussion)

cuts = c(-1, 70, 80,90,95, 100)

hws <- hws %>% 
  mutate(grade = cut(total, cuts))
levels(hws$grade) <- c('F','C','B','A','A+')

openxlsx::write.xlsx(hws, 'Personal/Fall2020a_grades.xlsx')
