run_analysis <- {
    
## Getting & Cleaning Data Course Project
##
## This script performs the following tasks:
##  1) Get/merge training/test data sets from the link
##      https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
##  2) Extract the mean and standard deviation for each measurement
##  3) Rename the activities in the data set with descriptive activity names
##  4) Label the data set with descriptive variable names
##  5) Create a tidy data set with the average of each variable/activity/subject combination
    
## Step 1 - If not previously downloaded (!file.exists), get collected data from
##          the above URL and store it in ./data/Dataset.zip file.
##
##          Extract relevant data from it and store in corresponding datasets.
##          Once collected, construct the main dataset binding columns & rows
##          (subject + activity + data) for each set (test + train)
  
    cat("Analysis started.\n")
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    fileSep <- .Platform$file.sep
    directory <- paste(".", "data", sep=fileSep)
    fileDest <- paste(directory, "Dataset.zip", sep=fileSep)
    
    if(!file.exists(directory))
        dir.create(directory)
    if(!file.exists(fileDest))
    {
        cat(paste("Downloading file from:",fileURL,"\n"))
        download.file(fileURL, fileDest, method="curl")
    }
    cat("Processing data:\n")
    dataset_path <- "UCI\ HAR\ Dataset"
    activitylabels_path <- paste(dataset_path, "activity_labels.txt", sep=fileSep)
    features_path <- paste(dataset_path, "features.txt", sep=fileSep)
    testdata_path <- paste(dataset_path, "test", "X_test.txt", sep=fileSep)
    testlabels_path <- paste(dataset_path, "test", "y_test.txt", sep=fileSep)
    testsubject_path <- paste(dataset_path, "test", "subject_test.txt", sep=fileSep)
    traindata_path <- paste(dataset_path, "train", "X_train.txt", sep=fileSep)
    trainlabels_path <- paste(dataset_path, "train", "y_train.txt", sep=fileSep)
    trainsubject_path <- paste(dataset_path, "train", "subject_train.txt", sep=fileSep)
    
    activity_labels <- read.table(unz(fileDest, activitylabels_path))
    features <- read.table(unz(fileDest, features_path))
    cat("\tProcessing test data set\n")
    test_dataset <- read.table(unz(fileDest, testdata_path))
    test_labels <- read.table(unz(fileDest, testlabels_path))
    test_subject <- read.table(unz(fileDest, testsubject_path))
    cat("\tProcessing train data set\n")
    train_dataset <- read.table(unz(fileDest, traindata_path))
    train_labels <- read.table(unz(fileDest, trainlabels_path))
    train_subject <- read.table(unz(fileDest, trainsubject_path))

    main_dataset <- rbind(cbind(test_subject,test_labels,test_dataset),
                          cbind(train_subject,train_labels,train_dataset))
 
## Step 2 - To extract mean and standard deviation for each measurment, first
##          rename columns (subject + activity + features**) in order to scan
##          columns containing (mean or std) 
##              ** replacing with underscores any invalid characters in variable names
##          And then only keep the first 2 columns + columns containing "mean" or "std"
##              but not begining with angle (not mean or std but angle measures) 

    colnames(main_dataset) <- c("Subject","Activity",gsub("-|\\(|\\)|,","_",features$V2))

    keep_keywords <- c("Subject", "Activity", "mean", "std")
    exclude_keywords <- c("angle")
    cols_with_keep <- as.logical(rowSums(sapply(keep_keywords, grepl,
                                                names(main_dataset), ignore.case=TRUE)))
    cols_with_exclude <- as.logical(rowSums(sapply(exclude_keywords, grepl,
                                                   names(main_dataset), ignore.case=TRUE)))
    keep_columns <- cols_with_keep & !cols_with_exclude
    main_dataset <- main_dataset[,keep_columns]

## Step 3 - Replace numeric contents in the "Activity" column of main_dataset
##          with the corresponding activity form activity_labels

    main_dataset$Activity <- activity_labels[main_dataset$Activity,2]

## Step 4 - Replace some characters in main_dataset column names to make them more
##          readable and (kind of) user friendly

    colnames(main_dataset) <- c(gsub("___|__","_",names(main_dataset)))
    last_char <- substr(names(main_dataset),nchar(names(main_dataset)),
                        nchar(names(main_dataset)))=="_"
    colnames(main_dataset) <- ifelse(last_char,
                                     substr(names(main_dataset),1,
                                            nchar(names(main_dataset))-1),
                                     names(main_dataset))
    colnames(main_dataset) <- c(gsub("BodyBody","Body",names(main_dataset)))
    colnames(main_dataset) <- c(gsub("tBody","time_Body",names(main_dataset)))
    colnames(main_dataset) <- c(gsub("fBody","freq_Body",names(main_dataset)))
    colnames(main_dataset) <- c(gsub("tGravity","time_Gravity",names(main_dataset)))

## Step 5 - Calculate average for each subject/activity/variable combination
##          and create a final tidy data set
##
##          Output final tidy data set to Summary.txt file (in working directory)

    cat("\tGenerating tidy data set\n")
    library(plyr)
    summary_dataset <- aggregate(main_dataset[3:length(names(main_dataset))],
                                 by=list(main_dataset$Subject,main_dataset$Activity),
                                 mean)
    colnames(summary_dataset) <- c("Subject","Activity",
                                   names(main_dataset[3:length(names(main_dataset))]))

    outputfile <- "Summary.txt"
    write.table(summary_dataset, outputfile, row.names=FALSE)
    cat(paste("Analysis completed.\nResults are in",outputfile,"\n"))
}