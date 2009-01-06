function SonifyRemovepan_Callback(hObject, eventdata, handles)

p = get(hObject, 'Parent');
h = findobj(p, 'Tag', 'panTsObj');

% Clear label and UserData
set(h, 'String', '');
set(h, 'UserData', []);

% Set these to 1
h = findobj(p, '-regexp', 'Tag', 'pan(Min|Max)');
set(h, 'String', '1');

%%
% Rest all values to default