function process(obj, hObj)
% PROCESS  This method is called when the Process button is pressed
%
% Get the tree nodes
p     = get(hObj,'Parent');
nodes = getSelectedTreeNodes(obj, p);

% Bail out if only one node is not selected
if length(nodes) ~= 1
  errordlg('Please select a single node');
  return;
end

% The selected tree node
node = nodes(1);

dataObjS = getDataObjectFromTreeNode(obj, node);
if isempty(dataObjS)
  errordlg('Please select a valid node');
  return;
end

TSObj = dataObjS.DataObj;
if ~isa(TSObj, 'tSeries')
  errordlg('Please select a timeSeries node');
  return;
end

% Call the 'auto' method of tSeries
spec = dataAnalysis(TSObj, 'autocorr');

% Repackage
dataObjS.DataObj = spec;

% Add to node in tree
out = addToDataAnalysisFolder(obj, getValue(node), dataObjS);

collapseAndUnLoadTree(obj, p);
% Try this instead of the above collapse
% openTree(obj, p, out);

% EOF
