function obj = setlength(obj, len)
% SETLENGTH  Alters the length of the timeseries data

oldLen = size(obj.tsObj.data, 1);

% Fix up the time info first then data
obj.tsObj.TimeInfo = setlength(obj.tsObj.TimeInfo, len);

data = obj.tsObj.data;
if oldLen > len
  % Truncate
  obj.tsObj.data = data(1:len);
else
  % Pad with NaN's
  d = len-oldLen;
  obj.tsObj.data = [data; nan(d,1)];
end

% [EOF]
