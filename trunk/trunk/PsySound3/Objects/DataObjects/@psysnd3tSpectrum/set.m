function s = set(s, propName, propVal)
% SET method for Spectrum

% Set Field
switch(lower(propName))
 case 'time'
  s.Time = propVal;
 
 case 'timename'
  s.TimeName = propVal;
 
 case 'timeunit'
  s.TimeUnit = propVal;
 
 otherwise
  % Dispatch it off to the base class
  base = set(s.psysnd3Spectrum, propName, propVal);
  s.psysnd3Spectrum = base;

end
