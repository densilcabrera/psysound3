function SonifyRemovefreq_Callback(hObject, eventdata, handles)

p = get(hObject, 'Parent');
h = findobj(p, 'Tag', 'freqTsObj');

% Clear label and UserData
set(h, 'String', '');
set(h, 'UserData', []);

% Disable Min
h = findobj(p, 'Tag', 'freqMin');
set(h, 'Enable', 'off');