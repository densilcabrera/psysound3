

function SonifyPlayOutput_Callback(hObject, eventdata, handles)

p = get(hObject, 'Parent');
h = findobj(p, 'Tag', 'SonifyButton');

dat = get(h, 'UserData');

if ~isempty(dat{1})
  % Get the original string
  str = get(hObject, 'String');
  
  % Set to Playing...
  set(hObject, 'String', 'Playing...');
  pause(0.2);
  
  % Actually play
  % xxx - Matlab clips for some reason if we don't reduce the amplitude
  sound(dat{1}*0.8, dat{2});
  
  % Reset the string
  set(hObject, 'String', str);
else
  % throw an error dialog
  warndlg(['Sonified file not found. Please press the ''Sonify'' ' , ...
            'button and try again']);
end