#modeling part1- Decision Tree
library(dplyr)
library(rpart)
library(rpart.plot)
library(pROC)
library(tidyr)
library(plotly)
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

#전처리, scaling 등등
gas_recipe <- recipe(station_per_car ~., data = train_gas) %>%
  step_center(all_predictors(), -all_outcomes()) %>%
  step_scale(all_predictors(), -all_outcomes()) %>% 
  step_zv(all_predictors()) %>% 
  prep()
summary(gas_recipe)

#Decision Tree
my.control <- rpart.control(cp=0.005, minsplit=6)
gas_dt <- rpart(station_per_car ~ ., data=train_gas, method='anova', control=my.control)
summary(gas_dt)
prp(gas_dt)

#prediction
gas_dt_pred <- predict(gas_dt, newdata = train_gas)

#MSE 확인
gas_dt_pred <- gas_dt_pred %>% 
  cbind(train_gas$station_per_car) %>% 
  as.tibble()
colnames(gas_dt_pred) <- c('.pred', 'station_per_car')

library("MLmetrics")
mse_dt <- MSE(gas_dt_pred$.pred, gas_dt_pred$station_per_car)
mse_dt

#Variable Importance
gas_dt$variable.importance
vi_dt <- sort(gas_dt$variable.importance, decreasing=T)
barplot(vi_dt, las=2)
