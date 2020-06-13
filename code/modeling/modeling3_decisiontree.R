###Modeling 4. 수소차 시뮬레이션 (구 단위)
#- input: car_gu.csv, gasstation_imputation.csv 활용 (modeling3에 비교하여, gasstation.csv를 추가로 활용함)
#- target: 수소차 대수

#라이브러리 가져오기
library(tidymodels)
library(dplyr)
library(rpart)
library(rpart.plot)

#데이터 가져오기
car_gu <- read.csv('data/cleansing/car_gu.csv')
gas <- read.csv('data/cleansing/gasstation_imputation.csv')

#원본 자료 보존
raw_car_gu <- car_gu 
raw_gas <- gas

#데이터 합치기
# car_gu <- cbind(car_gu, total_pop[,2])
# car_gu <- car_gu %>% 
#   select(gu, Hyd_car, r1, r2) #gas와 비교하였을 때, car변수에 해당하는 값이 다르다...왜지?

#gas <- raw_gas %>% 
# select(gu, inflow, outflow, land_value, enterprise, distributor)
# select(-station_per_car, -day_pop, -night_pop, -car_per_station, -gas_station,
#        -road_area, -university) #변수가 너무 많으면, 나중에 stepwise가 안 돌아가서 미리 필요없는 것들은 임의로 제거해준다.

data <- merge(car_gu, gas, by = 'gu')
data <- data %>% 
  select(-c('gu','r1_from','r2_from','r3_from','r4_from','lat','lng'))

#데이터 표준화(standardization)
data_z <- data %>%
  mutate_each(funs(z=scale(.))) %>% 
  select(ends_with('z'))

data_z <- round(data_z, 3)
#colnames(data_z) <- substring(colnames(data_z),1,3)

my.control <- rpart.control(cp=0)
hyd_dt <- rpart(Hyd_car_z ~ ., data=data_z, method='anova', control=my.control)
summary(hyd_dt)
prp(hyd_dt)

#prediction
hyd_dt_pred <- predict(hyd_dt, newdata = data_z)

#MSE 확인
hyd_dt_pred <- hyd_dt_pred %>% 
  cbind(data_z$Hyd_car_z) %>% 
  as.tibble()
colnames(hyd_dt_pred) <- c('.pred', 'Hyd_car_z')

library("MLmetrics")
mse_dt <- MSE(hyd_dt_pred$.pred, hyd_dt_pred$Hyd_car_z)
mse_dt

#Variable Importance
hyd_dt$variable.importance
vi_dt <- sort(hyd_dt$variable.importance, decreasing=TRUE)
barplot(vi_dt, las=2, col='lightgreen')

#표준화 복원
y_mean <- mean(data$Hyd_car)
y_std <- sqrt(var(data$Hyd_car))
y_dt <- y_mean + hyd_dt_pred*y_std
y_dt
MSE(y_dt$Hyd_car_z, y_dt$.pred)
