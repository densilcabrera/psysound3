function varargout = anim(obj, option, tStr, aObj, buttH)
% MOVIE  Movie function for tSpectrum

out = [];

time = get(obj, 'Time');
data = get(obj, 'Data');
freq = get(obj, 'Freq');

tStep = diff(time);
tStep = tStep(2);

% This is the timer period in seconds (effectivly 10 frames per sec)
tPeriod = 0.1;

% Switch on option
switch(option)
 case 'GetList'
  out = {'specMovie'};
  
  if nargout
    varargout{1} = out;
  end
  
  % bail out
  return;
  
 case 'specMovie'
  origCB  = get(buttH, 'Callback');
  origSTR = get(buttH, 'String');
  
  % Create the player object
  CB.stopFcn  = @stopAnim;
  CB.timerFcn = @plotAnim;
  
  playerObj = createPlayerObj(aObj, CB);
  set(playerObj, 'TimerPeriod', tPeriod);
  
  % Labels etc ...
  fName = get(obj, 'FreqName');
  fUnit = get(obj, 'FreqUnit');
  dName = get(obj, 'DataName');
  dUnit = get(obj, 'DataUnit');
  
  axis([0 max(freq) min(min(data)) max(max(data))]);
  xlabel([fName, ' (', fUnit, ')']);
  ylabel([dName, ' (', dUnit, ')']);

  % Plot first frame
  f = 1;
  % h = plot(freq, data(f,:));
  h = line('xdata', freq, 'ydata', data(f,:), 'color', 'blue');
  
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

  len = size(data, 1);
  dur = round(tPeriod / tStep);
  f   = f + dur;
  
  function plotAnim(p_src, p_ev)
    set(h, 'ydata', data(f,:));
    % set(get(h, 'Parent'), 'yLim', yLim);
    f = f + dur;
    
    % Make sure we don't walk off the end
    if f > len
      f = len;
    end
    drawnow;
  end

end % anim

% [EOF]
