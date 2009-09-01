function dataOut = processWindow(obj, dataIn)
% PROCESSWINDOW This is the core workhorse of this analyser
%
% NOTE: Every window is the same size and comes appropriately
%       zero-padded both in front and at rear, whenever neccessary,
%       and so that is why the following is just a straightforward
%       call.

if size(dataIn,2) ~= 1 && size(dataIn,2) ~= 2
  dataOut = [];
  return;
end

fs = get(obj, 'fs');
minFreq = 27.5;
bins = 12;
maxFreq = minFreq * 2^9;
thresh= 0.0054;
sparKernel= sparseKernel(minFreq, maxFreq, bins, fs, thresh);

% get frequency scale
%fs = get(obj, 'fs');
%N  = get(obj, 'windowLength') - 1;
%N2 = N/2;

% Note that 4*power2dB is equivalent to 40*log10, which yields 
% integer steps for each 1/12 oct band.
% Start at 40 Hz band
% frequencybands = round(4*power2dB((fs/N) * (0:N2)))-63;
% numberofbands = 109;
% Start at 20 Hz band
%frequencybands = round(4*power2dB((fs/N) * (0:N2)))-51;
%numberofbands = 109;
chan = get(obj,'channels');
dataOut = @run;
% 
function dataOut =run(dataIn)

    if chan == 1
        % Find the power spectrum
    twelfthoctspectrum = (abs(constQ(dataIn', sparKernel))) .^2;
    dataOut = [twelfthoctspectrum];  % Make row vector
    end
    
    
    
    if chan == 2
        twelfthoctspectrumL = (abs(constQ(dataIn(:,1)', sparKernel))) .^2;
        twelfthoctspectrumR = (abs(constQ(dataIn(:,2)', sparKernel))) .^2;
        dataOut = [twelfthoctspectrumL twelfthoctspectrumR];  % Make row vector
    end    
    % send to output
    
end %run
 end

% end processWindow