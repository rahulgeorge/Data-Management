#Starting course on July 4th

#-----------------------------------------------------------------------------
#Data Sources

#United Nations - data.un.org
#Country Data - data.gov + data.gov/opendatasites #WOW
#Gapminder - Lot of data on human data
#Kaggle

#-----------------------------------------------------------------------------

#Managing Files
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
#Rename column names
chicago <- readRDS("./data/chicago.rds")
str(chicago)
names(chicago)
chicago <- rename(chicago, pm25 = pm25tmean2, dewpoint = dptp) #Renames the variables pm25tmean2 to pm25 & dptp to dewpoint in DF chicago

chicago <- mutate(chicago, tempcat2 = factor(tmpd > 80, labels = c("cold", "hot")))
hotcold <- group_by(chicago, tempcat) #Groups by the tempcat factor

summarise(hotcold, pm25 = mean(pm25), o3 = max(o3tmean2), no2 = median(no2tmean2)) #Summarises the new variables for both groups created by the factor variable
summarise(hotcold, pm25 = mean(pm25, na.rm = TRUE), o3 = max(o3tmean2), no2 = median(no2tmean2)) #Removes the NA in the mean in the above statement

chicago <- mutate(chicago, year = as.POSIXlt(date)$year + 1900)
years <- group_by(chicago, year)
summarise(years, pm25 = mean(pm25, na.rm = TRUE), o3 = max(o3tmean2), no2 = median(no2tmean2))

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

#Tidying Data with dplyr
by_package <- group_by(cran, package)
pack_sum <- summarize(by_package,
                      count = n(),
                      unique = n_distinct(ip_id),
                      countries = n_distinct(country),
                      avg_bytes = mean(size))

quantile(pack_sum$count, probs = 0.99) #Calculating the top 1% or 99th percentile
top_counts <- filter(pack_sum, count > 679)
View(top_counts) #Provides a full view


#Reading from MySQL

library(RMySQL)
ucscDB <- dbConnect(MySQL(), user="genome", host="genome-mysql.soe.ucsc.edu") #Got information from http://genome.ucsc.edu/goldenPath/help/mysql.html
result <- dbGetQuery(ucscDB, "show databases;") #Connects to MySQL to send a query and sends the MySQL query to show all databases; in the server
dbDisconnect(ucscDB) #Very important to disconnect

hg19 <- dbConnect(MySQL(), user="genome", db = "hg19", host="genome-mysql.soe.ucsc.edu")
allTables <- dbListTables(hg19) #All tables in DB
length(allTables)
allTables[1:5]

dbListFields(hg19, "affyU133Plus2") #Checking for all the fields in affy.. table
dbGetQuery(hg19, "select count(*) from affyU133Plus2") #Count of number of elements in the table. (Rows)\

affyData <- dbReadTable(hg19, "affyU133Plus2")
head(affyData)

query <- dbSendQuery(hg19, "select * from affyU133Plus2 where misMatches between 1 and 3") #misMatches is a column in the table #Stored remotely at DB
affyMis <- fetch(query) #Retrieves information from BD
quantile(affyMis$misMatches)
affyMisSmall <- fetch(query, n = 10) #Gets only a small set back using the same query we stored in the DB
dbClearResult(query)
dim(affyMisSmall)
dbDisconnect(hg19)

        #https://www.pantz.org/software/mysql/mysqlcommands.html
        #https://www.r-bloggers.com/2011/08/mysql-and-r/



#Reading from HDF5 - Hierarchical Data Format

 #To install follow the following steps
        # if (!requireNamespace("BiocManager", quietly = TRUE))
        #         install.packages("BiocManager")
        # BiocManager::install()
 #BiocManager::install(rhdf5)

library(rhdf5)
created = h5createFile("example.h5") #Creating an HDF5 file
created

created = h5createGroup("example.h5", "foo") #Create groups inside the HDF5
created = h5createGroup("example.h5", "baa")
created = h5createGroup("example.h5", "foo/foobaa")
h5ls("example.h5") #View contents of HDF5 file

A = matrix(1:10, nr=5, nc=2)
h5write(A, "example.h5", "foo/A") #Writes the matrix into the group foo
B <- array(seq(0.1,2.0,by = 0.1),dim=c(5,2,2))
attr(B, "scale") <- "litre"
h5write(B, "example.h5", "foo/foobaa/B")
h5ls("example.h5")

df <- data.frame(1L:5L, seq(0,1,length.out=5), c("ab","cde","fghi","a","s"), stringsAsFactors = FALSE)
h5write(df, "example.h5", "df") #Can pass a variable directly to the top group

readA <- h5read("example.h5", "foo/A")
readB <- h5read("example.h5","foo/foobaa/B")
readdf <- h5read("example.h5", "df")
readdf

h5write(c(12,13,14),"example.h5","foo/A", index=list(1:3,1))
h5read("example.h5","foo/A")


#Reading Data from the Web
con <- url("https://scholar.google.com/citations?user=HI-I6C0AAAAJ&hl=en")
htmlCode =  readLines(con)
close(con)
htmlCode

library(XML)
library(RCurl)
url <- getURL("https://scholar.google.com/citations?user=HI-I6C0AAAAJ&hl=en")
html <- htmlTreeParse(url, useInternalNodes = TRUE)
xpathSApply(html, "//title", xmlValue)
xpathSApply(html, "//td[@id='gsc_a_ac gs_ibl']", xmlValue) #Not6 working for me

 #Get from HTTR package
library(httr)
html2 <- GET("https://scholar.google.com/citations?user=HI-I6C0AAAAJ&hl=en")
content2 <- content(html2, as = "text")
parsedHtml <- htmlParse(content2, asText = TRUE)
xpathApply(parsedHtml, "//title", xmlValue)

pg1 <- GET("http://httpbin.org/basic-auth/user/passwd")
pg1 #This wont as error code 401 as we didnt login

pg2 <- GET("http://httpbin.org/basic-auth/user/passwd", authenticate("user","passwd"))
pg2
names(pg2)

google <- handle("http://google.com") #Setting a handle
pg1 <- GET(handle = google, path = "/")
pg2 <- GET(handle = google, path = "search")


#Reading Data from APIs

        #Twitter Info - https://developer.twitter.com/en/docs/twitter-api/early-access
        #API Key - 66hKsADgbVB2bLMIUbVfeTG3k
        #API Secret - tkt5XXlnWqa2PvnGyMxBKsSwhK9PQFHov7fXknfqfppZ8gKnG9
        #Bearer Token - AAAAAAAAAAAAAAAAAAAAAAtuRgEAAAAAIaMilMHo0u5pJ3fG2xJopGd8WgQ%3DZBAupmVNUmROrSp8hFl5AmT26pAmCrs1fBCFLiNMlzyYTwb6nn
        #Access Token - 1346191428-q6m8k9KdEhgawEw56jZoTUqJL3IloKwn8RpqyH4
        #Access Secret - yThR6z9lUpFc6G70IJrGRQ8MYGdQAwTyx3NaiQ89d7xDy

myapp <- oauth_app("tweetCoursera", key = "66hKsADgbVB2bLMIUbVfeTG3k", secret = "tkt5XXlnWqa2PvnGyMxBKsSwhK9PQFHov7fXknfqfppZ8gKnG9")
sig <- sign_oauth1.0(myapp, token = "1346191428-q6m8k9KdEhgawEw56jZoTUqJL3IloKwn8RpqyH4", token_secret = "yThR6z9lUpFc6G70IJrGRQ8MYGdQAwTyx3NaiQ89d7xDy")
homeTL <- GET("https://api.twitter.com/1.1/statuses/home_timeline.json", sig)
json1 <- content(homeTL)
library(jsonlite)
json2 <- jsonlite::fromJSON(toJSON(json1)) #converting from Robject to JSON to data frame using the jsonlite package
json2[1,1:4]



#Subsetting and Sorting

set.seed(13435)
x <- data.frame("var1" = sample(1:5), "var2" = sample(6:10), "var3" = sample(11:15))
x <- x[sample(1:5),]
x$var2[c(1,3)] <- NA

x[,1]
x[,"var1"]
x[1:2,"var2"]
x[(x$var1 <= 3 & x$var3 >11),]
x[(x$var1 <= 3 | x$var3 >15),]
x[x$var2>8,] #Has problem dealing with NA
x[which(x$var2 >8),] #Use which() to deal with NA

sort(x$var1)
sort(x$var1, decreasing = TRUE)
sort(x$var2, na.last = TRUE)

x[order(x$var1, x$var3),] #To order a dataframe 

        #plyr package
library(dplyr)
arrange(x,var1)

        #Adding rows and columns
x$var4 <- rnorm(5)
y <- cbind(x,rnorm(5)) #Binds at the right
y <- cbind(rnorm(5),y) #Binds at the left
y

        #Baltimore City Data
restData <- read.csv("./data/Restaurants.csv")
head(restData,n=3)
quantile(restData$cncldst, na.rm = TRUE)
quantile(restData$cncldst, probs = c(0.25,0.5,0.75,0.99))

table(restData$zipcode, useNA = "ifany") #useNA = IfAny will show the count of missing values as well. By default this is ommitted
table(restData$cncldst, restData$zipcode) #Creates a 2 dimensional table

        #Checking for missing values
sum(is.na(restData$cncldst)) #Returns the count of missing values
any(is.na(restData$cncldst)) 
all(restData$zipcode > 0) #Checks if all zipcode values are > 0
colSums(is.na(restData)) #Giuves count of NA for every column

table(restData$zipcode %in% c("21212", "21213"))
restData[restData$zipcode %in% c("21212", "21213"),] #Subsets the DF using the logical operator

        #Working with UC Berkley Admissions data
data("UCBAdmissions")
DF <- as.data.frame(UCBAdmissions)
str(DF)
summary(DF)

xt <- xtabs(Freq ~ Gender + Admit, data = DF) #Creates a table where Freq's information is shown within the table and Gender and Admin are on both axis
xt 
object.size(xt)


#Creating New Variables
restData <- read.csv(("./data/Restaurants.csv"))
        #Creating sequences
s1 <- seq(1,10,by=2) #Creates a sequence s1 with min value 1 & max value 10 and increaing each by 2
s2 <-seq(1,10,length = 3) #length of the sequenmce will eb 3

restData$nearMe <- restData$nghbrhd %in% c("Roland Park", "Homeland")
table(restData$nearMe)
restData$zipWrong <- ifelse(restData$zipcode < 0, TRUE, FALSE) #ifelse function definition
table(restData$zipWrong, restData$zipcode < 0) #Table between the new variable and a condition to check if it came properly

        #Creating categorical variables
restData$zipcode <- as.numeric(restData$zipcode)
restData$zipGroups <- cut(restData$zipcode, breaks = quantile(restData$zipcode, na.rm = TRUE)) #Cut command to break it up to some value (quantiles of zipcode). Returns a factor variabel
table(restData$zipGroups)
table(restData$zipGroups, restData$zipcode)

library(Hmisc)
restData$zipGroups <- cut2(restData$zipcode,g=4)

        #Creating Factor Variables
restData$zcf <- factor(restData$zipcode) #Creating a factor variable
restData$zcf[1:10]
yesno <- sample(c("yes","no"), size = 10, replace = TRUE)
yesnofac <- factor(yesno, levels = c("yes","no"))
relevel(yesnofac, ref = "yes") #Relevels the factor vairbale startying with yes. Not needed in this case.
as.numeric(yesnofac)


#Reshaping Data

library(reshape2)
head(mtcars)

        #Melting Data Set
mtcars$carname <- rownames(mtcars)
carMelt <- melt(mtcars, id = c("carname", "gear", "cyl"), measure.vars = c("mpg","hp")) #Creates a skinned down data set for ID values as 
                                                                                        #given with a separate row for each variable value defined
head(carMelt)
tail(carMelt)

        #Castind Data Set
cylData <- dcast(carMelt, cyl ~ variable)
cylData
cylData <- dcast(carMelt, cyl ~ variable, mean) #Taking the data set and reorganising it in different ways.
cylData

        #Averaging values
head(InsectSprays)
tapply(InsectSprays$count, InsectSprays$spray, sum)
spIns <- split(InsectSprays$count, InsectSprays$spray) #Another way - splitting
spIns 
sprCount <- lapply(spIns, sum)
sprCount
sapply(spIns, sum)

        #Plyr Package
library(plyr)
ddply(InsectSprays, .(spray), summarize, sum = sum(count))


#Merging Data 
reviews <- read.csv("./data/reviews.csv")
solutions <- read.csv("./data/solutions.csv")
head(reviews)
head(solutions)
names(reviews)
names(solutions)

mergedData <- merge(reviews, solutions, by.x = "solution_id", by.y = "id", all = TRUE)
head(mergedData)



#Editing Text Variable
list.files("./data")
cameraData <- read.csv("./data/cameras.csv")
names(cameraData)
tolower(names(cameraData)) #to convert all names to lower case
#strsplit function can be used to seperate names containing "."

fileUrl1 <- "https://dl.dropboxusercontent.com/u/7710864/data/reviews-apr29.csv"
download.file(fileUrl1, destfile = "./data/reviews.csv", method = "curl")
fileUrl2 <- "https://dl.dropboxusercontent.com/u/7710864/data/solutions-apr29.csv"
download.file(fileUrl2, destfile = "./data/solutions.csv", method = "curl")
reviews <- read.csv("./data/reviews.csv")
solutions <- read.csv("./data/solutions.csv")
head(reviews,2)

names(reviews) 
sub("_","",names(reviews)) #Substitues all underscores in names of review with nothing to remove them
gsub("_","",testName) #Removes all underscores in a name. The above method only removes the first one

#Finding Values - grep(), grepl()

grep("Alameda", cameraData$intersecti) #Searches for Alameda in the CameraData loaded earlier's intersection column
table(grepl("Alameda", cameraData$intersecti)) #grepl returns True when alameda appears and False else. Here creating a table for the same
cameraData2 <- cameraData[grepl("Alameda", cameraData$intersecti),] #Selects all rows where alameda is matched to a new variable

grep("Alameda", cameraData$intersecti, value = TRUE) #This returns the values instead of the index  
#Check for length of grep to see if the search doesnt return anything. Length will be 0

#useful string operations
library(stringr)
nchar("Rahul George") #Returns number of characters
substr("Rahul George",1,7) #Takes values from first through 7
paste("Rahul", "George")
str_trim("Rahul       ") #Removes the spaces


#Regular Expressions

        #Metacharacters are used to identify scenarios more speific and more extensively than can be matched literally.
        #Literally matching picks out specific instances of a word as searched
        
        # ^ represents start of a line ^i think will only return sentences starting with ithink
        # $ represents the end of the line, ex. morning$
        # [Bb][Uu][Ss][Hh] will match all the possible cases of the word Bush
        # ^[Ii] am will match all lines starting with I am with i in any case
        
        #You can specify a range of letter using [a-z] or [a-zA-Z] or [0-9]
        
        #When used inside the character class, ^ also means NOT
        #[^?.]$ indicates serching lined that do not end with ? or .
        
        # "." dot is a metacharacter as well which means it can be anything
        #9.11 will search for all instances where dot can be anything (one character) inbetween 9 & 11. Ex. 9-11, 9/11, 103.169.114.66, 9:11 am
        # Pipe opertor indicates or flood|fire indicates search for flood or fire. flood|earthquake|fire
        # ^[Gg]ood|[Bb]ad searches for G/good in start of line and B/bad anywhere int he line
        # ^([Gg]ood|[Bb]ad) both will be searched in beginning of the line
        # question mark indicates that the expression is optional
        #[Gg]eorge( [Ww]\.)? [Bb]ush - Will not necessarily need W in the middle to match
                #the escape "\" is used to indicate that the dot is not a meta character in this expression
        #(.*) * means any number, including none of the item 
                #(24, m, germany) or () both will match for the above
        # * is a greedy operator and will check for the longest possible match
                # ^s(.*)s will look for the longest expression between two s and wont consider if there is an s in between 2 s
                # ^s(.*?)s will reduce the greediness. not sure how!!
        # + means atleast one of the item
                #[0-9]+ (.*)[0-9]+ means atleast one number followed by another number with any charactwrs in between
        # {} are interval quantifiers that specify the minimum and maximum number of matches of an experession
                #[Bb]ush( +[^ ]+ +){1,5} debate will match all instances where Bush and debate is seperated by atleast 1 space
                #followed by something not a space followed by a space and will allow for 1 to 5 repeates of that type
                #In curly operator {m,n} is atleast m and not more than n, {m} means exactly m, {m,} means atleast m
        # \1 or \2 etc is used to remember the expression matched in ()
                # +([a-zA-Z]+) +\1 will match lines good night night baby or blah blah blah blah etc


#Working with Dates

d1 <- date()
d1
class(d1) #Character

d2 <- Sys.Date()
d2
class(d2) #Date

        # %d = day as number(0-31), %a = abbreviated weekday, %A = unabbreviated weekday, %m = month (00-12) 
        # %b = abbreviated month, %B = unabbreviated Month, %y = 2 digit year, %Y = four digit year

format(d2, "%a %b %d") #"Thu Jul 29"

x = c("1jan1960", "2jan1960","31mar1960","30jul1960")
z <- as.Date(x, "%d%b%Y")
z
z[1] - z[2]
as.numeric(z[1]-z[2])

weekdays(d2)
months(d2)
julian(d2)

library(lubridate) #Very useful to work with dates
ymd("20140108")
mdy("08/04/2013")
mdy("08042013")
dmy("03-04-2013")
ymd_hms("2011-08-03 10:15:03")
ymd_hms("2011-08-03 10:15:03", tz = "Pacific/Auckland")

