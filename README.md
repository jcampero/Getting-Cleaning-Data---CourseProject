Getting & Cleaning Data Course Project
======================================
To perform the tasks for the Getting & Cleaning Data Course Project execute the
run_analysis.R script provided in this directory.

This script performs the following 5 main steps:

Step 1
======
- Access the Human Activity Recognition Using Smartphones Data Set from the following
    link:
    https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
- If you would like to see a brief description of the Human Activity Recognition Using
    Smartphones Project and how the input data was generated, refer to the following link:
    http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
- For time and network bandwidth efficiency, if the local working directory already
    contains a copy of the original data (stored in the ./data directory), the script
    doesn't download the file again and uses the present copy
- Once the zip file is transferred and saved as "Dataset.zip"" (or is already present),
    8 files are read to construct a working data frames for each one. Files accessed
    within Dataset.zip are:
        - /UCI HAR Dataset/activity_labels.txt
        - /UCI HAR Dataset/features.txt
        - /UCI HAR Dataset/test/X_test.txt
        - /UCI HAR Dataset/test/y_test.txt
        - /UCI HAR Dataset/test/subject_test.txt
        - /UCI HAR Dataset/train/X_train.txt
        - /UCI HAR Dataset/train/y_train.txt
        - /UCI HAR Dataset/train/subject_train.txt
- The test and train working data frames are binded together by columns (subject,
    activity and data) and by rows (test and train) to create the main data set
    where subsequent data transformations will be performed in the next steps.

Step 2
======
- Excluding the 1st and 2nd (subject and activity respectively), the rest of the
    columns in the main data set are renamed using values in the second column of the
    features data frame (to avoid potential problems with the use of invalid characters
    in the column names, all invalid characters are replaced with underscores "_")
- To only preserve columns that contains mean or standard deviation data, column names
    are searched for the presence of "Subject", "Activity" (1st and 2nd), "mean" or
    "std" to construct a logical data frame
- The logical data frame is used to subset the main data frame and delete all the
    columns that don't contain mean or standard deviation data (except the 1st and 2nd)
    
Step 3
======
- Values in the 2nd column of the main data set (Activity) are replaced with the
    corresponding value (row index) in the 2nd column of the activity labels data
    frame, thus replacing all numeric values with their respective textual
    description

Step 4
======
- In step 2, column names in the main data set were changed according to the
    corresponding feature name from the original data in the features.txt (only
    replacing any invalid characters with underscores). In order to make the names
    of the preserved columns (mean and standard deviation data) more readable and
    understandable, the following rules are applied:
        - double or triple underscores are replaced with a single one
        - ending underscores in column names are omitted
        - "t(Body/Gravity)" is changed to "time_(Body/Gravity)"
        - "f(Gravity)" is changed to "freq_(Gravity)"
        - "BodyBody" is replaced to "Body"

Step 5
======
- The last step calculates the average for each subject/activity/data variable
    combination in the main data set using the aggregate function, with the following
    parameters:
        - Main data set subsetted from column 3 to last (data variables)
        - Grouped by column 1 and 2 ("Subject" and "Activity")
        - Mean function (to calculate the average of each combination)
- The resulting data set with [# Subjects x # Activities] rows and the same number of
    columns as the main data set is assigned to a new data set, and it represents the
    final (not so narrow) tidy data set*, containing:
        + Column 1 - Subject
        + Column 2: - Activity (descriptive text)
        + Column 3:last - Average of the original mean and standard deviation
                            data variables grouped by subject/activity
* Per the tidy data definition in "Tidy Data" papper by Hadley Wickham:
    http://vita.had.co.nz/papers/tidy-data.pdf"
- As the aggregate function renames the first 2 columns used to group the data,
    "Subject" and "Activity" are reassigned as their respective column names
- Finally, the resulting tidy data set is written in a flat file (suppressing the row
    names) in the working directory, named "Summary.txt"