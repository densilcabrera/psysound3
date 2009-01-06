function val = subsref(obj, S)
% SUBSREF method for psysnd3DataObject
%
% NOTE: Only the 'dot' syntax is supported for now

switch(S(1).type)
 case '.'
  propName = S(1).subs;

  % Call the get method
  val = get(obj, propName);

  % Dispatch the rest to MATLAB
  if length(S) > 1
    val = builtin('subsref', val, S(2:end));
  end
  
 otherwise
  error(['DataObject: subsref : ', S.type, ' syntax not ' ...
                                               'yet supported']);
end
