function dataOut = processWindow(obj, dataIn)
% PROCESSWINDOW This is the core workhorse of this analyser
%
% We are using raw mode - the whole file to be analysed is stored 
% in dataIn.

if dataIn == 1
  dataOut = 1;
  return;
end

fs = get(obj, 'fs');

oDataRate = get(obj, 'outputDataRate');

[ReverbTime, Time] = T(dataIn,fs);

dataOut = {ReverbTime,Time};