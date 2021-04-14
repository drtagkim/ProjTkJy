#smartstore visit count
suppressMessages({
  library(tidyverse,quietly = TRUE)
  library(rvest,quietly = TRUE)
  library(progress,quietly = TRUE)
  library(jsonlite,quietly = TRUE)
})

smart_store_data <- readRDS('smart_store_data.rds')

smartStoreVisitCount <- function(u) {
  url = paste0('https://smartstore.naver.com/i/v1/visit/',u,sep='')
  r=fromJSON(url) ; Sys.sleep(1)
  pb$tick()
  r$total
}

args=commandArgs(trailingOnly = TRUE)
mi=as.numeric(args[1])
ma=as.numeric(args[2])
ofn=args[3]

cat("==== Smart Store Visit Data Collection ====\n")
ids <- smart_store_data$id[mi:ma]
pb <- progress_bar$new(total=length(ids))
x <- ids %>% map_dbl(smartStoreVisitCount)
y <- tibble(id=ids,total_visit=x)
saveRDS(y,ofn)
cat("File saved:",ofn,"\nBye.\n")