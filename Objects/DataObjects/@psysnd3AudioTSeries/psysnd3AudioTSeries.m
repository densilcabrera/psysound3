function obj = psysnd3AudioTSeries(varargin)
% PSYSND3AUDIOTSERIES  Audio Timeseries data object for PsySound3
%
%

switch(nargin)
 case 0
  % Create an empty object
  obj = struct('origFileName', '', ...
               'bits', [], ...
               'Fs',   []);
  
  obj = builtin('class', obj, 'psysnd3AudioTSeries', psysnd3tSeries);
 
 case {1,2,3}
  arg1 = varargin{1};
  
  if isa(arg1, 'AudioTSeries')
    obj = arg1
  elseif  isnumeric(arg1)
    if nargin>1
      % Call the default constructor
      obj = psysnd3AudioTSeries;
      
      % Set fields
      obj.origFileName = '';
      obj.Fs   = varargin{2};
      obj.bits = 16;
      
      % And swap out the base object
      obj.psysnd3tSeries = createDataObject('tSeries', arg1);
      
      % Set the appropriate sampling time
      obj.psysnd3tSeries.TimeInfo.Increment = 1/varargin{2};
      
      obj = set(obj, 'Name', varargin{3});
      
    else
      error(['Unable to construct AudioTSeries object. No sampling frequency specified']);
    end
  elseif isstr(arg1)
    % A string, i.e. filename has been passed in
    
    if exist(arg1, 'file')
      % load data
      [Y, Fs, bits] = wavread(arg1);
      
      % use prefs xxx
      Y = Y(:,1);
      
      % Call the default constructor
      obj = psysnd3AudioTSeries;
      
      % Set fields
      obj.origFileName = arg1;
      obj.Fs   = Fs;
      obj.bits = bits;
      
      % And swap out the base object
      obj.psysnd3tSeries = createDataObject('tSeries', Y);
      
      % Set the appropriate sampling time
      obj.psysnd3tSeries.TimeInfo.Increment = 1/Fs;
      
      % Set the wav-file name as the name
      [pStr, name] = fileparts(arg1);
      obj = set(obj, 'Name', name);
      
    else
      error(['Unable to construct AudioTSeries object. File name : ' ...
             arg1, ' does not exist']);
    end
  else
    error('psysnd3AudioTSeries: Unknown input argument');
  end
  
 otherwise
  error('Invalid number of arguments supplied');
  
end % switch

% [EOF]
