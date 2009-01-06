function val = getSize(obj)
% GETSIZE method of psysnd3Spectrum

val = [size(get(obj, 'Data')) length(get(obj, 'Time'))];

% [EOF]
