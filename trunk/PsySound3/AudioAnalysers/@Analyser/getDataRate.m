function out = getDataRate(obj, varargin)
% GETDATARATE  This is the effective sampling time for
%              synchronisation purposes

rate = [];
switch obj.type
 case 'TimeDomain'
   % e.g. SLM
   rate = get(obj, 'fs');
  
 case {'Psychoacoustic', 'FrequencyDomain'}
   % e.g    LoudnessMG              FFT
   rate = getWindowRate(obj);
  
 case 'Raw'
   rate = get(obj, 'outputDataRate');
 
 otherwise
   error('Unknown Analyser type encountered');
end

% Assign output
out = rate;

% EOF
