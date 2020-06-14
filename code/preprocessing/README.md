## 두 가지 종류의 데이터 전처리 진행(1. 충전소 관련 / 2. 차량 관련)


## 1. 충전소 관련 데이터 Imputation (파일: imputation.R)
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

## 2. 차량 관련데이터 전처리 코드 순서
### ( data2(법정동_기준).R -> data2(행정동_기준).R -> preprocessing.R)

- 사용한 파일 목록 : 서울시 자동차 등록현황(동별, 연료별)(20190430).xls, locate.csv, report.csv, 서울시 행정구역 시군구 정보 (좌표계_ WGS1984).csv, 서울시_근교_충전소좌표(정리).txt

- 데이터 병합에 있어서 동 분류 기준이 다르다는 점 확인. (법정동 / 행정동 두 가지로 분류)
- 이후 행정동은 차량 대수 데이터 확보를 위해 자치구 단위로 합침.

### 최종 전처리 완료 데이터 2가지 산출
- car_v2.csv : 법정동 기준으로 분류, row(데이터)가 많지만 col(변수)이 적음
- car_gu.csv : 자치구 기준으로 분류, row(데이터)가 작지만 col(변수)가 다양함
