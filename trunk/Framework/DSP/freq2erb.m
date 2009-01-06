function erb = freq2erb(freq)
% FREQ2ERB  converts freq (Hz) to erbs

erb = 21.4*log10(4.37*freq/1e3+1);

% end freq2erb
