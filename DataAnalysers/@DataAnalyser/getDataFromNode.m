function [nodeObj, dataObjS, node, uit] = getDataFromNode(obj, hObj, nodeType)

p     = get(hObj,'Parent');
[nodes, uit] = getSelectedTreeNodes(obj, p);

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

nodeObj = dataObjS.DataObj;
if ~isa(nodeObj, nodeType)
  errordlg(['Please select a ' nodeType ' node.']);
  return;
end
