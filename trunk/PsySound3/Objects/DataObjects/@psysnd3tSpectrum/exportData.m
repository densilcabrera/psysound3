function fid = exportData(obj, fid, delim, varargin)
% EXPORTDATA  Writes to file id

short = false;
if ~isempty(varargin)
  short = varargin{1};
end

% Write Header
% Name
fprintf(fid, '%s\n', get(obj, 'Name'));
fprintf(fid, '\n');

% Some info
data = get(obj, 'Data');
fprintf(fid, 'Samples : [%dx%d]\n', size(data, 1), size(data, 2));
fprintf(fid, '\n');

% Corner label
dataName = get(obj, 'DataName');
dataUnit = get(obj, 'DataUnit');
freqName = get(obj, 'FreqName');
freqUnit = get(obj, 'FreqUnit');

fprintf(fid, ['%s(%s)', delim, '%s(%s)', delim], ...
        dataName, dataUnit, ...
        freqName, freqUnit);

% Freqency vector
freq = get(obj, 'Freq');
if short
  fprintf(fid, ['%f', delim], freq(1:10));
  fprintf(fid, '...');
else
  fprintf(fid, ['%f', delim], freq);
end
% new line
fprintf(fid, '\n');

% Time label
fprintf(fid, ['%s(%s)', delim, delim], ...
  get(obj, 'TimeName'), get(obj, 'TimeUnit'));
% new line
fprintf(fid, '\n');

% Time vector and data
val = double(['%f', delim]);
if short
  dlen = size(data, 2);    if dlen>10, dlen=10; end
  tlen = length(obj.Time); if tlen>10, tlen=10; end
  % Extra spacing for time
  str = ['%f', delim, delim, char(repmat(val, 1, dlen))];
  str(end-(length(delim)-1):end) = '';
  str = strcat(str, '\n');

  fprintf(fid, str, [obj.Time(1:tlen) data(1:tlen,1:dlen)]');
  fprintf(fid, '...\n...');
else
  % Build format string to be of lenght 1 row
  len = size(data, 2);
  % Extra spacing for time
  str = ['%f', delim, delim, char(repmat(val, 1, len))];
  str(end-(length(delim)-1):end) = '';
  str = strcat(str, '\n');

  fprintf(fid, str, [obj.Time data]');
end
% end exportData
