function treeArray = dataStorageTree(varargin)
% DATASTORAGETREE object for PsySound3 data files
%
% This object is a container object to act as an array for the
% dataStorage objects

switch nargin
  case 0
    p = getPsysound3Prefs;		% Load root object
    ind = 1;
    treeArray = [];
		[treeArray] = recurseTree(p.dataDir, treeArray, ind);
	otherwise
    error('Invalid argument(s) in constructor of dataStorageTree');
end

% Assign out



function [treeArray,ind] = recurseTree(dataDir, treeArray, ind)
	load(fullfile(dataDir, filesep, 'dataInfo.mat'));
	 for i = 1:length(dsArr)
		if dsArr(i).isLeaf == 1  
      
			treeArray(ind).name = dsArr(i).name;
			treeArray(ind).dObj = dsArr(i);
      treeArray(ind).nodeType = dsArr(i).nodeType; 
			treeArray(ind).isLeaf = 1;
      treeArray(ind).filename = [dataDir filesep dsArr(i).filename];
      treeArray(ind).children = length(dsArr);
      ind = ind + 1;
    else
      treeArray(ind).name = dsArr(i).name;
      treeArray(ind).nodeType = 'Folder';
      treeArray(ind).isLeaf = 0;
      treeArray(ind).filename = [dataDir filesep dsArr(i).filename];
      treeArray(ind).children = length(dsArr);
      [treeArray,ind] = recurseTree(treeArray(ind).filename, treeArray, ind+1);
    end

  end

% end dataStorage constructor
