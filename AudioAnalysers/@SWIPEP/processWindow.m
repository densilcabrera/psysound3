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

[p,t,s] = swipep(dataIn,fs,[],1/oDataRate);

dataOut = {p,s,t};