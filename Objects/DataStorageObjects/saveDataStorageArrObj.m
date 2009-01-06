function saveDataStorageArrObj(saveDir, dsArr)
% SAVEDATASTORAGEARROBJ   Save the data storage array object

fName = fullfile(saveDir, filesep, 'dataInfo.mat');

save(fName, 'dsArr');

end % saveDataStorageArrObj

