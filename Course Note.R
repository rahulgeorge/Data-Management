#Starting course on July 4th
dir.create("data") #Creates a new directory - data
dir.exists("data") #Checks if the current directory has a child directory data

fileURL <- "https://opendata.arcgis.com/api/v3/datasets/7055dbb02f0c4f14ab7ea3eb5ebfda42_0/downloads/data?format=csv&spatialRefId=3857"
download.file(fileURL, destfile = "./data/cameras.csv", method = "curl") # ./ puts the URL as relative #curl method is required to download from HTTPS 
list.files("./data")
dateDownloaded <- date() #Good to keep track when you downloaded the file

cameraData <- read.table("./data/cameras.csv", sep = ",", header = TRUE, quote = "") #No quotations in the file. 
head(cameraData)

#Reading excel
        #library(xlsx)
cameraData <- read.xlsx("./data/cameras.xlsx", sheetIndex = 1, header = TRUE)
colIndex < 2:3
rowIndex <- 1:4
cameraData <- read.xlsx("./data/cameras.xlsx", sheetIndex = 1, colIndex = colIndex, rowIndex = rowIndex) #Reading specific rows and columns
        #write.xlsx - Writing excel
        #XLConnect package for manipulating excel files

#Tags, Elements & Attributes
# start tag - <section>
# end tag - </section>
# empty tag - <line-break />
#Elements are specific examples of tags

#Attributes are components of labels as shown below
#<img src="jeff.jpg" />

#Reading XML
library(XML)
fileURL <- "./data/simple.xml"
doc <- xmlTreeParse(fileURL, useInternal = TRUE)
rootNode <- xmlRoot(doc) #Wrapper for the entire XML
xmlName(rootNode) #Name of the element
names(rootNode) #Names of all elements within
rootNode[[1]] #First Element
rootNode[[1]][[1]] #Still drilling down

xmlSApply(rootNode, xmlValue) #Sapply function for XML. xmlValue function returns the values for the xml or subsets

xpathSApply(rootNode, "//name", xmlValue) # //name accesses name element at any node level #Seperate book available for learning xpath
xpathSApply(rootNode, "//price", xmlValue) #Accesses price

#Accessing data from the web

fileURL <- getURL("https://www.espn.in/nfl/team/_/name/bal/baltimore-ravens")
doc <- htmlTreeParse(fileURL, useInternal = TRUE)
readHTMLTable(doc)

#Reading JSON - Javscript Object Notation
library(jsonlite)
jsonData <- fromJSON("https://api.github.com/users/jtleek/repos")
names(jsonData) #Shows the JASON headers and drills down further
names(jsonData$owner)
names(jsonData$owner$login)

myjson <- toJSON(iris, pretty = TRUE) #Converts IRIS data to JSON format. Pretty intends the JSON
iris2 <- fromJSON(myjson)
head(iris2)

#data.table package
library(data.table)
DF <- data.frame(x=rnorm(9), y=rep(c("a","b", "c"), each = 3), z = rnorm(9))
head(DF,3)

DT <- data.table(x=rnorm(9), y=rep(c("a","b", "c"), each = 3), z = rnorm(9))
head(DF,3)

tables() #command to view all the tables in memory
DT[2,] #subsetting rows
DT[DT$y == "b",] 

DT[c(2,3)] #If you just pass one variable, it subsets using rows. Little diff to data frame
DT[,c(2,3)] #This doesnt subset columns like in data frame. Really diverges from data frame
 #This is used to calculate values for variables with expressions.
DT[,list(mean(x),sum(z))] #you can pass a list of functions to perform on variables. Here x & z are columns where the function needs to be applied. No need for ""
DT[,table(y)]
DT[,w:=z^2] #Adds a new column w that is the square of the column z

DT2 <- DT
DT[,y:=2] #here when DT is changed DT2 created above will also get changed. Data table doesnt keep copies and this is helpful for memory management
 #For copying, use the copy function

DT[,m:= {tmp <- (x+z); log2(tmp+5)}] #Multiple statement column creation
DT[,a:= x>0] #Creates a new column with value of condition
DT[,b:= mean(x+w), by = a] #creates a new column b where the values of mean of x&z is taken but grouped by a which here is either TRUE or FALSE

 # .N integer with length 1 
DT <- data.table(x = sample(letters[1:3], 1E5, TRUE))
DT[, .N, by = x] #counts the number of times each values of x is in the data table

DT <- data.table(x = rep(c("a","b","c"), each = 100), y = rnorm(300))
setkey(DT, x)
DT['a'] #Quickly subsetting using a

DT1 <- data.table(x = c("a","a","b","dt1"), y = 1:4)
DT2 <- data.table(x = c("a","b","dt2"), z = 5:7)
setkey(DT1, x); setkey(DT2, x)
merge(DT1, DT2)

big_df <- data.frame(x = rnorm(1E6), y = rnorm(1E6))
file <- tempfile()
write.table(big_df, file = file, row.names = FALSE, col.names = TRUE, sep = "\t", quote = FALSE)
system.time(fread(file)) #fread function can be used to read data.table, it is a drop in substitute for read.table but much more efficient
system.time(read.table(file, header = TRUE, sep = "\t"))

#SWIRL NOTES
##Manipulating Data with dplyr

#dplyr package installed
library(dplyr)
mydf <- read.csv(path2csv, stringsAsFactors = FALSE) #path2CSV was created automatically in swirl
head(mydf)
cran <- tbl_df(mydf) #load the data into what the package authors call a 'data frame tbl' or 'tbl_df'
rm("mydf")
cran #Main use is printing. Check this out
 
 #dplyr supplies five 'verbs' that cover most fundamental data manipulation tasks: select(), filter(), arrange(), mutate(), and summarize().
 #subsetting columns using select
select(cran, ip_id, package, country) #Selects just these columns
select(cran, r_arch:country) #selects all columns from r_arch to country, similar to operating on numbers 1:5
select(cran, country:r_arch)
select(cran, -time) #Removes time column

 #Subsetting rows using filter
filter(cran, package == "swirl") #Only swirl downloads
filter(cran, r_version == "3.1.1", country == "US") #Can give multiple conditions comma seperated
filter(cran, !is.na(r_version))

 #Sorting using arrange
cran2 <- select(cran, size:ip_id)
arrange(cran2, ip_id) #Arrange in ascending order
arrange(cran2, desc(ip_id)) #Descending ip_id order
arrange(cran2, package, ip_id) #arranges first by package and then by ip_id
arrange(cran2, country, desc(r_version), ip_id)

cran3 <- select(cran, ip_id, package, size)
mutate(cran3, size_mb = size / 2^20) #Creating a new column based on values of another column

summarize(cran, avg_bytes = mean(size)) #collapses the entire data to show new value avg_bytes as calculated

#Grouping and Chaining with dplyr
by_package <- group_by(cran, package) #At the top of the output above, you'll see 'Groups: package', which tells us that this tbl has been grouped by the package variablw.
                                        #Now any operation we apply to the grouped data will take place on a per package basis.
summarise(by_package, mean(size)) #Summarise now gives mean for all the packages as it is grouped by package already

 # You should also take a look at ?n and ?n_distinct, so
 # that you really understand what is going on.

pack_sum <- summarize(by_package,
                      count = n(),
                      unique = n_distinct(ip_id) ,
                      countries = n_distinct(country),
                      avg_bytes = mean(size))

quantile(pack_sum$count, probs = 0.99) #Provides the top 1% 0.99 percetile of the downloaded packages based on count of download. Gives the values of count above which it is top 1%
top_counts <- filter(pack_sum, count > 679) #Getting all the top ones.
View(top_counts) #Provides a great view of the table
top_counts_sorted <- arrange(top_counts, desc(count))

#Chaining using dplyr
cran %>% #This operator is used to chain commands
        select(ip_id, country, package, size) %>% #No need to provide the prior package into the argument. Operator facilitates that
        mutate(size_mb = size / 2^20) %>%
        filter(size_mb <= 0.5) %>%
        arrange(desc(size_mb)) %>% 
        print #Print doesnt need the function paranthesis in chaining
