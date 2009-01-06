function ind = findeq(dsArr, dsObjIn)
% EQ  Finds the child that matches the given dataStorage object

ind = 0;

for i=1:getNumChildren(dsArr)
  obj = dsArr.children(i);
  if eq(obj, dsObjIn)
    ind = i;
    break;
  end
end

% EOF
