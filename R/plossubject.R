# Function to search PLoS Journals, by subject

plossubject <- 
# Args:
#   subject: search terms for article subject (character)
#   fields: fields to return from search (character) [e.g., 'id,title'], 
#     any combination of search fields [see plosfields$field] 
#   limit: number of results to return (integer)
#   results: print results or not (TRUE or FALSE)
# Examples:
#   plossubject('ecology', 'subject', 9, 'FALSE')
#   plossubject('ecology',  limit = 5, results = 'TRUE')
#   plossubject('ecology',  'subject', limit = 99, results = 'TRUE')

function(subject, fields = NA, limit = NA, results = FALSE, 
  url = 'http://api.plos.org/search',
  key = getOption("PlosApiKey", stop("need an API key for PLoS Journals")),
  ..., 
  curl = getCurlHandle() ) 
{
  args <- list(apikey = key)
  if(!is.na(subject))
    args$q <- paste('subject:', subject, sep="")
  if(!is.na(fields))
    args$fl <- fields
  if(!is.na(limit))
    args$rows <- limit
  args$wt <- "json"
  tt <- getForm(url, 
    .params = args,
    ...,
    curl = curl)
  jsonout <- fromJSON(I(tt))
  tempresults <- jsonout$response$docs
  numres <- length(tempresults) # number of search results
  names(numres) <- 'Number of search results'
  dfresults <- data.frame( do.call(rbind, tempresults) )
  if (results == "TRUE") { return(list(numres, dfresults)) }
    else { return(numres) }
}