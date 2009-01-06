function updateDataAnalyserPanel(obj, panel)
% UPDATEDATAANALYSERPANEL This method is called everytime a tree
%                         node is clicked.
%
%
% Update Enable/Disable state of plot buttons depending on 
% the type of objects in listbox4
sNodes = getSelectedTreeNodes(obj, panel); 
len    = length(sNodes);
  
% Find all the panels
univPanel = findobj(panel, 'Tag', 'UnivariatePanel');
bvPanel   = findobj(panel, 'Tag', 'BivariatePanel');
tsPanel   = findobj(panel, 'Tag', 'TimeseriesPanel');


for i = 1:len
  s = getDataObjectFromTreeNode(obj, sNodes(i));
  if isempty(s)
  panelSwitch(univPanel, 'off');
  panelSwitch(bvPanel, 'off');
  panelSwitch(tsPanel, 'off');
    return;
  elseif ~strcmp(class(s.DataObj),'tSeries')
  panelSwitch(univPanel, 'off');
  panelSwitch(bvPanel, 'off');
  panelSwitch(tsPanel, 'off');
    return;
  end
end


switch(len)
 case 0
  panelSwitch(univPanel, 'off');
  panelSwitch(bvPanel, 'off');
  panelSwitch(tsPanel, 'off');
 
  case 1
  panelSwitch(univPanel, 'on');
  panelSwitch(bvPanel, 'off');
  panelSwitch(tsPanel, 'on');
  
  case 2
  panelSwitch(univPanel, 'on');
  panelSwitch(bvPanel, 'on');
  panelSwitch(tsPanel, 'off');
    
 
  otherwise
  panelSwitch(univPanel, 'on');
  panelSwitch(bvPanel, 'on');
  panelSwitch(tsPanel, 'off');
end


function s = panelSwitch(panel, status)
% Get children of panel and set to status.

children = get(panel,'Children');
for i = 1:length(children)
  set(children(i),'Enable',status);
end

 
% EOF
