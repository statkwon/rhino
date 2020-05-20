car <- read.csv("data/cleansing/data2(법정동기준).csv")
pop <- read.csv("data/cleansing/data2(행정동 기준).csv")

library(tidyverse)
#1. car 데이터 구 단위로 통합
# 변수명 설정
str(car)
station_locate <-as.factor(c("여의도", "양재", "상암", "하남"))
colnames(car) <- c("gu", "dong", "car", "Hyd_car", 
                   "dong_num", "dong_code", "dong_eng", 
                   "lat", "lng","s_yeoui", "s_yangjae", "s_sangam", "s_hanam")

# NA를 0으로 impute
apply(is.na(car),2, sum)
car$Hyd_car[is.na(car$Hyd_car)] <- 0

apply(is.na(car),2, sum)

#구별 차량 총 대수
car_gu<- car %>% 
  group_by(gu) %>% 
  summarise_at(vars(ends_with("car")), funs(sum))

car_gu
#이후 구별로 새로운 위도 경도 추출



# 2. car_gu, car 의 충전소와의 거리 rank화
# 2-1)법정동별 데이터
car <- car %>% 
  select(-c(dong_num, dong_code, dong_eng))

str(car)
sort <- t(apply(car[,7:10],1,sort))
colnames(sort)  <- paste("r",(1:4) ,sep ="")
car <- cbind(car,sort)
car_v2 <- car %>% 
  mutate(r1_from = ifelse(r1 == s_yeoui, "여의도",
                          ifelse(r1 == s_yangjae,"양재" ,
                                 ifelse(r1==s_sangam,"상암","하남")))) %>% 
  mutate(r2_from = ifelse(r2 == s_yeoui, "여의도",
                          ifelse(r2 == s_yangjae,"양재" ,
                                 ifelse(r2==s_sangam,"상암","하남"))))%>% 
  mutate(r3_from = ifelse(r3 == s_yeoui, "여의도",
                          ifelse(r3 == s_yangjae,"양재" ,
                                 ifelse(r3==s_sangam,"상암","하남")))) %>% 
  mutate(r4_from = ifelse(r4 == s_yeoui, "여의도",
                          ifelse(r4 == s_yangjae,"양재" ,
                                 ifelse(r4==s_sangam,"상암","하남")))) %>% 
  select(-starts_with("s"))

head(car_v2)
write.csv(car_v2, "data/cleansing/car_v2.csv", row.names = F)

#2 -2) 구 단위 데이터
car_gu

#구별 좌표 입력
seoul_location <- read.csv("data/서울시 행정구역 시군구 정보 (좌표계_ WGS1984).csv")
str(seoul_location)
seoul_location <- seoul_location %>% 
  select(시군구명_한글, 위도, 경도)
colnames(seoul_location) <- c("gu", "lat", "lng")

car_gu <- as.data.frame(car_gu)
car_gu <- car_gu %>% 
  left_join(seoul_location) 

#충전소 좌표 데이터를 활용, 좌표 간 거리 계산
hyd_location <- read.csv("data/서울시_근교_충전소좌표.txt")

car_gu <-car_gu %>% 
  mutate(s_yeoui = sqrt((lat - hyd_location[1,2])**2 + 
                     (lng - hyd_location[1,3])**2 )) %>%
  mutate(s_yangjae = sqrt((lat - hyd_location[2,2])**2 + 
                     (lng - hyd_location[2,3])**2 )) %>%
  mutate(s_sangam = sqrt((lat - hyd_location[3,2])**2 + 
                     (lng - hyd_location[3,3])**2 )) %>%
  mutate(s_hanam = sqrt((lat - hyd_location[4,2])**2 + 
                     (lng - hyd_location[4,3])**2 )) 

#rank화
str(car_gu)
sort_gu <- t(apply(car_gu[,6:9],1,sort))
colnames(sort_gu)  <- paste("r",(1:4) ,sep ="")
car_gu <- cbind(car_gu,sort_gu)
car_gu <- car_gu %>% 
  mutate(r1_from = ifelse(r1 == s_yeoui, "여의도",
                          ifelse(r1 == s_yangjae,"양재" ,
                                 ifelse(r1==s_sangam,"상암","하남")))) %>% 
  mutate(r2_from = ifelse(r2 == s_yeoui, "여의도",
                          ifelse(r2 == s_yangjae,"양재" ,
                                 ifelse(r2==s_sangam,"상암","하남"))))%>% 
  mutate(r3_from = ifelse(r3 == s_yeoui, "여의도",
                          ifelse(r3 == s_yangjae,"양재" ,
                                 ifelse(r3==s_sangam,"상암","하남")))) %>% 
  mutate(r4_from = ifelse(r4 == s_yeoui, "여의도",
                          ifelse(r4 == s_yangjae,"양재" ,
                                 ifelse(r4==s_sangam,"상암","하남")))) %>% 
  select(-starts_with("s"))

head(car_gu)  


##아직 미완성 -> 자치구별 데이터 종합할 예정
