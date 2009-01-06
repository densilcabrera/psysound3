function updateDataAnalyserPanel(obj, panel)
% UPDATEDATAANALYSERPANEL This method is called everytime a tree
%                         node is clicked.
%
% Fills in the appropriate text box(es)

sNodes = getSelectedTreeNodes(obj, panel); 
len    = length(sNodes);

resetText();

p = getPsysound3Prefs;

if len > 0
  node     = sNodes(1);
  nodePath = getPath(node);
  
  % Update the data dir
  str = ['Summary for results in : ', p.dataDir];
  set(obj.dataDir, 'String', str);

  len = length(nodePath);
  ind = 2;  % skip root
  while ind < len + 1
    cNode = nodePath(ind);

    if ind == 2
      % This is the audio file
      setStringAudioFileNode(obj.fileInfo, cNode);
      
    elseif ind == 3
      % This should be the analyser
      setStringAnalyserNode(obj.AudioAnalyserInfo, cNode);
    
    elseif ind == 4
      % The data object
      setStringDataNode(obj, cNode);
    
    else
      % To be completed
    end
    ind = ind + 1;
  end
end

  function resetText
    set(obj.dataDir, 'String', 'Psysound3 data directory ...');
    set(obj.fileInfo, 'String', 'Audio file info ...');
    set(obj.AudioAnalyserInfo, 'String', 'Audio Analyser info ...');
    set(obj.AudioDataOutput, 'String', ['Data output from Audio ' ...
                        'Analyser ... ']);
%     set(obj.DataAnalyserOutput, 'String', ['Output form Data Analyser ' ...
%                         '...']);
    end % resetText
end % updateDataAnalyserPanel

%
% Local functions
%

% Formats string for an audio file node
function setStringAudioFileNode(h, node)

  [data, junk] = getDataFromDsArrNode(node);

  if ~isempty(data)
    str{1}  = sprintf(['File name \t: %s\n', ...
                       'Length \t: %.2f s\n', ...
                       'Sample Rate \t: %d Hz\n', ...
                       'Bit depth \t: %d\n', ...
                       'Channels \t: %d\n'], ...
                      data.realName, ...
                      data.samples/data.sampleRate, ...
                      data.sampleRate,...
                      data.bitsPerSample, ...
                      data.channels);
    
    set(h, 'String', str);
    
    % Stick the fullpath to the audio file on play button
    hButt = findobj(get(h, 'Parent'), 'Tag', 'playButton', ...
                    'Style', 'pushbutton');
    if ishandle(hButt)
      set(hButt, 'UserData', getValue(node), 'Enable', 'on');
    end
  end  
end


% Formats string for an audio analyser node
function setStringAnalyserNode(h, node)
  
  [data, date] = getDataFromDsArrNode(node);
  
  if ~isempty(data)
    if strcmp(data.type, 'TimeDomain')
      rateStr  = 'Output Data Rate';
    else
      rateStr  = 'Window Rate';
    end
    
    str{1}  = sprintf(['Date \t: %s\n', ...
                       'Window length \t : %d samples\n', ...
                       'Overlap \t : %d %s\n', ...
                       '%s\t: %.2f Hz\n', ...
                       'Output Data Samples \t: %d\n'], ...
                      date, ...
                      data.windowLength, ...
                      data.overlap.size, data.overlap.type,...
                      rateStr, ...
                      data.outputDataRate,...
                      data.outputSamples);
    
    str{2} = sprintf('\n%s:\n', data.Name);
    str{3} = getAnalyserSettingsString(data);
    set(h, 'String', str);
  end
end

% Formats string for a data node
function setStringDataNode(obj, node)
  h        = obj.AudioDataOutput;
  dataObjS = getDataObjectFromTreeNode(obj, node);
  
  if ~isempty(dataObjS)
    dObj = dataObjS.DataObj;
    sz = whos('dObj');
    if sz.bytes > 1e6;
      % Megabytes
      sz = sz.bytes/1024/1024;
      str{1} = sprintf('Approx. data/file size : %.2f MB\n', sz);
    else
      % kilobytes
      sz = sz.bytes/1024;
      str{1} = sprintf('Approx. data/file size : %.2f kB\n', sz);
    end
    str{2} = getDataObjectStatsString(dObj);
    
    set(h, 'String', str);
  end
end

% Gets the data struct from a dsArr obj
function [data, date] = getDataFromDsArrNode(node)

  fName = fullfile(getValue(node), 'dataInfo');
  data  = [];
	date  = '';
	
  if exist([fName, '.mat']) == 2
    load(fName);
    
    if exist('dsArr', 'var') == 1
      data = dsArr.data;
      date = dsArr.date;
    end
  end
end
% EOF
