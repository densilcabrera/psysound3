function dataOut = processWindow(obj, dataIn)
% PROCESSWINDOW This is the core workhorse of this analyser
%
% We are using raw mode - the whole file to be analysed is stored 
% in dataIn.

if dataIn == 1
  dataOut = 1;
  return;
end

filtermethod = 1; % (or GUI choice)
cal = 34.0507; % set to make 1 kHz tone at 40 dB yield 1 sone
faster = 1; % if you think this analyser is slow, try setting this to 0!
decay = 5000; % 5 seconds of decay after the end of the file
doplot = 0; % do not make a plot

fs = get(obj, 'fs');

oDataRate = get(obj, 'outputDataRate');

[InstantaneousLoudness, ShortTermLoudness, LongTermLoudness, times] = MGBLoudness2b(dataIn,fs,filtermethod,cal,faster,decay,doplot);

dataOut = {InstantaneousLoudness, ShortTermLoudness, LongTermLoudness, times'};