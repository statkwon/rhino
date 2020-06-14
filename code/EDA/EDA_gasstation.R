#EDA - gas station
#강북구 imputation된 데이터
gas_tbl <- read.csv("data/cleansing/gasstation_imputation.csv")

#corr polot
gas_corr <- cor(gas_tbl[,5:16])
corrplot::corrplot(gas_corr)
#상관계수가 높이 나오는 변수그룹
#inflow & outflow
#enterprise, distributor
#parking_area, school, road_area, population, day_pop, night_pop


#inflow, outflow
gas_tbl %>% 
  ggplot(aes(x= inflow, y= outflow))+
  geom_point() 


gas_tbl %>%
  mutate(flow = (inflow+outflow)/2) %>% 
  select(gu, flow) %>% 
  ggplot(aes(fill = gu))+
  geom_bar(aes(x = gu, y =flow), stat= "identity")+
  coord_flip()+
  theme(legend.position = "none")+
  xlab("자치구")

#land_value
summary(gas_tbl$land_value)

gas_tbl %>%
  ggplot(aes(fill = gu))+
  geom_bar(aes(y =  gu, x =land_value), stat= "identity")+
  coord_fixed(xlim=c(100,125))+
  theme(legend.position = "none")+
  ylab("자치구")

#university
gas_tbl %>% 
  ggplot(aes(fill = gu))+
  geom_bar(aes(y=gu, x= university), stat = "identity")+
  theme(legend.position = "none")+
  ylab("자치구")

#enterprise, distributor
gas_tbl %>% 
  select(enterprise, distributor) %>% 
  cor()

gas_tbl %>% 
  select(enterprise, distributor) %>% 
  skimr::skim()

gas_tbl %>% 
  select(gu, enterprise, distributor) %>% 
  gather(key = "key", value = "n", enterprise:distributor) %>%
  ggplot(aes(y= gu, fill = key))+
  geom_bar(aes(x = n), stat = "identity")+
  ylab("자치구")+
  xlab("enterprise & distributor")


#parking_area, school, road_area, population, day_pop, night_pop
gas_tbl %>% 
  select( parking_area, school, road_area, population, day_pop, night_pop) %>% 
  cor()
#그나마 school 이 관련성이 떨어져서 따로 하기로함

#school
gas_tbl %>% 
  select(school) %>%  
  skimr::skim()

gas_tbl %>% 
  ggplot(aes(fill = gu))+
  geom_bar(aes(y=gu, x= school), stat = "identity")+
  coord_fixed(xlim=c(40,165))+
  theme(legend.position = "none")+
  ylab("자치구")

##parking_area, road_area, population, day_pop, night_pop
gas_tbl %>% 
  select(parking_area, road_area, population, day_pop, night_pop) %>% 
  skimr::skim()

gas_tbl %>% 
  select(gu, day_pop, night_pop) %>% 
  gather(key = "key", value = "n", ends_with("pop")) %>%
  ggplot(aes(y= gu, fill = key))+
  geom_bar(aes(x = n), position = "fill",stat = "identity")+
  ylab("자치구")+
  xlab("day & night pop")

parking_area_plot<-
gas_tbl %>% 
  ggplot(aes(fill = gu))+
  geom_bar(aes(y=gu, x= parking_area), stat = "identity")+
  theme(legend.position = "none")+
  ylab("자치구")+
  scale_y_discrete(breaks = c())


road_area_plot<-
gas_tbl %>% 
  ggplot(aes(fill = gu))+
  geom_bar(aes(y=gu, x= road_area), stat = "identity")+
  theme(legend.position = "none")+
  ylab("자치구")+
  scale_y_discrete(breaks =c())

pop_plot<-
gas_tbl %>% 
  ggplot(aes(fill = gu))+
  geom_bar(aes(y=gu, x= population), stat = "identity")+
  theme(legend.position = "none")+
  ylab("자치구")+
  scale_y_discrete(breaks =c())

day_pop_plot <-
gas_tbl %>% 
  ggplot(aes(fill = gu))+
  geom_bar(aes(y=gu, x= day_pop), stat = "identity")+
  theme(legend.position = "none")+
  ylab("자치구")+
  scale_y_discrete(breaks =c())

night_pop_plot<-
gas_tbl %>% 
  ggplot(aes(fill = gu))+
  geom_bar(aes(y=gu, x= night_pop), stat = "identity")+
  theme(legend.position = "none")+
  ylab("자치구")+
  scale_y_discrete(breaks =c())

legend<-
gas_tbl %>% 
  ggplot(aes(fill =gu))+
  geom_bar(aes(x= gu, y =c(0)), stat = "identity")+
  scale_fill_discrete(name = "자치구")+
  theme(legend.position = "top")
  
library(gridExtra)
grid.arrange(parking_area_plot, road_area_plot,pop_plot, day_pop_plot,
             night_pop_plot, nrow= 2)


#car_per_station
gas_tbl %>%
  ggplot(aes(fill = gu))+
  geom_bar(aes(y =  gu, x =car_per_station), stat= "identity")+
  theme(legend.position = "none")+
  ylab("자치구")

#1차 완료

# to do(5/22~)
# gas station:
# 
# car_gu :
# 자치구별 연령대 비율, 중요해보이는 연령대로 몇개 더 
# 자치구별 차량 데이터(서울시 지도에 그렸으면 싶음) : 요청사항 
# 
# car_v2 :
# 지도위에 그리는 시각화가 최선으로 생각됨
