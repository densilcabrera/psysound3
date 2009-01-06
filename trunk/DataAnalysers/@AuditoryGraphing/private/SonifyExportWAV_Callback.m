
function SonifyExportWAV_Callback(hObject, eventdata, handles)

% Find the sonified signal
p = get(hObject, 'Parent');
h = findobj(p, 'Tag', 'SonifyButton');

dat = get(h, 'UserData');

if ~isempty(dat{1})
  % Get the name of the file
  [fName, pName] = uiputfile('*.wav', 'Save file as');
  
  % Write wav file
  wavwrite(dat{1}, dat{2}, fullfile(pName, fName));
  
else
    warndlg(['Sonified file not found. Please press the ''Sonify'' ' , ...
            'button and try again']);
end
