function st = convertToDataObjects(obj)
% CONVERTTODATAOBJECTS  Method for the dataStorageTree object

for i = 1:length(obj.tree)
  filename = obj.tree(i).filename;
  load(filename);
  objs{i} = dataObjS;
end
st = objs;
% EOF
