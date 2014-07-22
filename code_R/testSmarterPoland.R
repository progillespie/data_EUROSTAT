# Tutorial from http://rpubs.com/adam_dennett/8955

# Skipped the bit where I installed these...Just starting from loading them.
library("rgdal")
library("RColorBrewer")
library("sp")
library("GISTools")
library("classInt")
library("maptools")
library("SmarterPoland")

dir()
setwd("D:/Data/testSmarterPoland")


# create a new empty object called 'temp' in which to store a zip file
# containing boundary data
temp <- tempfile(fileext = ".zip")
# now download the zip file from its location on the Eurostat website and
# put it into the temp object
download.file("http://epp.eurostat.ec.europa.eu/cache/GISCO/geodatafiles/NUTS_2010_60M_SH.zip", 
              temp)
# now unzip the boundary data
unzip(temp)

#Your boundary data can now be converted into a spatial polygons data frame.
#This is a data format that R is able to work with. As these are boundaries 
#for the NUTS hierarchy, we'll give the dataframe a suitable name:
EU_NUTS <- readOGR(dsn = "./NUTS_2010_60M_SH/data", layer = "NUTS_RG_60M_2010")

#We can now plot our boundary data to see what it looks like:
plot(EU_NUTS)


#You'll notice that the EU looks a little squished - this is because the 
#projection is set to a default which distorts the map compared to what we
#commonly see. To get the projection information for the map, we can extract
#the PROJ.4 string:
proj4string(EU_NUTS)


#To project our map using a more familiar projection (such as the google maps
#projection many of us are used to seeing) we can set the projection using a 
#new PROJ.4 string. This can be carried out using the spTransform function:
EU_NUTS <- spTransform(EU_NUTS, CRS("+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs"))

#We can now re-plot our boundary data to see the changes that the new PROJ.4
#string makes:
plot(EU_NUTS)


#To obtain the PROJ.4 string for a whole variety of different projections 
#and datums, the spatialreference.org website is a very useful resource: 
#    http://www.spatialreference.org


#If you wish to browse the Eurostat database before starting this section, 
#go to: http://epp.eurostat.ec.europa.eu/portal/page/portal/statistics/search_database

#Here you can look at the various tables contained in the different 
#sub-folders and play with the alternative ways of chopping up the 
#'hypercube' data structures to create two-dimensional tabulations.

#Data can be downloaded from Eurostat in conventional csv or excel 
#tabulations, which are fine for day-to-day useage and can themselves be 
#read into R. It is also possible, however, to download data tables directly
#into R. To do this we will make use of the SmarterPoland package which is 
#able to read data directly from the Eurostat database and, perhaps even 
#more usefully, clean and format the data ready for analysis.

#First we will create a table of contents containing the table definitions 
#and table codes:
EurostatTOC <- getEurostatTOC()

#If you are using RStudio, you will be able to examine the contents of the 
#new EurostatTOC dataframe by double clicking on it in your workspace. If you 
#are not using RStudio, then you should be! But if for some weird reason 
#you're still resistant, then you can look at the top few rows of the data 
#frame using the head() function:
head(EurostatTOC)


#You should be able to see a number of columns including the title of each 
#table in the database and the code for that table.

#At this point we are now going to download some unemployment data from the 
#European Labour Force Survey. Yes, I know this is a practical about Census 
#data, so by all means find a Census table that interests you and apply 
#everything which follows below to that table. Unemployment data are quite 
#interesting though, so this is where we will focus the rest of this 
#ractical.

#The table we are interested in is "Unemployment rates by sex, age and NUTS 2 
#regions (%)" - table code lfst_r_lfu3rt

#We will download the data from this table in its 'molten' form. The molten 
#data format gives us the most flexibility for reformatting our data into a 
#useable table. For more infomation on the molten data format, 
#see: Wickham, H. (2007) Reshaping Data with the reshape Package, 
#       Journal of Statistical Software, 21(12) 
#       - http://www.jstatsoft.org/v21/i12/paper

#To download the lfst_r_lfu3rt in molten form, we will use the 
#getEurostatRCV()' function in the SmarterPoland package and store it in 
#a data frame called 'data':
data <- getEurostatRCV(kod = "lfst_r_lfu3rt")


#In order to reformat our data, we need to be aware of the different 
#variables contained within the dataset. To check this we can use the 
#unique() function to look at the different variables associated with age, 
#sex and time:
unique(data$age)
unique(data$sex)
unique(data$time)


#Now we are aware of the choice of variables available we should select a combination of time to map.

#For example we might want to look at the distribution of unemployment 
#across Europe for all people aged 20-64 in 2012. One way to select out 
#this data from the main data table would be to create a subset:
sub_data <- subset(data, (age == "Y20-64") & (sex == "T") & (time == "2012 "))


#This is fine, but every time we want to look at another combination of 
#variables (unemployed Females aged 15-24 in 2011, for example) we will 
#need to create a new subset. An alternative option is to rearrange our 
#data using the reshape package. Fortunately this package has already been 
#installed as part of the SmarterPoland package.

#For details on the conceptual framework underpinning the reshape package, 
#see Wickham (2007) mentioned above.

#We will now rearrange the data using the cast() function so that the data 
#frame contains a column for each of the variables combinations in our data 
#set - for example: 15-24, Male, 2012; 15-24, Female, 2012; 15-24, Total, 
# 2012, etc.
mapdata <- cast(data, geo ~ time + age + sex)


#As Wickham (2007) outlines, the casting formula has this basic form: 
#col_var_1 + col_var_2 ~ row_var_1 + row_var_2

#Because we want to combine all of the values contained in time (14 values),
#age (4 values), and sex (3 values) so that there is a unique combination 
#of each (14*4*3 = 168 new variables), these three values go on the 
#right-hand side of the function. We want to keep the individual values of 
#geo, so this goes on the left-hand side of the function. Try experimenting 
#with placing different variables on the left and right hand sides of the 
#cast function and see how the molten data are merged differently.

#As before, view a summary of your new data frame in either the RStudio 
#viewer or using the head() function:
head(mapdata)


#You will notice that the variable names are now just concatenations of the 
#original variable values.


#The EU_NUTS spatial polygons data frame you created earlier has a data 
#object associated with it. View the first few rows of data already 
#attached to the data object as follows:
head(EU_NUTS@data)


#You will see four columns containing data: The NUTS_ID which contains the 
#NUTS code for the particular boundary polygon; STAT_LEVL_ which indicates 
#whether the boundary is a NUTS0, NUTS1, NUTS2 or NUTS3 boundary (for 
#details of the differences, visit 
#http://epp.eurostat.ec.europa.eu/portal/page/portal/nuts_nomenclature/introduction); SHAPE_AREA which gives an indication of the size of the polygon; and SHAPE_LEN its length.

#We can use the common codes in the NUTS_ID field of our spatial polygons 
#data frame and the geo field in mapdata to combine the two dataframes. 
#This can be done using the match() function:
EU_NUTS@data = data.frame(EU_NUTS@data, mapdata[match(EU_NUTS@data[, "NUTS_ID"], 
                                                      mapdata[, "geo"]), ])

#The square brackets in this function allow us to match row data in the two 
#data frames by column vectors with the specific names NUTS_ID and geo. If 
#you now look at the data object of EU_NUTS using the head(EU_NUTS@data) 
#function, you'll see all of the columns from mapdata appended. You may 
#notice that these first few rows contain NULL values, but this is to be 
#expected as the data are at NUTS2 level and the first few polgons in the 
#spatial polygons data frame are at NUTS3 level.

#OK, now we're ready to get mapping!!

#At the start of this practical we imported the colorbrewer package. This 
#package allows you to choose from a variety of different, pleasing to the 
#eye, colour palettes. To examine the range, visit 
#http://colorbrewer2.org/. 
#In this example we will be using the RdPu palette, but by all means choose 
#your own and change the code below accordingly.

#We will opt for a 5 colour scheme and store this in a data frame called 
#my_colours
my_colours <- brewer.pal(5, "RdPu")

#Next we need to select the variable we are going to map and calculate the 
#breaks in the data which will define the colour ranges on the map. In this 
#example we will map the unemployment rates of all people aged 20-64 in 
#2012 (the X2012._Y20.64_T variable in our data frame).

#Defining the breaks in this variable can be achieved with the 
#classIntervals() function and then extracting the vector of breaks (brks) 
#from the function:
breaks <- classIntervals(EU_NUTS@data$X2012._Y20.64_T, n = 5, style = "fisher", 
                         unique = TRUE)$brks

#To save us attempting to define the best partitions in our data, here we 
#make use of the Fisher-Jenks natural breaks algorithm using the "fisher" 
#style option.

#Everything is now in place to plot your map. This can be done with a 
#simple call to the plot() function:
plot <- plot(EU_NUTS, col = my_colours[findInterval(EU_NUTS@data$X2012._Y20.64_T, 
                                                    breaks, all.inside = TRUE)], axes = FALSE, border = NA)


#If you wish, you can also add in the borders of the countries by first 
#creating a new spatial polygons dataframe containing just the country 
#(NUTS0 or STAT_LEVL 0) boundaries:
CountryBorder <- EU_NUTS[EU_NUTS@data$STAT_LEVL_ == 0, ]


#and then add these to your plot:
plot <- plot(CountryBorder, border = "#707070", add = TRUE)


#In order to add a legend, you will need to know the the coordinates for 
#the upper-left corner of the box that contains your legend. Do find these, 
#you can use the locator() function:
locator()


#This will allow you to click anywhere on your open map plot before 
#pressing escape to get generate the coordinates of where you clicked. 
#In this example, clicking somewhere in the north atlantic will generate 
#the following x and y coordinates which can then be included in the 
#legend() function:
plot <- legend(x = -6080915, y = 8730220, legend = leglabs(round(breaks, digits = 2), 
                                                           between = " to <"), fill = my_colours, bty = "n", cex = 0.7, title = "Unemployment Rate")


#To generate a PDF of your map all of the above code can be included 
#between a pdf() and a dev.off() function:
pdf("map.pdf", width = 10, height = 10, title = "Unemployment rates by sex, age and NUTS 2 regions (%)", 
    paper = "a4")
plot <- plot(EU_NUTS, col = my_colours[findInterval(EU_NUTS@data$X2012._Y20.64_T, 
                                                    breaks, all.inside = TRUE)], axes = FALSE, border = NA)
plot <- plot(CountryBorder, border = "#707070", add = TRUE)
plot <- legend(x = -6080915, y = 8730220, legend = leglabs(round(breaks, digits = 2), 
                                                           between = " to <"), fill = my_colours, bty = "n", cex = 0.7, title = "Unemployment Rate")
title("Total Unemployment rates 20-64 year olds, \nEU NUTS 2 regions (% of total workforce), 2012")
dev.off()
