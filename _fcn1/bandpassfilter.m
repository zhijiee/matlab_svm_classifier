% bandpass input into separate bands

function xm_filtered = bandpassfilter(xm,para)

nband = para.nband;

for i= para.nstartband: nband
    xm_filtered(:,:,i) = xm;
    nSection = para.BPNumSec(i);
    fCoe = para.BPCoe{i};
    fGain = para.BPGain{i};
    for j=1:nSection
        B = fCoe(j,1:3);
        A = fCoe(j,4:6);
        xm_filtered(:,:,i) = fGain(j)*filter(B,A,xm_filtered(:,:,i));
    end
end