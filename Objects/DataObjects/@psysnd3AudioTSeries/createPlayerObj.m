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

% Bits on unix and mac can only be 16. Bits on windows can be 24. (Not 32) 
if isunix && bits > 16
    bits = 16;
elseif bits>24 
    bits = 24;
end

% Create player object
playObj = audioplayer(Y, Fs, bits);

% Install callback functions
playObj.StopFcn  = stopFcn;
playObj.TimerFcn = timerFcn;

% end
