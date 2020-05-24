###Modeling 3. 수소차 시뮬레이션 (구 단위)
#- input: car_gu.csv, population.csv 활용 
#- target: 수소차 대수

#라이브러리 가져오기
library(dplyr)

#데이터 가져오기
car_gu <- read.csv('data/cleansing/car_gu.csv')
pop <- read.csv('data/cleansing/population.csv')
raw_car_gu <- car_gu # 원본 자료 보존

#이름 정제
pop <- pop %>% 
  janitor::clean_names()
colnames(pop)

#구별 인구수 계산
total_pop <- pop %>% 
  group_by(jachigu) %>% 
  summarise(total_pop = sum(gye))

#데이터 합치기
car_gu <- cbind(car_gu, total_pop[,2])
car_gu <- car_gu %>% 
  select(gu, car, Hyd_car, r1, r2, r3, r4, total_pop)

#데이터 표준화(standardization)
car_gu_z <- car_gu %>%
  mutate_each(funs(z=scale(.)), -c('gu')) %>% 
  select(ends_with('z'))

#GLM
gu_glm1 <- glm(Hyd_car_z~., data=car_gu_z)
gu_glm2 <- glm(Hyd_car_z~.-car_z, data=car_gu_z)
gu_glm3 <- glm(Hyd_car_z~.-car_z-total_pop_z, data=car_gu_z)

summary(gu_glm1) #car_Z, r1_z, total_pop_z과 유의함
summary(gu_glm2) #r1_z만 유의함
summary(gu_glm3) #r1_z만 유의함
###r1_z의 계수가 음인 것으로 미루어보아, r1이 작을수록, 즉, 첫번째 주유소와의 거리가 가까울 수록 유의미하다.
gu_glm1$deviance; gu_glm2$deviance; gu_glm3$deviance

#Stepwise Selection
step(gu_glm1, direction = 'both')
step(gu_glm2, direction = 'both')
step(gu_glm3, direction = 'both')
###모든 것에서 r1_Z은 살아남았다. 즉, r1을 중요한 변수로 놓고 모델링을 진행해도 무방하다고 결론내릴 수 있다.

