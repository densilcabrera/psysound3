function val = display(obj)
% DISPLAY  Method for the dataStorageTree object
name = obj.tree(1).name;
files = 0;
tSpectrums = 0;
for i = 1:length(obj.tree)
  if strcmp(obj.tree(i).nodeType, 'AudioFileFolder')
    files = files + 1;
  end
end
fprintf('\nDataStorageTree Object\n');
fprintf('\tFiles Represented: %d \n',files);

% EOF
