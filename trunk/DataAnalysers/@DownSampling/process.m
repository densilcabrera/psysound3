function process(obj, hObj)
% PROCESS  This method is called when the Execute button is pressed
%
% Get the tree nodes
panel = get(hObj,'Parent');
nodes = getSelectedTreeNodes(obj, panel);

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

% Get the P and Q values from the ui
pObj = findobj(panel, 'Tag', 'PValue');
qObj = findobj(panel, 'Tag', 'QValue');

p = str2double(get(pObj, 'String'));
q = str2double(get(qObj, 'String'));

% Call the 'downsample' method of tSeries
ts = dataAnalysis(TSObj, 'downsample', p, q);

% Repackage
dataObjS.DataObj = ts;

% Add to node in tree
out = addToDataAnalysisFolder(obj, getValue(node), dataObjS);

collapseAndUnLoadTree(obj, panel);
% Try this instead of the above collapse
% openTree(obj, panel, out);

% EOF
