#충전소 입지 top 5

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

data

#CV
a <- order(runif(dim(data)[1]))
folds <- createFolds(a, k = 10)
ctrl <- trainControl(method="repeatedcv", number=10, repeats=5)
modFit_repeatedcv <- train(Hyd_car ~., data=data, method="glm", trControl = ctrl)
summary(modFit_repeatedcv)

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

#Top5 뽑을 준비
N <- nrow(loc_data)
pred_zip <- c()

for (i in 1:N){
  #Edit here idx number
  new_gas <- loc_data[loc_data$idx ==i,]
  new_gas
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
  
  #round and max after_pred
  for (idx in 1:25){
    simul_result[idx,4] <- max(simul_result[idx,2], round(simul_result[idx,4]))
  }
  
  #compare before, after
  #apply(simul_result[,2:4],2, sum) #before, after 모두 출력
  
  pred_zip[i] <- apply(simul_result[,2:4],2, sum)[3]
  # pred_mat[i,2] <- apply(simul_result[,2:4],2, sum)[3]
}

#Top5 산출
a <- 0:4 #Top N 까지 산출하고 싶으면 0:(N-1)로 수정하기
idx <- data.frame(sapply(sort(pred_zip, index.return=TRUE), `[`, length(pred_zip)-a))$ix
loc_data[idx,] %>% select(gu, dong) #미아동, 길음동, 번동, 월계동, 장위동동
# pred_zip[idx] - sum(simul_result[,2]) #top 5 늘어난 대수
