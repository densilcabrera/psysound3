function obj = set(obj, prop, val)
% SET method for DataAnalyser

switch(lower(prop))
 case 'name'
  obj.Name = val;
  
 case 'group'
  obj.Group = val;
  
 otherwise
  error(['Unknown property, ', prop]);
end

% EOF
