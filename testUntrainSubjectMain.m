% To test the accuracy on a subject who is not included in the training dataset. 
clear;
addpath('.\_fcn1');  
addpath('.\libsvm-3.11\matlab');

data = 'data';
para_setting0; 

fEEGDataCl1 = [];
fEEGDataCl2 = [];

% Cross validation for a single subject not included. 
% prepare for training

for iSubj=1:(para.nsubject)
    sFilename=para.eegfile(iSubj).name;
    fEEgData=load([para.dataDir sFilename]);
    
    [tempfEEGDataCl1,tempfEEGDataCl2] = extractData(fEEgData,para.ClassID);

    fEEGDataCl1{iSubj} = zeros(size(tempfEEGDataCl1,1), size(tempfEEGDataCl1,2));
    fEEGDataCl2{iSubj} = zeros(size(tempfEEGDataCl2,1), size(tempfEEGDataCl2,2));
    
    fEEGDataCl1{iSubj} = tempfEEGDataCl1;
    fEEGDataCl2{iSubj} = tempfEEGDataCl2;

    %Artifact Removal 
    fEEGDataCl1{iSubj} = ArtifactRemoval(fEEGDataCl1{iSubj}, para);
    fEEGDataCl2{iSubj} = ArtifactRemoval(fEEGDataCl2{iSubj}, para);

    %fEEGDataCl1Test = ArtifactRemoval(fEEGDataCl1Test, para);
    %fEEGDataCl2Test = ArtifactRemoval(fEEGDataCl2Test, para);

    %Extract features 
    fFeatCL1{iSubj} = extractFea(fEEGDataCl1{iSubj},para);
    fFeatCL2{iSubj} = extractFea(fEEGDataCl2{iSubj},para);

    %fFeatCL1Test = extractFea(fEEGDataCl1Test,para);
    %fFeatCL2Test = extractFea(fEEGDataCl2Test,para);

    % Not sure (extending the length of feeg)
    feaNo = size(fFeatCL1{iSubj},2);                 %lzq: feaNo: number of bands - 1 = 6.

    nTrial1{iSubj} = floor((size(fFeatCL1{iSubj},1))/para.maStep);
    nTrial2{iSubj} = floor((size(fFeatCL2{iSubj},1))/para.maStep);

    %nTrial3 = floor((size(fFeatCL1Test,1))/para.maStep);
    %nTrial4 = floor((size(fFeatCL2Test,1))/para.maStep);

    fFeatureCL1{iSubj} = zeros(nTrial1{iSubj},feaNo*2);                %lzq: create 2D with dims (30, 12)
    fFeatureCL2{iSubj} = zeros(nTrial2{iSubj},feaNo*2);

    %fFeatureCLlTest = zeros(nTrial3,feaNo*2);                %lzq: create 2D with dims (30, 12)
    %fFeatureCL2Test = zeros(nTrial4,feaNo*2);

    % these operations does not do anything, mean of itself/ variance of a
    % itself 
    for j=1:nTrial1{iSubj}
        idx=(j-1)*para.maStep+1:(j-1)*para.maStep+para.maFeat;         %lzq: note: there are 10 items overlapped with next.
        for k=1:feaNo
            % !! need to formulate it based on overlap and trial length etc.!!
            fFeatureCL1{iSubj}(j,k)=mean(fFeatCL1{iSubj}(idx,k));       %lzq: xx1(j,k): average of a specified band (band k) ratio within this epoch (19 data!) (why not 20 data?)
            fFeatureCL1{iSubj}(j,k+feaNo)=var(fFeatCL1{iSubj}(idx,k))*50;      %lzq: xx1(j, k + 6): variance of the specified band K ration within this epoch (19data)    
        end
    end

    for j=1:nTrial2{iSubj}
        idx=(j-1)*para.maStep+1:(j-1)*para.maStep+para.maFeat;         %lzq: note: there are 10 items overlapped with next.   
        for k=1:feaNo
            % !! need to formulate it based on overlap and trial length etc.!!
            fFeatureCL2{iSubj}(j,k)=mean(fFeatCL2{iSubj}(idx,k));
            fFeatureCL2{iSubj}(j,k+feaNo)=var(fFeatCL2{iSubj}(idx,k))*50;
        end
    end


end


% Training with k-1 users and testing with the 1 user

for index=1:(para.nsubject)

numTrial1 = sum([nTrial1{:}]) - nTrial1{index};
numTrial2 = sum([nTrial2{:}]) - nTrial2{index};

fYLabelCL1 = zeros(numTrial1,1);
fYLabelCL2 = ones(numTrial2,1);

fXTrain = [];
fYTrain = [fYLabelCL1; fYLabelCL2];

    for i=1:(para.nsubject)
        if i ~= index
            fXTrain = [fXTrain;fFeatureCL1{i}];        
        end        
    end
    for i=1:(para.nsubject)
        if i ~= index
            fXTrain = [fXTrain;fFeatureCL2{i}];        
        end        
    end


    

fXTest = [fFeatureCL1{index}; fFeatureCL2{index}];
fYTest = [zeros(nTrial1{index},1); ones(nTrial2{index},1)];


mdl=libsvmtrain(fYTrain,fXTrain, '-b 1 -c 9 -g 0.5 -t 2 -q');
[fClResult{index}, fAcc{index}, vv{index}]=libsvmpredict(fYTest, fXTest, mdl, '-b 1');


fScoreCL1{index} = vv{index}(1:nTrial1{index},:)
fScoreCL2{index} = vv{index}(nTrial1{index}+1:nTrial1{index}+nTrial2{index},:)


end



%my_save_model(mdl, "svm_model.txt");

%dlmwrite('probability_test_zj.csv', vv, 'delimiter', ',', 'precision', 16); 


