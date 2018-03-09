% cross validation for single subject
% Initial version: zz.2014.06.04
% Revision: ctg 2018.02
% to get band setting similar to 
addpath('.\_fcn1');  
addpath('.\libsvm-3.11\matlab');
close all; clc; clear all;

data = 'data';
para_setting0; 

for iSubj=1:para.nsubject
    sFilename=para.eegfile(iSubj).name;
    fEEgData=load([para.dataDir sFilename]);


    % prepare eeg data for class 1 & 2
    % Class0- Meditation; Class2- Stress

    [fEEGDataCl1,fEEGDataCl2] = extractData(fEEgData,para.ClassID);

    fEEGDataCl1 = ArtifactRemoval(fEEGDataCl1, para);
    fEEGDataCl2 = ArtifactRemoval(fEEGDataCl2, para);

    fFeatCL1 = extractFea(fEEGDataCl1,para);
    fFeatCL2 = extractFea(fEEGDataCl2,para);
    feaNo = size(fFeatCL1,2);                 %lzq: feaNo: number of bands - 1 = 6.
    nTrial1 = floor((size(fFeatCL1,1)-para.maFeat)/para.maStep);
    nTrial2 = floor((size(fFeatCL2,1)-para.maFeat)/para.maStep);
    fFeatureCLl = zeros(nTrial1,feaNo*2);                %lzq: create 2D with dims (30, 12)
    fFeatureCL2 = zeros(nTrial2,feaNo*2);
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

    %===========================================
    % SVM eval
    nFold = para.nFold;
    nCVTrial1 = floor(nTrial1/nFold);
    nCVTrial2 = floor(nTrial2/nFold);
    fYLabelCL1 = zeros(nTrial1,1);
    fYLabelCL2 = ones(nTrial2,1);

    fScoreCL1{iSubj} = zeros(nCVTrial1*nFold,2);
    fScoreCL2{iSubj} = zeros(nCVTrial2*nFold,2);

    for iFold = 1:nFold        
        idx1 = (iFold-1)*nCVTrial1 + 1:iFold*nCVTrial1;         
        idx2 = (iFold-1)*nCVTrial2 + 1:iFold*nCVTrial2;         

        fXTrainCL1 = fFeatureCLl;
        fXTrainCL1(idx1,:)=[];                           %lzq: delete the data relate to subject i.
        fYTrainCL1 = fYLabelCL1;
        fYTrainCL1(idx1)=[];                             %lzq: delete the sleepiness result for subject i.
  
        fXTrainCL2 = fFeatureCL2;
        fXTrainCL2(idx2,:)=[];                           %lzq: delete the data relate to subject i.
        fYTrainCL2 = fYLabelCL2;
        fYTrainCL2(idx2)=[];                             %lzq: delete the sleepiness result for subject i.

        fXTrain = [fXTrainCL1; fXTrainCL2];
        fYTrain = [fYTrainCL1; fYTrainCL2];

        fXTest = [fFeatureCLl(idx1,:); fFeatureCL2(idx2,:)];
        fYTest = [fYLabelCL1(idx1); fYLabelCL2(idx2)];
      
        %training
        mdl=libsvmtrain(fYTrain,fXTrain, '-b 1 -c 9 -g 0.5 -t 2 -q');
        %testing
        [fClResult, fAcc, vv]=libsvmpredict(fYTest, fXTest, mdl, '-b 1');
        %fScore{iSubj,iFold}(:,:) = vv;
        fScoreCL1{iSubj}(idx1,:) = vv(1:nCVTrial1,:);        
        fScoreCL2{iSubj}(idx2,:) = vv(nCVTrial1+1:nCVTrial1+nCVTrial2,:);
        fFoldAcc(iSubj,iFold) = fAcc(1); 
        
        %save mdl into files
        save('zhijie', 'mdl');
        save('fYTest','fYTest');
        save('fXTest','fXTest');
        

    end
end


fprintf(1,'\nResult summary:');
fprintf(1,'\nNumber of subjects: %d', para.nsubject)
for iSubj=1:para.nsubject
    fprintf(1,'\nSubj %d: %s\nTotal accuracy = %.2f%%\n',...
        iSubj,para.eegfile(iSubj).name, mean(fFoldAcc(iSubj,:)));
    fprintf(1,'%d fold CV: ', para.nFold);
    fprintf(1,'%.2f%%, ',fFoldAcc(iSubj,:));
    fprintf(1,'\n');
    figure(iSubj);
    subplot(4,1,1); plot((fScoreCL1{iSubj}(:,:))); 
    title([para.eegfile(iSubj).name, ' -- class 1']);
    subplot(4,1,2); plot((fScoreCL1{iSubj}(:,1)-fScoreCL1{iSubj}(:,2))); 
    subplot(4,1,3); plot((fScoreCL2{iSubj}(:,:)));
    title([para.eegfile(iSubj).name, ' -- class 2']);
    subplot(4,1,4); plot((fScoreCL2{iSubj}(:,2)-fScoreCL2{iSubj}(:,1))); 

end

%==================================
% smoothing classification score 
%==================================
for iSubj=1:para.nsubject
    fprintf(1,'\n\nSubj %d: %s (Smoothing out scores)',iSubj,para.eegfile(iSubj).name);
    fSmScoreCL1 = SmoothScore(fScoreCL1{iSubj}, para, para.ClassID(1));
    fSmScoreCL2 = SmoothScore(fScoreCL2{iSubj}, para, para.ClassID(2));

    figure(iSubj);
    nNumTrial1 = size(fScoreCL1{iSubj},1);
    subplot(4,1,1); plot(1:nNumTrial1,fScoreCL1{iSubj}(:,1),'b',1:nNumTrial1,fScoreCL1{iSubj}(:,2),'r');
    subplot(4,1,2); plot(1:nNumTrial1,fSmScoreCL1(:,1),'b',1:nNumTrial1,fSmScoreCL1(:,2),'r');
    title([para.eegfile(iSubj).name, ' -- class 1']);
    nNumTrial2 = size(fScoreCL2{iSubj},1);
    subplot(4,1,3); plot(1:nNumTrial2,fScoreCL2{iSubj}(:,1),'b',1:nNumTrial2,fScoreCL2{iSubj}(:,2),'r');
    subplot(4,1,4); plot(1:nNumTrial2,fSmScoreCL2(:,1),'b',1:nNumTrial2,fSmScoreCL2(:,2),'r');
    title([para.eegfile(iSubj).name, ' -- class 2']);
    
    fRawAccCL1 = sum(fScoreCL1{iSubj}(:,1)>fScoreCL1{iSubj}(:,2))/nNumTrial1*100;
    fSmoothAccCL1 = sum(fSmScoreCL1(:,1)>fSmScoreCL1(:,2))/nNumTrial1*100;
    fRawAccCL2 = sum(fScoreCL2{iSubj}(:,1)<fScoreCL2{iSubj}(:,2))/nNumTrial2*100;
    fSmoothAccCL2 = sum(fSmScoreCL2(:,1)<fSmScoreCL2(:,2))/nNumTrial2*100;
    
    fprintf(1, '\nInput Acc: %f class %d,  %f class %d',fRawAccCL1, para.ClassID(1), fRawAccCL2,para.ClassID(2));
    fprintf(1, '\nOutput Acc: %f class %d,  %f class %d',fSmoothAccCL1, para.ClassID(1), fSmoothAccCL2,para.ClassID(2));
    
end

function outScore = SmoothScore(inScore, para, nClassID)
    nNumTrial = size(inScore,1);
    fMAMat = zeros(nNumTrial,nNumTrial);
    kMAComp=para.smoothscore ; %10; % this parameter can be adjusted/optimised
    for k =1:nNumTrial-kMAComp
        fMAMat(k,k:k+kMAComp-1) = 1/kMAComp;
    end
    for k =kMAComp:-1:1
        fMAMat(nNumTrial-k+1,nNumTrial-k+1:nNumTrial) = 1/k;
    end

    outScore = inScore;
    outScore(:,1) = fMAMat*inScore(:,1);    
    outScore(:,2) = fMAMat*inScore(:,2);    

end

%{
lzq: 
Usage: svm-train [options] training_set_file [model_file]
options:
-s svm_type : set type of SVM (default 0)
	0 -- C-SVC
	1 -- nu-SVC
	2 -- one-class SVM
	3 -- epsilon-SVR
	4 -- nu-SVR
-t kernel_type : set type of kernel function (default 2)
	0 -- linear: u'*v
	1 -- polynomial: (gamma*u'*v + coef0)^degree
	2 -- radial basis function: exp(-gamma*|u-v|^2)
	3 -- sigmoid: tanh(gamma*u'*v + coef0)
	4 -- precomputed kernel (kernel values in training_set_file)
-d degree : set degree in kernel function (default 3)
-g gamma : set gamma in kernel function (default 1/num_features)
-r coef0 : set coef0 in kernel function (default 0)
-c cost : set the parameter C of C-SVC, epsilon-SVR, and nu-SVR (default 1)
-n nu : set the parameter nu of nu-SVC, one-class SVM, and nu-SVR (default 0.5)
-p epsilon : set the epsilon in loss function of epsilon-SVR (default 0.1)
-m cachesize : set cache memory size in MB (default 100)
-e epsilon : set tolerance of termination criterion (default 0.001)
-h shrinking : whether to use the shrinking heuristics, 0 or 1 (default 1)
-b probability_estimates : whether to train a SVC or SVR model for probability estimates, 0 or 1 (default 0)
-wi weight : set the parameter C of class i to weight*C, for C-SVC (default 1)
-v n: n-fold cross validation mode
-q : quiet mode (no outputs)


`svm-predict' Usage
===================

Usage: svm-predict [options] test_file model_file output_file
options:
-b probability_estimates: whether to predict probability estimates, 0 or 1 (default 0); for one-class SVM only 0 is supported

model_file is the model file generated by svm-train.
test_file is the test data you want to predict.
svm-predict will produce output in the output_file.
%}
% % vvScore = zeros(para.nsubject,2*ntrial,2);
% % for i=1:para.nsubject
% %    xxtrain = xxAll;
% %    yytrain = yyAll';
% %    idx = (i-1)*ntrial*2 + 1:ntrial*2*i;         %lzq: 1 : 60, or 61 : 120 ....
% %    xxtrain(idx,:)=[];                           %lzq: delete the data relate to subject i.
% %    yytrain(idx)=[];                             %lzq: delete the sleepiness result for subject i.
% %    xxtest = xxAll(idx,:);
% %    yytest = yyAll(idx)';
% %       
% %    mdl=libsvmtrain(yytrain,xxtrain, '-b 1 -c 9 -g 0.5 -t 2');
% %      [res, accuracy, vv]=libsvmpredict(yytest, xxtest, mdl, '-b 1');
% %  vvScore(i,:,:) = vv;
% %      %   plot(vv); pause;
% %    accAll(i) = accuracy(1);
% %    vvAll(:,i) = vv(:,2);  
% % end
% % cv = mean(accAll); 