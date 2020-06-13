## 1. Modeling1_*** : Variable Importance를 파악하기 위해 다양한 모델링을 시도하였다.
#### 세부 모델별 요약
1) Bagging (modeling1_bagging2.R)
중요변수: enterprise, inflow, land_value, outflow, university
이미지파일: VI_bagging.png

2) Decision Tree (modeling1_decisiontree.R)
중요변수: inflow, outflow, enterprise, day_pop, distributor
이미지파일: VI_decisiontree.png

3) Random Forest (modeling1_randomfrest.R)
중요변수: inflow, enterprise, outflow, university, distributor

#### Modeling1 결과
최종선택 중요변수: outflow, land_value, enterprise, distributor




#### 습작도 포함되어있다.
습작1. modeling1_adaboost.R
- Error in if (nrow(object$splits) > 0) { : 인자의 길이가 0입니다
습작2. modeling1_bagging.R
- Error in if (nrow(object$splits) > 0) { : 인자의 길이가 0입니다
습작3. modeling1_bagging3.R
