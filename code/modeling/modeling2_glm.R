###Modeling2. 수소차 시뮬레이션 (법정동 단위)
# - input: 동별총대수, rank(변수 정리)
# - target: 수소차 대수

#라이브러리 가져오기
library(dplyr)

#데이터 가져오기
car_dong <- read.csv('data/cleansing/car_v2.csv')
raw_car_dong <- car_dong # 원본 자료 보존
head(car_dong)

car_dong <- car_dong %>% 
  select(gu, dong, car, Hyd_car, r1, r2, r3, r4)

#데이터 표준화(standardization)
car_dong_z <- car_dong %>%
  mutate_each(funs(z=scale(.)), -c('gu', 'dong')) %>% 
  select(ends_with('z'))

#GLM
dong_glm1 <- glm(Hyd_car_z~., data=car_dong_z)
dong_glm2 <- glm(Hyd_car_z~.-car_z, data=car_dong_z)

summary(dong_glm1) #모두 유의하게 나옴
summary(dong_glm2) #모두 유의하게 나옴

#Stepwise Selection
step(dong_glm1, direction = 'both')
step(dong_glm2, direction = 'both')
###모든 변수들이 살아남았다. 적어도 서울권 안에만 있으면 어디를 가서도 충전을 할 마음가짐이 있는 것으로 보인다.


###Hyd_car 자체가 아직 많이 보급이 되어있지 않아서(값이 대부분 0) 모든 변수가 다 유의하게 나오는 기이한 현상이 발생한 것으로 보인다.

