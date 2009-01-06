function out = subsref(dsObj, S)
% SUBSREF method for dataStorage
%
% Only overload the dot operator

switch(S(1).type)
 case '.'
  out = dsObj.(S(1).subs);

  % Dispatch the rest to MATLAB
  if length(S) > 1
    out = builtin('subsref', out, S(2:end));
  end
  
 otherwise
  % Dispatch the rest to MATLAB
  out = builtin('subsref', dsObj, S);
end

% EOF
