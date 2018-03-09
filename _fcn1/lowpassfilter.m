% bandpass input into separate bands

function xm_filtered = lowpassfilter(xm,para)

nband = para.nband;

nSection = para.LPNumSec;
fCoe = para.LPCoe;
fGain = para.LPGain;

for i=para.nstartband:nband
    for j=1:nSection
        B = fCoe(j,1:3);
        A = fCoe(j,4:6);
        xm_filtered(:,i) = fGain(j)*filter(B,A,xm(:,i));
    end
end