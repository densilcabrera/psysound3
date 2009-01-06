function exportGenericHeader(obj, fid)
% EXPORTGENERICHEADER  Exports a generic header

% Add some info
fprintf(fid, '%s\n\n', get(obj, 'Name'));
fprintf(fid, 'Audio filename : %s\n\n', get(obj, 'filename'));

if ~strcmp(get(obj, 'type'), 'TimeDomain')
  % Window length
  fprintf(fid, 'Window length : %d samples\n', get(obj, 'windowLength'));

  % Overlap
  ov = obj.overlap;
  fprintf(fid, 'Overlap : %d %s\n', ov.size, ov.type);
  
  % Windowing function
  wFunc = get(obj, 'windowFunc');
  if strcmp(wFunc, 'rect')
    wFunc = 'rectangular';
  end
  fprintf(fid, 'Window function : %s\n', wFunc);
end

% Output data rate
fprintf(fid, 'Output data rate : %.2f Hz\n', get(obj, ...
                                              'outputDataRate'));
fprintf(fid, '\n');

% EOF
