setwd("/home/pseudo/Arbeitsfläche/Coursera/Getting_data/week4/Assignment")
library(data.table)
library(tibble)

## Task1 ## 
## Create a merged datset ##

fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"  ##fileURL
download.file(fileURL, "Dataset.zip") ##Download
unzip("Dataset.zip") ##Unzip

SubjectsTrain <- fread("/home/pseudo/Arbeitsfläche/Coursera/Getting_data/week4/Assignment/UCI HAR Dataset/train/subject_train.txt")
SubjectsTest <- fread("/home/pseudo/Arbeitsfläche/Coursera/Getting_data/week4/Assignment/UCI HAR Dataset/test/subject_test.txt")

ActivityyTrain <- fread("/home/pseudo/Arbeitsfläche/Coursera/Getting_data/week4/Assignment/UCI HAR Dataset/train/y_train.txt")
ActivityTest <- fread("/home/pseudo/Arbeitsfläche/Coursera/Getting_data/week4/Assignment/UCI HAR Dataset/test/y_test.txt") 

DataTrain <- fread("/home/pseudo/Arbeitsfläche/Coursera/Getting_data/week4/Assignment/UCI HAR Dataset/train/X_train.txt")
DataTest <- fread("/home/pseudo/Arbeitsfläche/Coursera/Getting_data/week4/Assignment/UCI HAR Dataset/test/X_test.txt")

Subjects <- rbind(SubjectsTest,SubjectsTrain)
head(Subjects)
setnames(Subjects,"V1","subject")
Activity <- rbind(ActivityTest,ActivityyTrain)
setnames(Activity,"V1","activity")
Data <- rbind(DataTest,DataTrain)

mergeddata <- cbind(Subjects,Activity,Data)

setkey(mergeddata, subject,activity)  ## Subjekt und Key fixieren

## Task2 ##

# Information for Mean and SD are stored in the features.txt in Column 2

Features <- fread("/home/pseudo/Arbeitsfläche/Coursera/Getting_data/week4/Assignment/UCI HAR Dataset/features.txt")

## Coluns are renamed for a better Overview

setnames(Features,names(Features),c("number", "featureName"))

## Subsetting to only mean od standard deviation

Features <- Features[grepl("mean|std",featureName)]

## To substract from raw data, where each variable is a measure ment and here with a list we have to introduce a new variable with the correct code

Features$featureCode <- paste0("V",Features$number)
names(mergeddata)

matching <- c(key(mergeddata), Features$featureCode)
extractedData <- mergeddata[, matching, with= F]


## Task 3 ##

# Information is stored in the activity_labels.txt file

ActivityNames <- fread("/home/pseudo/Arbeitsfläche/Coursera/Getting_data/week4/Assignment/UCI HAR Dataset/activity_labels.txt")

setnames(ActivityNames, names(ActivityNames), c("activity", "ActivityName"))


## Task 4 ##

## add activity names to dataset

finaldata <- merge(extractedData, ActivityNames, by="activity", all.x=T)

## Fix ActivityName as a key

setkey(finaldata, subject,activity, ActivityName) 

## Reshape datset from wide to long to have descriptive entries for each cod

finaldata <- data.table(melt(finaldata, key(finaldata), variable.name = "featureCode"))

## Reorder Columns and add feasture name

finaldata <- merge(finaldata, Features[, list(number, featureCode, featureName)], by = "featureCode", all.x=T)

## Task 5

## Create a tidy datset with average for each subject, activity and feature

setkey(finaldata, subject, ActivityName, featureName)

tidydata <- finaldata[, list(count= .N, average=mean(value)), by = key(finaldata)]
