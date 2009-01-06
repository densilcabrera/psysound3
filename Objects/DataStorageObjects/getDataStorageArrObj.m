function dsArr = getDataStorageArrObj(saveDir)
% GETDATASTORAGEARROBJ   Get existing data storage array object, if
%                        it exists, otherwise create and return a
%                        new one
%

fName = fullfile(saveDir, filesep, 'dataInfo.mat');
dsArr = [];

if exist(fName, 'file')
  load(fName);
else
  % Create a new one
  dsArr = dataStorageArray;
end

end % getDataStorageArrObj

