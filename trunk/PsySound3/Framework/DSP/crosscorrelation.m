function ACF = crosscorrelation(data1, data2)
% CROSSCORRELATION Finds the cross-correlation of two time signals' data

lagCount = round(length(data1)/2);

nFFT =  2^(nextpow2(length(data1)) + 1);

F1    =  fft(data1 , nFFT);
F2    =  fft(data2 , nFFT);

F    =  conj(F1) .* F2;
ACF  =  ifft(F);
ACF  =  ACF(1:(lagCount + 1));  % Retain non-negative lags.
ACF  =  ACF ./ ACF(1);          % Normalize.
ACF  =  real(ACF);

end % crosscorrelation
