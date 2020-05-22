#modeling part1
library(tidymodels)
library(tidyverse)
#library(ipred)
library(adabag)
set.seed(519)

gas <- read.csv("data/cleansing/gasstation.csv")
skimr::skim(gas)

#변수명 변경
colnames(gas) <- c('gu', 'gas_station', 'car', 'station_per_car', 'inflow', 'outflow', 'land_value', 'university',
  'enterprise', 'distributor', 'parking_area', 'school', 'road_area', 'population', 'day_pop', 'night_pop')

#전처리 시작
gas_tbl <- gas %>% as_tibble %>% 
  janitor::clean_names()
gas_tbl<-gas_tbl %>%
  filter(gu != "강북구") %>%
  mutate(station_per_car = car/gas_station) %>% 
  select(-c(gu, car, gas_station)) #구 제거 #NA있는 강북구 제거

#split
gas_split <- initial_split(gas_tbl, prop = 0.8)

train_gas <- training(gas_split)
test_gas  <- testing(gas_split)

#전처리, scailing 등등
gas_recipe <- recipe(station_per_car ~., data = train_gas) %>%
  step_center(all_predictors(), -all_outcomes()) %>%
  step_scale(all_predictors(), -all_outcomes()) %>% 
  step_zv(all_predictors()) %>% 
  prep()

summary(gas_recipe)

#test에 전처리 적용
gas_testdata <- gas_recipe %>% 
  prep() %>% 
  bake(new_data = test_gas)

glimpse(gas_testdata)

#결과 확인
juice(gas_recipe) %>% 
  head()


#Bagging
gas_bagging <- bagging(station_per_car~., data=gas_tbl)
summary(gas_bagging)

importanceplot(gas_bagging)

gas_bagging_pred <- predict(gas_bagging, data=train_gas)

gas_pred <- cbind(train_gas, gas_bagging_pred) %>% 
  select(station_per_car, gas_bagging_pred)

attach(gas_pred)
library("MLmetrics")
mse1 <- MSE(gas_bagging_pred, station_per_car)
detach(gas_pred)
mse1

