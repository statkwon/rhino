###Modeling 4. 수소차 시뮬레이션 (구 단위)
#- input: car_gu.csv, population.csv, gasstation.csv 활용 (modeling3에 비교하여, gasstation.csv를 추가로 활용함)
#- target: 수소차 대수

#라이브러리 가져오기
library(dplyr)

#데이터 가져오기
car_gu <- read.csv('data/cleansing/car_gu.csv')
pop <- read.csv('data/cleansing/population.csv')
gas <- read.csv('data/cleansing/gasstation_imputation.csv')

#원본 자료 보존
raw_car_gu <- car_gu 
raw_pop <- pop
raw_gas <- gas

#이름 정제
pop <- pop %>% 
  janitor::clean_names()

#구별 인구수 계산
total_pop <- pop %>%
  group_by(jachigu) %>%
  summarise(total_pop = sum(gye))
#######문제점!!!!! population.csv에서 '계'와 gasstation.csv에서 '총생활인구수'가 다르다...?!?

#데이터 합치기
car_gu <- cbind(car_gu, total_pop[,2])
car_gu <- car_gu %>% 
  select(gu, Hyd_car, r1, r2) #gas와 비교하였을 때, car변수에 해당하는 값이 다르다...왜지?

gas <- raw_gas %>% 
  select(gu, inflow, outflow, land_value, enterprise, distributor)
  # select(-station_per_car, -day_pop, -night_pop, -car_per_station, -gas_station,
  #        -road_area, -university) #변수가 너무 많으면, 나중에 stepwise가 안 돌아가서 미리 필요없는 것들은 임의로 제거해준다.

data <- merge(car_gu, gas, by = 'gu')

#데이터 표준화(standardization)
data_z <- data %>%
  mutate_each(funs(z=scale(.)), -c('gu')) %>% 
  select(ends_with('z'))

data_z <- round(data_z, 3)
colnames(data_z) <- substring(colnames(data_z),1,3)

#GLM
data_glm <- glm(Hyd_car_z~., data=data_z)
summary(data_glm)
###변수가 너무 많아서 그런지 그 어떤 변수도 유의하지 않다.

#Stepwise Selection
step(data_glm, direction = 'both')
### Error in (function (x, ...)  : 'print'내에 있는 클래스명이 너무 깁니다
### 임의로 몇몇 변수는 빼고 돌려야겠다. #위에서 gas 에서 빼준다.

###죄송합니다, 이 에러는 어떻게 해결해야할지 모르겠네요.