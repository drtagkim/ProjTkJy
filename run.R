source("R/browser.R")
collectExtraInfoSmartStore <- function(b,url_ss) {
  #b : browser (chromian)
  #url_ss : url of smart store
  get_profile_url <- function(u) {
    page <- read_html(u)
    x1<-page %>% html_element('body > script:nth-child(2)') %>% html_text()
    x1a <- x1 %>% stringr::str_remove('window.__PRELOADED_STATE__=')
    x2<-fromJSON(x1a)
    paste0('https://smartstore.naver.com',x2[["serverLocationPath"]],'/profile')
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

run <- function(mi,ma,outfilename) {
  MIN=mi
  MAX=ma
  smartstore_extra=list()
  b  <- factoryChrome() ; Sys.sleep(1)
  #b$view() ; Sys.sleep(1)
  cnt=1
  pb <- txtProgressBar(min=MIN,max=MAX,style=3)
  for(i in MIN:MAX) {
    url=smartstores[i,]$crUrl
    smartstore_extra[[cnt]] = tryCatch({b %>% collectExtraInfoSmartStore(url)},
                                       error=function(e) {list()})
    names(smartstore_extra)[length(smartstore_extra)]=i
    setTxtProgressBar(pb,i)
    cnt=cnt+1
  }
  b$close() ; Sys.sleep(1)
  close(pb)
  saveRDS(smartstore_extra,outfilename)
  cat("File saved:",outfilename,'\n')
}
smartstores=readRDS("smartstores_extra_raw.rds")
args=commandArgs(trailingOnly = TRUE)
mi=as.numeric(args[1])
ma=as.numeric(args[2])
ofn=args[3]
cat("---- Smart Store Extra Data Collection ----\n")
run(mi,ma,ofn)
cat("Bye.\n")