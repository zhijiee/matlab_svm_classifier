% This is to create the SVM Model by processing the EEG data in chunks of
% SAMPLE_RATE. The original goal was to mimic how REAL-TIME EEG is
% processed to be more accurate. But this is scraped because the this is
% not a very good representation of the data. 

addpath('.\_fcn1');  
addpath('.\libsvm-3.11\matlab');

data = 'data';
para_setting0; 

fEEGDataCl1 = [];
fEEGDataCl2 = [];

% prepare for training
for iSubj=1:(para.nsubject)
    sFilename=para.eegfile(iSubj).name;
    fEEgData=load([para.dataDir sFilename]);
    
    [tempfEEGDataCl1,tempfEEGDataCl2] = extractData(fEEgData,para.ClassID);

    fEEGDataCl1 = [fEEGDataCl1;tempfEEGDataCl1];
    fEEGDataCl2 = [fEEGDataCl2;tempfEEGDataCl2];
end

temp = [];
%Artifact Removal 
winsize = para.fs * para.winLen;
newCL1 = [];
newCL2 = [];
for i=0:floor(size(fEEGDataCl1,1)/512)-1
   temp = ArtifactRemoval(fEEGDataCl1(i*para.fs+1 : i*para.fs + winsize,:),para );
   newCL1 = [newCL1; temp];
      
end
for i=0:floor(size(fEEGDataCl2,1)/512)-1
  temp = ArtifactRemoval(fEEGDataCl2(i*para.fs+1 : i*para.fs + winsize,:),para );
  newCL2 = [newCL2; temp];
end

fEEGDataCl1 = newCL1;
fEEGDataCl2 = newCL2;

newFeatCl1 = [];
newFeatCl2 = [];

for i=0:floor(size(fEEGDataCl1,1)/512)-1
    temp = extractFea(fEEGDataCl1(i*para.fs+1 : i*para.fs + winsize,:),para);
    newFeatCl1 = [newFeatCl1; temp];
end

for i=0:floor(size(fEEGDataCl2,1)/512)-1
    temp = extractFea(fEEGDataCl2(i*para.fs+1 : i*para.fs + winsize,:),para);
    newFeatCl2 = [newFeatCl2; temp];
end 

fFeatCL1 = newFeatCl1;
fFeatCL2 = newFeatCl2;
%Extract features 
%fFeatCL1 = extractFea(fEEGDataCl1,para);
%fFeatCL2 = extractFea(fEEGDataCl2,para);

% Not sure (extending the length of feeg)
feaNo = size(fFeatCL1,2);                 %lzq: feaNo: number of bands - 1 = 6.

nTrial1 = floor((size(fFeatCL1,1))/para.maStep);
nTrial2 = floor((size(fFeatCL2,1))/para.maStep);


fFeatureCLl = zeros(nTrial1,feaNo*2);                %lzq: create 2D with dims (30, 12)
fFeatureCL2 = zeros(nTrial2,feaNo*2);


% these operations does not do anything, mean of itself/ variance of a
% itself 
for j=1:nTrial1
    idx=(j-1)*para.maStep+1:(j-1)*para.maStep+para.maFeat;         %lzq: note: there are 10 items overlapped with next.
    for k=1:feaNo
        % !! need to formulate it based on overlap and trial length etc.!!
        fFeatureCLl(j,k)=mean(fFeatCL1(idx,k));       %lzq: xx1(j,k): average of a specified band (band k) ratio within this epoch (19 data!) (why not 20 data?)
        fFeatureCLl(j,k+feaNo)=var(fFeatCL1(idx,k))*50;      %lzq: xx1(j, k + 6): variance of the specified band K ration within this epoch (19data)    
    end
end

for j=1:nTrial2
    idx=(j-1)*para.maStep+1:(j-1)*para.maStep+para.maFeat;         %lzq: note: there are 10 items overlapped with next.   
    for k=1:feaNo
        % !! need to formulate it based on overlap and trial length etc.!!
        fFeatureCL2(j,k)=mean(fFeatCL2(idx,k));
        fFeatureCL2(j,k+feaNo)=var(fFeatCL2(idx,k))*50;
    end
end

fYLabelCL1 = zeros(nTrial1,1);
fYLabelCL2 = ones(nTrial2,1);


fXTrain = [fFeatureCLl; fFeatureCL2];
fYTrain = [fYLabelCL1; fYLabelCL2];

mdl=libsvmtrain(fYTrain,fXTrain, '-b 1 -c 9 -g 0.5 -t 2 -q');
my_save_model(mdl, "svm_model_segments.txt");


