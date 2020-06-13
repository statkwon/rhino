## 1. Modeling1_*** : Variable Importance 파악
#### Modeling1 결과
최종선택 중요변수: outflow, land_value, enterprise, distributor

#### 세부 모델별 요약
1) Bagging (modeling1_bagging2.R)
- 중요변수: enterprise, inflow, land_value, outflow, university
- 이미지파일: VI_bagging.png

2) Decision Tree (modeling1_decisiontree.R)
- 중요변수: inflow, outflow, enterprise, day_pop, distributor
- 이미지파일: VI_decisiontree.png

3) Random Forest (modeling1_randomfrest.R)
- 중요변수: inflow, enterprise, outflow, university, distributor
- 이미지파일: VI_randomforest.png

## 2. Modeling2_*** : 근거리 수소충전소 변수와 수소차 대수의 상관관계 분석 (car_v2.csv 활용)
#### GLM Modeling2 결과
rank1~rank4까지 모두 유의미한 상관관계

## 3. Modeling3_*** : 최종예측모델 선정
#### 목표: MSE 계산을 통해, 해석력과 예측력을 골고루 갖춘 모형 선택
- DecisionTree: 27.86282 (modeling3_decisiontree.R)
- GLM: 5.76 (modeling3_glm2.R)
#### MSE가 더 작은 GLM 선택

#### 본 폴더에는 습작도 포함되어 있다.
- 습작1. modeling1_adaboost.R: Error in if (nrow(object$splits) > 0) { : 인자의 길이가 0입니다
- 습작2. modeling1_bagging.R: Error in if (nrow(object$splits) > 0) { : 인자의 길이가 0입니다
- 습작3. modeling1_bagging3.R
- 습작4. modeling3_glm.R: glm2를 위한 초석
- 습작5. modeling3_glm3.R: 부적절한 설명변수가 너무 많았다.
