function [dsArr, dsObj] = removeNode(dsArr, arg)
% REMOVENODE  Removes the given node in the array
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
