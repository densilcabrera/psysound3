function obj = constructDataObjects(obj, dataBuffer, TimePoints)
%  CONSTRUCTDATAOBJECTS Constructs the appropriate data objects
%

% Analogous to assignoutputs
wChoices = getwChoices(obj);
iChoices = getiChoices(obj);

fs = get(obj, 'outputDataRate');

% Get the full matrix data from the buffer
data = dataBuffer.data.get();

% Divvy out the timeseries objects
out      = {};
colCount = 1;
for w=1:length(wChoices)
  wStr = wChoices(w);
  
  % dB offsets
  switch(wChoices(w))
   case 'A'
    dBoffset = 94.89;
   case 'B'
    dBoffset = 94.89;
   case 'C'
    dBoffset = 94.89;
   case 'D'
    dBoffset = 94.89;
   case 'R'
    dBoffset = 95.89;
   case 'Z'
    % unweighted
    dBoffset = 94.89;
    otherwise
    dBoffset = 94.89;
    warning('SLM: unknown level offset');
  end
  
  for i=1:length(iChoices)
    switch char(iChoices(i))
			case 'f',
      	iStr = 'Fast';
      	del  = 1 * 0.125 * fs;
    	case 's'
  			iStr = 'Slow';
      	del  = 1 * 1 * fs;
    	case 'i',
      	iStr = 'Impulse';
      	del  = 1 * 0.035 * fs;
    	case 'p',
      	iStr = 'Peak';
      	del  = 1 * 0.00050 * fs;
      otherwise
        iStr = char(iChoices(i));
        tau = str2num(iStr(2:end));
      	del  = 1 * tau * fs;
		end

    % Pad the filter delay with NaN's
    if getIgnoreDelay(obj)
      del = round(del);
      data(1:del, colCount) = NaN;
    end
    
    % Convert to dB and adjust level
    dBdata = power2dB(data(:, colCount).^2) + dBoffset;
    
    % Assign each col
    ts = createDataObject('tSeries', dBdata, 'dB', dBoffset);
    if ~strcmp(wChoices(w), 'Z')
      ts.Name = ['SPL ', wStr, '-weighted ', iStr];
    else
      ts.Name = ['SPL ', wStr, '-Unweighted ', iStr];
    end      

    % Assign
    out{end+1} = ts;
    
    % update count
    colCount = colCount+1;
  end
end
    
% Set the proper sampling rate
for i=1:length(out)
  out{i}.TimeInfo.Increment = 1/get(obj, 'outputDataRate');
end

% Set the output property
obj = set(obj, 'output', out);

% end constructDataObjects