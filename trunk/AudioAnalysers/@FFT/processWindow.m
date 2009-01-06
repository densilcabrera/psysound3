function f = processWindow(obj, dataIn)
% PROCESSWINDOW This is the core workhorse of this analyser
%
% NOTE: Every window is the same size and comes appropriately
%       zero-padded both in front and at rear, whenever neccessary,
%       and so that is why the following is just a straightforward
%       call.
chan = get(obj,'channels');
if chan ~= 1 && chan ~= 2
  dataOut = [];
  return;
end
% Initialize flag
doCZT = false;

if ~isempty(obj.cztF)
 fs = get(obj, 'fs');
 wl = get(obj, 'windowLength');
 
 f1 = obj.cztF(1);     % in hertz
 f2 = obj.cztF(2);     % in hertz
 R1 = obj.cztF(3);     % z-plane radius
 R2 = obj.cztF(4);     % z-plane radius

 %omega = exp(-j*2*pi*(f2-f1)/(wl*fs));
 %a     = exp(j*2*pi*f1/fs);
 a = R1*exp(j*f1*2*pi/fs);
 omega = ( R2/R1 )^(-1/(wl-1)) * exp(-j*(f2-f1)*2*pi/fs/(wl-1)) ;
 % Set flag
 doCZT = true;
end 

% Return function handle
f = @run;


  %
  % Nested run function
  %
  function dataOut = run(dataIn)
    if doCZT
      % Call MATLAB's Chirp Z-transform command
            dataOut = czt(dataIn, wl, omega, a)';
    else
      % Call MATLAB's fft command
        dataOut = fft(dataIn)';  % Make row vector
    end
  end % run
end
% end processWindow
