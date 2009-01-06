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

% get frequency scale
fs = get(obj, 'fs');
N  = get(obj, 'windowLength') - 1;
N2 = N/2;

% Note that 4*power2dB is equivalent to 40*log10, which yields 
% integer steps for each 1/12 oct band.
% Start at 40 Hz band
% frequencybands = round(4*power2dB((fs/N) * (0:N2)))-63;
% numberofbands = 109;
% Start at 20 Hz band
frequencybands = round(4*power2dB((fs/N) * (0:N2)))-51;
numberofbands = 121;
chan = get(obj,'channels');
dataOut = @run;
% 
function dataOut =run(dataIn)
    % Find the power spectrum
    spectrum = (abs(fft(dataIn))) .^2;   
    
    % initialise output spectrum
    twelfthoctspectrum = zeros(numberofbands,1);
    twelfthoctspectrumL = zeros(numberofbands,1);
    twelfthoctspectrumR = zeros(numberofbands,1);

    % Sum power spectrum components within each 1/12-octave band
    % start at band 52, which is 20 Hz
    if chan == 1
    for n = 1:N2
        if (frequencybands(n) >= 1) && (frequencybands(n) <= numberofbands)
            twelfthoctspectrum(frequencybands(n)) = twelfthoctspectrum(frequencybands(n)) + spectrum(n,1);
        end
    end
    dataOut = twelfthoctspectrum';  % Make row vector
    end
    
    
    
    if chan == 2
        for n = 1:N2
        if (frequencybands(n) >= 1) && (frequencybands(n) <= numberofbands)
            twelfthoctspectrumL(frequencybands(n)) = twelfthoctspectrumL(frequencybands(n)) + spectrum(n,1);
            twelfthoctspectrumR(frequencybands(n)) = twelfthoctspectrumR(frequencybands(n)) + spectrum(n,2);
        end
        end
        dataOut = [twelfthoctspectrumL twelfthoctspectrumR];  % Make row vector
    end    
    % send to output
    
end %run
 end

% end processWindow