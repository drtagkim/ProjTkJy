# ============================================== #
# Naver Shopping Live Video Comments Collector
# Taekyung Kim(PhD)
# Kwangwoon University, Business School
# kimtk@office.kw.ac.kr
# Last update: 2021-04-16
# dependencies: tidyverse

#' @title Video Comment Linear Processor
#' @description This function is a processor that collect comments linearly.
#' @param comment_url Comment URL
#' @param politely Pace to hit the server
#' @param verbose Print a progress (T/F), default TRUE
#' @eval DataFrame 
videoCommentLinearProcessor <- function(comment_url,politely,verbose=TRUE) {
  #variables
  comment_test = list()
  i = 1
  nextCommentId = NULL
  #iteration
  while(TRUE) {
    if(verbose) {
      cat(".")
    }
    x1 = parse_url(comment_url) #parsing URL code
    #point to the next if needed
    if(!is.null(nextCommentId)) {
      x1$query$lastCommentNo=nextCommentId
    }
    #visit
    x1 = build_url(x1) #rebuild URL
    x2 = tryCatch(fromJSON(x1),error=function(e) {NULL})
    Sys.sleep(politely) #cool down
    x3 = x2$comments #if nothing, NULL
    if(!is.null(x3)) {
      comment_test[[i]] = x3 #writing data
      i = i+1
      if(!x2$hasNext) { #if nothing more
        if(verbose) {
          cat("End\n")  
        }
        break
      }
    }
    if(verbose) {
      if(i %% 50 == 0) cat("Next\n")
    }
    nextCommentId = x2$lastCommentNo #last comment ID updated
  }
  comments = bind_rows(comment_test)
  rv=comments %>% distinct()
  rv$id = NULL #remove meaningless item
  rv #return
}

#' @title Collect Naver Shopping Live Video Comments
#' @description Collect Naver Shopping Live Video Comments
#' @param vid Video ID
#' @param politely Pace to hit the server
#' @param dataProcessor algorithm videoCommentLinearProcessor
#' @param verbose Print a progress, default TRUE
collectVideoComments <- function(vid=107958,politely=1,dataProcessor=videoCommentLinearProcessor,verbose=TRUE) {
  if(verbose) {
    cat("Naver Shopping Live Comment Collector...\n")
    cat("..Video ID:",vid,'\n')
    cat("..Pick up pace:",politely,'second(s)\n')
    cat("..Progress(.).. Starting now...\n")
  }
  comment_url=paste0("https://apis.naver.com/live_commerce_web/viewer_api_web/v1/broadcast/",
                     vid,
                     "/replays/comments?includeBeforeComment=false&size=100",sep='')
  rv=dataProcessor(comment_url,politely,verbose)
  if(verbose) {
    cat("\nItems are collected.\n")
  }
  rv
}