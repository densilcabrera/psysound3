function process(obj, hObj)
% PROCESS  This method is called when the Process button is pressed
%
% Get the tree nodes

% Get the tree nodes

[TSObj, dataObjS, node, uit] = getDataFromNode(obj, hObj, 'tSeries');

% Call the 'fft' method of tSeries
spec = dataAnalysis(TSObj, 'fft');

% Repackage
dataObjS.DataObj = spec;

% Add to node in tree
putDataToNode(obj, dataObjS, node, uit, hObj);

% EOF

