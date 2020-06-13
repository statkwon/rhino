#reference: https://bradleyboehmke.github.io/HOML/bagging.html

# Helper packages
library(dplyr)       # for data wrangling
library(ggplot2)     # for awesome plotting
library(doParallel)  # for parallel backend to foreach
library(foreach)     # for parallel processing with for loops

# Modeling packages
library(caret)       # for general model fitting
library(rpart)       # for fitting decision trees
library(ipred)       # for fitting bagged decision trees

# make bootstrapping reproducible
set.seed(123)

#데이터 가져오기
gas <- read.csv("data/cleansing/gasstation_imputation.csv")
colnames(gas) <- c('gu', 'gas_station', 'car', 'station_per_car', 'inflow', 'outflow', 'land_value', 'university',
                   'enterprise', 'distributor', 'parking_area', 'school', 'road_area', 'population', 'day_pop', 'night_pop', 'car_per_station')
skimr::skim(gas)

gas <- gas %>% 
  mutate_each(funs(scale(.)), -c('gu', 'gas_station','car','station_per_car')) %>% 
  select(-c('gu', 'gas_station','car','station_per_car'))


#apply bagging within caret and use 10-fold CV
gas_bag2 <- train(
  car_per_station ~ .,
  data = gas,
  method = "treebag",
  trControl = trainControl(method = "cv", number = 10),
  nbagg = 200,  
  control = rpart.control(minsplit = 2, cp = 0)
)
gas_bag2

# Fit trees in parallel and compute predictions on the test set
predictions <- foreach(
  icount(160), 
  .packages = "rpart", 
  .combine = cbind
) %dopar% {
  # bootstrap copy of training data
  index <- sample(nrow(gas), replace = TRUE)
  ames_train_boot <- gas[index, ]  
  
  # fit tree to bootstrap copy
  bagged_tree <- rpart(
    car_per_station ~ ., 
    control = rpart.control(minsplit = 2, cp = 0),
    data = gas
  )
  
  predict(bagged_tree, newdata = gas)
}
predictions[1:5, 1:7]

#Variable Importance
vip::vip(gas_bag2, num_features = 40, bar = FALSE)