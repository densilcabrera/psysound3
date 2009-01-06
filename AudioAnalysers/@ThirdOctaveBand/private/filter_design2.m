function [B,A] = filter_design2(Fc,Fs,N);

%    Warning: for meaningful design results, center frequency used
%    should preferably be in range Fs/200 < Fc < Fs/5.
%    Usage of the filter: Y = FILTER(B,A,X). 
%
%    Requires the Signal Processing Toolbox. 
% Design Butterworth 2Nth-order one-third-octave filter. 

% original from the Salford http://www.acoustics.salford.ac.uk/research/

f1 = 2^(-1/6)*Fc; 
f2 = 2^(1/6)*Fc; 
f1 = f1/(Fs/2);
f2 = f2/(Fs/2);
[B,A] = butter(N,[f1,f2]);