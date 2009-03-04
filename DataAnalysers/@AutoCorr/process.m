function process(obj, hObj)
% PROCESS  This method is called when the Process button is pressed
%
% Get the tree nodes

[TSObj, dataObjS, node, uit] = getDataFromNode(obj, hObj, 'tSeries');

% Call the 'autocorr' method of tSeries
spec = dataAnalysis(TSObj, 'autocorr');

% Repackage
dataObjS.DataObj = spec;


putDataToNode(obj, dataObjS, node, uit, hObj);
% EOF
