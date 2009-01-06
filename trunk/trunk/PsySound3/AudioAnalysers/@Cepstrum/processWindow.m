function dataOut = processWindow(obj, dataIn)
% PROCESSWINDOW This is the core workhorse of this analyser
%
% NOTE: Every window is the same size and comes appropriately
%       zero-padded both in front and at rear, whenever neccessary,
%       and so that is why the following is just a straightforward
%       call.

% Call MATLAB's real Cepstrum command
dataOut = rceps(dataIn)';  % Make row vector

% note - it would also be possible to obtain the minimum phase
% reconstruction of the signal at this point using the optional second
% output of rceps()

% end processWindow