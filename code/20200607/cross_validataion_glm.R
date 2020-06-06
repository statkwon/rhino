library(caret)
install.packages("kernlab")
library(kernlab)
library(tidyverse)

a <- order(runif(dim(data)[1]))
folds <- createFolds(a, k = 10)
folds


ctrl <- trainControl(method="repeatedcv", number=10, repeats=5)
modFit_repeatedcv <- train(Hyd_car ~., data=data, method="glm", trControl = ctrl)

predict(modFit_repeatedcv, data)

#http://www.sthda.com/english/articles/38-regression-model-validation/157-cross-validation-essentials-in-r/

