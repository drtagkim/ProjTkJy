#browser
#taekyung kim
#updated 2021-04-09

library(chromote,quietly = TRUE)
library(dplyr,quietly = TRUE)
library(rvest,quietly = TRUE)
library(jsonlite,quietly = TRUE)

factoryChrome <- function(visible=FALSE) {
  b=ChromoteSession$new()
  if(visible) b$view()
  return(b)
}
navigate <- function(b,u,waitSec=5) {
  invisible({
    b$Page$navigate(u,wait_=FALSE)
    b$Page$loadEventFired()
    Sys.sleep(waitSec)
  })
}
click <- function(b,code) {
  x=sprintf('document.querySelector("%s").click();',code)
  invisible({
    b$Runtime$evaluate(x)
  })
}
