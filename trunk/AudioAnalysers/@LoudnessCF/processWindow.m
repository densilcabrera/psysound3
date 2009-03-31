function funcH = processWindow(obj, dataIn)
% PROCESSWINDOW This is the core workhorse of this analyser
%

fs    = get(obj, 'fs');
dlmFH = dlm(fs);

funcH = @run;
  
  %
  % The actual process method
  %
  function dataOut = run(dataIn)
    % Add the scaling factor. Basically this is all that
    % estimateCalibrationCoefficientDLM seems to do!
      dataIn = dataIn/(2*10^.5);
      [N, main_N, spec_N] = dlmFH(dataIn);
      
      Fl = 0;
      if ~isstr(N)
        Fl = fluct(main_N);
      end
      
      dataOut = {N, main_N, spec_N, Fl};
   end % run
end % processWindow
