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

