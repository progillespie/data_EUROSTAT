## Get the package if you don't have it
# install.packages("devtools")
# require("devtools")
# install_github("rsdmx", "opensdmx")

library(rsdmx)
library(data.table)
library(RCurl)
library(XML)
# Example from Eurostat getting started portal at: 
#    http://epp.eurostat.ec.europa.eu/portal/page/portal/sdmx_web_services/getting_started/a_few_useful_points
# To build the query URL matching the following ...
#http://ec.europa.eu/eurostat/SDMX/diss-web/rest/data/nama_gdp_c/.EUR_HAB.B1GM.DE+FR+IT?startPeriod=2010&endPeriod=2013

root        <- "http://ec.europa.eu/eurostat/SDMX/diss-web/rest"
resource    <- "data"
flowRef     <- "nama_gdp_c"
key         <- ".EUR_HAB.B1GM.DE+FR+IT"
time.filter <- "?startPeriod=2010&endPeriod=2013"
#query <- paste(root,resource,flowRef,paste(key,time.filter, sep=""), sep="/")
query <- "http://ec.europa.eu/eurostat/SDMX/diss-web/rest/dataflow/ESTAT/all/latest"
sdmx_xml_file <- xmlParse(query)
data  <- data.table(as.data.frame(readSDMX(sdmx_xml_file, isURL=F)))
#data

# OR specifiy a filepath and set isURL=F

#file  <- "aact_ali01.sdmx/aact_ali01.sdmx.xml"
#file  <- "tsc00001.sdmx/tsc00001.sdmx.xml"

#data  <- data.table(as.data.frame(readSDMX(file, isURL=F)))

