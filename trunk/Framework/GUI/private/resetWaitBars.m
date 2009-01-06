function resetWaitBars(wBars, wText)
% RESETWAITBARS  Resets the waitbars. Called by runanalysis and PsySoundGUI

wBarInitText = {'Buffer', 'Analyser', 'File'};
if ~isempty(wBars)
  for i=1:3
    updateWaitBar(wBars(i), 0);
    set(wText(i), 'String', wBarInitText{i});
  end
end

% end resetWaitBars
