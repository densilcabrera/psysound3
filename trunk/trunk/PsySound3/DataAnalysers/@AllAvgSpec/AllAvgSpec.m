function obj = AllAvgSpec(varargin)
% ALLAVGSPEC Constructor. Implements a multi-graph of ALL the
%            Average Magnitude spectrums in the data set.
%

switch(nargin)
 case 0
  obj  = struct([]); % no fields
  base = DataAnalyser;

  obj = class(obj, 'AllAvgSpec', base);
  
 case 1
  arg = varargin{1};
  
  if isa(arg, 'AllAvgSpec')
    % Copy constructor
    obj = arg;
  else
    error('Unknown argument');
  end
  
 otherwise
  error(['Invalid number of arguments for AllAvgSpec : ', ...
         num2str(nargin)]);
end

% Set defaults
obj = set(obj, 'Name',  'Average Spectrum (All)');
obj = set(obj, 'Group', 'Visualisation');

% EOF
