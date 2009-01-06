function testcals(filename, inputLevel)
% TESTCALS
%
% work through each output dataobject performing a few simple tests to
% ensure each of them make sense. 

% Get list of variables in mat-file
variables = whos('-file', filename);

% load the file
load(filename);

% dB Level

for i = 1:length(variables)-1
  cmd = strcat('get(' , variables(i).name ,',' ,'''output'')');
  results = eval(cmd);
  for j = 1:length(results)
    resultclass = class(results{j});
    try
    switch resultclass
      case {'timeseries'}
        failures(i,j) = auditTimeseries(results{j},inputLevel,variables(i).name); 
      case {'Spectrum'}
        failures(i,j) = auditSpectrum(results{j},inputLevel,variables(i).name);
      case {'tSpectrum'}
        failures(i,j) = auditTimeSpectrum(results{j},inputLevel,variables(i).name);
    end
    catch
      disp('audit failed');
    end
    
  end
  failureCounted{i} = sprintf('%s\t%i\n',variables(i).name, sum(failures(i,:)));
end

disp('************');
disp('Failures:');
for i = 1:length(failureCounted)
fprintf('%s\n',failureCounted{i});
end

function failure = auditTimeseries(ts,inputLevel,varName)
% tests for timeseries
fprintf('%s\t%s\t',varName,ts.Name)
fprintf('%.2f\t%.2f\t %.2f\t',ts.DataInfo.UserData.median, inputLevel, ts.DataInfo.UserData.median - inputLevel)
if abs(ts.DataInfo.UserData.median - inputLevel)>1
  fprintf('Failed\n');
  failure =1;
else
  fprintf('Passed\n');
  failure =0;
end

function failure = auditSpectrum(sp,inputLevel,varName)
% tests for timeseries
fprintf('%s\t%s\t',varName,sp.Name)
fprintf('%.2f\t%.2f\t%.2f\t',max(sp.data), inputLevel, max(sp.data) - inputLevel)
if abs(max(sp.data) - inputLevel)>1
  fprintf('Failed\n');
  failure =1;
else
  fprintf('Passed\n');
  failure =0;
end


function failure = auditTimeSpectrum(tsp,inputLevel,varName)
% tests for timeseries

fprintf('%s\t%s\t',varName,tsp.Name)
  fprintf('TimeSpectrum...\n');
failure = 0;
