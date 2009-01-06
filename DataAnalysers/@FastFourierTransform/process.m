function process(obj, hObj)
% PROCESS  This method is called when the Process button is pressed
%
% Get the tree nodes

% Get the tree nodes
panel = get(hObj,'Parent');
[nodes,uit] = getSelectedTreeNodes(obj, panel);

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

% Call the 'difference' method of tSeries
ts = dataAnalysis(TSObj, 'difference');

% Repackage
dataObjS.DataObj = ts;

% Add to node in tree
out = addToDataAnalysisFolder(obj, getValue(node), dataObjS, uit);

%collapseAndUnLoadTree(obj, panel);
% Try this instead of the above collapse
% openTree(obj, panel, out);

% EOF

