function dsArr = dataStorageArray(varargin)
% DATASTORAGEARRAY object for PsySound3 data files
%
% This object is a container object to act as an array for the
% dataStorage objects

switch nargin
 case 0
  % Create a new (empty) object
  obj.children = struct([]);
  obj.type     = '';
  obj.date     = '';
  obj.data     = [];
  
  % Instantiate the object
  obj = class(obj, 'dataStorageArray');
  
 case 1
  arg1 = varargin{1};

  % Simply return for dataStorage objects
  if isa(arg1, 'dataStorageArray')
    obj = arg1;
  end

 otherwise
  error('Invalid argument(s) in constructor of dataStorageArray');
end

% Assign output
dsArr = obj;

% end dataStorage constructor
