#' Base function to search PLoS Journals
#' @import RJSONIO RCurl
#' @param terms search terms (character)
#' @param fields fields to return from search (character) [e.g., 'id,title'], 
#'    any combination of search fields [type 'data(plosfields)', then 
#'    'plosfields']
#' @param toquery list specific fields to query (if NA, all queried)
#' @param start record to start at (used in combination with limit when 
#' you need to cycle through more results than the max allowed=1000)
#' @param limit number of results to return (integer)
#' @param url the PLoS API url for the function (should be left to default)
#' @param key your PLoS API key, either enter, or loads from .Rprofile
#' @param ... optional additional curl options (debugging tools mostly)
#' @param curl If using in a loop, call getCurlHandle() first and pass 
#'  the returned value in here (avoids unnecessary footprint)
#' @return Number of search results (vis = FALSE), or number of search in a table
#'    and a histogram of results (vis = TRUE).
#' @export
#' @examples \dontrun{
#' searchplos('ecology', 'id', limit = 2)
#' searchplos('ecology', 'id,publication_date', limit = 2)
#' searchplos('ecology', 'id', limit = 100)
#' searchplos('ecology', 'id,title', limit = 2)
#' searchplos(terms="*:*", fields='id', toquery='doc_type:full', start=0, limit=250)
#' searchplos(terms="*:*", fields='id', toquery='cross_published_journal_key:PLoSONE', start=0, limit=250)
#' searchplos(terms="*:*", fields='id', 
#'    toquery=list('cross_published_journal_key:PLoSONE', 'doc_type:full'), 
#'    start=0, limit=250)
#' }
searchplos <- 

function(terms = NA, fields = NA, toquery = NA, start = 0, limit = 1000, 
  url = 'http://api.plos.org/search',
  key = getOption("PlosApiKey", stop("need an API key for PLoS Journals")),
  ..., 
  curl = getCurlHandle() ) 
{
  args <- list()
  if(!is.na(toquery[[1]])) {
    if(length(toquery)==1) {args$fq <- toquery} else
        {args <- list(fq=toquery[[1]], fq=toquery[[2]])} } else
          NULL
  args$api_key <- key
  if(!is.na(terms))
    args$q <- terms
  if(!is.na(fields))
    args$fl <- fields
  if(!is.na(start))
    args$start <- start
  if(!is.na(limit))
    args$rows <- limit
  args$wt <- "json"
  
  argsgetnum <- args
#   message(paste(url, "q=", terms, , ,  sep = ''))
#   argsgetnum$rows <- 0
  getnum <- getForm(url, 
    .params = argsgetnum,
    ...,
    curl = curl)
  getnumrecords <- fromJSON(I(getnum))$response$numFound
  
  if(min(getnumrecords, limit) < 1000) {
    if(!is.na(limit))
      args$rows <- limit
    tt <- getForm(url, 
      .params = args,
      ...,
      curl = curl)
    jsonout <- fromJSON(I(tt))
    tempresults <- jsonout$response$docs
    numres <- length(tempresults) # number of search results 
    names(numres) <- 'Number of search results'
#     dfresults <- data.frame( do.call(rbind, tempresults) )
    dfresults <- do.call(c, tempresults)
    names(dfresults) <- NULL
    return(list(numres, dfresults))  
  } else
    { 
      gotothis <- min(getnumrecords, limit)
      getvecs <- seq(from=1, to=gotothis, by=500)
      args$rows <- 500
      dfresults_ <- list()
      for(i in 1:length(getvecs)) {
        args$start <- i
        tt <- getForm(url, 
          .params = args,
          ...,
          curl = curl)
        jsonout <- fromJSON(I(tt))
        tempresults <- jsonout$response$docs  
        dfresults_[[i]] <- data.frame( do.call(rbind, tempresults) )
      }
      dfresults__ <- do.call(rbind, dfresults_)
      names(getnumrecords) <- 'Number of search results'
      return(list(getnumrecords, dfresults__))
    }
}
# http://api.plos.org/search/?q=*:*&fl=id&fq=doc_type:full&rows=250&start=0&api_key=WQcDSXml2VSWx3P

# searchplos(terms="*:*", fields='id', 
#     toquery=list('cross_published_journal_key:PLoSONE', 'doc_type:full'), 
#     start=28400, limit=250)[[2]]