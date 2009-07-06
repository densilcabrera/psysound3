function process(obj, hObj)
% PROCESS  This method is called when the Process button is pressed
%
% Get the tree nodes

[TSObj, dataObjS, node, uit] = getDataFromNode(obj, hObj, 'tSeries');

out = analyse(TSObj);

ER = out{1};
SPR = out{2};
Alpha = out{3};
SB = out{4};


timestep = diff(t);
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

