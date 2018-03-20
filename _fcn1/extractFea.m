function [xwinFeature,winBound] = extractFea(xm,para)

%==  Initialize parameters
fs = para.fs;
winLen = para.winLen;     %lzq: window length, 3 seconds
overlap = para.overlap;   
winTime = [];
winStart = [];
winEnd = [];
winIdx = 1;                                        

%==  Extract features
winSz = floor(winLen*fs);     %lzq: window size for 3 seconds: 2 * 256 = 512;         
%window size (sample)
winShift = floor( winSz*(100-overlap)/100);    %lzq: #samples overlapped : 512 * (100-50)/100 = 256     --- 0.5 * 3 * 256 = 384
%window shift size (sample)

numSeg = floor((length(xm) - winSz)/winShift) + 1; %lzq: divided the 8 minutes data into 1.5 seconds block. total 318 blocks.
% Why num of segment not = (length(xm) - winShift)/winShift.. 1 seg
% features left out

numChannel = size(xm,2);

nband = para.nband;

xwinFeature = zeros(numSeg,nband * numChannel);      %create 2D array
xm_filtered = bandpassfilter(xm,para);  % CTG: to breakdown input signal to 6 bands (delta, theta, alpha, lbeta, hbeta, gamma)
                                        % multiple channels   
dlmwrite('extractFea_after_bandpass.csv', xm_filtered, 'delimiter', ',', 'precision', 16); 

for iSeg = 1:numSeg
    xstart = (iSeg-1)*winShift +1;
    xend = (iSeg-1)*winShift + winSz;                           

    for iCh = 1: numChannel
        xwinFeature1(iSeg,iCh,:) = sum(xm_filtered(xstart:xend,iCh,:).^2);  %CTG: relative power   
        xwinFeature1(iSeg,iCh,:) = xwinFeature1(iSeg,iCh,:)/sum(squeeze(xwinFeature1(iSeg,iCh,:)));  %CTG: relative power   
    end
    iFeat = 1;
    for j =1:numChannel
        for m=1:nband
            xwinFeature(iSeg,iFeat) = xwinFeature1(iSeg,j,m);
            iFeat = iFeat + 1;          
        end
    end
    
end
