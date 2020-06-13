# 2. 행정동 기준 데이터 (425개동)

#pop
pop <- read.csv("data/report.csv", na = c("-"))
str(pop)

pop_clean <- pop %>% 
  filter(동 != "소계",동 !="합계", 구분 == "계") %>% 
  select(-기간, -구분)

pop_clean
str(pop_clean)
write.csv(pop_clean, "data/data2(행정동 기준).csv", row.names = F)

#pop_claen : 자치구, 동, 동별인구수, 연령별인구수
#425 rows

#동 분류에 차이가 있음
#pop : 행정동(425)
#car, locate : 법정동(467)

