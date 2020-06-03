###Modeling 4. 수소차 시뮬레이션 (구 단위)
#- input: car_gu.csv, population.csv, gasstation.csv 활용 (modeling3에 비교하여, gasstation.csv를 추가로 활용함)
#- target: 수소차 대수

#라이브러리 가져오기
library(dplyr)

#데이터 가져오기
car_gu <- read.csv('data/cleansing/car_gu.csv')
pop <- read.csv('data/cleansing/population.csv')
gas <- read.csv('data/cleansing/gas.csv')

#원본 자료 보존
raw_car_gu <- car_gu 
raw_pop <- pop
raw_gas <- gas

#이름 정제
pop <- pop %>% 
  janitor::clean_names()

#구별 인구수 계산
total_pop <- pop %>%
  group_by(jachigu) %>%
  summarise(total_pop = sum(gye))
#######문제점!!!!! population.csv에서 '계'와 gasstation.csv에서 '총생활인구수'가 다르다...?!?

#데이터 합치기
car_gu <- cbind(car_gu, total_pop[,2])
# car_gu <- car_gu %>% 
#   select(gu, Hyd_car, r1, r2) #gas와 비교하였을 때, car변수에 해당하는 값이 다르다...왜지?

# gas <- raw_gas %>% 
#   select(gu, inflow, outflow, land_value, enterprise, distributor)
# select(-station_per_car, -day_pop, -night_pop, -car_per_station, -gas_station,
#        -road_area, -university) #변수가 너무 많으면, 나중에 stepwise가 안 돌아가서 미리 필요없는 것들은 임의로 제거해준다.
gas <- gas %>% 
  select(-car)
data <- merge(car_gu, gas, by = 'gu')
data <- data %>% 
  select(-c('gu','r1_from','r2_from','r3_from','r4_from', 'lat','lng'))
colnames(data)

data <- data %>% 
  select(c("Hyd_car","r1", "r2", "outflow", "land_value", "enterprise", "distributor") )
colnames(data)


#train / test split
n <- sample(1:25, 17)

train_data <- data[n,]
test_data <- data[-n,]


# library(tidymodels)
# hyd_recipe <- recipe(Hyd_car ~., data = train_data) %>%
#   step_center(all_predictors(), -all_outcomes()) %>%
#   step_scale(all_predictors(), -all_outcomes()) %>% 
#   step_zv(all_predictors()) %>% 
#   prep()
# 
# summary(hyd_recipe)
# 
# `iris_recipe` 요리법을 그대로 시험 데이터에 적용시켜 나중에 예측모형 성능평가에 사용한다. 
# 이때 사용되는 동사가 `bake()`로 구워둔다. 
# 
# test_data_z <- hyd_recipe %>% 
#   prep() %>% 
#   bake(new_data = test_data)
# 
# glimpse(test_data_z)
# 
# train_data_z <- train_data %>%
#   mutate_all(funs())
# 
# train_mean <- apply(train_data,2, mean)
# train_sd <- sqrt(apply(train_data,2, var))
z_df = data.frame(1:17)
df = train_data
for(i in 1:ncol(df)){
  mean <- mean(df[,i])
  sd <- sqrt(var(df[,i]))
  z_col <- (df[,i]-mean)/sd
  z_df <- data.frame(z_df, z_col)
  colnames(z_df)[i+1] <- colnames(df)[i]
}
train_data_z <- z_df[,-1]
str(train_data_z)
#data_z <- round(data_z, 3)
#colnames(data_z) <- substring(colnames(data_z),1,3)
#GLM
hyd_glm <- glm(Hyd_car~., data=train_data_z)
#summary(hyd_glm)
###변수가 너무 많아서 그런지 그 어떤 변수도 유의하지 않다.

#Stepwise Selection
hyd_glm <- stats::step(hyd_glm, direction = 'both')

### Error in (function (x, ...)  : 'print'내에 있는 클래스명이 너무 깁니다
### 임의로 몇몇 변수는 빼고 돌려야겠다. #위에서 gas 에서 빼준다.

###죄송합니다, 이 에러는 어떻게 해결해야할지 모르겠네요.


##############################################################################

#prediction
hyd_glm_pred <- predict(hyd_glm, newdata = train_data_z)

#MSE 확인
hyd_glm_pred <- hyd_glm_pred %>% 
  cbind(train_data_z$Hyd_car) %>% 
  as.tibble()
colnames(hyd_glm_pred) <- c('.pred', 'Hyd_car')

mse_glm <- MSE(hyd_glm_pred$.pred, hyd_glm_pred$Hyd_car)
mse_glm

#Variable Importance
# hyd_glm$variable.importance
# vi_dt <- sort(hyd_glm$variable.importance, decreasing=TRUE)
# barplot(vi_dt, las=2, col='lightgreen')

#표준화 복원
y_mean <- mean(train_data$Hyd_car)
y_std <- sqrt(var(train_data$Hyd_car))
y_glm <- y_mean + hyd_glm_pred*y_std
y_glm <- ceiling(y_glm) #올림처리
MSE(y_glm$Hyd_car, y_glm$.pred)
###outliar를 예측하는 데에는 DT에 비해서 좋다.
###다만, 반대로 말하면 outliar가 아니라 일반적으로 적은 구들에 대해서는 잘 예측하지 못한다.
###개인적인 생각으로는, 우리는 수소차가 많이 늘어나는 것이 좋으니까


#test
z_df = data.frame(1:8)
df2 = test_data
for(i in 1:ncol(df)){
  mean <- mean(df[,i])
  sd <- sqrt(var(df[,i]))
  z_col <- (df2[,i]-mean)/sd
  z_df <- data.frame(z_df, z_col)
  colnames(z_df)[i+1] <- colnames(df2)[i]
}
test_data_z <- z_df[,-1]
str(test_data_z)
str(train_data_z)

#prediction
hyd_glm_pred <- predict(hyd_glm, newdata = test_data_z)
#MSE 확인
hyd_glm_pred <- hyd_glm_pred %>% 
  cbind(test_data_z$Hyd_car) %>% 
  as.tibble()
colnames(hyd_glm_pred) <- c('.pred', 'Hyd_car_z')

mse_glm <- MSE(hyd_glm_pred$.pred, hyd_glm_pred$Hyd_car_z)
mse_glm

#Variable Importance
# hyd_glm$variable.importance
# vi_dt <- sort(hyd_glm$variable.importance, decreasing=TRUE)
# barplot(vi_dt, las=2, col='lightgreen')

#표준화 복원
y_mean <- mean(train_data$Hyd_car)
y_std <- sqrt(var(train_data$Hyd_car))
y_glm <- y_mean + hyd_glm_pred*y_std
y_glm <- ceiling(y_glm) #올림처리
MSE(y_glm$Hyd_car_z, y_glm$.pred)
###outliar를 예측하는 데에는 DT에 비해서 좋다.
###다만, 반대로 말하면 outliar가 아니라 일반적으로 적은 구들에 대해서는 잘 예측하지 못한다.
###개인적인 생각으로는, 우리는 수소차가 많이 늘어나는 것이 좋으니까


