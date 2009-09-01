function obj = dataStorageTree(varargin)
% DATASTORAGETREE object for PsySound3 data files
%
% This object is a container object to act as an array for the
% dataStorage objects and as a method to access (not change) the 
% data Objects themselves. 
%
% Use get method to get dataobjects of a particular type

switch nargin
  case 0
    p = getPsysound3Prefs;		% Load root object
    ind = 1;
    treeArray = [];
    analyserName = '';
		treeArray = recurseTree(p.dataDir, treeArray, ind, p.dataDir, analyserName);
	otherwise
    error('Invalid argument(s) in constructor of dataStorageTree');
end

obj = struct('tree',treeArray);
obj = class(obj,'dataStorageTree');



% Assign out
function [treeArray,ind] = recurseTree(dataDir, treeArray, ind, rootDir, analyserName)
% Recursive function to build array of tree elements.
  try
    load(fullfile(dataDir, filesep, 'dataInfo.mat'));
  catch
    treeArray(ind).name = 'No Data';
    return;
  end

  for i = 1:getNumChildren(dsArr)
		if dsArr(i).isLeaf == 1  
      treeArray(ind).name = dsArr(i).name;
			treeArray(ind).date = dsArr(i).date;
      treeArray(ind).nodeType = dsArr(i).nodeType; 
			treeArray(ind).isLeaf = 1;
      treeArray(ind).filename = [dataDir filesep dsArr(i).filename];
      treeArray(ind).children = length(dsArr);
      treeArray(ind).analyserName = analyserName;
      audiofilename = strrep(treeArray(ind).filename,rootDir,'');
      fileseps = strfind(audiofilename,filesep);
      if length(fileseps)==1; fileseps(2) = length(audiofilename)+1;   end
      treeArray(ind).audiofile = audiofilename(fileseps(1)+1:fileseps(2)-1);
      ind = ind+1;
    else
      treeArray(ind).name = dsArr(i).name;
      treeArray(ind).nodeType = dsArr(i).nodeType;
			treeArray(ind).date = dsArr(i).date;
      treeArray(ind).isLeaf = 0;
      treeArray(ind).filename = [dataDir filesep dsArr(i).filename];
      treeArray(ind).children = length(dsArr);
      % If this is a data folder, then everything below it is from the same
      % analyser folder. 
      if sum(strcmp(dsArr(i).nodeType, {'AudioAnalyserFolder','SubjectiveDataFolder'}))
        analyserName = dsArr(i).filename;
      end 
      treeArray(ind).analyserName = 'None';
      audiofilename = strrep(treeArray(ind).filename,rootDir,'');
      fileseps = strfind(audiofilename,filesep);
      if length(fileseps)==1; fileseps(2) = length(audiofilename)+1;   end
      treeArray(ind).audiofile = audiofilename(fileseps(1)+1:fileseps(2)-1);
      [treeArray,ind] = recurseTree(treeArray(ind).filename, treeArray, ind+1, rootDir, analyserName);
    end
  end
  
  
% end dataStorage constructor
