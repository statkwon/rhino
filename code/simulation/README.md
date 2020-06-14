### simulation_total.R는 시뮬레이션 활용 개념을 이해시키는 데 도움
### top5.R에도 위의 내용이 포함되어 있으나, loop를 돌려서 동별로 충전소가 생겼다는 가정 하에 각각의 예측 값 산출 

### simulation_total.R
- cv를 이용한 glm 모델 사용

- 새로운 충전소가 추가되었을 때, 가까운 충전소 거리가 최신화 됨을 이용하여 test set 형성
```r
new_gas <- loc_data[loc_data$idx ==150,]
```
  - 50번째줄의 숫자를 바꿔서 각 행정동별로 수소차 변동 예측이 확인 가능하다.

- 변화된 test set에 따라서 자치구 별 차량 대수 예측
- 결과 비교 : 
before/ before_pred / after_pred -> 원래 차량수 / 차량수 예측(현재 기준) / 차량수 예측(충전소가 추가되었다는 가정)

### top5.R
```r
#Top5 산출
a <- 0:4 #Top N 까지 산출하고 싶으면 0:(N-1)로 수정하기
idx <- data.frame(sapply(sort(pred_zip, index.return=TRUE), `[`, length(pred_zip)-a))$ix
loc_data[idx,] %>% select(gu, dong) #쌍문동, 길음동, 창동, 미아동, 하월곡동
```
  - 결과: 쌍문동, 길음동, 창동, 미아동, 하월곡동
  - 순서대로 도봉구, 성북구, 도봉구, 강북구, 성북구
```r
a <- 0:4 #87번째줄 / Top N: 0:(N-1)로 수정하기
```
  - Top 5가 아니라 Top N 까지 산출하고 싶으면, 87번째줄 수정하기
