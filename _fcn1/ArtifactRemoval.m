function fOutEEGData = ArtifactRemoval(raw_fInEEGData,para)

    %== Bandpass-filter signals (0.3-45 Hz)
    dlmwrite('raw_eeg.csv',raw_fInEEGData, 'delimiter', ',', 'precision', 16); 
    fInEEGData = filter(para.preFiltB,para.preFiltA,raw_fInEEGData);
    dlmwrite('eeg_after_filter.csv',fInEEGData, 'delimiter', ',', 'precision', 16); 

    fRefData = zeros(size(fInEEGData));
    fOutEEGData = zeros(size(fInEEGData));
    datalength=length(fInEEGData);
    for j=1:para.nComp
        for k =1:datalength-para.kCompMat(j)
            fRefData (k,:) = mean(fInEEGData(k:k+para.kCompMat(j)-1,:));
        end
        fOutEEGData(1:datalength-para.kCompMat2(j),:) = ...
            fInEEGData(para.kCompMat2(j)+1:datalength,:) - ...
            fRefData(1:datalength-para.kCompMat2(j),:) + ...
            fOutEEGData (1:datalength-para.kCompMat2(j),:);
    end 
    fOutEEGData = fOutEEGData/para.nComp;
end