function setPsysound3Prefs(var)
% SETPSYSOUND3PREFS Sets/saves the PsySound3 preferences
%
% Note: This is per installation.  Multi-user preferences are not
%       yet supported.

p = getPsySoundDir;

if ~isempty(p)
  % Construct the fullpath to the prefs file
  prefFile = fullfile(p, filesep, 'prefs.mat');
  
  save(prefFile, '-struct', 'var');
  
else
  error('PsySound3 does not seem to be installed on this system');
end

% end getPsysound3Prefs
