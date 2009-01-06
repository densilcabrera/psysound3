function val = get(obj, propName)
% GET method for tSpectrum

% Note: isfield appears to be broken on MATLAB 7.4 so using a
% switch statement instead
switch(lower(propName))
 case 'time'
  val = obj.Time;
 
 case 'timename'
  val = obj.TimeName;
 
 case 'timeunit'
  val = obj.TimeUnit;
 
 case 'spectrum'
  val = obj.psysnd3Spectrum;
 
 otherwise
  % Dispatch it off to the base class
  val = get(obj.psysnd3Spectrum, propName);

end

% [EOF]
