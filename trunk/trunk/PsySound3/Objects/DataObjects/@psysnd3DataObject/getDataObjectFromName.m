function obj = getDataObjectFromName(obj, node, dataObjChoice)
% GETDATAOBJECTFROMNAME If an audio file node is chosen and the name of the
% AudioAnalyser and the Data Object is known, then find the dataobject

dName1 = getValue(node);
fName1 = fullfile(dName1, 'dataInfo.mat');
D1     = load(fName1);

if ~strcmp(D1.dsArr.type, 'AudioFileFolder')
  % Skip - only for AudioFile nodes
  return;
end

% The name of the audio file
audioFileName = getName(node);

% Loop over each analyser
for i=1:getNumChildren(D1.dsArr)
  dName2 = fullfile(dName1, D1.dsArr(i).filename);
  fName2 = fullfile(dName2, 'dataInfo.mat');
  D2     = load(fName2);
  
  if ~strcmp(D2.dsArr.type, 'AudioAnalyserFolder')
    % Must be an analyser folder
    continue;
  end

  % Loop over each data object
  for j = 1:getNumChildren(D2.dsArr)
    
    % Data object name
    analyserObjName = D1.dsArr(i).name;
    dataObjName     = D2.dsArr(j).name;
    choice          = [analyserObjName ' - ' dataObjName];

    if ~strcmp(choice,dataObjChoice)
      continue
    else
      break;
    end
  end
  
end

