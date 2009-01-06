function Sonify(obj, hObj)
% Sonify Callabck for the Sonify pushbutton

% Initial handle retrieval
p   = get(hObj,'Parent');
utb = get(p,   'Parent');
utg = get(utb, 'Parent');
fig = get(utg, 'Parent');

% Temporarily make visible so that we can manipulate the current
% figure.  This is the only way I've found to make plot-as-you-go
% work
% xxx use findall!!!
set(fig, 'HandleVisibility', 'on');
set(0,   'CurrentFigure',     fig);

% Get the tree nodes
nodes = getSelectedTreeNodes(obj, p);

% Bail out if empty
if isempty(nodes)
  return;
end

% Switch on Sonify Type
switch(get(hObj, 'String'))
 case 'Sonify'
  % Get the FIRST object and plot
  dataObjS = getDataObjectFromTreeNode(obj, nodes(1));
  minMax.freq(1:2) = [100 5000];
  minMax.level(1:2) = [100 100];
  minMax.pan(1:2) = [0.5 0.5];
  signal = sonifyData({dataObjS.DataObj,dataObjS.DataObj,dataObjS.DataObj},dataObjS.DataObj.time,minMax,dataObjS.AnalyserObj.fs,0);
  sound(signal,dataObjS.AnalyserObj.fs);
  
end % switch(buttonType)

% EOF
