function psysound3
% PSYSOUND3
% 
% This wrapper function checks to make sure PsySound3 is
% installed and then opens the GUI

% Check to see if PsySound3 is on the path
p = path;

if ~isempty(findstr(p, 'psysound3')) 
	try
    getPsysound3Prefs; % CHECK IF PREFERENCES ARE THERE (May not be if PsySound paths added manually)
  catch
    configPsySound3;
  end
  disp('Starting PsySound3. ');
  disp('Please read README File distributed with Software.');
  disp('PsySound is BETA Software. Use at your own risk.');
  
  PsySoundGUI;
else
  fprintf(['PsySound3 does not seem to be configured, configuring before proceeding.\n']);
  configPsySound3;
  PsySoundGUI;
end


function configPsySound3
% CONFIGPSYSOUND3
% 
% Adds appropriate PsySound3 directories to the path and checks Matlab
% version. You only need to do this once.
%
% Note: You MUST be in the PsySound3 directory for this function to
%       work

try
  fprintf('Checking Versions... \n');

  reqVer = '7.3';
  
  % First check required ML version
  v = ver('matlab');
  
  vPrts  = getParts(v.Version);
  rvPrts = getParts(reqVer);
  
  if any(vPrts < rvPrts)
    error(['PsySound requires a minimum Matlab version of ', ...
           reqVer]);
  else
       fprintf('Matlab Version (> 7.3) OK.\n');
  end

  % Warn for the signal processing toolbox
  sigV = ver('signal');
  if isempty(sigV)
    warning(['Signal Processing Toolbox not found. PsySound may ', ...
             'not function correctly']);
  else
      fprintf('Signal Processing Toolbox OK.\n');
  end



  fprintf('Setting up Paths...\n');

  
  % This finds the path of the configPsySound3 MFILE
  folderpath = fileparts(mfilename('fullpath'));

  % If not the same then move to correct directory
  if ~strcmp(pwd,folderpath) 
      cd (folderpath)
  end
      

  % Add the PsySound3 dir
  addpath(pwd);
  
  %subdirs = {'GUI', 'AudioAnalysers', 'DataAnalysers', 'dataObjects', ...
  %           'dataStorage', 'utils'};
  
  subdir = genpath(pwd);
	%% Do not add .svn paths

  if isunix
  colons = findstr(subdir,':');
  elseif ispc
  colons = findstr(subdir,';');
  end
      
  boundaries = [[1 colons(1:end-1)+1]' [colons(1:end)-1]'];
  direcInd = 1;
  for i = 1:length(boundaries)
    direc = subdir(boundaries(i,1):boundaries(i,2));
    if isempty(findstr(direc,'.svn')) & isempty(findstr(direc,'PsysoundData')) % Svn folders and PsySoundData folders are useless.
    subdirs(direcInd) = {subdir(boundaries(i,1):boundaries(i,2))};
    direcInd = direcInd + 1;% Increment
    end
  end
  
  for dr = subdirs
   addpath(char(dr));
  end
  
  disp('Added PsySound3 directories to path successfully.');
  disp('');
  
  % Now save the path
  if savepath,
    disp(['Unable to save Matlab path. Please check write permissions ' ...
          'of ', matlabroot, filesep, 'toolbox', filesep, 'local', ...
          filesep, 'pathdef.m']);
    disp('');
    disp(' You may continue to use PsySound for this session.');
    disp(' However, you will need to run this configuration script again');
    disp(' the next time Matlab is restarted.');
  else
    disp('Matlab path saved successfuly.');
  end
  disp('');
catch
  disp(['There was an error configuring PsySound. Please see ' ...
        'below']);
  rethrow(lasterror);
end

try  
    prefs = getPsysound3Prefs;
    fprintf('Preferences already set up.\n');
catch
    prefs.dataDir = [folderpath filesep 'PsySoundData'];
    fprintf('Setting up Preferences...\n');
    fprintf(['Setting data folder to: \t'  [folderpath filesep 'PsysoundData'] '\nYou can change this using File>>Preferences in the PsySound3 GUI.\n']);
    prefs.showWaitBar= 0;
    prefs.multiChannelType= 1;
    prefs.multiChannelSelect= 1;
    prefs.combineChannels= 1;
    prefs.calibrationIndex= {1; 0; 0};
    prefs.calibrationLvl = '70';
    setPsysound3Prefs(prefs);
end
    


% Subfunction to parser the version string. This is based on the
% verLessThan.m file in Matlab 7.4
function parts = getParts(V)
parts = sscanf(V, '%d.%d.%d')';
    if length(parts) < 3
      parts(3) = 0; % zero-fills to 3 elements
    end
    
