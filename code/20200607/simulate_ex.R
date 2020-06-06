library(tidyverse)
#simulation from glm model
col_model <- colnames(data)
col_model
str(car_gu)
data_new <- car_gu[,1:35] %>%
  full_join(gas, by ="gu") %>%
  select(all_of(col_model), lat, lng) %>% 
  mutate(d1 = r1, d2 = r2, before_car = Hyd_car) %>% 
  select(-c(r1,r2, Hyd_car))

data_new

loc_data <- car %>% 
  mutate(idx = row_number()) %>% 
  select(idx, gu, dong ,lat, lng)
  
#Edit here idx number
new_gas <- loc_data[loc_data$idx ==150,]
new_gas
data_dist <- data_new %>% 
  mutate(d3 = sqrt((lat - new_gas$lat)^2+
           (lng - new_gas$lng)^2)) %>%  
  select(d1,d2,d3)

r1 <-apply(data_dist, 1, min)
r2 <- apply(data_dist, 1, median)

#generate simulation data
data_simul <- data_new %>% 
  select(-c(d1,d2, lat, lng)) %>% 
  data.frame( r1, r2)

# simulating by glm 
simul_result <- data.frame(gu =car_gu$gu,
           before = data_simul$before_car,
           before_pred = predict(modFit_repeatedcv, data), 
           after_pred = predict(modFit_repeatedcv, data_simul))

#compare before, after
apply(simul_result[,3:4],2, sum)
