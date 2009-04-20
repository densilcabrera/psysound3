function addSummaryToNode(obj, dataObjS, node, varargin)

% get the filename
nName = getValue(node);
nodeObj = dataObjS.DataObj;

for i = 1:nargin-3
  summary = varargin{i};
  nodeObj.stats = setSummary(nodeObj.stats, summary{1}, summary{2}, summary{3});
end
% repackage
dataObjS.DataObj = nodeObj;

% overwrite
save(nName, 'dataObjS');



