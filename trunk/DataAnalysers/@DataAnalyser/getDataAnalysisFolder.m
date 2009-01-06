function fPath = getDataAnalysisFolder(obj, fullPaths)
% GETDATAANALYSISFOLDER  Returns the path to the dataAnalysis
%                        folder under which the specific (eg FFT or
%                        DownSampling) data analysis folder should
%                        be created
%
%

fPath = [];

if ~iscell(fullPaths)
  % Path of the original data file
  [path, fName] = fileparts(fullPaths);
else
  if length(fullPaths) ~= 2
    errordlg('DataAnalysis of more than 2 nodes is currently not supported');
    return;
  end
  
  % Find a common ancestor
  path1 = fullPaths{1};
  path2 = fullPaths{2};
  
  % Work from the front until we no longer match
  [token1, path1] = strtok(path1, filesep);
  [token2, path2] = strtok(path2, filesep);
  
	fPath = '/';
  while strcmp(token1, token2)
    fPath = fullfile(fPath, token1);
    
    [token1, path1] = strtok(path1, filesep);
    [token2, path2] = strtok(path2, filesep);
  end

  if ~exist(fPath, 'dir')
    error([fPath,' does not exist!']);
  end
  
  % Check if already in dataAnalysis hierarchy
  str = [filesep, 'dataAnalysis', filesep];
  if ~isempty(findstr(str, fPath))
    return;
  end
  
%   % Add dataAnalysis dir, if needed
%   dsArr = getDataStorageArrObj(fPath);
%   
%   % Make associated dataStorage node for it
%   dsObj = dataStorage('dataAnalysis', ...
%                       'dataAnalysis', ...
%                       'DataAnalysisFolder', ...
%                       0);
%   % Add and save
%   dsArr = addNode(dsArr, dsObj);
  saveDataStorageArrObj(fPath, dsArr);

%   % Check if dataAnalysis already exists
%   fPath = fullfile(fPath, 'dataAnalysis');
%   if ~exist(fPath, 'dir')
%     % Create it
%     [s, m] = mkdir(fPath);
%     if ~s
%       error(m);
%     end
%   end
  
  return;
end

% If already within a dataAnalysis hierarchy, then we're done
str = [filesep, 'dataAnalysis', filesep];
if ~isempty(findstr(str, path))
  fPath = path;
  return;
end

% Next check if we've already created a subdir for this dataObject
dsArrPath = fullfile(path, 'dataInfo.mat');
load(dsArrPath);

% Find the dataStorage node
[dsObj, index] = findChildWithFileName(dsArr, fName);

if isempty(dsObj)
  error('dataStorage object not found!');
end

% Path to the dataAnalysis folder
daPath = fullfile(path, fName, 'dataAnalysis');

% Check if we need to create a new folder
if dsObj.isLeaf
  % Consistency checking
  if exist(daPath, 'dir')
    error('The dataAnalysis folder already exists!');
  end
  
  % Make sub-node
  dsArr(index).isLeaf   = 0;
  dsArr(index).nodeType = 'DataAnalyserFolder';
  save(dsArrPath, 'dsArr');

  % Make sub-dir with same name
  subDir = fullfile(path, fName);
  [s, m] = mkdir(subDir);
  if ~s
    error(m);
  end
  
  % Add dataStorageArray
  dsArr = getDataStorageArrObj(subDir);
  
  % Add original node, modified
  dsObj.filename = fullfile('..', dsObj.filename);
  dsArr = addNode(dsArr, dsObj);
  
  
  %% Modification - removing the use of datanalysis folder - too many
  %% levels for easy usage.
  
  %   % Make dataAnalysis sub-directory
  %   [s, m] = mkdir(daPath);
  %   if ~s
  %     error(m);
  %   end
  %
  %   % Make associated dataStorage node for it
  %   dsObj = dataStorage('dataAnalysis', ...
  %                       'dataAnalysis', ...
  %                       'DataAnalysisFolder', ...
  %                       0);
  %   % Add and save
  %   dsArr = addNode(dsArr, dsObj);
  saveDataStorageArrObj(subDir, dsArr);
  
else
  % We've already switched the node, therefore, the dataAnalysis
  % folder should already exist
%   if ~exist(daPath, 'dir')
%     error('dataAnalysis folder does not exist!');
%   end
end

daPath = strrep(daPath,'/dataAnalysis','');
% Assign output
fPath = daPath;

% EOF
