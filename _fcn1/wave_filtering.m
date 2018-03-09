function [xm_clean,b1,a1,b2,a2] = wave_filtering(xm0,fs)
   %== Notch-filter signals (50 Hz)
   fnotch = 50;              %notch frequency at 50 Hz
   wo = fnotch/(fs/2);
   bw = wo/35;               %bandwidth with Q-factor = 35
   [b1,a1] = iirnotch(wo,bw);  %second-order notch digital filter
   xm00 = filter(b1,a1,xm0);
   %== Bandpass-filter signals (0.3-64 Hz)
   fOrder = 4;               %IIR filter order for bandpass
   [b2,a2] = butter(fOrder,[0.3 64]/(fs/2),'bandpass');    
                %butterworth filter
   xm_clean = filter(b2,a2,xm00);