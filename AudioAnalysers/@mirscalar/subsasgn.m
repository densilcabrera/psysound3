function obj = subsasgn(obj, S, value)
% SUBSASGN method for Spectrum
%
% NOTE: Only the 'dot' syntax is supported for now

switch(S(1).type)
 case '.'
  propName = S.subs;

  % First get the value
  propVal = get(obj, propName);
  
  % Alter it, if need be using MATLAB
  % if length(S) > 1
  %   value = builtin('subsasgn', propVal, S(2:end), value);
  % end
  
  % Call the set method
  obj = set(obj, propName, value);
  
  % Dispatch the rest to MATLAB
 otherwise
  error([class(obj), ': subsasgn : ', S.type, ' syntax not ' ...
                                               'yet supported']);
end
