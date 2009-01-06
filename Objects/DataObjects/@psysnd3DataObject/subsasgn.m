function obj = subsasgn(obj, S, val)
% SUBSASGN method for psysnd3DataObject
%
% NOTE: Only the 'dot' syntax is supported for now

switch(S(1).type)
 case '.'
  % The first field
  propName = S(1).subs;

  if length(S) > 1
    % Get the underlying object/struct we are trying to modify
    o = get(obj, propName);
    
    % Set the field
    val = builtin('subsasgn', o, S(2:end), val);
  end

  % Call the set method
  obj = set(obj, propName, val);
  
 otherwise
  error(['DataObject: subsasgn : ', S.type, ' syntax not ' ...
         'yet supported']);
end

% [EOF]
