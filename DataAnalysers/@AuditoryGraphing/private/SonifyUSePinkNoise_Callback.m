% 
function SonifyUSePinkNoise_Callback(hObject, eventdata, handles)

p    = get(hObject, 'Parent');
h(1) = findobj(p, 'Tag', 'freqTsObj');
h(2) = findobj(p, 'Tag', 'freqMax');
h(3) = findobj(p, 'Tag', 'freqMin');

val = get(hObject, 'Value');

if val == 0
  set(h, 'Enable', 'on');
else
  set(h, 'Enable', 'off');
end

str = get(h(1), 'String');
if isempty(str)
  % If sting is empty, leave freqMin off
  set(h(3), 'Enable', 'off');
end