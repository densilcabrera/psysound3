function obj = Threshold(varargin)
% FASTFOURIERTRANSFORM   Constructor. Implements fft
%

switch(nargin)
 case 0
  obj  = struct([]); % no fields
  base = DataAnalyser;

  obj = class(obj, 'Threshold', base);
  
 case 1
  arg = varargin{1};
  
  if isa(arg, 'Threshold')
    % Copy constructor
    obj = arg;
  else
    error('Unknown argument');
  end
  
 otherwise
  error(['Invalid number of arguments for Threshold : ', ...
         num2str(nargin)]);
end

% Set defaults
obj = set(obj, 'Name',  'Threshold');
obj = set(obj, 'Group', 'Data Analysis');

% EOF
