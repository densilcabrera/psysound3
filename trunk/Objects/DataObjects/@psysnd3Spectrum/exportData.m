function fid = exportData(obj, fid, delim, varargin)
% EXPORTDATA  Writes to file id

short = false;
if ~isempty(varargin)
  short = varargin{1};
end

% Write Header
% Name
fprintf(fid, '%s\n', get(obj, 'Name'));

% Some info
len = length(obj.Data);
fprintf(fid, 'Samples : %d\n', len);
fprintf(fid, '\n');

% Freqency
fprintf(fid, ['%s (%s)', delim], obj.FreqName, obj.FreqUnit);
if short
  fprintf(fid, ['%f', delim], obj.Freq(1:10));
  fprintf(fid, '...');
else
  fprintf(fid, ['%f', delim], obj.Freq);
end
% new line
fprintf(fid, '\n');

% Data
fprintf(fid, ['%s (%s)', delim], obj.DataName, obj.DataUnit);
if short
  fprintf(fid, ['%f', delim], obj.Data(1:10));
  fprintf(fid, '...');
else
  fprintf(fid, ['%f', delim], obj.Data);
end
% end exportData
