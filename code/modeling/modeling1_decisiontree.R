#modeling part1- Decision Tree
library(tidymodels)
library(dplyr)
library(rpart)
library(rpart.plot)
library(pROC)
library(tidyr)
library(plotly)
set.seed(522)

#데이터 가져오기
gas <- read.csv("data/cleansing/gasstation_imputation.csv")
colnames(gas) <- c('gu', 'gas_station', 'car', 'station_per_car', 'inflow', 'outflow', 'land_value', 'university',
                   'enterprise', 'distributor', 'parking_area', 'school', 'road_area', 'population', 'day_pop', 'night_pop', 'car_per_station')
skimr::skim(gas)

gas <- gas %>% 
  mutate_each(funs(scale(.)), -c('gu', 'gas_station','car','station_per_car')) %>% 
  select(-c('gu', 'gas_station','car','station_per_car'))

# #split
# gas_split <- initial_split(gas_tbl, prop = 0.8)
# 
# train_gas <- training(gas_split)
# test_gas  <- testing(gas_split)

# #전처리, scaling 등등
# gas_recipe <- recipe(station_per_car ~., data = train_gas) %>%
#    step_center(all_predictors(), -all_outcomes()) %>%
#    step_scale(all_predictors(), -all_outcomes()) %>% 
#    step_zv(all_predictors()) %>% 
#    prep()
# summary(gas_recipe)

#Decision Tree
my.control <- rpart.control(cp=0)
gas_dt <- rpart(car_per_station ~ ., data=gas, method='anova', control=my.control)
summary(gas_dt)
prp(gas_dt)

#prediction
gas_dt_pred <- predict(gas_dt, newdata = gas)

#MSE 확인
gas_dt_pred <- gas_dt_pred %>% 
  cbind(gas$car_per_station) %>% 
  as.tibble()
colnames(gas_dt_pred) <- c('.pred', 'station_per_car')

library("MLmetrics")
mse_dt <- MSE(gas_dt_pred$.pred, gas_dt_pred$station_per_car)
mse_dt

#Variable Importance
gas_dt$variable.importance
vi_dt <- sort(gas_dt$variable.importance, decreasing=TRUE)
barplot(vi_dt, las=2, col='skyblue')

# vi_dt <- as.tibble(cbind(names(vi_dt), vi_dt))
# colnames(vi_dt) <- c('X', 'vi')
# library(ggplot2)
# ggplot(data = vi_dt, aes(x=X, y=vi)) +
#   geom_bar()
# vi_dt
