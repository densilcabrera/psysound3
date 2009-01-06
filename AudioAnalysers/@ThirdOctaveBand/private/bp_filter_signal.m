% function sig_out = bp_filter_signal(cutoff, Fs, sig, number_cascade);
%
%   creates chebyshev type I bandpass filter with cutoff frequencies defined

function sig_out = bp_filter_signal(cutoff, Fs, sig, N)
w_low = cutoff(1)/(Fs/2);
w_high = cutoff(2)/(Fs/2);
[num, den] = cheby1(N, 0.5, [w_low w_high]);
% draw bode plot of filter
%freqz(num,den,linspace(0,24000,1024),48000);

sig_out = filter(num,den,sig);
sig_out = filter(num,den,sig_out);
sig_out = filter(num,den,sig_out);
sig_out = filter(num,den,sig_out);
sig_out = filter(num,den,sig_out);
sig_out = filter(num,den,sig_out);
sig_out = filter(num,den,sig_out);
sig_out = filter(num,den,sig_out);
