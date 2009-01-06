function freq = erb2freq(erb)
% ERB2FREQ  converts erbs to freq (Hz)

freq = 1e3*(10.^(erb/21.4)-1)/4.37;

% end erb2freq
