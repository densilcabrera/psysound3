function out = analyse(obj, DObj, varargin)
% ANALYSE  This method is called when the Process button is pressed - it
% is the actual analysis and the process method is the wrapper around it.
%


if strcmp(class(DObj),'struct')
    TSObj = DObj.DataObj;
    data = TSObj.data;
elseif strcmp(class(DObj),'tSeries')
    TSObj = DObj;
    data = DObj.data;
elseif strcmp(class(DObj),'double')
    TSObj = timeseries(DObj);
    TSObj.TimeInfo.Increment = 1/varargin{1};
    data = DObj;
end

%There could be NaNs at the start or end. 
% It shouldn't be more than 2/3 of the sample.
% Remove Remove Remove
nanind = find(isnan(data(end-29:end)));
firstThird = floor(length(data)/3);
firstfinite =  find(isnan(data(1:firstThird)),1,'last');
endTwoThirds = floor(2 * (length(data)/3));
lastfinite =  find(isnan(data(endTwoThirds:end)),1,'first');
lastfinite = endTwoThirds + lastfinite;
if isempty(lastfinite);  lastfinite = length(data);end
if isempty(firstfinite);  firstfinite = 1; end
data = data(firstfinite+1:lastfinite-2);

time = TSObj.time;
fs =1/TSObj.TimeInfo.Increment;
wl = floor(fs /2);

if nargin == 4
  pRa = varargin{1};
  pSm = varargin{2};
else 
  pRa = 0;
  pSm = 0;
end

% use a 2/20Hz bandpass 4th order butterworth filter
[b,a] = butter(4, 10/(fs/2),'low');
datafilt = filtfilt(b,a,data);



% Automatically Convert to Midi Notes
if strcmp(TSObj.DataInfo.Units,'Hz')
	datafilt = hz2midi(datafilt);
  units = 'Hz';
else
  units = TSObj.DataInfo.Units;
end
units = 'Hz';
[RateTS,ExtentTS] = RateExtentZeroX(datafilt, time, fs, wl);

RateStatsI = find(isfinite(RateTS));
RateStats = RateTS(RateStatsI); % Finite only
RateMed = median(RateStats); 
RateStD = tsprctile(RateStats,75) - tsprctile(RateStats,25);

ExtentStatsI = find(isfinite(ExtentTS));
ExtentStats = abs(ExtentTS(ExtentStatsI));
ExtentMed = median(ExtentStats);
ExtentStD = tsprctile(ExtentStats,75) - tsprctile(ExtentStats,25);
summary1 = {'Median Rate','Hz',RateMed};
summary2 = {'Std. Dev Rate','Hz',RateStD};
summary3 = {'Median Extent',units,ExtentMed};
summary4 = {'Std. Dev Extent',units,ExtentStD};

[CentroidHz] = SmoothnessCentroid(datafilt, time, fs, wl, pSm);
summary5 = {'Smoothness Centroid','Hz',CentroidHz};

out = {summary1,summary2,summary3,summary4, summary5};

Annotations = find(~isnan(RateTS));


if pRa
  figure; 
  
  h(1) = subplot(2,1,1);
  plot(time(1:length(RateTS)),RateTS,'ro'); hold on;
  plot(time(Annotations),RateTS(Annotations),'k'); hold on;
 set(gca,'Box', 'off');
  
  h(2) = subplot(2,1,2);
  plot(time(1:length(data)), data,'k'); hold on;
  plot(time(Annotations), data(Annotations),'og');
  set(gca, 'Box','off')
  
  linkaxes(h,'x');
end
% EOF



function [Rate,Extent] = RateExtentZeroX(tsTrain, time, fs, wl)
time = time(1:length(tsTrain));

diffSig  = [0; diff(tsTrain)];
posGoing = diffSig(1:end-1) <= 0 & diffSig(2:end) > 0;
posGoing = [0; posGoing; ];
negGoing = diffSig(1:end-1) > 0 & diffSig(2:end) <= 0;
negGoing = [0; negGoing;];
posTime  = posGoing .* time;
negTime  = negGoing .* time;
row = 1;
breakout =0;
fs = 1/ (time(3) - time(2));
topfreq = 15;
lowfreq = 1;
startind = floor(fs/topfreq/2);
lastind = floor (fs/lowfreq/2);
for i = 1+startind:length(posTime)
  if posTime(i) > 0 % positive going zerox transition
    for j = (i-startind):-1:i-lastind % Move backwards
      if negTime(j) > 0 % negative going transition
        posneg = [i j];
        for k = (j-startind):-1:i-lastind % Move backwards
         if k>0
          if posTime(k) > 0 % Last posgoing transition
            negpos = [j k];
            indexs(row  , 1:2) = negpos; % last posgoing transition
            indexs(row+1, 1:2) = posneg;
            row = row+2;
            breakout = 1;
          end
         end
          if breakout||k==1;
            break
          end
        end
      end
      if breakout||j==1
        breakout =0;
        break
      end
    end
  end
end

TimeDifferences = [time(indexs(:,1)) - time(indexs(:,2))];
DataDifferences = [tsTrain(indexs(:,1)) - tsTrain(indexs(:,2))];

RateS = 1./(TimeDifferences*2);
Rate = NaN(length(tsTrain),1);
Rate(indexs(:,1)) = RateS;

Extent = NaN(length(tsTrain),1);
Extent(indexs(:,1)) = DataDifferences;




function [vibrato] =  Vibrato(tsTrain, time, fs, wl)
% usage: [vibratoExtent,pitch] =  Vibrato(matrix, fileNumber, window);

window = 100;

% we'll go over the end of the pitch train
vibrato.pitchValues = [vibrato.pitchValues; NaN(window,1)];
for i =1:length(vibrato.pitchValues)-window
  % look for the max
  vibrato.pitchMax(i) = nanmax(vibrato.pitchValues(i:i+window));
  % look for the min
  vibrato.pitchMin(i) = nanmin(vibrato.pitchValues(i:i+window));
  % look for the Mean pitch
  vibrato.pitchMean(i) = mean(vibrato.pitchValues(i:i+window));
end

% get rid of that buffer
vibrato.pitchValues = vibrato.pitchValues(1:end-window);


% the Extent will be calculated as the Max-Min
vibrato.Ext = vibrato.pitchMax-vibrato.pitchMin;
vibrato.ExtAvg = nanmean(vibrato.Ext);

% rate is calculated statistically using zero crossing 





function m = hz2midi(hz)

m=(69+12 * log(abs(hz)/440)/log(2));



function meanValue = nanmean(inputVector)
[rows,columns] = size(inputVector);
if rows>columns
  inputVector = inputVector';
end
indexes = find(isfinite(inputVector));
try
  meanValue = mean(inputVector(indexes));
catch
  meanValue = NaN;
  return
end

if isempty(meanValue)
  meanValue = NaN;
  return
end

function minValue = nanmin(inputVector)
[rows,columns] = size(inputVector);
if rows>columns
  inputVector = inputVector';
end
indexes = find(isfinite(inputVector));
try

  minValue = min(inputVector(indexes));
catch
  minValue = NaN;
  return
end

if isempty(minValue)
  minValue = NaN;
end



function maxValue = nanmax(inputVector)
[rows,columns] = size(inputVector);
if rows>columns
  inputVector = inputVector';
end
indexes = find(isfinite(inputVector));
try
  maxValue = max(inputVector(indexes));
catch
  maxValue = NaN;
  return
end

if isempty(maxValue)
  maxValue = NaN;
end


function hVibrato = hVibrato(vibrato)

% Now find the parts that we can do the
k = 1;
i=1;
while (i < length(vibrato.pitchValues))
  if (isfinite(vibrato.pitchValues(i)))
    j = i;
    while (isfinite(vibrato.pitchValues(j)))
      j = j + 1;
    end
    vMarkers(k,:) = [i j];
    i = j;
    k = k+1;
  else
    i = i+1;
  end
end

[rows,columns] = size(vMarkers);
vibrato.hRate(1:vMarkers(1,1)-1) = NaN;
vibrato.hAmp(1:vMarkers(1,1)-1) = NaN;
for i = 1:rows
  signal = vibrato.pitchValues(vMarkers(i,1):vMarkers(i,2));
  signal(end) = signal(end-1);
  signal_fft = fft(signal(1:end));
  signal_fft(1) = 0;              % Kill DC to make hilbert transform
  signal = ifft(signal_fft);      % recreate signal
  signal_h = hilbert(signal);     % hilbert transform - complex signal now
  signal_a = abs(signal_h);       % get Amplitude
  signal_ph = angle(signal_h);    % get phase
  signal_uw = unwrap(signal_ph);  % unwrap phase
  signal_d = diff(signal_uw);     % differentiate
  signal_Hz = signal_d * fs / (2*pi); % rate in Hz
  vibrato.hRate(vMarkers(i,1):vMarkers(i,2)) = [signal_Hz; NaN;];
  vibrato.hAmp(vMarkers(i,1):vMarkers(i,2)) = [signal_a];
  if (i<rows)
    vibrato.hRate(vMarkers(i,2):vMarkers(i+1,1)) = NaN;
    vibrato.hAmp(vMarkers(i,2):vMarkers(i+1,1)) = NaN;
  else
    % Only look at the stuff 1 sec after the start and 1 sec before the end.
    % Do it before we pad out the ts.
    vibrato.hRateAvg = nanmean(vibrato.hRate(100:end-100));
    vibrato.hAmpAvg = nanmean(vibrato.hAmp(100:end-100));
    vibrato.hRate(vMarkers(i,2):length(vibrato.pitchValues)) = NaN;
    vibrato.hAmp(vMarkers(i,2):length(vibrato.pitchValues)) = NaN;
  end
end


function [CentroidHz] = SmoothnessCentroid(data, time, fs, wl, pSm)

freqscale = (([1:length(data)]' - 1) / length(data)) * fs;
magnitudeData = abs(fft(data).^2);
CentroidHz = sum(freqscale.*magnitudeData) / (sum(magnitudeData)+eps);


if pSm
  plot(freqscale(1:end/2),10*log10(magnitudeData(1:end/2)));
  axis([0 20 40 100]);
end

