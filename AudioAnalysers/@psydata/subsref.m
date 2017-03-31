function value = subsref(obj, S)
% SUBSREF method for Spectrum
%
% NOTE: Only the 'dot' syntax is supported for now

switch(S(1).type)
 case '.'
  propName = S(1).subs;

  % Call the set method
  value = get(obj, propName);
  
  % Dispatch the rest to MATLAB
  if length(S) > 1
    value = builtin('subsref', value, S(2:end));
  end
 otherwise
  error([class(obj), ': subsasgn : ', S.type, ' syntax not ' ...
                                               'yet supported']);
end
