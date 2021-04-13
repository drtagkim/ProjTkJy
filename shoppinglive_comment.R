videoCommentLinearProcessor <- function(comment_url,politely) {
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

collectVideoComments <- function(vid=107958,politely=1,dataProcessor=videoCommentLinearProcessor) {
  comment_url=paste0("https://apis.naver.com/live_commerce_web/viewer_api_web/v1/broadcast/",
                     vid,
                     "/replays/comments?includeBeforeComment=false&size=100",sep='')
  rv=dataProcessor(comment_url,politely)
  rv
}