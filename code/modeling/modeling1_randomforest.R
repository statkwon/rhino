#modeling part1
library(tidymodels)
library(tidyverse)
set.seed(522)
gas <- read.csv("data/cleansing/gasstation_imputation.csv")
gas <- gas %>% 
  select(-c('car_per_station','car','gas_station'))

skimr::skim(gas)

# #전처리 시작
# gas_tbl <- gas %>% as_tibble %>%
#   janitor::clean_names()
# 
# gas_tbl<-gas_tbl %>%
#   filter(gu != "강북구") %>% #NA있는 강북구 제거
#   mutate(station_per_car = car/gas_station) %>%
#   select(-c(gu, gas_station, car))
# 
# #split
# gas_split <- initial_split(gas_tbl, prop = 0.8)
# 
# train_gas <- training(gas_split)
# test_gas  <- testing(gas_split)
# 
# #전처리, scailing 등등
gas_recipe <- recipe(station_per_car ~., data = gas) %>%
  prep()
# 
# summary(gas_recipe)
# 
# # #test에 전처리 적용
# gas_testdata <- gas_recipe %>%
#   prep() %>%
#   bake(new_data = test_gas)
# 
# glimpse(gas_testdata)
# 
# #결과 확인
# juice(gas_recipe) %>%
#   head()

#찐 모델링1 : Random forest
gas_ranger <- rand_forest(trees = 100) %>%
  set_mode("regression") %>% 
  set_engine("ranger") # `ranger` 팩키지
# set_engine("randomForest") %>% # `randomForest` 팩키지


library(workflows)

gas_workflow <- 
  workflow() %>% 
  add_model(gas_ranger) %>% 
  add_recipe(gas_recipe)

gas_fit <- gas_workflow %>% 
  fit(data = gas)

gas_fit

gas_pred <- gas %>% 
  bind_cols(gas_fit %>% predict(gas))

head(gas_pred)

#MSE 확인
gas_pred %>% 
  select(station_per_car, .pred)
library("MLmetrics")
attach(gas_pred)
mse_rfo <- MSE(.pred,station_per_car)
detach(gas_pred)
mse_rfo

#변수중요도 확인
#https://koalaverse.github.io/vip/articles/vip.html
library(ranger)
library(vip)
set.seed(522)
rfo <- ranger(station_per_car ~ ., data = gas, importance = "impurity")
vi_rfo <- sort(rfo$variable.importance, decreasing = T)
barplot(vi_rfo, las = 2)

# library(caret)
# varImp(gas_fit$fit$fit$fit, scale = FALSE)
# 
# 
# #모델
# glmfit=glm(station_per_car~.,data=train_gas,family=gaussian)
# summary(glmfit)
# 

