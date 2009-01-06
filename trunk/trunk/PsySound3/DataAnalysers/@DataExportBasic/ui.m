function obj = ui(obj, panel)
% UI metod for basic data export
% 
% Basically a grid
%
% Inputs:
%  panel : is the handle to the left panel of the data analyser

bgColor = [0.9 0.9 0.9];

% Data dir info
pos = [0.03 0.03 0.8 0.7];
boxH = uicontrol('Parent', panel, ...
  'units', 'normalized', ...
  'Position', pos, ...
  'String',  'no data ...', ...
  'FontSize', 9, ...
  'HorizontalAlignment', 'left', ...
  'BackgroundColor', bgColor, ...
  'Style',   'listbox');

% Delimiter
pos(2) = pos(2) + pos(4) + 0.02;
pos(4) = 0.05;
pos(3) = 0.15;
uicontrol('Parent', panel, ...
  'units', 'normalized', ...
  'Position', pos, ...
  'String',  'Choose delimiter:', ...
  'BackgroundColor', bgColor, ...
  'FontSize', 9, ...
  'HorizontalAlignment', 'left', ...
  'Style',   'text');

pos(1) = pos(1)+pos(3)+0.01;
pos(3) = 0.1;
uicontrol('Parent', panel, ...
  'units', 'normalized', ...
  'Position', pos, ...
  'String',  'Comma|Tab|Space|Other', ...
  'BackgroundColor', bgColor, ...
          'Value', 2, ...
  'FontSize', 9, ...
  'Callback', @toggleDelim, ...
  'Style',   'popup');

pos(1) = pos(1)+pos(3)+0.01;
pos(3) = 0.035;
delimH = uicontrol('Parent', panel, ...
  'units', 'normalized', ...
  'Position', pos, ...
  'String',  ';', ...
  'BackgroundColor', bgColor, ...
  'FontSize', 9, ...
  'Enable', 'off', ...
  'Callback', @setDelim, ...
  'HorizontalAlignment', 'left', ...
  'Style',   'edit');

% Checkbox single file
pos(1) = pos(1) + pos(3) + 0.025;
pos(2) = pos(2) + 0.055;
pos(3) = 0.03;
singleFileChkBoxH = uicontrol('Parent', panel, ...
  'units', 'normalized', ...
  'Position', pos, ...
  'String',  '', ...
  'BackgroundColor', bgColor, ...
  'FontSize', 9, ...
  'HorizontalAlignment', 'left', ...
  'Style',   'checkbox');

pos(1) = pos(1) + pos(3);
pos(2) = pos(2) - 0.055;
pos(3) = 0.55;
pos(4) = 0.1;
h = uicontrol('Parent', panel, ...
              'units', 'normalized', ...
              'Position', pos, ...
              'String',  '', ...
              'BackgroundColor', bgColor, ...
              'FontSize', 9, ...
              'HorizontalAlignment', 'left', ...
              'Style',   'text');
str = {'Export into a single file.',...
       ['You will be prompted for a filename otherwise each selected node will ' ...
        'be saved in a different file']};

set(h, 'String', str);

% Buttons
pos = [0.85 0.03 0.12 0.07];
uicontrol('Parent', panel, ...
  'units', 'normalized', ...
  'Position', pos, ...
  'String',  'Export', ...
  'BackgroundColor', bgColor, ...
  'FontSize', 9, ...
  'Callback', @exportCB, ...
  'Style',   'pushbutton');

pos(2) = pos(2) + pos(4) + 0.01;
uicontrol('Parent', panel, ...
  'units', 'normalized', ...
  'Position', pos, ...
  'String',  'Preview', ...
  'BackgroundColor', bgColor, ...
  'FontSize', 9, ...
  'Callback', @previewCB, ...
  'Style',   'pushbutton');

  %
  % Nested function to toggle delim custom edit box
  %
  delimStr = '\t'; % Tab default
  function toggleDelim(src, ev)
    switch(popupstr(src))
      case 'Comma'
        delimStr = ',';
        set(delimH, 'Enable', 'off');
      case 'Space'
        delimStr = ' ';
        set(delimH, 'Enable', 'off');
      case 'Tab'
        delimStr = '\t';
        set(delimH, 'Enable', 'off');
      otherwise
        % Must be Other
        set(delimH, 'Enable', 'on');
        delimStr = get(delimH, 'String');
    end
  end

  function setDelim(src, ev)
    delimStr = get(src, 'String');
  end
  %
  % Preview button
  % 
  function previewCB(src, ev)
    set(boxH, 'Value', 1);
    
    sNodes = getSelectedTreeNodes(obj, panel);
    len    = length(sNodes);

    totalStr = [];
    for i=1:len
      node     = sNodes(i);
      dataObjS = getDataObjectFromTreeNode(obj, node);
      Str = '';
      
      if ~isempty(dataObjS) && ~isempty(dataObjS.AnalyserObj)
        Str = getStringFromDataObj(dataObjS);
      else
        fPath = getValue(node);
        fName = fullfile(fPath, 'dataInfo.mat');
        S     = load(fName);

        % This is not a data object
        Str = getStringForNonDataObject(fPath, S.dsArr, delimStr, Str);
      end
      totalStr = strvcat(totalStr, Str);
    end
    set(boxH, 'String', totalStr);
  end

  function Str = getStringFromDataObj(dObjS)
    dObj = dObjS.DataObj;
    Str = getHeaderString(dObjS.AnalyserObj);
     
    evalStr = ['exportData(dObj, 1, ''', delimStr, ''', 1);'];
    str = evalc(evalStr);
    str(end+1) = sprintf('\n');
    str = fixUpStringForNewLines(str, delimStr);
    
    Str = strvcat(Str, str);
  end

  %
  % Export button
  % 
  function exportCB(src, ev)
    sNodes = getSelectedTreeNodes(obj, panel);
    len    = length(sNodes);

    oneFid = 0;
    if get(singleFileChkBoxH, 'Value')
      % We need to write to a single file
      [fName, fPath] = uiputfile({'*.csv', 'Export file (*.csv)'}, ...
        'Export As', 'Untitled.csv');
      [oneFid, m] = fopen(fullfile(fPath, fName), 'wt');
      if ~isempty(m)
        error(m);
      end
    end
    
    for i=1:len
      node     = sNodes(i);
      dataObjS = getDataObjectFromTreeNode(obj, node);
      fPath    = getValue(node);
      fName    = [fPath, '.csv'];
      
      % Open file in text mode
      if ~oneFid
        [fid, m] = fopen(fName, 'wt');
        if ~isempty(m)
          error(m);
        end
      end
      
      if ~isempty(dataObjS) && ~isempty(dataObjS.AnalyserObj)
        % Call the dataObject data method
        if ~oneFid
          exportDataObject(dataObjS, fid, delimStr);
        else
          exportDataObject(dataObjS, oneFid, delimStr);
        end
      else
        % This is not a data object
        S = load(fullfile(fPath, 'dataInfo.mat'));

        if ~oneFid
          exportNonDataObject(fPath, S.dsArr, delimStr, fid)
        else
          exportNonDataObject(fPath, S.dsArr, delimStr, oneFid)
        end          
      end
      % Close each file
      if ~oneFid
        fclose(fid);
      end
    end
    
    % Close
    if oneFid
      fclose(oneFid);
    end
  end
end

% Subfunctions

% Writes each data object
function exportDataObject(dataObjS, fid, delimStr)
% Get header string
Str = getHeaderString(dataObjS.AnalyserObj);

% Write header string
for k=1:size(Str, 1)
  fprintf(fid, '%s\n', Str(k,:));
end
        
% Write data
exportData(dataObjS.DataObj, fid, delimStr);
fprintf(fid, '\n\n');

end

% Fixes up new lines ('\n') into vertical strings
function outStr = fixUpStringForNewLines(str, delimStr)

% Replace tabs into double spaces
if strcmp(delimStr, '\t')
  str = strrep(str, sprintf('\t'), '  ');
end

% Set string in the list box, but first we have to replace new lines
cr = sprintf('\n');
[Str, R] = strtok(str, cr);
while ~isempty(R)
  if length(R)>1 && R(2) == cr
    Str = strvcat(Str, ' ');
  end
  [str, R] = strtok(R, cr);
  Str = strvcat(Str, str);
end

outStr = Str;
end

function outObj = getAObjectFromDsArrObject(fPath, dsArr)
% Populate the Analyser object with data
aObj    = [];
outputs = {};
for k=1:getNumChildren(dsArr)
  dObj = load(fullfile(fPath, dsArr(k).filename));
  
  if isempty(aObj)
    aObj    = dObj.dataObjS.AnalyserObj;
    outputs = aObj.output;
  end
  
  % Set
  outputs{k} = dObj.dataObjS.DataObj;
  
end
aObj.output = outputs;

% Assign outputs
outObj = aObj;

end

% Returns a forammted header string
function hStr = getHeaderString(aObj)
hStr = '';

str = get(aObj, 'filename');
hStr = strvcat(hStr, str);

str = get(aObj, 'Name');
hStr = strvcat(hStr, str);

str = ['Window length : ', num2str(get(aObj, 'windowLength'))];
hStr = strvcat(hStr, str);

str = ['Overlap : ', num2str(getOverlap(aObj))];
hStr = strvcat(hStr, str, ' ');

end

% Recursive preview function
function outStr = getStringForNonDataObject(fPath, dsArr, delimStr, inStr)

switch (dsArr.type)
 case 'AudioAnalyserFolder'
  aObj    = getAObjectFromDsArrObject(fPath, dsArr);
  evalStr = ['exportData(aObj, 1, ''', delimStr, ''', 1);'];
  Str = evalc(evalStr);
  Str(end+1) = sprintf('\n');
  Str = fixUpStringForNewLines(Str, delimStr);
  
 case {'root', 'AudioFileFolder'}
  num = getNumChildren(dsArr);
  Str = inStr;
  for i=1:num
    % Recurse
    cPath = fullfile(fPath, dsArr(i).filename);
    S     = load(fullfile(cPath, 'dataInfo.mat'));
    Str   = getStringForNonDataObject(cPath, S.dsArr, delimStr, ...
                                             Str);
  end
    
 case 'DataAnalyserFolder'
  % to be completed
 otherwise
  % do nothing
end

outStr = strvcat(inStr, Str);

end

% Recursive export function
function exportNonDataObject(fPath, dsArr, delimStr, fid)
switch (dsArr.type)
 case 'AudioAnalyserFolder'
  aObj = getAObjectFromDsArrObject(fPath, dsArr);
  exportData(aObj, fid, delimStr);
  
 case {'root', 'AudioFileFolder'}
  num = getNumChildren(dsArr);
  for i=1:num
    % Recurse
    cPath = fullfile(fPath, dsArr(i).filename);
    S     = load(fullfile(cPath, 'dataInfo.mat'));
    exportNonDataObject(cPath, S.dsArr, delimStr, fid);
    
  end
 case 'DataAnalyserFolder'
  % to be completed
 otherwise
  % skip
end

end

% EOF
