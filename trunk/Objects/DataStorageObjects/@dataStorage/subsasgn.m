function dsObj = subsasgn(dsObj, S, val)
% SUBSASGN method for dataStorage
%
% Only overload the dot operator

switch(S(1).type)
 case '.'
  prop = S(1).subs;

  % Dispatch the rest to MATLAB
  if length(S) > 1
    obj = get(dsObj, prop);
    val = builtin('subsasgn', obj, prop, S(2:end));
  end
  
  % Set the property
  dsObj = set(dsObj, prop, val);
  
 otherwise
  % Dispatch the rest to MATLAB
  dsObj = builtin('subsasgn', dsObj, S, val);
end

% EOF

