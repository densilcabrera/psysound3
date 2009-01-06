function displayStatsObject(obj, hObj)
% DISPLAYSTATSOBJECT Callback for the Display pushbutton

% Initial handle retrieval
p   = get(hObj,'Parent');
utb = get(p,   'Parent');
utg = get(utb, 'Parent');
fig = get(utg, 'Parent');

% Get the tree nodes
nodes = getSelectedTreeNodes(obj, p);

% Bail out if empty
if isempty(nodes)
  return;
end


for i = 1:length(nodes)
	s = getDataObjectFromTreeNode(obj,nodes(i));
  col(:,i+1) = struct2cell(get(s.DataObj,'Stats'));
	col(1,i+1) = {s.AnalyserObj.filename};
  names = fieldnames(get(s.DataObj,'Stats'));
end
col = col(1:end-1,:);
names{1} = 'Filename';
names = names(1:end-1,:);
col(:,1) = names;

set(obj.Table,'Data',col);
