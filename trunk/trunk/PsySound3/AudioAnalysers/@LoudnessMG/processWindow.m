function f = processWindow(obj, dataIn)
% PROCESSWINDOW This is the core workhorse of this analyser
%
% NOTE: Every window is the same size and comes appropriately
%       zero-padded both in front and at rear, whenever neccessary,
%       and so that is why the following is just a straightforward
%       call.

% Create a function handle for Loudness
fs = get(obj, 'fs');
dataOut = MGLoudnessPsySound(fs);

% function handle to return
f = @run;

  % 
  % Local nested function
  %
  function dataOut = run(dataIn)
    [dataOut{1},dataOut{2},dataOut{3},dataOut{4},dataOut{5},dataOut{6},dataOut{7},dataOut{8},dataOut{9},dataOut{10},dataOut{11}] = MGLoudnessPsySound(dataIn,get(obj, 'fs'),get(obj, 'windowLength'),'F');
  end
end