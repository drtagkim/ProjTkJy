library(tidyverse)

f=list.files(pattern='^shoppinglive_profile_')
dset=f %>% map(function(x){readRDS(x)})
View(dset[[1]])
shopping_live_profile <- bind_rows(dset)
saveRDS(shopping_live_profile,'shopping_live_profile.rds')
