function obj = psysnd3Spectrum(varargin)
% PSYSND3SPECTRUM Constructor
%
%
  
switch nargin
 case 0
  % Create an empty object
  obj = struct('Data', [], ...
               'Freq', [], ...
               'DataName', 'Level',     ...
               'FreqName', 'Frequency', ...
               'DataUnit', 'dB',        ...
               'FreqUnit', 'Hz');
  
  % This is a subclass of the dataObject
  obj = builtin('class', obj, 'psysnd3Spectrum', psysnd3DataObject);
  
 case 1
  arg1 = varargin{1};
  
  if isa(arg1, 'Spectrum')
    obj = arg1;
  else
    error('Unknown input argument');
  end
 
 case 2
  % Assume freq, data and create the stats object
  freq = varargin{1};
  data = varargin{2};
  stats = createDataObject('Stats', data);
  
  % First call the default constructor
  obj = psysnd3Spectrum;
  
  % Then assign data
  obj = set(obj, 'Freq', freq);
  obj = set(obj, 'Data', data);
  obj = set(obj, 'Stats', stats);

end % switch

% [EOF]
