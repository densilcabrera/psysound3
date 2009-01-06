function dataOut = processWindow(obj, dataIn)
% PROCESSWINDOW This is the core workhorse of this analyser
%
% NOTE: Every window is the same size and comes appropriately
%       zero-padded both in front and at rear, whenever neccessary,
%       and so that is why the following is just a straightforward
%       call.

% Call the autocorrelation function in the modules directory
dataOut = autocorrelation(dataIn)';  % Make row vector

% end processWindow