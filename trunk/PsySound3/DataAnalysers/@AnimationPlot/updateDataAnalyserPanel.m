function updateDataAnalyserPanel(obj, panel)
% UPDATEDATAANALYSERPANEL This method is called everytime a tree
%                         node is clicked.
%
%
% Update Enable/Disable state of plot buttons depending on 
% the type of objects in listbox4
%

sNodes = getSelectedTreeNodes(obj, panel); 
len    = length(sNodes);

% Find all the buttons
plotButt   = findobj(panel, 'Style', 'Popup',      'Tag', 'PlotTypePopup');
movieButt  = findobj(panel, 'Style', 'Pushbutton', 'Tag', 'MovieButton');
XYButt = findobj(panel, 'Style', 'Pushbutton', 'Tag', 'XYButton');

switch(len)
  case 0
    % Leave 'em all off
    set(plotButt,   'Enable', 'off');
    set(movieButt,  'Enable', 'off');
    set(XYButt, 'Enable', 'off');

  case 1
    dataObjS = getDataObjectFromTreeNode(obj, sNodes(1));
    if ~isempty(dataObjS)
      plotListCell = anim(dataObjS.DataObj, 'GetList');
      if length(plotListCell) < 1
        set(plotButt,   'Enable', 'off');
        set(movieButt,  'Enable', 'off');
        set(XYButt,     'Enable', 'off');
        return;
      end
      % Set string on Popup
      set(plotButt,   'Value' , 1);
      set(plotButt,   'String', plotListCell);
      set(plotButt,   'Enable', 'on');
      set(movieButt,  'Enable', 'on');
      set(XYButt,     'Enable', 'off');
    else
      % This is a container object so disable all but the Graph
      set(movieButt, 'Enable', 'off');
      set(plotButt , 'Enable', 'off');
      set(XYButt, 'Enable', 'off');
    end
  case 2
    dataObjS = getDataObjectFromTreeNode(obj, sNodes(1));
    if ~isempty(dataObjS)
      plotListCell = anim(dataObjS.DataObj, 'GetList');
      % Set string on Popup
      set(plotButt,   'Value',  1);
      set(plotButt,   'String', plotListCell);
      set(plotButt,   'Enable', 'on');
      set(movieButt,  'Enable', 'off');
      set(XYButt, 'Enable', 'on');
    end

  otherwise
    % This is the multi-select case
    set(XYButt, 'Enable', 'on');

end

% EOF
