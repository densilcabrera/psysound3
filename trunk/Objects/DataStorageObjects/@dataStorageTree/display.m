function display(obj)
% DISPLAY  Method for the dataStorageTree object
try
  name = obj.tree(1).name;
catch
  fprintf('\n\tDataStorageTree Object: Empty\n');
  return;
end
  tSpectrums = 0;
names= {};
for i = 1:length(obj.tree)
  if sum(strcmp(obj.tree(i).audiofile, names))

  else
  	names(end + 1) = {obj.tree(i).audiofile};
	end
end
fprintf('\nDataStorageTree Object\n');
fprintf('\tFiles Represented: %d \n',length(names));
% EOF
