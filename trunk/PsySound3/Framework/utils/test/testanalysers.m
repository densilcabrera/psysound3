function testanalysers(filename)
% TESTANALYSERS
%
% work through each output dataobject performing a few simple tests to
% ensure each of them make sense. 

% Get list of variables in mat-file
variables = whos('-file', filename);

% load the file
load(filename);

for i = 1:length(variables)-1
  cmd = strcat('get(' , variables(i).name ,',' ,'''output'')');
  results = eval(cmd);
  for j = 1:length(results)
    resultclass = class(results{j});
    try
    switch resultclass
      case {'timeseries'}
        failures(i,j) = auditTimeseries(results{j}); 
      case {'Spectrum'}
        failures(i,j) = auditSpectrum(results{j});
      case {'tSpectrum'}
        failures(i,j) = auditTimeSpectrum(results{j});
    end
    catch
      disp('audit failed');
    end
    pause
  end
  failureCounted{i} = sprintf('%s\t%i\n',variables(i).name, sum(failures(i,:)));
end

disp('************');
disp('Failures:');
for i = 1:length(failureCounted)
fprintf('%s\n',failureCounted{i});
end

function failure = auditTimeseries(ts)
% tests for timeseries
disp('*****************');
fprintf('Name: %s\n',ts.Name)
% what is the length of the time vector
disp('Sizes')
fprintf('Data\t Time\n');
fprintf('%i\t %i\n',length(ts.Data),length(ts.Time));
% if they equal each other then they pass otherwise fail
if length(ts.Data)==length(ts.Time)
  disp(strcat(ts.Name,' Passed Size Consistency Test'));
  failure = 0;
else
  disp(strcat(ts.Name,' Failed Size Consistency Test'));
  failure = 1;
end
disp('Ranges')
fprintf('Min\tMax of Time\n');
fprintf('%.2f\t%.2f\n',min(ts.Time),max(ts.Time));
fprintf('Min\tMedian\tMean\tMax of Data\n');
fprintf('%.2f\t%.2f\t%.2f\t%.2f\n',ts.DataInfo.UserData.min,ts.DataInfo.UserData.median,ts.DataInfo.UserData.mean,ts.DataInfo.UserData.max);
if min(ts.Time)==0
  disp(strcat(ts.Name,' Passed Time Min Test'));
  failure = 0;
else
  disp(strcat(ts.Name,' Failed Time Min Test'));
  failure = 1;
end

function failure = auditSpectrum(sp)
% tests for timeseries
disp('*****************');
fprintf('Name: %s\n',sp.Name)

disp('Sizes')
fprintf('Data\t Freq\n');
fprintf('%i\t %i\n',length(sp.data),length(sp.Xaxes));
% if they equal each other then they pass otherwise fail
if length(sp.data)==length(sp.Xaxes)
  disp(strcat(sp.Name,' Passed Size Consistency Test'));
  failure = 0;
else
  disp(strcat(sp.Name,' Failed Size Consistency Test'));
  failure = 1;
end

disp('Ranges')
fprintf('Min\tMax of Freq\n');
fprintf('%.2f\t%.2f\n',min(sp.Xaxes),max(sp.Xaxes));
fprintf('Min\tMax of Data\n');
fprintf('%.2f\t%.2f\n',min(sp.data),max(sp.data));

function failure = auditTimeSpectrum(tsp)
% tests for timeseries
disp('*****************');
fprintf('Name: %s\n',tsp.Name)

disp('Sizes')
fprintf('Time\tYaxes\tDataSize\n');
fprintf('%i\t%i\t%i\t%i\n',length(tsp.Time),length(tsp.Yaxes),size(tsp.data));

datasize = size(tsp.data);
% if they equal each other then they pass otherwise fail
if datasize(1)==length(tsp.Yaxes) && datasize(2)==length(tsp.Time)
  disp(strcat(tsp.Name,' Passed Size Consistency Test'));
  failure = 0;
else
  disp(strcat(tsp.Name,' Failed Size Consistency Test'));
  failure = 1;
end

disp('Ranges')
fprintf('Min\tMax of Time\n');
fprintf('%.2f\t%.2f\n',min(tsp.Time),max(tsp.Time));
if min(tsp.Time)==0
  disp(strcat(tsp.Name,' Passed Time Min Test'));
  failure = 0;
else
  disp(strcat(tsp.Name,' Failed Time Min Test'));
  failure = 1;
end
