function obj = set(obj, prop, val)
% SET method for DownSampling

switch(lower(prop))
 case 'p'
  obj.P = val;
  
 case 'q'
  obj.q = val;
  
 otherwise
  % Try the base class
  base = set(obj.DataAnalyser, prop, val);
  obj.DataAnalyser = base;
end

% EOF
