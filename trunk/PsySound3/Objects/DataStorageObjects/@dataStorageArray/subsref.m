function out = subsref(dsArr, S)
% SUBSREF method for dataStorageArray
%
% Only overload the dot operator

out = [];

switch(S(1).type)
 case '()'
  subs = S(1).subs{1};
  
  if isnumeric(subs)
    % Simple index
    out = dsArr.children(subs);
  
  elseif isstr(subs)
    % Match name
    out = findChildWithName(dsArr, subs)
  
  elseif isa(subs, 'dataStorage')
    % Match exact child
    ind = findeq(dsArr, subs);
    out = dsArr.children(ind);
    
  else
    error('Unknown subsref type requested');
  end
    
  % Dispatch the rest to MATLAB
  if length(S) > 1
    out = builtin('subsref', out, S(2:end));
  end
  
 otherwise
  % Dispatch the rest to MATLAB
  out = builtin('subsref', dsArr, S);
end

% EOF
