function obj = Difference(varargin)
% FASTFOURIERTRANSFORM   Constructor. Implements fft
%

switch(nargin)
 case 0
  obj  = struct([]); % no fields
  base = DataAnalyser;

  obj = class(obj, 'Difference', base);
  
 case 1
  arg = varargin{1};
  
  if isa(arg, 'Difference')
    % Copy constructor
    obj = arg;
  else
    error('Unknown argument');
  end
  
 otherwise
  error(['Invalid number of arguments for Difference : ', ...
         num2str(nargin)]);
end

% Set defaults
obj = set(obj, 'Name',  'Difference');
obj = set(obj, 'Group', 'Data Analysis');

% EOF
