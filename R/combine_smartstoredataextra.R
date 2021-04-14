source('combine_smartstoredataextra.R')
f=list.files(pattern='^smartstore_extra_')
dset=f %>% map(function(x){readRDS(x)})
ss_datalab_dist=dset %>% map(transform_smartstore_datalab_distribution) %>% bind_rows()
ss_profile=dset %>% map(transform_smartstore_profile) %>% bind_rows()
ss_grade_zzim = dset %>% map(extract_smartstore_grade_zzim) %>% bind_rows()
saveRDS(ss_datalab_dist,'ss_datalab_dist.rds')
saveRDS(ss_profile,'ss_profile.rds')
dim(ss_profile)
dim(ss_datalab_dist)
smartstores$myid <- as.character(smartstores$myid)
ss1 <- smartstores %>% inner_join(ss_grade_zzim)
ss1 <- ss1 %>% inner_join(ss_profile)
names(ss1)

ss_grade_zzim <- ss1 %>% select(id,grade,zzim)
saveRDS(ss_grade_zzim,'ss_grade_zzim.rds')



ss <- smartstores %>% inner_join(ss_profile)
dim(ss)
View(ss_datalab_dist)

v=ss_datalab_dist %>% select(myid,age,rating)
v1 <- v %>% tidyr::spread(key=age,value=rating)
View(v1)
names(v1)[2:7] <- paste("age_rating_",names(v1)[2:7],sep='')

ss1 <- ss %>% inner_join(v1)
dim(ss1)
smart_store_data <- ss1
saveRDS(smart_store_data,file='smart_store_data.rds')
names(smart_store_data)
smart_store_data$myid=NULL
View(smart_store_data)
