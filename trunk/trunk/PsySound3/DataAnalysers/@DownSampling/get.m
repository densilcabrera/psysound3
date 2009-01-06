function val = get(obj, prop)
% GET method for DownSampling

switch(lower(prop))
 case 'p'
  val = obj.P;
  
 case 'q'
  val = obj.q;
  
 otherwise
  % Try the base class
  val = get(obj.DataAnalyser, prop);
end

% EOF
