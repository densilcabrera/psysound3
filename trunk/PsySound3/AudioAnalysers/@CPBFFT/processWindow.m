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
% 1/3-oct bands, with 12.5 Hz given as band 1.
% Note that power2dB is equivalent to 10*log10, which yields 
% integer steps for each 1/3 oct band.
frequencybands = round(power2dB((fs/N) * (0:N2))) - 10;
numberofbands = 33;
chan = get(obj,'channels');
dataOut = @run;

function dataOut =run(dataIn)
    % Find the power spectrum
    spectrum = (abs(fft(dataIn))) .^2;   
    


    % Sum power spectrum components within each 1/3-octave band
    if chan == 1
            % initialise output spectrum
    thirdoctspectrum = zeros(numberofbands,1);
    for n = 1:N2
        if (frequencybands(n) >= 1) && (frequencybands(n) <= (numberofbands))
            thirdoctspectrum(frequencybands(n)) = thirdoctspectrum(frequencybands(n)) + spectrum(n,1);
        end
    end

    % send to output
    dataOut = thirdoctspectrum';  % Make row vector
    end
    if chan ==2
            % initialise output spectrum
    thirdoctspectrumL = zeros(numberofbands,1);
    thirdoctspectrumR = zeros(numberofbands,1);
        for n = 1:N2
        if (frequencybands(n) >= 1) && (frequencybands(n) <= (numberofbands))
            thirdoctspectrumL(frequencybands(n)) = thirdoctspectrumL(frequencybands(n)) + spectrum(n,1);
            thirdoctspectrumR(frequencybands(n)) = thirdoctspectrumR(frequencybands(n)) + spectrum(n,2);
        end
    end

    % send to output
    dataOut = [thirdoctspectrumL thirdoctspectrumR];  % Make row vector
    end    
end %run
end

% end processWindow