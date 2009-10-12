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


% Get axes
ax = findobj(p, 'Tag','ComparisonAxes');

% Find contextmenu stuff
uih = get(ax, 'UIContextMenu');
lg  = findobj(uih, 'Type', 'uimenu', 'Tag', 'legend');
gr  = findobj(uih, 'Type', 'uimenu', 'Tag', 'grid');
nf  = findobj(uih, 'Type', 'uimenu', 'Tag', 'newFig');

set([lg gr nf], 'Enable', 'on');
set(lg, 'Checked', 'off');

% Get the Popup choice
popupChoice = 'bar';


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

statNumber = listdlg('PromptString','Select a statistic to graph:',...
                      'SelectionMode','single',...
                      'ListString',col(2:end,1));
statNumber = statNumber + 1;

axes(ax);
eval([popupChoice '(cell2mat(col(statNumber,2:end)))']);
set(ax,'XTickLabel',col(1,2:end));
ylabel([s.AnalyserObj.Name, ' ', s.DataObj.tsObj.DataInfo.Unit]);
xlabel('Sound File');


set(ax,'Tag','ComparisonAxes');




