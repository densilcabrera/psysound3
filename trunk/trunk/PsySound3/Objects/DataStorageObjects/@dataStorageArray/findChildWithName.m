function [dsObj, index] = findChildWithName(dsArr, name)
% FINDCHILDWITHNAME  Finds the child that matches the given name

dsObj = [];
index = 0;

for i=1:getNumChildren(dsArr)
  obj = dsArr.children(i);
  
  if strcmp(obj.name, name)
    dsObj = obj;
    index = i;
    break;
  end
end

% EOF
