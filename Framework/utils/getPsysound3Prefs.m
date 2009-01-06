function out = getPsysound3Prefs
% GETPSYSOUND3PREFS Gets the PsySound3 preferences
%
% Note: This is per installation.  Multi-user preferences are not
%       yet supported.

out = [];
p   = getPsySoundDir;

if ~isempty(p)
  % Construct the fullpath to the prefs file
  prefFile = fullfile(p, filesep, 'prefs.mat');
  
  pref = load(prefFile);

  if ~isfield(pref, 'multiChannelType')
    pref.multiChannelType   = 1;
    pref.multiChannelSelect = 1;
    pref.combineChannels = 1;
  end
  
  % Calibration
  % 1 0 0 means With Files
  % 0 1 0 means Without Files
  % 0 0 1 SPL level
  % This is also the order they appear in the Preference GUI
  if ~isfield(pref, 'calibrationIndex')
    pref.calibrationIndex = {1; 0; 0};
    pref.calibrationLvl   = 70;
  end
else
  error('PsySound3 does not seem to be installed on this system');
end

% Assign output
out = pref;

% end getPsysound3Prefs
