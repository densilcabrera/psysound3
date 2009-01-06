
% Update duration stuff as soon as an Add is pressed
function updateDurScFactor(p)
% Get scaling factor from the GUI
h = findobj(p, 'Tag', 'outScFactor');
set(h, 'String', '-');

% Get the scaling type
h = findobj(p, 'Tag', 'outScFactorPopup');
set(h, 'Value', 1);
