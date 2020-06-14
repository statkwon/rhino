### Imputation (파일: imputation.R)
- gasstation.csv(원래 file명 : total_data.csv)중에서 유일하게 강북구의 inflow, outflow가 결측치이다.
- road_area와 교통량(inflow, outflow) 상관관계 높아서 유일변수로 회귀분석 실시
```r
inflow.lm <- lm(inflow~road_area, data=gas_tbl_lm)
outflow.lm <- lm(outflow~road_area, data=gas_tbl_lm)
```
- 강북구 inflow, outflow 결측치 채워넣기
```r
gas_tbl$inflow[3] <- predict(inflow.lm, newdata = gas_tbl %>% filter(gu == '강북구') %>% select(-gu))
gas_tbl$outflow[3] <- predict(outflow.lm, newdata = gas_tbl %>% filter(gu == '강북구') %>% select(-gu))
```
- gasstation_imputation.csv로 저장하고, 추후 imputation된 파일로 진행할 것
