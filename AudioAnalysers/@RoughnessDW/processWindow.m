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
    % Multiplication added to set levels correctly for roughness.
    % a 60dB 100% 70hz amplitude modulated tone comes out at 0.91
    % It should come out at 1 asper.
    % The discrepancy is a gain thing, and identical results can 
    % be obtained by using an offset of approx 4.867dB.
    % We don't want to change SLM though, so offset is applied here.
    dataOut = fH(dataIn * 1.71); 
  end

end % processWindow