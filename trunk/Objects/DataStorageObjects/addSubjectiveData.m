function addSubjectiveData(dObj,targetaudiofile)
% ADDSUBJECTIVEDATA Add a subjective data file to the data tree
%
%
% This code takes a formatted ps3 dataObject (usually a timeseries 
% object and adds it to a special analyser folder called 
% SubjectiveData. These objects behave in the same way as 
% objective analysis data.
%

%% Find targetaudio file node
%
% Strip .wav, .aiff, .aif, .au
targetaudiofile = strrep(targetaudiofile,'.wav','');
targetaudiofile = strrep(targetaudiofile,'.aiff','');
targetaudiofile = strrep(targetaudiofile,'.aif','');
targetaudiofile = strrep(targetaudiofile,'.au','');

% get data dir
dataDir = getPsysound3Prefs;
dataDir = dataDir.dataDir;
dsArr = getDataStorageArrObj(dataDir);

% Look for targetaudiofile node
for i = 1:getNumChildren(dsArr)
  if strcmp(dsArr(i).name,targetaudiofile)
    audiofilenum = i;
    break;
  end
end

% Break out if no audio file found
if ~exist('audiofilenum')
  return;
end

path = [dataDir filesep dsArr(audiofilenum).name];
dsArr = getDataStorageArrObj(path);


% Check if subjective data folder exists
for i = 1:getNumChildren(dsArr)
    if strcmp(dsArr(i).name,'SubjectiveData')
      subdatafoldernum = i;
    end
end
    
% Create folder if no subdata folder found
if ~exist('subdatafoldernum')    
%   % Make associated dataStorage node for it
   dsObj = dataStorage('Subjective Data', ...
                       'SubjectiveData', ...
                       'SubjectiveDataFolder', ...
                       0);   % Add and save
   dsArr = addNode(dsArr, dsObj);
   saveDataStorageArrObj(path, dsArr);

   fPath = fullfile(path, 'SubjectiveData');
   if ~exist(fPath, 'dir')
     % Create it
     [s, m] = mkdir(fPath);
     if ~s
       error(m);
     end
   end
end

path = fullfile(path,'SubjectiveData');

%% Format data object into a dataObjS
DObj = createDataObject('tSeries', dObj.data);
DObj = set(DObj,'time',dObj.time);
DObj.Name = dObj.Name;
DObj.DataInfo.UserData = dObj.DataInfo.UserData;


% Add Analyser Object (subclass from analyser)
AObj = Analyser;
AObj.Name = 'Subjective Data';

% Create struct ...
dataObjS.DataObj     = DObj;
dataObjS.AnalyserObj = AObj;

%% Save dataObjs
% Create a valid name
dataName     = DObj.Name;
dataSaveName = genvarname(dataName);

% Build the full path
dataFileName = fullfile(path, dataSaveName);

% getDataStorage
dsArrObj = getDataStorageArrObj(path);

% and Save
save(dataFileName, 'dataObjS');

%% Add node to tree 
% Add node
dsObjData = dataStorage(dataName, dataSaveName, class(DObj), 1);
dsArrObj  = addNode(dsArrObj, dsObjData);

% Build up the full path - the dir should already exist
saveDir = fullfile(path, 'dataInfo.mat'); 

% Sort
dsArr = sort(dsArrObj);

% ... and Save
save(saveDir, 'dsArr');