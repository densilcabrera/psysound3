function out = getDataObjectFromTreeNode(obj, node, varargin)
% GETDATAOBJECTFROMTREENODE  Retrieves the data object struct from a tree node

out = [];
% Use the given leaf node
fName = getValue(node);
if exist([fName, '.mat'], 'file')
  load(fName);
  out = dataObjS;
else
  % See if this is the Audiofile timeseries object
  [fPath, fName] = fileparts(fName);
  fName = fullfile(fPath, fName, [fName, '.mat']);
  if exist(fName, 'file')
    load(fName);
    out = dataObjS;
  end
end

% EOF
