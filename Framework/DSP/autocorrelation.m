function ACF = autocorrelation(data)
% AUTOCORRELATION Finds the autocorrelation of the time signal data

lagCount = round(length(data)/2);

nFFT =  2^(nextpow2(length(data)) + 1);
F    =  fft(data , nFFT);
F    =  F .* conj(F);
ACF  =  ifft(F);
ACF  =  ACF(1:(lagCount + 1));  % Retain non-negative lags.
ACF  =  ACF ./ ACF(1);          % Normalize.
ACF  =  real(ACF);

end % autocorrelation
