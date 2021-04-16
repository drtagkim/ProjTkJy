suppressMessages({
  library(tidyverse)
  library(rvest)
  library(jsonlite)
  library(progress)
  library(tictoc)
})

# Function ----------------------------------------------------------------


collectChannelProfile <- function(cid,politely=1,verbose=FALSE) {
  if(verbose) {
    cat("Channel:",cid,"profile...")
  }
  
  u=paste("https://apis.naver.com/selectiveweb/selectiveweb/my/",cid,"/live-channel-profile",sep='')
  r=tryCatch(fromJSON(u),error=function(e){
    NULL
  })
  Sys.sleep(politely)
  if(is.null(r)) {
    if(verbose) {
      cat("No.\n")
    }
    return(NULL)
  }
  if(verbose) {
    cat("OK.\n")
  }
  pb$tick()
  tibble(
    broadcastOwnerId=r$broadcastOwnerId,
    serviceId=r$serviceId,
    serviceName=r$serviceName,
    broadcasterId=r$broadcasterId,
    nickname=r$nickname,
    storeHomeEndUrl=ifelse(is.null(r$storeHomeEndUrl),"",r$storeHomeEndUrl),
    isPlaceOwner=r$isPlaceOwner,
    hasCollabo=r$hasCollabo
  )
}


# Main --------------------------------------------------------------------


args=commandArgs(trailingOnly = TRUE)
mi=as.numeric(args[1])
ma=as.numeric(args[2])
ofn=paste("shoppinglive_profile_",mi,"-",ma,'.rds',sep='')
idx=mi:ma
#
tic()
pb <- progress_bar$new(total=length(idx))
### message
cat("Shopping Live profile collection.\n")
### ---- 
result <- idx %>% map(function(x) {
  collectChannelProfile(x,verbose=FALSE)
}) %>% bind_rows()
cat("\nEllapsed time:")
toc()
cat("File saving...",ofn,'...')
saveRDS(result,ofn)
cat("OK. Bye.\n")
pb$terminate()