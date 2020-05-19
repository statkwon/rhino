#modeling part1

library(tidyverse)
set.seed(519)
gas <- read.csv("data/cleansing/total_data.csv")

skimr::skim(gas)

#변수명 변경
colnames(gas) <- c('gu', 'gas_station', 'car', 'station_per_car', 'inflow', 'outflow', 'land_value', 'university',
  'enterprise', 'distributor', 'parking_area', 'school', 'road_area', 'population', 'day_pop', 'night_pop')
library(tidymodels)

#전처리 시작
gas_tbl <- gas %>% as_tibble %>% 
  janitor::clean_names()
gas_tbl<-gas_tbl %>%
  filter(gu != "강북구") %>%
  mutate(station_per_car = car/gas_station) %>% 
  select(-c(gu, gas_station, car)) #구 제거 #NA있는 강북구 제거

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
  fit(data = train_gas)

gas_fit


gas_pred <- train_gas %>% 
  bind_cols(gas_fit %>% predict(train_gas))

head(gas_pred)

#MSE 확인
gas_pred %>% 
  select(station_per_car, .pred)
attach(gas_pred)
library("MLmetrics")
mse1 <- MSE(.pred,station_per_car)
detach(gas_pred)
mse1

#변수중요도 확인
#https://koalaverse.github.io/vip/articles/vip.html
library(vip)
set.seed(101)
rfo <- ranger(station_per_car ~ ., data = train_gas, importance = "impurity")
(vi_rfo <- rfo$variable.importance)
barplot(vi_rfo, horiz = TRUE, las = 1)

library(caret)
varImp(gas_fit$fit$fit$fit, scale = FALSE)


#모델
glmfit=glm(station_per_car~.,data=train_gas,family=gaussian)
summary(glmfit)

