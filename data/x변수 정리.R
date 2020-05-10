# Setting
'''
install.packages('readxl')
install.packages('tidyverse')
install.packages('dplyr')
install.packages('tidyr')
'''

library(readxl)
library(tidyverse)
library(dplyr)
library(tidyr)

dir <- ("C:/Users/Duck/Dropbox/DSI")
setwd(dir)

# Reading data sets
(file_list <- list.files(dir,pattern='.xlsx'))
# 혹은 file_list <- list.files(dir)[grepl('xlsx$',file_list)]
empty <- list()
name <- c('price','univ','business','logis','park','school')

for(i in 1:length(file_list)){
  empty[[i]] <- readxl::read_excel(file_list[i])
  assign(name[i], empty[[i]])
}

#land price 
colnames(price)[1] <- '지역'
for(i in 1:nrow(price)){
  if(is.na(price[[1]][i])){
  price[[1]][i] <- price[[1]][i-1]
  }
}


price <- price %>%
  filter(지역=='서울', !is.na(...2)) %>%
  select(구=...2, price='2019년')

# The number of university
univ <- univ %>%
  filter(시도=='서울',행정구역!='계') %>%
  select(구=행정구역,univ=전체)

# Business
business <- business %>%
  filter(기간==2018,자치구!='합계',동=='소계') %>%
  select(구=자치구,business=합계...4)
  
#mutate(합계...4=as.numeric(합계...4)) 
#rename(구=자치구,business=sum)


# logis
logis <- logis %>%
  select(구=자치구,logis=합계...4) %>%
  slice(-1:-4)

# park
park <- park %>%
  select(구=자치구,park_lot=합계...4) %>%
  slice(-1:-3)

# school
school <- school %>%
  filter(시도=='서울',행정구역!='계',설립=='소계') %>% 
  select(구=행정구역,school=계)

total <- Reduce(function(...) merge(..., by='구', all.x=TRUE), list(price,univ,business,logis,park,school))
write.csv(total,'x변수.csv')


