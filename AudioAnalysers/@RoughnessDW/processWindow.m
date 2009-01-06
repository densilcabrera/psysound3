function f = processWindow(obj, dataIn)
% PROCESSWINDOW This is the core workhorse of this analyser
%
% NOTE: Every window is the same size and comes appropriately
%       zero-padded both in front and at rear, whenever neccessary,
%       and so that is why the following is just a straightforward
%       call.

% Create a function handle for roughness
fs = get(obj, 'fs');
fH = roughness(fs);

% function handle to return
f = @run;

  % 
  % Local nested function
  %
  function dataOut = run(dataIn)
    dataOut = fH(dataIn);
  end

end % processWindow