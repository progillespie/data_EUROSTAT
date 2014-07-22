library(XML)

url <- "http://epp.eurostat.ec.europa.eu/NavTree_prod/everybody/BulkDownloadLis
ting"
xmlparsed <- xmlParse(file(url))

## obtain dataset node::
series_data <- getNodeSet(xmlparsed, "//Series")

if(length(series_data)==0){
  
  datasetnode <- xmlChildren( xmlChildren(xmlparsed)[[1]])[[2]]
  
  series_data<-xmlChildren(datasetnode)[ names(xmlChildren(datasetnode))=="Series"]
  
}

## prepare dataset

dataset.frame <- data.frame(matrix(ncol=3))
colnames(dataset.frame) <- c('REF_AREA', 'TIME_PERIOD', 'OBS_VALUE')
## loop over data

counter=1
for (i in 1: length(series_data)){
  if('Obs'%in%names(xmlChildren(series_data[[i]])) ){ ## To ignore empty //Series nodes
    for (j in 1: length(xmlChildren(series_data[[i]]))){
      dataset.frame[counter,1] <- xmlAttrs(series_data[[i]])['REF_AREA']
      dataset.frame[counter,2] <- xmlAttrs(series_data[[i]][[j]])['TIME_PERIOD']
      dataset.frame[counter,3] <- xmlAttrs(series_data[[i]][[j]])['OBS_VALUE']
      counter=counter+1
    }
  }
}


head(dataset.frame,5)