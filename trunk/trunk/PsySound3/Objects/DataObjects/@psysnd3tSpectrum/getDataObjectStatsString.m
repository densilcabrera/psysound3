function out = getDataObjectStatsString(obj)
% GETDATAOBJECTSTATSSTRING  Formats and returns stats string
%

out = '';

% Time
time   = get(obj, 'time');
str{1} = sprintf('Number of time slices %d\n', size(time,1));

tstep = obj.Time(2)-obj.Time(1);
str{end+1} = sprintf('Window time step : %.2f s\n', tstep);
str{end+1} = sprintf('\n');

% Frequency
str{end+1} = getFreqStr(obj);

out = [str{:}];

% EOF
