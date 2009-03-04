function addSummaryToNode(obj, dataObjS, node, summary)

% get the filename
nName = getValue(node);
nodeObj = dataObjS.DataObj;

nodeObj.stats = setSummary(nodeObj.stats, summary{1}, summary{2}, summary{3});
% repackage
dataObjS.DataObj = nodeObj;

% overwrite
save(nName, 'dataObjS');



