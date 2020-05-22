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

# train bagged model
# gas_bag1 <- bagging(
#   formula = station_per_car ~ .,
#   data = train_gas,
#   nbagg = 100,  
#   coob = TRUE,
#   control = rpart.control(minsplit = 2, cp = 0)
# )
# gas_bag1

#apply bagging within caret and use 10-fold CV
gas_bag2 <- train(
  station_per_car ~ .,
  data = gas_tbl_z,
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
  index <- sample(nrow(gas_tbl_z), replace = TRUE)
  ames_train_boot <- gas_tbl_z[index, ]  
  
  # fit tree to bootstrap copy
  bagged_tree <- rpart(
    station_per_car ~ ., 
    control = rpart.control(minsplit = 2, cp = 0),
    data = gas_tbl_z
  ) 
  
  predict(bagged_tree, newdata = gas_tbl_z)
}

predictions[1:5, 1:7]

#Variable Importance
vip::vip(gas_bag2, num_features = 40, bar = FALSE)


# predictions %>%
#   as.data.frame() %>%
#   mutate(
#     observation = 1:n(),
#     actual = train_gas$station_per_car) %>%
#   tidyr::gather(tree, predicted, -c(observation, actual)) %>%
#   group_by(observation) %>%
#   mutate(tree = stringr::str_extract(tree, '\\d+') %>% as.numeric()) %>%
#   ungroup() %>%
#   arrange(observation, tree) %>%
#   group_by(observation) %>%
#   mutate(avg_prediction = cummean(predicted)) %>%
#   group_by(tree) %>%
#   summarize(RMSE = RMSE(avg_prediction, actual)) %>%
#   ggplot(aes(tree, RMSE)) +
#   geom_line() +
#   xlab('Number of trees')
# 
# 
# stringr::str_extract(tree)
