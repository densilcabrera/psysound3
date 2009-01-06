function val = get(obj, prop)
% GET method for DataAnalyser

switch(lower(prop))
 case 'name'
  val = obj.Name;
  
 case 'group'
  val = obj.Group;
  
 otherwise
  error(['Unknown property, ', prop]);
end

% EOF
