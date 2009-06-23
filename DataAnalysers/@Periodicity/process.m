function process(obj, hObj)
% PROCESS  This method is called when the Process button is pressed
%
% Get the tree nodes

[TSObj, dataObjS, node, uit] = getDataFromNode(obj, hObj, 'tSeries');

% Get the Checkboxes from the ui
panel = get(hObj,'Parent');
pRa = findobj(panel, 'Tag', 'PeriodicityGraphRateExt');
pSm = findobj(panel, 'Tag', 'PeriodicityGraphSmoothness');
pRa = get(pRa, 'Value'); pSm = get(pSm, 'Value'); 



out = analyse(obj,dataObjS,pRa,pSm);

addSummaryToNode(obj, dataObjS, node, out{1}, out{2},out{3},out{4});


% EOF



function [Rate,Extent] = RateExtentZeroX(tsTrain, time, fs, wl)

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
          if posTime(k) > 0 % Last posgoing transition
            negpos = [j k];
            indexs(row  , 1:2) = negpos; % last posgoing transition
            indexs(row+1, 1:2) = posneg;
            row = row+2;
            breakout = 1;
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
