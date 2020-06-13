###imputation

#데이터 가져오기기
gas <- read.csv("data/cleansing/gasstation.csv")

#변수명 변경
colnames(gas) <- c('gu', 'gas_station', 'car', 'station_per_car', 'inflow', 'outflow', 'land_value', 'university',
                   'enterprise', 'distributor', 'parking_area', 'school', 'road_area', 'population', 'day_pop', 'night_pop')

#전처리 시작
gas_tbl <- gas %>% as_tibble %>% 
  janitor::clean_names()

gas_tbl <- gas_tbl %>%
  mutate(car_per_station = car/gas_station)

skimr::skim(gas_tbl)
colnames(gas_tbl)

# 강북구 imputation (유일하게 inflow, outflow가 NA이다.)
gas_tbl_lm <- gas_tbl %>% 
  filter(gu != '강북구') %>% 
  select(-gu)

inflow.lm <- lm(inflow~road_area, data=gas_tbl_lm) #road_area와 교통량(inflow, outflow) 상관관계 높아서 유일변수로 회귀분석 실시
outflow.lm <- lm(outflow~road_area, data=gas_tbl_lm)
gas_tbl$inflow[3] <- predict(inflow.lm, newdata = gas_tbl %>% filter(gu == '강북구') %>% select(-gu))
gas_tbl$outflow[3] <- predict(outflow.lm, newdata = gas_tbl %>% filter(gu == '강북구') %>% select(-gu))
#write.csv(gas_tbl, file='data/cleansing/gasstation_imputation.csv', row.names = FALSE)