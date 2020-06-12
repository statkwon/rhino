#라이브러리 가져오기
library(tidyverse)
library(dplyr)
library(caret)
library(kernlab)
library(tidyverse)

#데이터 가져오기
car_gu <- read.csv('data/cleansing/car_gu.csv')
car <- read.csv('data/cleansing/car_v2.csv')
pop <- read.csv('data/cleansing/population.csv')
gas <- read.csv('data/cleansing/gasstation_imputation.csv')

#전처리
pop <- pop %>% 
  janitor::clean_names()
total_pop <- pop %>%
  group_by(jachigu) %>%
  summarise(total_pop = sum(gye)) #구별 인구수 계산
car_gu <- cbind(car_gu, total_pop[,2]) #데이터 합치기
gas <- gas %>% 
  select(-car)
data <- merge(car_gu, gas, by = 'gu')
data <- data %>% 
  select(-c('gu','r1_from','r2_from','r3_from','r4_from', 'lat','lng'))
data <- data %>% 
  select(c("Hyd_car","r1", "r2", "outflow", "land_value", "enterprise", "distributor") )

#CV
a <- order(runif(dim(data)[1]))
folds <- createFolds(a, k = 10)
ctrl <- trainControl(method="repeatedcv", number=10, repeats=5)
modFit_repeatedcv <- train(Hyd_car ~., data=data, method="glm", trControl = ctrl)

#simulation from glm model
col_model <- colnames(data)
data_new <- car_gu %>%
  full_join(gas, by ="gu") %>%
  select(all_of(col_model), lat, lng) %>% 
  mutate(d1 = r1, d2 = r2, before_car = Hyd_car) %>% 
  select(-c(r1,r2, Hyd_car))

loc_data <- car %>% 
  mutate(idx = row_number()) %>% 
  select(idx, gu, dong ,lat, lng)

#Edit here idx number
new_gas <- loc_data[loc_data$idx ==150,]
data_dist <- data_new %>% 
  mutate(d3 = sqrt((lat - new_gas$lat)^2+
                     (lng - new_gas$lng)^2)) %>%  
  select(d1,d2,d3)

r1 <- apply(data_dist, 1, min)
r2 <- apply(data_dist, 1, median)

#generate simulation data
data_simul <- data_new %>% 
  select(-c(d1,d2, lat, lng)) %>% 
  data.frame( r1, r2)

# simulating by glm 
# cross_validation_glm.R 돌리기
simul_result <- data.frame(gu =car_gu$gu,
                           before = data_simul$before_car,
                           before_pred = predict(modFit_repeatedcv, data), 
                           after_pred = predict(modFit_repeatedcv, data_simul))

#compare before, after
apply(simul_result[,2:4],2, sum)
