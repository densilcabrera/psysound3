function process(obj, hObj)
% PROCESS  This method is called when the Process button is pressed
%
% Get the tree nodes

% hObj is the handle to the ui object, unless it is a path directly to the
% dataStorage object.
if ischar(hObj)
    p = getPsysound3Prefs;
    [data, TSObj, dataObjS] = getDataObjData(hObj);
    node = uitreenode('v0',fullfile(p.dataDir,hObj),'Root',[],1); % just locally for convenience
    uit = [];
else
    [TSObj, dataObjS, node, uit] = getDataFromNode(obj, hObj, 'tSpectrum');
end

out = analyse(obj,dataObjS);

ER = out{1};
SPR = out{2};
Alpha = out{3};
SB = out{4};


timestep = diff(TSObj.Time);
timestep = timestep(1);


% Repackage
dataObjS.DataObj = createDataObject('tSeries',ER');
dataObjS.DataObj.TimeInfo.Increment = timestep;
dataObjS.DataObj.Name = 'Energy Ratio';
dataObjS.DataObj.DataInfo.Unit = 'dB';
% Add to node in tree
out = addToDataAnalysisFolder(obj, getValue(node), dataObjS, uit);


% Repackage
dataObjS.DataObj = createDataObject('tSeries',SPR');
dataObjS.DataObj.TimeInfo.Increment = timestep;
dataObjS.DataObj.Name = 'Singing Power Ratio';
dataObjS.DataObj.DataInfo.Unit = 'dB';
% Add to node in tree
out = addToDataAnalysisFolder(obj, getValue(node), dataObjS, uit);

% Repackage
dataObjS.DataObj = createDataObject('tSeries',Alpha');
dataObjS.DataObj.TimeInfo.Increment = timestep;
dataObjS.DataObj.Name = 'Alpha';
dataObjS.DataObj.DataInfo.Unit = 'dB';
% Add to node in tree
out = addToDataAnalysisFolder(obj, getValue(node), dataObjS, uit);

% Repackage
dataObjS.DataObj = createDataObject('tSeries', SB' );
dataObjS.DataObj.TimeInfo.Increment = timestep;
dataObjS.DataObj.Name = 'Spectral Balance';
dataObjS.DataObj.DataInfo.Unit = 'dB';
% Add to node in tree
out = addToDataAnalysisFolder(obj, getValue(node), dataObjS, uit);


% collapseAndUnLoadTree(obj, p);
% Try this instead of the above collapse
% openTree(obj, p, out);

% EOF

