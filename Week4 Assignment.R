#Managing the dataset
if(!file.exists("./workingData")) { 
        dir.create("./workingData") #Creating folder to operate in
}

fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL, destfile = "./workingData/dataset.zip") #Downloading the dataset
unzip(zipfile = "./workingData/dataset.zip", exdir = "./workingData") #Unzipping the dataset

#Loading required libraries
library(dplyr)

#Reading testing data
xTest <- read.table("./workingData/UCI HAR Dataset/test/X_test.txt")
yTest <- read.table("./workingData/UCI HAR Dataset/test/y_test.txt")
subjectTest <- read.table("./workingData/UCI HAR Dataset/test/subject_test.txt")

#Reading training data
xTrain <- read.table("./workingData/UCI HAR Dataset/train/X_train.txt")
yTrain<- read.table("./workingData/UCI HAR Dataset/train/y_train.txt")
subjectTrain <- read.table("./workingData/UCI HAR Dataset/train/subject_train.txt")

#Reading features description
features <- read.table("./workingData/UCI HAR Dataset/features.txt")

#Reading activity labels
activityLabels <- read.table("./workingData/UCI HAR Dataset/activity_labels.txt")



#Action 4 - Labeling dataset with descriptive variable names
colnames(xTest) <- features[,2] #Assigning feature names
colnames(yTest) <- "activityID"
colnames(subjectTest) <- "subjectID"

colnames(xTrain) <- features[,2]
colnames(yTrain) <- "activityID"
colnames(subjectTrain) <- "subjectID"

colnames(activityLabels) <- c("activityID", "activityType")

#Action 1 - Merges the training and the test sets to create one data set.
mergedTest <- cbind(yTest, subjectTest, xTest) #Merging all testing data to form ActivityID, SubjectID & Features
mergedTrain <- cbind(yTrain, subjectTrain, xTrain) #Merging all training data to form ActivityID, SubjectID & Features
completeData <- rbind(mergedTest, mergedTrain)

#Action 2 - Extracting Mean & Standard Deviation 
colNames <- colnames(completeData) #Extracting column names of the final merged dataset
meanStdVector <- (grepl("mean", colNames) | grepl("std", colNames)) #Searching for mean and standard deviation in column names
meanStdVector[c(1,2)] <- TRUE #Including the ActivityID & SubjectID columnns into the vector
meanStdData <- completeData[,meanStdVector] #Final modified data set containing only mean and standard deviation data

#Action 3 - Adding Descriptive Activity Names
meanStdData_withActivity <- merge(activityLabels, meanStdData, by = "activityID", all.y = TRUE)

#Action 5 - Creating an independent data set with the average of each variable for each activity and subject
by_activityType <- meanStdData_withActivity %>% #Grouping the mean and standard deviation data by activity type and subject ID. This will be stored as a tbl
        group_by(activityType, subjectID)

averageSummary <- by_activityType %>% #Summarising all variables across activity type and subject ID
        summarise_all(mean)

write.table(averageSummary, "./workingData/tidyData.txt", row.names = FALSE) #Writing the final output as a TXT file
