function varargout = anim(obj, option, tStr, aObj, buttH)
% MOVIE  Movie function for tSeries

time = get(obj, 'Time');
data = get(obj, 'Data');

% This is the timer period in seconds
tPeriod = 0.1;

% Switch on option
switch(option)
 case 'GetList'
  out = {'comet'};
  
  if nargout
    varargout{1} = out;
  end
  
  % bail out
  return;
  
 case 'comet'
  origCB  = get(buttH, 'Callback');
  origSTR = get(buttH, 'String');
  
  % Create the player object
  CB.stopFcn  = @stopAnim;
  CB.timerFcn = @plotAnim;
  
  playerObj = createPlayerObj(aObj, CB);
  set(playerObj, 'TimerPeriod', tPeriod);
  
  % Plot one point. Following logic in comet.m
  axis([0 max(time) min(data) max(data)]);
  l = line('xdata', time(1), 'ydata', data(1), 'erase', 'none', ...
           'color', 'blue');
  
  xlabel(['Time (', obj.tsObj.TimeInfo.Units, ')']);
  ylabel([obj.tsObj.Name, ' (', obj.tsObj.DataInfo.Units, ')']);
  title(tStr);
  
  % Set up the Movie button to say stop
  set(buttH, 'String', 'Stop');
  set(buttH, 'Callback', @(src, ev)stop(playerObj));
  
  % GO!
  play(playerObj);
  
 otherwise
  error(['Unknown option : ', option, ' given']);
end % switch

  %
  % Nested  functions
  % 
  function stopAnim(s_src, s_ev)
    % Restore original Movie callback and string
    set(buttH, 'Callback', origCB, 'String', origSTR);
  end

  ti     = get(obj, 'TimeInfo');
  inc    = get(ti, 'Increment');
  len    = length(data);
  dur    = round(tPeriod / inc);
  start  = 2;
  finish = start + dur;
  
  function plotAnim(p_src, p_ev)
    set(l, 'xdata', time(start:finish), ...
           'ydata', data(start:finish));
    start  = finish;
    finish = start + dur;
    
    % Make sure we don't walk off the end
    if finish > len
      finish = len;
    end
    drawnow;
  end

end % anim
