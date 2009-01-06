function val = get(obj, prop)
% GET method for DAAF
try
  val = obj.(prop);
catch
  error(['Unknown property, ', prop]);
end

% EOF
