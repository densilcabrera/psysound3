function obj = constructDataObjects(obj, dataBuffer, timePoints)
%  CONSTRUCTDATAOBJECTS Constructs the appropriate data objects
%
% 

% Analogous to assignoutputs

VP = dataBuffer.VP.get();
SP = dataBuffer.SP.get();
PT = dataBuffer.PT.get();
CT = dataBuffer.CT.get();
M  = dataBuffer.M.get();
S  = dataBuffer.S.get();
CP  = dataBuffer.CP.get();

out = {};

VirtualVPTS  = createDataObject('tSpectrum', (1:size(VP, 2)), VP, timePoints);
VirtualVPTS = set(VirtualVPTS,'Name','Virtual Pitch');
VirtualVPTS = set(VirtualVPTS,'FreqName','Note');
VirtualVPTS = set(VirtualVPTS,'FreqUnit','note number');
VirtualVPTS = set(VirtualVPTS,'DataName','Pitch Strength');
VirtualVPTS = set(VirtualVPTS,'DataUnit','');
out{end+1} = VirtualVPTS;

SpectralVPTS = createDataObject('tSpectrum', (1:size(SP, 2)), SP, timePoints);
SpectralVPTS = set(SpectralVPTS,'Name','Spectral Pitch');
SpectralVPTS = set(SpectralVPTS,'FreqName','Note');
SpectralVPTS = set(SpectralVPTS,'FreqUnit','note number');
SpectralVPTS = set(SpectralVPTS,'DataName','Pitch Strength');
SpectralVPTS = set(SpectralVPTS,'DataUnit','');
out{end+1} = SpectralVPTS;

tstep = 1/get(obj, 'outputDataRate');

% format for TimeSeries
timeSeriesOutput = createDataObject('tSeries', PT);
timeSeriesOutput.DataInfo.Unit = '';
timeSeriesOutput.Name = 'Pure Tonalness'; 
timeSeriesOutput.TimeInfo.Increment = tstep;
out{end+1} = timeSeriesOutput;

% format for TimeSeries
timeSeriesOutput = createDataObject('tSeries', CT);
timeSeriesOutput.DataInfo.Unit = '';
timeSeriesOutput.Name = 'Complex Tonalness'; 
timeSeriesOutput.TimeInfo.Increment = tstep;
out{end+1} = timeSeriesOutput;

% format for TimeSeries
timeSeriesOutput = createDataObject('tSeries', M);
timeSeriesOutput.DataInfo.Unit = '';
timeSeriesOutput.Name = 'Multiplicity'; 
timeSeriesOutput.TimeInfo.Increment = tstep;
out{end+1} = timeSeriesOutput;

CombinedVPTS = createDataObject('tSpectrum', (1:size(S, 2)), S, timePoints);
CombinedVPTS = set(CombinedVPTS,'Name','Note Salience');
CombinedVPTS = set(CombinedVPTS,'FreqName','Note');
CombinedVPTS = set(CombinedVPTS,'FreqUnit','note number');
CombinedVPTS = set(CombinedVPTS,'DataName','Salience pattern (Parncutt)');
CombinedVPTS = set(CombinedVPTS,'DataUnit','');
out{end+1} = CombinedVPTS;

% Do the Chord Change Likelihood estimates
order = 6; % This is the amount of smoothing applied during the differencing.
[chords,cLH,ChrdChTimes,chroTSpec] = PitchProfile(S,timePoints,order);

ChromaVPTS = createDataObject('tSpectrum', (1:size(chroTSpec, 2)), chroTSpec, timePoints);
ChromaVPTS = set(ChromaVPTS,'Name','Chroma Salience ');
ChromaVPTS = set(ChromaVPTS,'FreqName','Chroma');
ChromaVPTS = set(ChromaVPTS,'FreqUnit','number');
ChromaVPTS = set(ChromaVPTS,'DataName','Chroma Pattern (Parncutt)');
ChromaVPTS = set(ChromaVPTS,'DataUnit','');
out{end+1} = ChromaVPTS;


timeSeriesOutput = createDataObject('tSeries', cLH);
timeSeriesOutput = set(timeSeriesOutput,'Time',timePoints(1:end-order));
timeSeriesOutput.DataInfo.Unit = '';
timeSeriesOutput.Name = 'Chord Change Likelihood'; 
% add Events

for i = 1:length(ChrdChTimes);
  ChrdChT(i) = {ChrdChTimes(i)};
end
timeSeriesOutput = addevent(timeSeriesOutput,chords,ChrdChT); % add multiple events - chord changes and their names
out{end+1} = timeSeriesOutput;

% Set output on the object
obj = set(obj, 'output', out);

% end constructDataObjects