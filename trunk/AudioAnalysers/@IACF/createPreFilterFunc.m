function f = createPreFilterFunc(obj)
% CREATEPREFILTERFUNC Creates a PreFilter function

% Get the weighting type from the object
N  = get(obj, 'windowLength');
Fs = get(obj, 'fs');

% Create the A weightings function structure
fweight = weightings(N, Fs, 'A');
  
% Assign the run method
f = fweight.run;

% EOF

