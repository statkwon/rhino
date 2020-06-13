library(tidyverse)

#car
car <- read_excel("data/서울시 자동차 등록현황(동별, 연료별)(20190430).xls")
str(car)
car <- car[-472,]

car_clean <- data.frame(t(matrix(unlist(str_split(car$사용본거지법정동명, " ", n =3)), nrow = 3)))[,2:3]
colnames(car_clean) <- c("자치구", "동")
car_clean["동별총대수"] <- car$`동별 총 대수`
car_clean["수소차대수"] <- car$수소

car_clean
str(car_clean)
write.csv(car_clean, "data/car_clean.csv", row.names = F)
#car_clean : 자치구, 동, 동별총대수, 수소차대수
#471 rows


car <- read.csv("data/car_clean.csv")
locate <- read.csv("data/locate.csv")

#1. 법정동 기준 데이터(467개동) 
str(locate)
str(car)


locate <- locate %>% 
  mutate(동 = 읍면동명) %>% 
  select(-읍면동명)


#동명 중복 처리

car %>% 
  group_by(동) %>% 
  count() %>% 
  filter(n>1)
#신사동 - 337:강남구, 458 : 은평구
# 신정동 - 101:양천구, 332 : 마포구

locate <- locate %>% 
  inner_join(car, by ="동") %>% 
  select(-c(동별총대수,수소차대수))

locate <- locate[!((locate$고유번호 ==337)&(locate$자치구 == "은평구")),]
locate <- locate[!((locate$고유번호 ==458)&(locate$자치구 == "강남구")),]
locate <- locate[!((locate$고유번호 ==332)&(locate$자치구 == "양천구")),]
locate <- locate[!((locate$고유번호 ==101)&(locate$자치구 == "마포구")),]
str(locate)

#생략된 동 확인

car %>% 
  full_join(locate, by = c("동", "자치구")) %>% 
  filter(is.na(위도))


car %>% 
  filter(동 %in% c("도동1가", "노유동","학동",  "포이동"))

#법정동은 467개이므로, 4개동 행 삭제

df1 <- car %>% 
  full_join(locate, by = c("동", "자치구")) %>% 
  filter(!is.na(위도))

write.csv(df1, "data/data2(법정동기준).csv", row.names = F)



