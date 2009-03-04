function process(obj, hObj)
% PROCESS  This method is called when the Process button is pressed
%
% Get the tree nodes

[TSObj, dataObjS, node, uit] = getDataFromNode(obj, hObj, 'tSeries');

% Call the 'difference' method of tSeries
ts = dataAnalysis(TSObj, 'difference');

% Repackage
dataObjS.DataObj = ts;

% Add to node in tree
putDataToNode(obj, dataObjS, node, uit, hObj);

% EOF

