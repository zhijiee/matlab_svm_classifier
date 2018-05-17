# MATLAB SVM generate Model

This code is written to convert .muse data file with the correct annotations into .csv files which can be used as training data to generate SVM model. 

This repository is used to supplement [FocusDataCollection](https://github.com/zhijiee/FocusDataCollection).It is designed to convert the Muse file from FocusDataCollection to CSV file for SVM training. 

## Prerequisities 

- Muse Player 
- MATLAB 

# How to use

## Step 1: Convert .Muse to .CSV using the folder 

The code to convert Muse file to CSV is in the folder [MuseToCSV](https://github.com/zhijiee/matlab_svm_classifier/tree/master/MuseToCSV). Additional instructions will be found on that page. 


## Step 2: Train SVM Model 

With the generated CSV files, place them into the DATA folder. They will be used for creating the SVM Model. 

### genFullModelBySegments.m
This code is created as the artifact removal(using moving average) when processing batches of 512 samples reduced the total number of samples in which it creates lesser features. Hence, this was created so that the Real-time EEG Classifer would perform more accurately. 

This has not been used already as I have modified the code to process 768 samples to mitigate this issue.

### genFullModelMain.m
Takes all CSV from DATA folder to generate a SVM Model. 

### my_save_model.m
This script receives a model generated using SVM and save as CSV for import in JAVA SVM. Some fields are hard coded. 

### myMain.m
10-fold cross validation for a single dataset. Developed for exporting data to do UNIT testing of the Android Real-time Classifer. To ensure both MATLAB and Java pre-processing is the same. 

### main.m
10-fold cross validation for all data. 

### testUntrainSubjectMain.m 
Used to test the accuracy on a participant's dataset who is not included in the training data. 