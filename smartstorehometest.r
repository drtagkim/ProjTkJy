#smartstorehometest.r

url<-"https://smartstore.naver.com/ssg01?NaPm=ct%3Dknfbh25c%7Cci%3Df0b2d14049cd73890eb4f26785b61180a7f8634b%7Ctr%3Dsl%7Csn%3D358251%7Chk%3De6ef3006578b52d1a2979c83dfe11198be8fc27c"
library(rvest)
library(tidyverse)
page <- read_html(url)
x1<-page %>% html_element('body > script:nth-child(2)') %>% html_text()
x1a <- x1 %>% stringr::str_remove('window.__PRELOADED_STATE__=')

x2<-fromJSON(x1a)
View(x2)
smartstorechannelid=x2[["smartStore"]][["channel"]][["id"]]

x1 <- fromJSON("https://smartstore.naver.com/i/v1/seller/individual-info/500153736")

x1 <- page %>% html_element("#container > div > div > div > div > a") %>% html_attr('href')
url1 <- paste0('https://smartstore.naver.com',x1)
page1 <- read_html(url1)
x1<-page %>% html_element('body > script:nth-child(2)') %>% html_text()
x1a <- x1 %>% stringr::str_remove('window.__PRELOADED_STATE__=')
x2a<-fromJSON(x1a)
View(x2a)
#
b <- factoryChrome()
b$Page$navigate(url1)
x1<-b$Runtime$evaluate('document.querySelector("body > script:nth-child(2)").innerHTML')
x1<-x1$result$value
x1a <- x1 %>% stringr::str_remove('window.__PRELOADED_STATE__=')
x2a<-fromJSON(x1a)
View(x2a)
b$close()
#
b <- factoryChrome()
b$Page$navigate(url)
x1<-b$Runtime$evaluate('document.querySelector("body > script:nth-child(2)").innerHTML')
x1<-x1$result$value
x1a <- x1 %>% stringr::str_remove('window.__PRELOADED_STATE__=')
x2a<-fromJSON(x1a)
View(x2a)
b$close()



