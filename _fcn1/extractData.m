function [OutEEGDataCL1,OutEEGDataCL2] = extractData(inEEGData,ClassID)

iNumSample = size(inEEGData,1);
iNumChannel = size(inEEGData,2)-1;
iLabelPos = size(inEEGData,2);
iNumSampleCL1 = sum(inEEGData(:,iLabelPos)==ClassID(1));
iNumSampleCL2 = sum(inEEGData(:,iLabelPos)==ClassID(2));

OutEEGDataCL1 = zeros(iNumSampleCL1,iNumChannel);
OutEEGDataCL2 = zeros(iNumSampleCL2,iNumChannel);

iSampleIdx1 =1;
iSampleIdx2 =1;
for i=1:iNumSample
    if inEEGData(i,iLabelPos)== ClassID(1)
        OutEEGDataCL1(iSampleIdx1,:) = inEEGData(i,1:iNumChannel);
        iSampleIdx1 = iSampleIdx1+1;
    end
    if inEEGData(i,iLabelPos)== ClassID(2)
        OutEEGDataCL2(iSampleIdx2,:) = inEEGData(i,1:iNumChannel);
        iSampleIdx2 = iSampleIdx2+1;
    end
end

