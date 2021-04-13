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
  r=tryCatch(fromJSON(u),error=function(e){
      NULL
    })
  if(is.null(r)) {
    if(verbose) {
      cat("No.\n")
    }
    return(NULL)
  }
  if(verbose) {
    cat("OK.\n")
  }
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
    v1 = tryCatch({u1 %>% fromJSON()},error=function(e){NULL})
    if(!is.null(v1)) {
      v1data=v1[[1]]
      broadcastOwnerId=cid
      products=v1data$displayProduct
      v1data$displayProduct=NULL
      v1data=cbind(broadcastOwnerId,v1data)
      if("broadcastId" %in% names(products)) {
        products$status=NULL
        v1data=left_join(v1data,products,by="broadcastId")
      }
      r[[cnt]] = v1data #append
      v1a = v1[[2]] #check next
      if(is.null(v1a)) break
      n=as.character(v1a)
      if(verbose) {
        cat("cnt:",cnt,"next:",n,"\n")
      }
      cnt = cnt +1
    } else {
      if(verbose) {
        cat("cnt:",cnt,"error\n")
      }
      break
    }
  }
  tryCatch(bind_rows(r),error=function(e) {NULL})
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
    r=tryCatch(fromJSON(uu),error=function(e) {NULL})
  })
  result
}

options(scipen=999)

collectVideoComments <- function(vid=107958,politely=1) {
  #vid=broadcst id
  #politely=1 sleeping
  comment_url=paste0("https://apis.naver.com/live_commerce_web/viewer_api_web/v1/broadcast/",
                     vid,
                     "/replays/comments?includeBeforeComment=false&size=100",sep='')
  comment_test=list()
  i=1
  nextCommentId=NULL
  while(TRUE) {
    cat(".")
    x1=parse_url(comment_url)
    if(!is.null(nextCommentId)) {
      x1$query$lastCommentNo=nextCommentId
    }
    x1=build_url(x1)
    x2=tryCatch(fromJSON(x1),error=function(e) {NULL})
    Sys.sleep(politely)
    x3=x2$comments
    if(!is.null(x3)) {
      comment_test[[i]]=x3
      x3comment=x3$commentNo[nrow(x3)]
      i=i+1
      if(!x2$hasNext) {
        #if((!is.null(nextCommentId)) && nextCommentId==x3comment) {
        cat("End\n")
        break
      }
    }
    if(i%%50==0) cat("Next\n")
    nextCommentId=x2$lastCommentNo
  }
  comments=bind_rows(comment_test)
  rv=comments %>% distinct()
  rv$id=NULL
  rv
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
# test 1 to 100
library(foreach)
channel_profile_1_50=list()
for(i in 1:50) {
  channel_profile_1_50[[i]]=collectChannelProfile(i,verbose=TRUE)
}
channel_profile_1_50=bind_rows(channel_profile_1_50)
View(channel_profile_1_50)
#
channel_data=list()
for(i in 1:50) {
  channel_data[[i]]=collectViedoItemsShoppingLive(i,politely=2,verbose=TRUE)
}
channel_data=bind_rows(channel_data)
#
channel_data_extra=channel_data %>%
  collectViedoItemsShoppingLiveUserData(verbose=TRUE) %>%
  bind_rows()
channel_data_binded=channel_data %>% left_join(channel_data_extra,by='broadcastId')
readr::write_csv(channel_data_binded,'channel_data_binded.csv')
readr::write_csv(channel_profile_1_50,'channel_profile.csv')



# Comment -----------------------------------------------------------------

v1=collectVideoComments()
v2=collectVideoComments(92721)
saveRDS(v2,"comment92721.RDS")

clipr::write_clip(v2)
