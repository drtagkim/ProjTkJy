#tester
source("R/browser.R")
source("R/smartstore.R")

# Tester ------------------------------------------------------------------

b=factoryChrome(TRUE)


b %>% navigate(getUrlNs()) %>% checkSmartStore()
Sys.sleep(10)
b %>% checkSmartStore()
items_collected = list()
item=list()
page=1
while(!is.null(item)) {
  cat("Page..",page)
  item=b %>% collectNssItems(page)
  items_collected[[page]]=item
  page=page+1
  cat("..OK\n")
  
}
