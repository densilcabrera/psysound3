function [dsObj, index] = findChildWithFileName(dsArr, fName)
% FINDCHILDWITHFILENAME  Finds the child that matches the given
%                        file name

dsObj = [];
index = 0;

for i=1:getNumChildren(dsArr)
  obj = dsArr.children(i);
  
  if strcmp(obj.filename, fName)
    dsObj = obj;
    index = i;
    break;
  end
end

% EOF
