function val = get(obj, index)
% GET  Method for the dataStorageTree object

load(obj.tree(index).filename);

val = dataObjS;

% EOF
