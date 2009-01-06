
function SonifyAddpan_Callback(hObject, eventdata, handles)

p = get(hObject, 'Parent');

DataChoice       = get(handles.OutputDataObjectsList,'Value');
DataObjectChoice = get(handles.OutputDataObjectsList,'String');

% Remove some stuff
origStr = DataObjectChoice{DataChoice};
newStr  = regexprep(origStr, 'timeseries:\s+', '');

if length(newStr) == length(origStr)
  warndlg('You may only add data objects of type timeseries', ...
         'Sonification add');
else
  h = findobj(get(hObject, 'Parent'), 'Tag', 'panTsObj');

  if ishandle(h) & isstr(newStr)
    set(h, 'String', newStr);
  end
  
  % Add an array of indicies to the UserData
  OutputResultsChoice = get(handles.OutputResultsList, 'Value');
  set(h, 'UserData', [OutputResultsChoice, DataChoice]);

  h = findobj(p, '-regexp', 'Tag', 'pan(Min|Max)');
  set(h(1), 'String', '1');
  set(h(2), 'String', '0');
  
end

updateDurScFactor(p);
