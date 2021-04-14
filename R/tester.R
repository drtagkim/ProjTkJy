#tester
source("R/browser.R")
source("R/smartstore.R")

# Tester ------------------------------------------------------------------
## Data collection test - for all category
smartstores=collect_smart_store()
saveRDS(smartstores,'smartstores.RDS')

## Data collection test - clothing
smartstores.cloting <- collect_smart_store(politely = 2,                #3 seconds wait
                                           category = categoryClothing) #clothing up to 100 pages (Naver provided in limit)
saveRDS(smartstores.cloting,'smartstores.cloting.RDS')

smartstores.shoes <- collect_smart_store(politely = 2,                #3 seconds wait
                                           category = categoryShoes) #shoes up to 100 pages (Naver provided in limit)
saveRDS(smartstores.shoes,'smartstores.shoes.RDS')

smartstores.cosmetics <- collect_smart_store(politely = 2,                #3 seconds wait
                                         category = categoryCosmetics) #cosmetics up to 100 pages (Naver provided in limit)
saveRDS(smartstores.cosmetics,'smartstores.cosmetics.RDS')
#
smartstores.living <- collect_smart_store(politely = 2,                #3 seconds wait
                                             category = categoryLiving) #cosmetics up to 100 pages (Naver provided in limit)
saveRDS(smartstores.living,'smartstores.living.RDS')
#
smartstores.food <- collect_smart_store(politely = 2,                #3 seconds wait
                                          category = categoryFood) #cosmetics up to 100 pages (Naver provided in limit)
saveRDS(smartstores.food,'smartstores.food.RDS')
#
smartstores.parenting <- collect_smart_store(politely = 2,                #3 seconds wait
                                        category = categoryParenting) #cosmetics up to 100 pages (Naver provided in limit)
saveRDS(smartstores.parenting,'smartstores.parenting.RDS')
#
smartstores.sports <- collect_smart_store(politely = 2,                #3 seconds wait
                                             category = categorySports) #cosmetics up to 100 pages (Naver provided in limit)
saveRDS(smartstores.sports,'smartstores.sports.RDS')
#
smartstores.digital <- collect_smart_store(politely = 2,                #3 seconds wait
                                          category = categoryDigital) #cosmetics up to 100 pages (Naver provided in limit)
saveRDS(smartstores.digital,'smartstores.digital.RDS')
#
smartstores.etc <- collect_smart_store(politely = 2,                #3 seconds wait
                                       category = categoryEtc) #cosmetics up to 100 pages (Naver provided in limit)
saveRDS(smartstores.etc,'smartstores.etc.RDS')


# Combine -----------------------------------------------------------------

smartstores.cloting <- readRDS("smartstores.cloting.RDS")
smartstores.shoes <- readRDS("smartstores.shoes.RDS")
smartstores.cosmetics <- readRDS("smartstores.cosmetics.RDS")
smartstores.living <- readRDS("smartstores.living.RDS")
smartstores.food <- readRDS("smartstores.food.RDS")
smartstores.parenting <- readRDS('smartstores.parenting.RDS')
smartstores.sports <- readRDS('smartstores.sports.RDS')
smartstores.digital <- readRDS('smartstores.digital.RDS')
smartsotres.etc <- readRDS("smartstores.etc.RDS")
#
View(smartstores.cloting)
smartstores <- bind_rows(
  smartstores.cloting,
  smartstores.shoes,
  smartstores.cosmetics,
  smartstores.living,
  smartstores.food,
  smartstores.parenting,
  smartstores.sports,
  smartstores.digital,
  smartsotres.etc
)
str(smartstores)
saveRDS(smartstores,'smartstore_browsing_2021-0413.rds')
clipr::write_clip(smartstores)
