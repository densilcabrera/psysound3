function [dsArr, dsObj] = replaceNode(dsArr, arg)
% REPLACENODE  Replaces the given node in the array with the argument
% 
% ARG   can be a numerical index or a name to match
% dsObj is the dataStorage object that was removed, empty if not found

num = getNumChildren(dsArr);

if isnumeric(arg)
  dsObj = dsArr.children(arg);
  dsArr.children(arg) = [];
elseif isstr(arg)
  [dsObj, index] = findChildWithName(dsArr, arg);
  dsArr.children(index) = [];
else
  error('Unknown input argument type');
end

% EOF
