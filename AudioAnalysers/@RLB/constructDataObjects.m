function obj = constructDataObjects(obj, dataBuffer, TimePoints)
%  CONSTRUCTDATAOBJECTS Constructs the appropriate data objects
%


rc  = get(obj, 'rmsChoices');
len = length(rc);
winRate = get(obj, 'outputDataRate');

output = cell(len, 1);

% Get the data
data = dataBuffer.data.get();

for i=1:len
  dat = data(:,i);
  
  % Pad filter delay with nan's
  if getIgnoreDelay(obj)
    del = winRate * rc(i);
    dat(1:del) = NaN;
  end
  
  % format for TimeSeries
  dBOffset = 93.94;
  logData  = power2dB(abs(dat)) + dBOffset;
  
  ts = createDataObject('tSeries', logData, 'dB', dBOffset);
  ts.Name = ['Loudness level - ', num2str(rc(i)), 's']; 
  ts.TimeInfo.Increment = 1/winRate;
  output{i} = ts;
end

% Assign outputs to object
obj = set(obj, 'output', output);

% end constructDataObjects
