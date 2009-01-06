function obj = DataExportGroup(varargin)
% DATAEXPORTBASIC  Basic DataExport 
%

switch(nargin)
 case 0
  % Hold onto text handles
  obj  = struct([]);
  base = DataAnalyser;

  obj = class(obj, 'DataExportGroup', base);
  
 case 1
  arg = varargin{1};
  
  if isa(arg, 'DataExportGroup')
    % Copy constructor
    obj = arg;
  else
    error('Unknown argument');
  end
  
 otherwise
  error(['Invalid number of arguments for DataExportGroup : ', ...
         num2str(nargin)]);
end

% Set defaults
obj = set(obj, 'Name',  'Timeseries group');
obj = set(obj, 'Group', 'Data Export');

% EOF
