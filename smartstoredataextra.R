#runner set
smartstores$myid=1:nrow(smartstores) #pseudo ID
saveRDS(smartstores,'smartstores_extra_raw.rds')
# Function ----------------------------------------------------------------
library(foreach)
library(tidyverse)
source("R/browser.R")
collectExtraInfoSmartStore <- function(b,url_ss) {
  #b : browser (chromian)
  #url_ss : url of smart store
  get_profile_url <- function(u) {
    page <- read_html(u)
    x1<-page %>% html_element('body > script:nth-child(2)') %>% html_text()
    x1a <- x1 %>% stringr::str_remove('window.__PRELOADED_STATE__=')
    x2<-fromJSON(x1a)
    paste0('https://smartstore.naver.com',x2[["serverLocationPath"]])
  }
  url=get_profile_url(url_ss)
  #print(url)
  b %>% navigate(url)
  #collect main data
  x1 = b$Runtime$evaluate('document.querySelector("body > script:nth-child(2)").innerHTML')
  Sys.sleep(0.2)
  x1 = x1$result$value
  x1a = x1 %>% stringr::str_remove('window.__PRELOADED_STATE__=')
  x2a = fromJSON(x1a)
  # store grade
  x3 = b$Runtime$evaluate('document.querySelector("#container > div > div > div > div > div > div > div:nth-child(1) > span:nth-child(3)").innerHTML')
  x3a = x3$result$value
  Sys.sleep(0.2)
  # ZZim
  x4 = b$Runtime$evaluate('document.querySelector("#container > div > div > div > div > div > div > button > span > span").innerHTML')
  x4a = x4$result$value %>% stringr::str_remove_all(stringr::fixed(',')) %>% as.numeric()
  list(profile=x2a,grade=x3a,zzim=x4a)
}

transform_smartstore_profile <- function(x1) {
  rv=x1 %>%
    map_dfr(function(x){
      x2a=x$profile
      id=as.character(x2a[["smartStore"]][["channel"]][["id"]])
      channelServiceType=x2a[["smartStore"]][["channel"]][["channelServiceType"]]
      channelName=x2a[["smartStore"]][["channel"]][["channelName"]]
      channelUrl=x2a[["smartStore"]][["channel"]][["url"]]
      phoneNo=as.character(x2a[["smartStore"]][["channel"]][["contactInfo"]][["telNo"]][["phoneNo"]])
      instagram=x2a[["smartStore"]][["channel"]][["storeExposureInfo"]][["exposureInfo"]][["INSTAGRAM"]]
      facebook=x2a[["smartStore"]][["channel"]][["storeExposureInfo"]][["exposureInfo"]][["FACEBOOK"]]
      saleCount=as.numeric(stringr::str_remove_all(x2a[["smartStore"]][["channel"]][["saleCount"]],stringr::fixed(',')))
      fullAddressInfo=x2a[["smartStore"]][["channel"]][["businessAddressInfo"]][["fullAddressInfo"]]
      businessid=as.character(x2a[["smartStore"]][["channel"]][["identity"]])
      ratioFemale=as.numeric(x2a[["datalab"]][["A"]][["ratioFemale"]])
      ratioMale=as.numeric(x2a[["datalab"]][["A"]][["ratioMale"]])
      tag=paste(x2a[["datalab"]][["A"]][["tag"]],collapse=',')
      tibble(
        id=ifelse(!is.null(id),id,''),
        channelServiceType=ifelse(!is.null(channelServiceType),channelServiceType,''),
        channelName=ifelse(!is.null(channelName),channelName,''),
        channelUrl=ifelse(!is.null(channelUrl),channelUrl,''),
        phoneNo=ifelse(!is.null(phoneNo),phoneNo,''),
        instagram=ifelse(!is.null(instagram),instagram,''),
        facebook=ifelse(!is.null(facebook),facebook,''),
        saleCount=ifelse(!is.null(saleCount),saleCount,0),
        fullAddressInfo=ifelse(!is.null(fullAddressInfo),fullAddressInfo,''),
        businessid=ifelse(!is.null(businessid),businessid,''),
        ratioFemale=ifelse(!is.null(ratioFemale),ratioFemale,0.0),
        ratioMale=ifelse(!is.null(ratioMale),ratioMale,0.0),
        tag=ifelse(!is.null(tag),tag,''))
    })
  rv = cbind(myid=names(x1),rv)
  rv
}

transform_smartstore_datalab_distribution <- function(x1) {
  map2_dfr(x1,names(x1),function(item,n) {
    ratings=item$profile[["datalab"]][["A"]][["ratings"]]
    if(length(ratings)<=0) {
      ratings=NULL
    } else {
      ratings=cbind(myid=n,ratings)
    }
    ratings
  })
}


