function display(obj)
% DISPLAY method for the dataStorageArray object

fprintf('\n\tDataStorageArray : %d nodes\n', getNumChildren(obj));
fprintf('\tType : %s\n', get(obj, 'type'));

% EOF
