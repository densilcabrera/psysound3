function obj = ui(obj, panel)
% UI metod for basic data export
% 
% Basically a grid
%
% Inputs:
%  panel : is the handle to the left panel of the data analyser

bgColor = [0.9 0.9 0.9];

% Data dir info
pos = [0.03 0.03 0.6 0.7];
boxH = uicontrol(...
    'Parent', panel, ...
    'units', 'normalized', ...
    'Position', pos, ...
    'String',  'Select Audio file node from tree ...', ...
    'FontSize', 9, ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', bgColor, ...
    'Max', 50, ...
    'Min', 1, ...
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

% Buttons
pos = [0.65 0.03 0.17 0.07];
uicontrol('Parent', panel, ...
  'units', 'normalized', ...
  'Position', pos, ...
  'String',  'Show Data Objects', ...
  'BackgroundColor', bgColor, ...
  'FontSize', 9, ...
  'Callback', @showDataObjectsCB, ...
  'Style',   'pushbutton');

pos = [0.85 0.03 0.12 0.07];
uicontrol('Parent', panel, ...
  'units', 'normalized', ...
  'Position', pos, ...
  'String',  'Export', ...
  'BackgroundColor', bgColor, ...
  'FontSize', 9, ...
  'Callback', @exportCB, ...
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
  % Callback to populate the listbox
  %
  function showDataObjectsCB(src, ev)
    sNodes = getSelectedTreeNodes(obj, panel);
    node   = sNodes(1);
  
    % Cleanup
    set(boxH, 'Value', 1);
    set(boxH, 'String', 'Select Audio file node from tree ...');
    
    dName1 = getValue(node);
    fName1 = fullfile(dName1, 'dataInfo.mat');
    D1     = load(fName1);
    
    if ~strcmp(D1.dsArr.type, 'AudioFileFolder')
      % Early bail out
      return;
    end
    
    str = {};
    % Loop over each Analyser
    for i=1:getNumChildren(D1.dsArr)
      dName2 = fullfile(dName1, D1.dsArr(i).filename);
      fName2 = fullfile(dName2, 'dataInfo.mat');
      D2     = load(fName2);
      
      if ~strcmp(D2.dsArr.type, 'AudioAnalyserFolder')
        % Must be an analyser folder
        continue;
      end
      
      % Add name of Analyser
      str{end+1} = ['- ', D1.dsArr(i).name];
      
      % Loop over each data object
      dStr = {};
      for j=1:getNumChildren(D2.dsArr)
        % Only report timeseries objects
        if strcmp(D2.dsArr(j).nodeType, 'tSeries')
          dStr{end+1} = D2.dsArr(j).name;
        end
      end
      
      if isempty(dStr)
        dStr{end+1} = ' no timeseries data objects found';
      end
      
      % String cat
      str = {str{:}, dStr{:}};
      
      % Add separator
      str{end+1} = ' ';
    end

    % Install string in list
    set(boxH, 'String', str);
    
  end % showDataObjectsCB

  %
  % Export button
  % 
  function exportCB(src, ev)
    sNodes = getSelectedTreeNodes(obj, panel);
    len    = length(sNodes);

    [fName, fPath] = uiputfile({'*.csv', 'Export file (*.csv)'}, ...
                               'Export As', 'Untitled.csv');
    [fid, m] = fopen(fullfile(fPath, fName), 'wt');
    if ~isempty(m)
      error(m);
    end

    % There is no header information in this
    for l=1:len
      node   = sNodes(l);
      dName1 = getValue(node);
      fName1 = fullfile(dName1, 'dataInfo.mat');
      D1     = load(fName1);
      
      if ~strcmp(D1.dsArr.type, 'AudioFileFolder')
        % Skip
        continue;
      end
      
      % The name of the audio file
      audioFileName = getName(node);
      
      time = [];
      data = [];
      head = {};
      % Loop over each Analyser
      for i=1:getNumChildren(D1.dsArr)
        dName2 = fullfile(dName1, D1.dsArr(i).filename);
        fName2 = fullfile(dName2, 'dataInfo.mat');
        D2     = load(fName2);
        
        if ~strcmp(D2.dsArr.type, 'AudioAnalyserFolder')
          % Must be an analyser folder
          continue;
        end
        
            % Loop over each data object
        for j=1:getNumChildren(D2.dsArr)
          % Data object name
          dataObjName = D2.dsArr(j).name;

          % Move on if this is object is not in the listbox
          if ~findDataObj(dataObjName)
            continue;
          end

          % Append one after another
          fName3  = fullfile(dName2, D2.dsArr(j).filename);
          D3      = load(fName3);
          dataObj = D3.dataObjS.DataObj;
          
          % Get the time vector, if needed
          if isempty(time)
            time = dataObj.time;
          end
          
          % Cache header
          head{end+1} = dataObj.Name;
          
          % Check data length
          if ~(length(time) == size(dataObj.data, 1))
            errordlg([D2.dsArr(j).name, ' for ', char(audioFileName), ...
                      ' does not match the dimensions of other ' ...
                      'data object. Partial data may have been exported.']);
            fclose(fid);
            return;
          end
          
          % Length's match so keep going
          data(:, end+1) = dataObj.data;
        end
      end
      
      if ~isempty(data)
        % Print header
        fprintf(fid, [delimStr, 'Time']);
        fprintf(fid, [delimStr, '%s'], head{:});
        fprintf(fid, '\n');
        
        % Print data
        fStr = char(audioFileName);
        fStr = strcat(fStr, [delimStr, '%.2f']);
        k=0;
        while k<size(data,2)
          fStr = strcat(fStr, [delimStr, '%f']);
          k=k+1;
        end
        fStr = strcat(fStr, '\n');
        fprintf(fid, fStr, [time, data]');
        
        % Add separator
        fprintf(fid, '\n');
      end
    end
    
    fclose(fid);
  end % exportCB
  
  %
  % Finds the data object name in the list box
  %
  function found = findDataObj(str)
    lstr = get(boxH, 'String');
    lval = get(boxH, 'Value');

    found = false;
    for k=1:length(lval)
      if strcmp(str, deblank(lstr(lval(k),:)))
        found = true;
        break;
      end
    end
  end
end

% EOF
