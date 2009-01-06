function updateWaitBar(h, x)
% UPDATEWAITBAR  Updates the waitbars.  Called directly by runanalysis and
%                indirectly by resetWaitBars

if x == 0
  % Reset
  wColor = 'w';
  x      = 1;
else
  wColor = 'b'; % blue
end

xpatch = [0 x x 0] * 100;
ypatch = [0 0 1 1];

% Make h current
axes(h);

% Note: We could make this a nested function in order to hold on to
% the patch handle, however, since there is only one child anyway,
% I think its ok.
p = findobj(h, 'Type', 'patch');
if ishandle(p)
  % Update
  set(p, ...
      'XData',     xpatch, ...
      'YData',     ypatch, ...
      'FaceColor', wColor);
else
  % Create
  patch(xpatch, ypatch, wColor, ...
        'EdgeColor', 'k',       ...
        'EraseMode', 'none');
end

% end updateWaitBars
