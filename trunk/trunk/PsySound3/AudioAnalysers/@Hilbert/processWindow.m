function dataOut = processWindow(obj, dataIn)
% PROCESSWINDOW This is the core workhorse of this analyser
%
% NOTE: Every window is the same size and comes appropriately
%       zero-padded both in front and at rear, whenever neccessary,
%       and so that is why the following is just a straightforward
%       call.

% Call MATLAB's hilbert command
hilbertData = hilbert(dataIn);

% Envelope
dataOut{1} = abs(hilbertData) .^ 2;

% Phase
phs = angle(hilbertData);
dataOut{2} = phs;

% Calculate frequency
fs = get(obj, 'fs');
freqData = medfilt1(diff([phs; 0])*fs/2/pi, 5);
dataOut{3} = freqData;

% end processWindow
