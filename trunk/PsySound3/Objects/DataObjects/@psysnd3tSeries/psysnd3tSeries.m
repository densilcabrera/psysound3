function obj = psysnd3tSeries(varargin)
% PSYSND3TSERIES  Timeseries data object for PsySound3
%
%

switch(nargin)
 case 0
  % Create an empty object
  obj = struct('tsObj', []);
  
  obj = builtin('class', obj, 'psysnd3tSeries', psysnd3DataObject);
 
 case {1, 2, 3}
  arg1 = varargin{1};
  
  unit     = '';
  dbOffset = 0;
  if nargin > 2
    unit = varargin{2};
    % For dB, see if there is an offset
    if strcmp(unit, 'dB')
      if nargin == 3
        dbOffset = varargin{3};
      end
    end
  end
  
  if isa(arg1, 'tSeries')
    obj = arg1
  elseif isnumeric(arg1)
    % An array is passed in, so use it to create a timeseries
    % object
    data = arg1;
    ts = timeseries(data);
    
    % Call the default constructor
    obj = psysnd3tSeries;
    
    % Set data unit
    ts.DataInfo.Unit = unit;

    % assign the timeseries obj
    obj.tsObj = ts;
  
    % Add statistics
    statsObj = createDataObject('Stats', data, dbOffset);
    obj = set(obj, 'Stats', statsObj);
    
  else
    error('psysnd3tSeries: Unknown input argument');
  end
  
 otherwise
  error('Invalid number of arguments supplied');
  
end % switch

% [EOF]

