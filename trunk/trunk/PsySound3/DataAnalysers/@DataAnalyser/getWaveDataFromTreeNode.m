function out = getWaveDataFromTreeNode(obj, node, varargin)
% GETWAVEDATAFROMTREENODE  Retrieves the wavefile data at top of any tree node

% Could be implemented a little cleaner if the getDataObjectFromTreeNode
% were removed. 

out = [];

% Get DataObject
s = getDataObjectFromTreeNode(obj,node);

% Check for PsySoundData Node (its Data Object is empty)
if isempty(s)
 return
end


  try
    dataObject = s.DataObj;
  catch
  end
% If not the wave file then go up tree to find it

stepsUpTree =0;
while (~strcmp(class(dataObject),'AudioTSeries')) && stepsUpTree < 10   
	node          = getParent(node);
  s = getDataObjectFromTreeNode(obj,node);
  try
    dataObject = s.DataObj;
  catch
  end
	stepsUpTree   = stepsUpTree + 1; % Don't want infinite loop
end

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
    out = dataObjS.DataObj;
  end
end

% EOF
