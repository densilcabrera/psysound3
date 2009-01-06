function p = getFullPathToSox
% GETFULLPATHTOSOX
% 
% Returns the full path of the sox binary file

% Check that PsySound is already configured and then build the path from
% there.

p    = '';
wPsy = which('psysound3');

if isempty(wPsy)
  err = ['PsySound is not configured.', ...
         'Please execute ''configPsySound''', ...
         'from the PsySound directory before calling this function'];
  error(err);
end

[pathStr, junk1, junk2, junk3] = fileparts(wPsy);

% The sox dir for PC's is called win32
if ispc,
  c = 'win32';
else
  c = lower(computer);
end

% Build the full path
p = fullfile(pathStr, 'bin', 'sox', c, 'sox');

% Add quotes for PC as most probably the path contains spaces,
% e.g. c:\Program Files
if ispc,
  p = ['"', p, '"'];
end
