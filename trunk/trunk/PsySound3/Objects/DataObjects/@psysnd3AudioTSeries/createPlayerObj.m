function playObj = createPlayerObj(obj, callbacks)
% CREATEPLAYEROBJ  Creates the player object associated with the audio
%
%     callbacks should be a structure with one or more fields of
%     'stopFcn' or 'timerFcn'

if nargin == 1
  callbacks = [];
end

stopFcn  = [];
timerFcn = [];

% Retrieve any callback functions
if ~isempty(callbacks)
  if isfield(callbacks, 'stopFcn')
    stopFcn = callbacks.stopFcn;
  end

  if isfield(callbacks, 'timerFcn')
    timerFcn = callbacks.timerFcn;
  end
end  

Y    = get(obj, 'data');
Fs   = obj.Fs;
bits = obj.bits;

% Create player object
playObj = audioplayer(Y, Fs, bits);

% Install callback functions
playObj.StopFcn  = stopFcn;
playObj.TimerFcn = timerFcn;

% end
