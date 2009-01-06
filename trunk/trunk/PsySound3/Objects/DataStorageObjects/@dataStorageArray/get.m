function val = get(obj, prop)
% GET  Method for the dataStorageArray object

val = [];

switch lower(prop)
 case 'type'
  val = obj.type;
  
 case 'data'
  val = obj.data;
  
 case 'date'
  val = obj.date;
  
 otherwise
  error(['Unknown property specified : ', prop]);
  
end

% EOF
