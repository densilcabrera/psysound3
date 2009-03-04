function f = processWindow(obj, dataIn)
% PROCESSWINDOW This is the core workhorse of this analyser
%
% This will ba a matrix with one column each for the outuput from
% the prefilter function.  Just call the PsySound3 integrator
% function.
%
% This is an example of a processWindow method that uses function
% handle.  The reason for this is to maintain state in the integrator

fs = get(obj, 'fs');
N  = get(obj, 'windowLength');

% Weight choices
wChoices = getwChoices(obj);
wLen     = length(wChoices);

% Integration choices
iChoices = getiChoices(obj);
iLen     = length(iChoices);

% This is the total length
len = iLen * wLen;

% Store function handles in an array of structs with name and
% function handle
s = struct([]);
j = 1;

% Loop through and populate the struct
for w = 1:wLen % foreach weighting type
  % Create and assign function handle
  s(j).wFH = weightings(N, fs, wChoices(w));
  s(j).iFH = {};
  % Now loop over each integration type
  for i = 1:iLen
    s(j).iFH{end+1} = integrator(fs, char(iChoices(i)));
  end
  j = j + 1;
end

% Create the function handle
f = @run;

% Store data in a flat cell array of column data
dataOut = cell(1, len);
  function dataOut = run(dataIn)
    data = [];
    k    = 1;
    for i=1:length(s)
      % Run the weightings filter
      data = s(i).wFH.run(dataIn);

      % Now run each of the integrations
      for j=1:length(s(i).iFH)
        dataOut{k} = s(i).iFH{j}(data);
        k = k+1;
      end % for j = iFH
    end % for i = length(s)
  end % run
end % processWindow
