function obj = setSummary(obj, propName, propUnit, propVal)
% setSummary method for Stats

len = length(obj.Summaries);
if isempty(obj.Summaries)
 len = 0;
end
obj.Summaries{len+1}.Name = propName;
obj.Summaries{len+1}.Unit = propUnit;
obj.Summaries{len+1}.Value = propVal;

% [EOF]
