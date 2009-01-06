
%%%
function SonifyPlayInput_Callback(hObject, eventdata, handles)
% Assume the user has not clicked away in the file panel

strs = get(handles.OutputFilesList, 'String');
val  = get(handles.OutputFilesList, 'Value');

str = get(hObject, 'String');

if ~isempty(findstr(str, 'Play'))
  % We are asked to play
  try
    load(strs{val}, 'fileinfo');
    [y, Fs]  = wavread(fileinfo.Filename);
    audioObj = audioplayer(y, Fs);
    
    % This is so that we can stop playing when we come back
    set(hObject, 'UserData', audioObj);

    % This is not quite working yet - the idea is to install a
    % Stopfcn so that after we stop playing we will revert the
    % string back
    % This is so that it automatically reverts the name when finished
%     strStop = ['set(', num2str(hObject), ', ''String'', ''Play Input ' ...
%                         'file'')']
%     set(audioObj, 'UserData', hObject);
%     set(audioObj, 'StopFcn', strStop);
    
    % Go ahead
    play(audioObj);
    
    set(hObject, 'String', 'Stop playing');
  catch
    set(hObject, 'UserData', []);
  end
else
  % We are asked to stop
  audioObj = get(hObject, 'UserData');
  
  if ~isempty(audioObj)
    if isa(audioObj, 'audioplayer')
      stop(audioObj);
    end
  end
  
  % Reset state
  set(hObject, 'String',   'Play Input file');
  set(hObject, 'UserData', []);
end
