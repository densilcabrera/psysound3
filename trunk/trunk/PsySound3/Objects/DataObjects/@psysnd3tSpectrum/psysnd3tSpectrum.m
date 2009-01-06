function obj = psysnd3tSpectrum(varargin)
% PSYSND3TSPECTRUM Constructor
%
%
  
switch nargin
 case 0
  % Create an empty object
  obj = struct('Time',     [],     ...
               'TimeName', 'Time', ...
               'TimeUnit', 'seconds');

  % Construct default Spectrum object
  specObj = psysnd3Spectrum;
  
  % This is a subclass of the dataObject
  obj = builtin('class', obj, 'psysnd3tSpectrum', specObj);
  
 case 1
  arg1 = varargin{1};
  
  if isa(arg1, 'tSpectrum')
    obj = arg1;
  else
    error('Unknown input argument');
  end
 
 case 3
  % Assume freq, time, data
  freq = varargin{1};
  data = varargin{2};
  time = varargin{3};
  
  % First call the default constructor
  obj = psysnd3tSpectrum;
  
  % Then assign data
  obj = set(obj, 'Freq', freq);
  obj = set(obj, 'Data', data);
  obj.Time = time;

 otherwise
  error('Unknown number of inputs');
  
end % switch
  
% [EOF]
