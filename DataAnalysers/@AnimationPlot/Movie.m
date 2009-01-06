function Movie(obj, hObj)
% GRAPH Callabck for the Graph pushbutton

% Initial handle retrieval
p   = get(hObj,'Parent');
utb = get(p,   'Parent');
utg = get(utb, 'Parent');
fig = get(utg, 'Parent');

% Figure out the value of the popup
plotPopup = findobj(p, 'Style', 'Popup', 'Tag', 'PlotTypePopup');
plotStrs  = get(plotPopup, 'String');
plotType  = '';
if ~isempty(deblank(plotStrs{1})),
  plotType  = deblank(plotStrs{get(plotPopup, 'Value'),:});
end

% Find axes
ax = findobj(p, 'Type','Axes', 'Tag', 'AnimAxes');

% Get the tree nodes
nodes = getSelectedTreeNodes(obj, p);

% Bail out if empty
if isempty(nodes)
  return;
end

% Clear up some things
axes(ax);
cla; legend off; colorbar off;

set(ax, 'UserData', []);
set(ax, 'XLimMode', 'auto');
set(ax, 'YLimMode', 'auto');
set(ax, 'ZLimMode', 'auto');

% Find contextmenu stuff
uih = get(ax, 'UIContextMenu');
lg  = findobj(uih, 'Type', 'uimenu', 'Tag', 'legend');
gr  = findobj(uih, 'Type', 'uimenu', 'Tag', 'grid');
nf  = findobj(uih, 'Type', 'uimenu', 'Tag', 'newFig');

set([lg gr nf], 'Enable', 'off');
set(lg, 'Checked', 'off');

% Switch on plot type
switch(get(hObj, 'String'))
 case 'Movie'
  % Get the FIRST object and plot
  dataObjS = getDataObjectFromTreeNode(obj, nodes(1));
  if ~isempty(dataObjS)
    aNode = getAudioObjFromTreeNode(obj, nodes(1));
    tStr  = dataObjS.DataObj.Name;
    anim(dataObjS.DataObj, plotType, tStr, aNode, hObj);
  end

 otherwise
  error('Unknown option encountered');
  
end % switch(buttonType)

% Add the context menu to lines & images, too
set(get(ax, 'Children'), 'UIContextmenu', uih);

% Enable context menu items
set(gr, 'Enable', 'on');
set(nf, 'Enable', 'on');

% Restore grid settings
if strcmp(get(gr, 'checked'), 'on')
  grid(ax, 'on');
end

% Reset some stuff
set(ax, 'Tag', 'AnimAxes');

% EOF
