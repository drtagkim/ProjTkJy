#smartstore
#taekyung kim
#updated 2021-04-09


# Literal -----------------------------------------------------------------

getUrlNs <- function() "https://search.shopping.naver.com/allmall"

# Control -----------------------------------------------------------------

checkSmartStore <- function(b) {
  code='#__next > div > div:nth-child(2) > div.mallList_mall_list__20gDk > div > div.mallFilter_btn_area__1uYIL > a.mallFilter_btn_smart__2AHAj'
  b %>% click(code)
}
collectNssItems <- function(b,p=1) {
  u=sprintf('https://search.shopping.naver.com/allmall/api/allmall?page=%d&sortingOrder=prodClk&isSmartStore=Y',p)
  b %>% navigate(u)
  x=b$Runtime$evaluate('document.body.innerHTML')
  if(x$result$value=='<pre style=\"word-wrap: break-word; white-space: pre-wrap;\">[]</pre>') return(NULL)
  x1=read_html(x$result$value)
  x2=fromJSON(x1 %>% html_element('pre') %>% html_text())
  return(x2)
}
