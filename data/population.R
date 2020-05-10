X1 = read.csv('자치구단위 서울 생활인구 일별 집계표.csv', header=TRUE, fileEncoding='euc-kr')
head(X1)
X1 = X1[,c(3,4,10,11)]

result = data.frame(matrix(NA,25,4))
result[,1] = unique(X1$시군구명)[-1]

for(i in 1:25){
  result[i,2] = mean(subset(X1, 시군구명==unique(X1$시군구명)[i+1])[,2])
  result[i,3] = mean(subset(X1, 시군구명==unique(X1$시군구명)[i+1])[,3])
  result[i,4] = mean(subset(X1, 시군구명==unique(X1$시군구명)[i+1])[,4])
}

colnames(result) = c('시군구명', '총생활인구수', '주간인구수', '야간인구수')

write.csv(result, 'population.csv', row.names=FALSE, fileEncoding='euc-kr')
