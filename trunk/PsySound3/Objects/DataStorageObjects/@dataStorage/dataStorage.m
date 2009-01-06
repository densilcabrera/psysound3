function dsObj = dataStorage(varargin)
% DATASTORAGE object for PsySound3 data files
%
% This object facilitates the rendering of the tree in Post procesing
%
% Description of field names of nodes
%   NAME      : Name of node eg. 'Average Magnitude Spectrum'
%   FILENAME  : The name of the file or dir this record corresponds
%               to
%   NODETYPE  : The type of node this is
%   DATE      : Date of creation
%   ISLEAF    : Whether or not this node has any children

switch nargin
 case 0
  % Create a new (empty) object
  obj.name     = '';
  obj.filename = '';
  obj.nodeType = '';
  obj.date     = '';
  obj.isLeaf   = 0;

  % Instantiate the object
  obj = class(obj, 'dataStorage');
  
 case 1
  arg1 = varargin{1};

  % Simply return for dataStorage objects
  if isa(arg1, 'dataStorage')
    obj = arg1;
  end

 case 4
    % Create default object
  obj = dataStorage;
  
  % Set properties
  obj.name     = varargin{1};
  obj.filename = varargin{2};
  obj.nodeType = varargin{3};
  obj.isLeaf   = varargin{4};
  obj.date     = datestr(now);

 otherwise
  error('Invalid argument(s) in constructor of dataStorage');
end

% Assign output
dsObj = obj;

% end dataStorage constructor
