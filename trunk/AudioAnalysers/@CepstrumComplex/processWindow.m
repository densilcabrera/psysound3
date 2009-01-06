function dataOut = processWindow(obj, dataIn)
% PROCESSWINDOW This is the core workhorse of this analyser
%
% NOTE: Every window is the same size and comes appropriately
%       zero-padded both in front and at rear, whenever neccessary,
%       and so that is why the following is just a straightforward
%       call.



% Initialize flag
doLifter = false;

if ~isempty(obj.LifterF)
    fs = get(obj, 'fs');
    wl = get(obj, 'windowLength');
    w = round(wl / 2);
    
    % get cepstral window start and end times
    t1 = obj.LifterF(1);
    t2 = obj.LifterF(2);
    
    % cepstral window in samples
    s1 = round(0.001 * t1 * fs) + 1;
    s2 = round(0.001 * t2 * fs) + 1; 
    
    % avoid errors
    if or(s1 < 1, s1 > w-1)
        s1 = 1;
    end
    if or(s2 < 2, s2 > w)
        s2 = w;
    end
    if s1 >= s2
        s1 = 1;
        s2 = w;
    end
    
    doLifter = true;
end 
% Return function handle
dataOut = @run;
 

  %
  % Nested run function
  %
  function dataOut = run(dataIn)
    if doLifter
      % Call MATLAB's complex Cepstrum command
        [cepstrum, nd] = cceps(dataIn);
        lifteredcepstrum = zeros(wl,1); 
        lifteredcepstrum(s1:s2,1) = cepstrum(s1:s2,1);
        lifteredcepstrum(wl-s2+1:wl-s1+1,1) = cepstrum(wl-s2+1:wl-s1+1,1);
        result = fft(icceps(lifteredcepstrum, nd));
        dataOut = result'; % Make row vector
    else
      % Call MATLAB's complex Cepstrum command
      dataOut = cceps(dataIn)';  % Make row vector
    end
  end % run
end
% end processWindow
