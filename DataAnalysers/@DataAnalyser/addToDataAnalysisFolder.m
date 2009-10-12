function out = addToDataAnalysisFolder(obj, fullPaths, dataObjS, uit)
% ADDTODATAANALYSISFOLDER  Gateway function
%
% eg.
% 
%   |
%   |--obj-- SPL A
%   |
%   |--obj-- SPL B
%   \
%    dataInfo.mat
%
% will become ....
%
%   |
%   |--obj--    SPL A
%   |    |
%   |    |--folder--  FFT (say)
%   |    |     |
%   |    |     |--obj-- SPL A
%   |    |     \
%   |    |     dataInfo.mat
%   \
%    dataInfo.mat (modified original)

out    = [];
daPath = getDataAnalysisFolder(obj, fullPaths);

if isempty(daPath) % jic
  return;
end

%
% Now for the specific dataAnalyser
%
daName         = class(obj);
dsObjDASfolder = fullfile(daPath, daName);
if ~exist(dsObjDASfolder)
  [s, m] = mkdir(dsObjDASfolder);
  if ~s
    error(m);
  end
end

% Get the dataAnalysis folder's dataStorageArray
dsArr = getDataStorageArrObj(daPath);
% for i = 1:getNumChildren(dsArr)
%   if 1 %getName(node)
%   dsArr = removeNode(dsArr,1);
%   end
% end

% Create the FFT (say) node
daObj = dataStorage(obj.Name, daName, [daName 'Folder'], 0);

% % Add and save as a reference in dataInfo.mat for this folder
dsArr = addNode(dsArr, daObj);
saveDataStorageArrObj(daPath, dsArr);

% and Save the new data Object in FFT folder
dsArr = getDataStorageArrObj(dsObjDASfolder);
dataObj         = dataObjS.DataObj;
dataObjName     = dataObj.name;
dataObjFileName = genvarname(dataObjName);
save(fullfile(dsObjDASfolder, dataObjFileName), 'dataObjS');

% Finally create a dataStorage object for this data object
dsDataObj = dataStorage(dataObjName,     ...
                        dataObjFileName, ...
                        class(dataObj),  ...
                        1);  % end of the road (isLeaf)

% Add and save as a reference in dataInfo.mat for this
dsArr = addNode(dsArr, dsDataObj);
saveDataStorageArrObj(dsObjDASfolder, dsArr);


if ~isempty(uit)
    % Update the UITree dynamically (see below)
    addToTree(daObj, dsArr, uit)
end

% Assign output
out = dsObjDASfolder;



%%%%%%%%%%%%%
% Subfunction
% add node to Tree
function addToTree(daObj, dsArr, uit)

% Get nodes and choose first one.
nodes = uit.getSelectedNodes;
node = nodes(1);
parent = node;

% Change icon
psyIconDir = [getPsySoundDir, filesep, 'Framework/GUI/icons'];
iconpath = [psyIconDir, filesep, 'foldericon.gif'];
[I,map] = imread(iconpath);  % read the icon
foldericon = im2java(I,map); % convert to java
parent.setIcon(foldericon);  % Set the node icon 

% Make node accept new children
parent.setAllowsChildren(1);
% When selected it will update
uit.setSelectedNode(parent);

% EOF
