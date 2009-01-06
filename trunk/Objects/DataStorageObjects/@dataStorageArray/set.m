function obj = set(obj, prop, val)
% SET  Method for the dataStorageArray object

switch lower(prop)
 case 'type'
  obj.type = val;
  
 case 'data'
  obj.data = val;
  
 case 'date'
  obj.date = val;
  
 otherwise
  error(['Unknown property specified : ', prop]);
  
end

% EOF
