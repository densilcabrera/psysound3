function obj = setSummary(obj, propName, propUnit, propVal)
% setSummary method for Stats

len = length(obj.Summaries);
noDuplicate = 1;
if isempty(obj.Summaries)
 len = 0;
end

for i = 1:len
  if strcmp(obj.Summaries{i}.Name, propName) && strcmp(obj.Summaries{i}.Unit, propUnit)
    obj.Summaries{i}.Name = propName;
    obj.Summaries{i}.Unit = propUnit;
    obj.Summaries{i}.Value = propVal;
    noDuplicate = 0;
  end
end

if noDuplicate
  obj.Summaries{len+1}.Name = propName;
  obj.Summaries{len+1}.Unit = propUnit;
  obj.Summaries{len+1}.Value = propVal;
end
    
% [EOF]
