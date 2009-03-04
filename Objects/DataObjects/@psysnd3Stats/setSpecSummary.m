function obj = setSpecSummary(obj, propName, propUnit, propVal)
% setSummary method for Stats

len = length(obj.SpecSummaries);
if strcmp(obj.SpecSummaries{1}.Name, '')
 len = 0;
end
obj.SpecSummaries{len+1}.Name = propName;
obj.SpecSummaries{len+1}.Unit = propUnit;
obj.SpecSummaries{len+1}.Value = propVal;

% [EOF]
