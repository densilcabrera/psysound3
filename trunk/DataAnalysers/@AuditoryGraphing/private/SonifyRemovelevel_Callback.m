
function SonifyRemovelevel_Callback(hObject, eventdata, handles)
p = get(hObject, 'Parent');
h = findobj(p, 'Tag', 'levelTsObj');

% Clear label and UserData
set(h, 'String', '');
set(h, 'UserData', []);

% Disable both min and max
h = findobj(p, '-regexp', 'Tag', 'level(Min|Max)');
set(h, 'Enable', 'off');