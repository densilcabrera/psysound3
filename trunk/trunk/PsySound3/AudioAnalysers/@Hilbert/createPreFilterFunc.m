function f = createPreFilterFunc(obj)
% CREATEPREFILTERFUNC Creates a PreFilter function

% Get the weighting type from the object
w  = getPreFilterWeighting(obj);
N  = get(obj, 'windowLength');
Fs = get(obj, 'fs');

if strcmp(w, 'none')
  % 'none' weightings was selected, so install empty function handle
  f = [];
else
  % Create the weightings function structure
  fweight = weightings(N, Fs, w);
  
  % Assign the run method
  f = fweight.run;
end

% EOF

