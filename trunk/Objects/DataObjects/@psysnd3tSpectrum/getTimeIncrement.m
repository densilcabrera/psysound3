function out = getTimeIncrement(obj)
% GETTIMEINCREMENT  Returns the increment in time

out = obj.Time(2) - obj.Time(1);

