function dataOut = processWindow(obj, dataIn)
% PROCESSWINDOW This is the core workhorse of this analyser
%
% NOTE: Every window is the same size and comes appropriately
%       zero-padded both in front and at rear, whenever neccessary,
%       and so that is why the following is just a straightforward
%       call.
%%
Fs_Hz = get(obj, 'fs');
nFFT = get(obj, 'windowLength');
N2=nFFT/2;

% get variables from base workspace
Noct = get(obj,'NOct');
Noct_Start_Hz = get(obj,'NOctStartHz');

%[numberofbands, frequencybands] = freqBands_1_N_oct(Fs_Hz, nFFT, Noct_Start_Hz, Noct);
numberofbands = get(obj, 'NOctNumBands');   % number of 1/n-octave bands
frequencybands = get(obj, 'NOct_FFT_2_NOctFreq');  % vector mapping FFT bin to 1/N-octave bands

%%
dataOut = @run;

function dataOut =run(dataIn)
    % Find the power spectrum
    spectrum = (abs(fft(dataIn))) .^2;   
    
    % initialise output spectrum
    Noctspectrum = zeros(numberofbands,1);

    % Sum power spectrum components within each 1/12-octave band
    % start at band 52, which is 20 Hz
    for n = 1:N2
        if (frequencybands(n) >= 1) && (frequencybands(n) <= numberofbands)
            Noctspectrum(frequencybands(n)) = Noctspectrum(frequencybands(n)) + spectrum(n,1);
        end
    end

    % send to output
    dataOut = Noctspectrum';  % Make row vector
end %run

end
% end processWindow