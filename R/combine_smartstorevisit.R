#combine ssvist
f=list.files(pattern='^ssvisit_')
dsetssvisit=f %>% map(function(x){readRDS(x)})
length(dsetssvisit)
ss_visit <- bind_rows(dsetssvisit)
dim(ss_visit)

names(smart_store_data)
smart_store_data <- smart_store_data %>% inner_join(ss_visit)
smart_store_data <- smart_store_data %>% inner_join(ss_grade_zzim)
dim(smart_store_data)
saveRDS(smart_store_data,file='smart_store_data.rds')

View(smart_store_data)
clipr::write_clip(smart_store_data)
