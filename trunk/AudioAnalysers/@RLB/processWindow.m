function f = processWindow(obj, dataIn)
% PROCESSWINDOW This is the core workhorse of this analyser
%
%
% This is an example of a processWindow method that uses function
% handle.  The reason for this is to maintain state in the filter
%
% Reference:
% [1] Souldore, "Evaluation of Objective Loudness Meters",
%     Presented at the 116th Conventio, 2004 May 8-11 Berlin,
%     Germany. Audio Engineering Society
  
fs = get(obj, 'fs');

% user setting
rc = obj.rmsChoices;

% Filter weightings from [1], pg 12
% These are defined for 48k
b = [1 -2 1];
a = [1 -1.99004745483398 0.99007225036621];

% Use direct substituition of the definition of the z-transform
% (z=exp(s*T)) to recalculate coeffecients for a different sampling
% rate
% Note: This could be another option for pre-filtering

if fs ~= 48e3;
  poles = roots(a);
  
  % Make polynomial after fixing up the roots
  % 
  % z = exp(s*T) --> s = ln(z)/T
  %
  % s = ln(z1)/T1 = ln(z2)/T2  -->  z2 = exp(ln(z1)*T2/T1)
  %
  a = poly(exp(log(poles)*48e3/fs));
  
  % Note that the two zeros at 1 remain there.
  % Note also, that the negligible high frequency gain adjustment
  % is ignored.
end

% Buffer for any remaining values after RMS block integration
lenrc   = length(rc);
winLens = floor(rc * fs);

% state vector
Zf = [];

% Create function handles for the rms buffers
rmsB = cell(lenrc, 1);
for i=1:lenrc
  % Calculate the filter's a coeffecient
  rmsB{i} = fastfilter(ones(winLens(i),1)/winLens(i));
end

% Output data vector
dataOut = cell(1, lenrc);

% Return run function handle
f = @run;

  %
  % Nested filtering function
  % 
  function dataOut = run(dataIn)
    % Run filter
    [y, Zf] = filter(b, a, dataIn, Zf);  

    % Square the data
    data = y.^2;
    
    % Now run through each of the integrations
    for i=1:lenrc
      dataOut{i} = rmsB{i}(data);
    end
 end
end % processWindow
