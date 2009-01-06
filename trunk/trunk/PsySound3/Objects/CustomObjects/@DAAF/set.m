function obj = set(obj, prop, val)
% SET method for DataAnalyser

try 
  
  obj.(prop) = val;
  
catch
  error(['Unknown property, ', prop]);
end

% EOF
