#check channels

# Library -----------------------------------------------------------------

library(tidyverse)
library(rvest)
library(chromote)
library(httr)
library(pbapply)

# Functions ---------------------------------------------------------------

checkStart <- function(b,i) {
  b$Page$navigate(urls[i])
  Sys.sleep(0.5)
  x<-b$Runtime$evaluate('document.querySelector("title").innerHTML')
  !startsWith(x$result$value,'undefined')
}

collectChannelProfile <- function(cid,politely=2,verbose=FALSE) {
  if(verbose) {
    cat("Channel:",cid,"profile...")
  }
  Sys.sleep(politely)
  u=paste("https://apis.naver.com/selectiveweb/selectiveweb/my/",cid,"/live-channel-profile",sep='')
  r=fromJSON(u)
  if(verbose) {
    cat("OK.\n")
  } 
  tibble(
    broadcastOwnerId=r$broadcastOwnerId,
    serviceId=r$serviceId,
    serviceName=r$serviceName,
    broadcasterId=r$broadcasterId,
    nickname=r$nickname,
    storeHomeEndUrl=r$storeHomeEndUrl,
    isPlaceOwner=r$isPlaceOwner,
    hasCollabo=r$hasCollabo
  )
}

buildShoppingLiveChannelVideoList <- function(cid="12323",nextItem=NULL) {
  #url parsing
  base="https://apis.naver.com/selectiveweb/live_commerce_web/v1/broadcast-owner?limit=20&sort=LATEST&next"
  urlp=parse_url(base)
  urlp$path=paste(urlp$path,cid,"broadcasts",sep='/')
  if(!is.null(nextItem)) {
    urlp$query$`next`=nextItem
  }
  build_url(urlp)
}
collectViedoItemsShoppingLive <- function(cid,politely=2,verbose=FALSE) {
  if(verbose) {
    cat("Naver Shopping Live: ----- \n")
    cat(" Channel ID:",cid,"\n")
    cat(" Creating a video list.\n")
  }
  r=list()
  n=NULL
  cnt=1
  while(TRUE) {
    u1=buildShoppingLiveChannelVideoList(cid,nextItem = n)
    Sys.sleep(politely)
    v1 = u1 %>% fromJSON()
    r[[cnt]] = v1[[1]] #append
    v1a = v1[[2]] #check next
    if(is.null(v1a)) break
    n=as.character(v1a)
    if(verbose) {
      cat("cnt:",cnt,"next:",n,"\n")
    }
    cnt = cnt +1
  }
  bind_rows(r)
}

split_ids <- function(ids) {
  plan=list()
  i=0
  while(TRUE) {
    lowerbound=(i*20+1)
    upperbound=(i*20+20)
    if(upperbound>length(ids)) {
      upperbound=length(ids)
      plan[[i+1]]=ids[lowerbound:upperbound]
      break
    }
    plan[[i+1]]=ids[lowerbound:upperbound]
    i=i+1
  }
  plan
}
collectViedoItemsShoppingLiveUserData <- function(sl,politely=2,verbose=FALSE) {
  if(verbose) {
    cat("\n Collecting video data\n")
  }
  ids=unique(sl$broadcastId)
  result=list()
  batch=20
  j=1
  plan=split_ids(ids) #plan
  pu = "https://apis.naver.com/selectiveweb/selectiveweb/v1/lives/extras?duration=true&likeTotalCount=true&onAirViewerCount=false&viewerTotalCount=true&"
  result=pblapply(plan,FUN=function(x) {
    Sys.sleep(politely)
    idsmarker=paste("ids=",x,sep="",collapse="&")
    uu=paste(pu,idsmarker,sep='')
    fromJSON(uu)
  })
  result
}

# Test --------------------------------------------------------------------

## Channels
url= "https://shoppinglive.naver.com/channels"
urls=paste(url,1:999999,sep='/')
#test

b = ChromoteSession$new()
for(i in 67200:67300) {
  cat(i,'...next\n')
  b$Page$navigate(urls[i])  
  Sys.sleep(0.5)
  x<-b$Runtime$evaluate('document.querySelector("title").innerHTML')
  if(startsWith(x$result$value,'undefined')) {
    cat("End of channels:",i-1)
    break
  }
}
b$Page$close()

## Test
test.channel.12323="12323" #test channel id
## profile data
test.12323.profile <- test.channel.12323 %>% collectChannelProfile(verbose=TRUE)
## channel items
test.12323 <- test.channel.12323 %>%
  collectViedoItemsShoppingLive(politely=2,verbose=TRUE)
## video (item detail)
test.12323.data <- test.12323 %>%
  collectViedoItemsShoppingLiveUserData(verbose=TRUE) %>%
  bind_rows()
## save result
saveRDS(test.12323.profile,'channel_12323_profile.RDS')
saveRDS(test.12323,"channel_12323.RDS")
saveRDS(test.12323.data,"channel_12323_videos.RDS")

###

test.12323.bid = unique(test.12323$broadcastId)




length(test.12323.bid)
test=split_ids(test.12323.bid)
v1=collectViedoItemsShoppingLiveUserData(test.12323.bid) %>% bind_rows()
