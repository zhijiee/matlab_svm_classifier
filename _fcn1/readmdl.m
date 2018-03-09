addpath('.\_fcn1');  
addpath('.\libsvm-3.11\matlab');
clear all;
% load model

fn = 'sleep_GMM_v02.mdl';
fp = fopen(fn);
while true
    line = fgetl(fp);
    if line == -1 % end of file
        break;
    end
    
    if strncmp(line, 'filter b1:', 10)
       line = fgetl(fp);
       hexr = strread(line, '%s','delimiter',',');
       b1 = hex2num(hexr);
    elseif strncmp(line, 'filter a1:', 10)
       line = fgetl(fp);
       hexr = strread(line, '%s','delimiter',',');
       a1 = hex2num(hexr);
    elseif strncmp(line, 'filter b2:', 10)       
       line = fgetl(fp);
       hexr = strread(line, '%s','delimiter',',');
       b2 = hex2num(hexr);
    elseif strncmp(line, 'filter a2:', 10)
       line = fgetl(fp);
       hexr = strread(line, '%s','delimiter',',');
       a2 = hex2num(hexr);
%parameters       
    elseif strncmp(line, 'para.band:',10)
       line = fgetl(fp);
       para.band = strread(line, '%f','delimiter',',');
    elseif strncmp(line, 'para.bandWt:',12)
       line = fgetl(fp);
       para.bandWt = strread(line, '%f', 'delimiter',',');
    elseif strncmp(line, 'para.winLen: ', 13)
        para.winLen = sscanf(line, 'para.winLen: %d');
    elseif strncmp(line, 'para.fs: ', 9)
        para.fs = sscanf(line, 'para.fs: %d');
    elseif strncmp(line, 'para.overlap: ', 14)
        para.overlap = sscanf(line, 'para.overlap: %d');
    elseif strncmp(line, 'para.trialLen: ', 15)
        para.trialLen = sscanf(line, 'para.trialLen: %d');
    elseif strncmp(line, 'para.window1: ', 14)
        para.window1 = sscanf(line, 'para.window1: %d');
    elseif strncmp(line, 'para.window2: ', 14)
        para.window2 = sscanf(line, 'para.window2: %d');
    elseif strncmp(line, 'para.window3: ', 14)
        para.window3 = sscanf(line, 'para.window3: %d');
    elseif strncmp(line, 'para.thres1: ', 13)
        para.thres1 = sscanf(line, 'para.thres1: %f');    
    elseif strncmp(line, 'para.thres2: ', 13)
        para.thres2 = sscanf(line, 'para.thres2: %f');
% svm paramters       
    elseif strncmp(line, 'SVM_Parameters:', 15)
        line = fgetl(fp);
        hexr = strread(line, '%s','delimiter',',');
        mdl.Parameters = hex2num(hexr);
    elseif strncmp(line, 'SVM_nr_class:', 13)
        % SVM_nr_class: 2
        mdl.nr_class = sscanf(line, 'SVM_nr_class: %d');
    elseif strncmp(line, 'SVM_totalSV:', 12)
        % SVM_totalSV: 2360
        mdl.l = sscanf(line, 'SVM_totalSV: %d');
    elseif strncmp(line, 'SVM_rho:', 8)
        %  fgetl(fp); % SVM_rho: -0.398960
        hexr = sscanf(line, 'SVM_rho: %s');
        mdl.rho = hex2num(hexr);
    elseif strncmp(line, 'SVM_Label:', 10)
        % SVM_Label: 2
        line = fgetl(fp); % 0,1,
        mdl.label = strread(line, '%f,');
    elseif strncmp(line, 'SVM_ProbA:', 10)
        % SVM_ProbA: -1.260670
        hexr = sscanf(line, 'SVM_ProbA: %s');
        mdl.probA = hex2num(hexr);
    elseif strncmp(line, 'SVM_ProbB:', 10)
        % SVM_ProbB: 0.139463
        hexr = sscanf(line, 'SVM_ProbB: %s');
        mdl.probB = hex2num(hexr);
    elseif strncmp(line, 'SVM_nSV:', 8)
        % SVM_nSV: 2
        line = fgetl(fp);% 1180,1180,
        mdl.nSV = sscanf(line, '%f,');
    elseif strncmp(line, 'SVM_sv_coef:', 12)
        % SVM_sv_coef: 2360
        line = fgetl(fp);% 1.000000,1.000000,...
        hexr = strread(line, '%s','delimiter',',');
        mdl.sv_coef = hex2num(hexr);
    elseif strncmp(line, 'SVM_SVs:', 8)
        % SVM_SVs: 2360
        sv = zeros(mdl.l, 12);
        for i = 1:mdl.l
            line = fgetl(fp);
            hexr = strread(line, '%s','delimiter',',');
            sv(i, :) = hex2num(hexr);
        end
    end
end
fclose(fp);
mdl.SV = sparse(sv);
