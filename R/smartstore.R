#smartstore
#taekyung kim
#updated 2021-04-09


# Literal -----------------------------------------------------------------

getUrlNs <- function() "https://search.shopping.naver.com/allmall"

# Control -----------------------------------------------------------------



# Static page experiment --------------------------------------------------

categoryClothing <- function(u) paste(u,'repCatNm=CLOTHING',sep='&')
categoryShoes <- function(u) paste(u,'repCatNm=SHOES',sep='&')
categoryCosmetics <- function(u) paste(u,'repCatNm=COSMETICS',sep='&')
categoryLiving <- function(u) paste(u,'repCatNm=LIVING',sep='&')
categoryFood <- function(u) paste(u,'repCatNm=FOOD',sep='&')
categoryParenting <- function(u) paste(u,'repCatNm=PARENTING',sep='&')
categorySports <- function(u) paste(u,'repCatNm=SPORTS',sep='&')
categoryDigital <- function(u) paste(u,'repCatNm=DIGITAL',sep='&')
categoryEtc <- function(u) paste(u,'repCatNm=ETC',sep='&')

#static test
collectNssItems <- function(p=1,category=NULL) {
  u=sprintf('https://search.shopping.naver.com/allmall/api/allmall?page=%d&sortingOrder=prodClk&isSmartStore=Y',p)
  if(!is.null(category)) {
    u=category(u) 
  }
  page=read_html(u)
  page %>% html_element('p') %>% html_text() %>% fromJSON()
}



# Dynamic page experiment -------------------------------------------------

checkSmartStore <- function(b) {
  code='#__next > div > div:nth-child(2) > div.mallList_mall_list__20gDk > div > div.mallFilter_btn_area__1uYIL > a.mallFilter_btn_smart__2AHAj'
  b %>% click(code)
}
#dynamic
collectNssItems2 <- function(b,p=1) {
  u=sprintf('https://search.shopping.naver.com/allmall/api/allmall?page=%d&sortingOrder=prodClk&isSmartStore=Y',p)
  b %>% navigate(u)
  x=b$Runtime$evaluate('document.body.innerHTML')
  if(x$result$value=='<pre style=\"word-wrap: break-word; white-space: pre-wrap;\">[]</pre>') return(NULL)
  x1=read_html(x$result$value)
  x2=fromJSON(x1 %>% html_element('pre') %>% html_text())
  return(x2)
}

collect_smart_store<-function(stopping=NULL,politely=2,category=NULL) {
  items_collected = list()
  item=list()
  page=1
  while(TRUE) {
    cat("Page..",page)
    item=collectNssItems(page,category)
    Sys.sleep(politely)
    if(length(item)<=0) {
      cat("no more page.\n")
      break
    }
    if(!is.null(stopping)) {
      if(page>=stopping) {
        cat("stopping rule satisfied.\n")
        break
      }
    }
    items_collected[[page]]=item
    page=page+1
    cat("..OK..Next.\n")
  }
  result=bind_rows(items_collected)
  cat("---------\n")
  cat(' summary \n')
  cat('N of rows =',nrow(result))
  cat('\n')
  result
}
