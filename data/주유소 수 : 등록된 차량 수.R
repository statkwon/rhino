# 차량 등록 대수
registered_car = read.table('서울시 자동차 등록 현황.txt', header=T)
registered_car = registered_car[-c(1,2),]
registered_car = registered_car[,-1]
registered_car = registered_car[,c('자치구', '합계', '승용차', '승합차', '화물차', '특수차', '이륜차')]
registered_car = registered_car[-26,]
rownames(registered_car) = 1:25

# 주유소 갯수
library(readxl)
gas_station = read_xlsx('서울시 주유소 수.xlsx')
gas_station = gas_station[gas_station$업태구분명=='주유소',]
gas_station = gas_station[gas_station$영업상태명!='폐업',]
gas_station = gas_station[,c('소재지전체주소', '도로명전체주소', '사업장명')]
gas_station = gas_station[c(grep('서울특별시', gas_station$소재지전체주소), grep('서울특별시', gas_station$도로명전체주소)),]

colSums(is.na(gas_station))
for(i in 1:nrow(gas_station)){
 if(is.na(gas_station[i,1])==TRUE){
   gas_station[i,1] = gas_station[i,2]
}
}
colSums(is.na(gas_station))
gas_station = gas_station[,-2]

for(i in 1:nrow(gas_station)){
  gas_station$소재지전체주소[i] = strsplit(gas_station$소재지전체주소, ' ')[[c(i, 2)]]
}

gas_station$소재지전체주소 = as.factor(gas_station$소재지전체주소)
gas_station = summary(gas_station$소재지전체주소)
gas_station = data.frame(names(gas_station), gas_station)
rownames(gas_station) = 1:25 ; colnames(gas_station) = c('자치구', '주유소 갯수')

# Y변수 생성
merge(gas_station, registered_car, by='자치구')
Y = merge(gas_station, registered_car, by='자치구')
Y = Y[,c(1,2,3)]
Y$합계 = gsub(',', '', Y$합계)
Y$합계 = as.numeric(Y$합계)
Y[,4] = Y[,2]/Y[,3]
colnames(Y)[4] = '주유소 갯수/등록된 차량수'