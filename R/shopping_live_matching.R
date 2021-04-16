library(tidyverse)
names(smart_store_data)
names(shopping_live_profile)

isSS <- startsWith(shopping_live_profile$storeHomeEndUrl,'https://smartstore.naver.com')
table(isSS)
shopping_live_profile.ss <- shopping_live_profile[isSS,]
View(shopping_live_profile.ss)
hasId <- shopping_live_profile.ss$broadcasterId %in% smart_store_data$id
table(hasId)
test <- smart_store_data %>% left_join(
  {shopping_live_profile.ss %>%
      select(slid=broadcasterId) %>%
      mutate(isShoppingLive=TRUE)
    },by=c("id"="slid"))
names(test)
test$isShoppingLive[is.na(test$isShoppingLive)]=FALSE
table(test$isShoppingLive)
smart_store_data <- test
rm(test)


