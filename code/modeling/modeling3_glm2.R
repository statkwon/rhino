###Modeling 4. 수소차 시뮬레이션 (구 단위)
#- input: car_gu.csv, population.csv, gasstation.csv 활용 (modeling3에 비교하여, gasstation.csv를 추가로 활용함)
#- target: 수소차 대수

#라이브러리 가져오기
library(dplyr)

#데이터 가져오기
car_gu <- read.csv('data/cleansing/car_gu.csv')
pop <- read.csv('data/cleansing/population.csv')
gas <- read.csv('data/cleansing/gasstation_imputation.csv')

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

#데이터 합치기
car_gu <- cbind(car_gu, total_pop[,2])
car_gu <- car_gu %>% 
  select(gu, Hyd_car, r1, r2)

gas <- raw_gas %>% 
  select(gu, inflow, outflow, land_value, enterprise, distributor)

data <- merge(car_gu, gas, by = 'gu')

#데이터 표준화(standardization)
data_z <- data %>%
  mutate_each(funs(z=scale(.)), -c('gu')) %>% 
  select(ends_with('z'))

data_z <- round(data_z, 3)
colnames(data_z) <- substring(colnames(data_z),1,3)

#GLM
hyd_glm <- glm(Hyd~., data=data_z)
summary(hyd_glm)

#Stepwise Selection
hyd_glm <- stats::step(hyd_glm, direction = 'both')

##############################################################################

#prediction
hyd_glm_pred <- predict(hyd_glm, newdata = data_z)

#MSE 확인
hyd_glm_pred <- hyd_glm_pred %>% 
  cbind(data_z$Hyd) %>% 
  as.tibble()
colnames(hyd_glm_pred) <- c('.pred', 'Hyd_car_z')

library("MLmetrics")
mse_dt <- MSE(hyd_glm_pred$.pred, hyd_glm_pred$Hyd_car_z)
mse_dt

#Variable Importance
# hyd_glm$variable.importance
# vi_dt <- sort(hyd_glm$variable.importance, decreasing=TRUE)
# barplot(vi_dt, las=2, col='lightgreen')

#표준화 복원
y_mean <- mean(data$Hyd_car)
y_std <- sqrt(var(data$Hyd_car))
y_glm <- y_mean + hyd_glm_pred*y_std
y_glm <- ceiling(y_glm) #올림처리
MSE(y_glm$Hyd_car_z, y_glm$.pred)
###높은 값을 예측하는 데에는 DT에 비해서 좋다.