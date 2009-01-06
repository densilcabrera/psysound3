function SonifyAddfreq_Callback(hObject, eventdata, handles)

p = get(hObject, 'Parent');

DataChoice       = get(handles.OutputDataObjectsList, 'Value');
DataObjectChoice = get(handles.OutputDataObjectsList, 'String');

% Remove some stuff
origStr = DataObjectChoice{DataChoice};
newStr  = regexprep(origStr, 'timeseries:\s+', '');

if length(newStr) == length(origStr)
  warndlg('You may only add data objects of type timeseries', ...
         'Sonification add');
else
  hts  = findobj(p, 'Tag', 'freqTsObj');
  hmax = findobj(p, 'Tag', 'freqMax');
  hmin = findobj(p, 'Tag', 'freqMin');
  
  if ishandle(hts) & isstr(newStr)
    set(hts, 'String', newStr);
  end
  
  % Add an array of indicies to the UserData
  OutputResultsChoice = get(handles.OutputResultsList, 'Value');
  set(hts, 'UserData', [OutputResultsChoice, DataChoice]);
  
  % Toggle off the pink noise checkbox
  cbH = findobj(p, 'Tag', 'SonifyUsePinkNoise');
  set(cbH, 'Value', 0);
  
  % Enable this and the Min/Max fields
  set([hts, hmin, hmax], 'Enable', 'on');
  
  % Some default vals
  set(hmin, 'String', '400');
  set(hmax, 'String', '4000');
  
end

updateDurScFactor(p);
