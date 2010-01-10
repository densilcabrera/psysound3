function obj = constructDataObjects(obj, dataBuffer, timePoints)
%  CONSTRUCTDATAOBJECTS Constructs the appropriate data objects
%
% Analogous to assignoutputs
%
offset = 94.48; %set so that a 1 kHz pure tone reads correctly in the 1 kHz 1/3-octave band (as opposed to thes power sum of all components)

% format for TimeSpectrum
IECFreqs = [25 32 40 50 63 80 100 125 160 200 250 320 400 500 630 800 1000 1250 1600 2000 2500 3150 4000 5000 6300 8000 10000 12500]';
for i = 1:length(IECFreqs)
    IECFreqsStr{i} = num2str(IECFreqs(i));
end
IECFreqs = IECFreqsStr;

try 
  % Get the time spectrum data
  tData = dataBuffer.data.get();
catch
  tData = dataBuffer;
end

TimePoints = (0:size(tData, 1)-1)' / get(obj, 'outputDataRate');

out = {};
tSpecOutPutData    = tData + offset;
TimeSpectrumOutput = createDataObject('tSpectrum', IECFreqs, ...
                                      tSpecOutPutData, TimePoints);
TimeSpectrumOutput = set(TimeSpectrumOutput,'Name', ...
                                       'One-third Octave Band Spectrogram');
TimeSpectrumOutput = set(TimeSpectrumOutput,'DataName','Level');
TimeSpectrumOutput = set(TimeSpectrumOutput,'DataUnit','dB');
TimeSpectrumOutput = set(TimeSpectrumOutput,'FreqName','Center Frequency');
TimeSpectrumOutput = set(TimeSpectrumOutput,'FreqUnit','Hz');
out{end+1} = TimeSpectrumOutput;

% Spectrum data
% Reconstruct magnitude data before taking logs
magData  = 10 .^ (tData/10);
meanData = mean(magData, 1);
outputSpectrumData = power2dB(meanData) + offset;

% format for Spectrum
 for i = 1:length(outputSpectrumData)
     if (outputSpectrumData(i) < 0)
         outputSpectrumData(i) = 0;
     end
 end

SpectrumOutput = createDataObject('Spectrum', IECFreqs, outputSpectrumData); 
SpectrumOutput = set(SpectrumOutput, 'Name','One-third Octave Band Spectrum');
SpectrumOutput = set(SpectrumOutput, 'DataName',  'Level');
SpectrumOutput = set(SpectrumOutput, 'DataUnit',  'dB');
SpectrumOutput = set(SpectrumOutput, 'FreqName',  'Center Frequency');
SpectrumOutput = set(SpectrumOutput, 'FreqUnit',  'Hz');
SpectrumOutput = set(SpectrumOutput, 'FreqScale', 'log');
out{end+1} = SpectrumOutput;

% Mod = 0 for free field
% Mod = 1 for diffuse field
Mod = 0;
fs = get(obj, 'fs'); % Note, this has no affect below

[N, specN] = loudness_1991(outputSpectrumData + 1.5, ...
                           'totally ignored', fs, Mod);

SpectrumOutput = createDataObject('Spectrum', [0.1:0.1:24]', specN);
SpectrumOutput = set(SpectrumOutput,'Name','Specific Loudness (ISO532B)');
SpectrumOutput = set(SpectrumOutput,'DataName', 'Loudness');
SpectrumOutput = set(SpectrumOutput,'DataUnit', 'Sones/Bark');
SpectrumOutput = set(SpectrumOutput,'FreqName', 'Critical Band Rate');
SpectrumOutput = set(SpectrumOutput,'FreqUnit', 'Bark');
out{end+1} = SpectrumOutput;

%Assign outputs to the obect
obj = set(obj, 'output', out);

% end constructDataObjects
