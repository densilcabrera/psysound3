function obj = setlength(obj, len)
% SETLENGTH  Alters the length of the time data

time   = obj.Time;
data   = get(obj, 'data');
oldLen = length(time);

if oldLen > len
  % Truncate
  obj.Time = time(1:len);
  obj  = set(obj, 'data', data(1:len,:));
else
  % Pad with NaN's
  d = len - oldLen;
  obj.Time = [time; nan(d,1)];
  
  data = [data; nan(d, size(data, 2))];
  obj = set(obj, 'data', data);
end

% [EOF]
