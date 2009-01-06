function out = getAudioObjFromTreeNode(obj, node)
% GETAUDIOOBJFROMTREENODE  Retrieves the Audio timeseries object
%                          associated with this node.  Essentially
%                          walks down from the root node.

out = [];

% Get the path of the root node
rootPath = node.getRoot().getValue();

% Get the full path of this node
fPath = getValue(node);

% Parse to get the audio node
audioName = strtok(strrep(fPath, rootPath, ''), filesep);

% Build the full file name
fName = fullfile(rootPath, audioName, [audioName, '.mat']);

if exist(fName, 'file')
  load(fName);
  out = dataObjS.DataObj;
end

% EOF
