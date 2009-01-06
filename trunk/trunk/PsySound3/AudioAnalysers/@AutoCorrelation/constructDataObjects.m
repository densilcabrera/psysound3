function obj = constructDataObjects(obj, dataBuffer, TimePoints)
%  CONSTRUCTDATAOBJECTS Constructs the appropriate data objects
%
% Analogous to assignoutputs
%

% Convenience variables
N  = get(obj, 'windowLength');
fs = get(obj, 'fs');

lagsListing = [0:(1/fs):(N/fs)]';
lagsListing = lagsListing(1:ceil(end/2));

% Get the Data
specData = dataBuffer.specData.get();

% Create the Time Spectrum
tSpec    = createDataObject('tSpectrum',lagsListing, specData, TimePoints);
tSpec.Name  = 'Correlogram';
tSpec.DataName = 'Correlation';
tSpec.DataUnit = 'Coefficient';
tSpec.FreqName = 'Lag';
tSpec.FreqUnit = 's';
tSpec.TimeName = 'Time';
tSpec.TimeUnit = 's';

% Take mean for Spectrum Object
meanSpec = mean(specData)./max(mean(specData));
Spec    = createDataObject('Spectrum', lagsListing,meanSpec);
Spec.Name  = 'Mean Correlation';
Spec.DataName = 'Normalised Correlation';
Spec.DataUnit = 'Coefficient';
Spec.FreqName = 'Lag';
Spec.FreqUnit = 's';

[rows,columns] = size(specData);
for i =1:rows
  % Lets get peaks to start with. 
  [pkFreq(i),pkHeight(i)] = getMaxPeaks(specData(i,:),fs,N);

end

pkHeight = pkHeight';
pkFreq = pkFreq'; 

pkHeight = createDataObject('tSeries',pkHeight);
pkHeight.Time = TimePoints;
pkHeight.Name = 'Peak Height';
pkHeight.DataInfo.Unit = 'Norm. Corr. Coef.';
pkFreq = createDataObject('tSeries',pkFreq);
pkFreq.Time = TimePoints;
pkFreq.Name = 'Peak Frequency';
pkFreq.DataInfo.Units = 'Hz';
tstep   = diff(TimePoints(1:2));

% Assign outputs to the object
out = {tSpec,Spec,pkHeight,pkFreq};
obj = set(obj, 'output', out);

% end constructDataObjects


function [pkFreq,pkHeight] = getMaxPeaks(inSignal,fs,N)
% walk down the autocorrelation function ramp from unity until the max peak
% is not the point I'm standing on.
i = 1;
% plot(inSignal);
% drawnow;
while i < length(inSignal)
   [x,ind]=max(inSignal(i:end));
   if ~(ind == 1)
       pkFreq = fs/(i+ind-1);
       pkHeight = inSignal(i+ind-1);
       return;
   end
   i = i+1;
end
pkFreq = NaN;
pkHeight = 0;


function [Peaks,Troughes] = getPeaks(inSignal)
% Median Filter
% smoothSig  = medfilt1(inSignal,5); 
% plot(smoothSig);
% Differentiate
  diffSig = diff(inSignal);
  % Create a matrix that contains the positive and negative differences 
  Positive = diffSig >= 0;
  Negative = diffSig < 0;
  Crossings = [Positive(1:end-1); Negative(2:end)];
  Crossings = sum(Crossings);
  % Crossings will be 1 most of the time, except for when negativefollows
  % positive (2) or positive follows negative (0). Peaks are 2, and
  % troughes are 0;
  Peaks = find(Crossings == 2) + 1; 
  Troughes = find(Crossings == 0) + 1;