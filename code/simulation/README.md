### simulation_total.R
```r
new_gas <- loc_data[loc_data$idx ==150,]
```
  - 50번째줄의 숫자를 바꿔서 각 행정동별로 수소차 변동 예측이 확인 가능하다.

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
