# 교통량 데이터 불러오기
# 2월의 경우 colnames이 잘못되어있어서 원데이터 E1셀 -> 방향 F1셀 -> 구분으로 재네이밍
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

# data importing
dir <- ("C:/Users/USER/Dropbox/DSI/2019년 지점별 일자별 교통량")
setwd(dir)
file_list <- list.files(dir)
file_list <- str_sort(file_list,numeric=T)

data <- data.frame()
for(file in file_list){
 temp <- readxl::read_excel(path=file,sheet=2)
 data <- dplyr::bind_rows(data,temp)
}

# data cleansing
street <- readxl::read_excel(path=file_list[12],sheet=3)
data <- cbind(data,rowSums(data[,8:31],na.rm=T))
hour <- paste('h',0:23,sep='')
colnames(data)[8:32] <- c(hour,'total')
result <- aggregate(total~지점번호+방향,data=data,sum)

street <- street %>%
  separate(주소,c('시','구'),' ') %>%
  filter(시=='서울시') %>%
  select(지점번호,시,구)

result2 <- merge(result,street,by='지점번호')
result3 <- aggregate(total~구+방향,data=result2,sum)

write.csv(result3, file="2019년 구별 교통량 합.csv")

