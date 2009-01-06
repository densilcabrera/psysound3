
function SonifyClearAll_Callback(hObject, eventdata, handles)
p = get(hObject, 'Parent');

% All min/max
h = findobj(p, '-regexp', 'Tag', '(freq|level|pan)(Min|Max)');
set(h, 'String', '0');

h = findobj(p, '-regexp', 'Tag', '(freq|level|pan)(TsObj)');
% Clear labels and UserData
set(h, 'String', '');
set(h, 'UserData', []);

h = findobj(p, 'Tag', 'outScFactor');
set(h, 'String', '5');

h = findobj(p, 'Tag', 'outScFactorPopup');
set(h, 'Value', 1);

h = findobj(p, 'Tag', 'SonifyUsePinkNoise');
set(h, 'Value', 1);