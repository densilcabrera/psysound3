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
graphButt  = findobj(panel, 'Style', 'Pushbutton', 'Tag', 'GraphButton');
multiGButt = findobj(panel, 'Style', 'Pushbutton', 'Tag', 'MultiGraphButton');
XYButt     = findobj(panel, 'Style', 'Pushbutton', 'Tag', 'X-YButton');
TwoAxisButt= findobj(panel, 'Style', 'Pushbutton', 'Tag', 'TwoAxisButton');
SubfigButt = findobj(panel, 'Style', 'Pushbutton', 'Tag', 'SubFigureButton');
switch(len)
 case 0
  % Leave 'em all off
  set(plotButt,   'Enable', 'off');
  set(graphButt,  'Enable', 'off');
  set(multiGButt, 'Enable', 'off');
  set(XYButt,     'Enable', 'off');
  set(TwoAxisButt,'Enable', 'off');
  set(SubfigButt ,'Enable', 'off');  
 case 1
  dataObjS = getDataObjectFromTreeNode(obj, sNodes(1));  
  if ~isempty(dataObjS)
    plotListCell = plot(dataObjS.DataObj, 'GetList');

    % Set string on Popup
    set(plotButt,   'Value',  1);
    set(plotButt,   'String', plotListCell);
    set(plotButt,   'Enable', 'on');
    set(graphButt,  'Enable', 'on');
    set(multiGButt, 'Enable', 'off');
  	set(TwoAxisButt,'Enable', 'off');
  set(SubfigButt ,'Enable', 'off');      
  else
    % This is a container object so disable all but the Graph
    set(graphButt,  'Enable', 'on');
    set(plotButt,   'Enable', 'off');
    set(multiGButt, 'Enable', 'off');
  end
  % By definition, this has to be off
  set(XYButt,  'Enable', 'off');
  
 case 2
  set(multiGButt, 'Enable', 'on');
  set(XYButt,     'Enable', 'on');
  set(TwoAxisButt,'Enable', 'on');
   set(SubfigButt ,'Enable', 'on');  
 otherwise
  % This is the multi-select case
  set(multiGButt, 'Enable', 'on');
  set(XYButt,     'Enable', 'off');
  set(TwoAxisButt,'Enable', 'off');
  set(SubfigButt ,'Enable', 'on');  

end

% EOF
