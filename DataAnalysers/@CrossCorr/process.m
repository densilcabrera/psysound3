function process(obj, hObj)
% PROCESS  This method is called when the Process button is pressed
%
% Get the tree nodes
p     = get(hObj,'Parent');
nodes = getSelectedTreeNodes(obj, p);

% Bail out if only one node is not selected
if length(nodes) ~= 2
  errordlg('Please select 2 nodes');
  return;
end

% The selected tree node
node1 = nodes(1);
node2 = nodes(2);

dataObjS1 = getDataObjectFromTreeNode(obj, node1);
dataObjS2 = getDataObjectFromTreeNode(obj, node2);
if isempty(dataObjS1) ||  isempty(dataObjS1)
  errordlg('Please select valid nodes');
  return;
end

TSObj1 = dataObjS1.DataObj;
TSObj2 = dataObjS2.DataObj;
if ~isa(TSObj1, 'tSeries') || ~isa(TSObj2, 'tSeries')
  errordlg('Please select only timeSeries nodes');
  return;
end

% Call the 'auto' method of tSeries
spec = dataAnalysis(TSObj1, 'crosscorr', TSObj2);

% Repackage
dataObjS.DataObj = spec;
dataObjS.AnalyserObj = {dataObjS1.AnalyserObj; dataObjS2.AnalyserObj};

% Add to node in tree
out = addToDataAnalysisFolder(obj, ...
                              {getValue(node1), getValue(node2)}, ...
                              dataObjS);

collapseAndUnLoadTree(obj, p);
% Try this instead of the above collapse
% openTree(obj, p, out);

% EOF
