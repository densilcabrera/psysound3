function obj = DownSampling(varargin)
% DOWNSAMPLING  Constructor.  Downsample in time
%

switch(nargin)
 case 0
  % And ratio fields
  obj.P = 1;
  obj.Q = 1;
  
  base = DataAnalyser;

  obj = class(obj, 'DownSampling', base);
  
 case 1
  arg = varargin{1};
  
  if isa(arg, 'DownSampling')
    % Copy constructor
    obj = arg;
  else
    error('Unknown argument');
  end
  
 otherwise
  error(['Invalid number of arguments for BasicPlot : ', ...
         num2str(nargin)]);
end

% Set defaults
obj = set(obj, 'Name',  'Downsample');
obj = set(obj, 'Group', 'Data Analysis');

% EOF
