function dsArr = subsasgn(dsArr, S, val)
% SUBSASGN method for dataStorageArray
%
% Only overload the paren operator

% This only exists to modify the underlying dataStorage objects

switch(S(1).type)
 case '()'
  % Get the index of the child we want to modify
  index = S(1).subs{1};
  
  % Get the actual dataStorage object
  dsObj = dsArr.children(index);
  
  % Modify it
  dsObj = subsasgn(dsObj, S(2:end), val);
  
  % Stick it back in
  dsArr.children(index) = dsObj;
  
 otherwise
  % Dispatch the rest to MATLAB
  out = builtin('subsasgn', dsObj, S);
end

% EOF
