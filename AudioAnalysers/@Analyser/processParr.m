function out = process(obj, fH, wH, varargin)
% PROCESS  Generic process method that is the workhorse of the
%          Analyser
%
%   OBJ = PROCESS(OBJ, FH) - Nominal usage. Calls the subclass'
%                            method PROCESSWINDOW to execute the
%                            analyser and returns the processed OBJ
%                            with its OUTPUT field populated with
%                            the specific DATAOBJECTS for the
%                            particular ANALYSER
%
%   OUT = PROCESS(OBJ, FH, 'estimate') 
%                               - Gives time and memory estimates for
%                                 the Analyser
%                               Where:
%                               - OUT(1) is the time estimate &
%                               - OUT(2) is the memory size of the
%                                        data buffers required 
%
%   WH is a function handle to a progress function.  It should have
%      only a single fractional (or 1) argument.
%
% Stages:
% ------
%   o) allocOutputDataStorage - Allocates data buffers in memory to
%                               store the results of each processed
%                               window
%   o) create windowing function
%   o) foreach window
%         - Read data from file via the readData utility
%         - Apply (if any) the windowing function
%         - "Analyse" the window using the processWindow method
%         - populate the data buffers using the assignOutputs method
%
%   o) Call constructDataObjects subclass method to create the
%      various timeseries, Spectrum, time Spectrum etc.. data
%      objects that are specific to the particular Analyser
%
% Command-line use:
% ----------------
%  If calling this method from the command-line the GUI settings
%  are (naturally) by-passed.  That means that unless the user sets
%  the Analyser properties via the 'set' command, DEFAULT
%  properties will be used.
%
%  Visual display:  Additionally, you may define a global variable
%  PSYSOUND_VERBOSITY and set its value to 1, for concise or 2, for
%  verbose, to display timing statistics and a wandering period
%  to indicate progress.
%
%
% Setup verbosity levels for displaying statistics on the screen
global PSYSOUND_VERBOSITY
vLvl = PSYSOUND_VERBOSITY;
if isempty(vLvl)
  vLvl = 0;
end
pTime = [];
aTime = 0;

% See if we're estimating
estimate  = 0;
calibrate = 0;
synch     = 0;
if ~isempty(varargin)
  var = varargin{1};
  if isstr(var)
    str = var;
    switch(str)
     case 'estimate'
      % We want time estimates
      estimate    = 1;
      fH.calCoeff = 1;
     case 'calibrate'
      % We are in the process of calibration, 
      % set the coeffecient to one
      fH.calCoeff = 1;
      calibrate   = 1;
     case 'synchronise'
      % Synchronise output
      synch     = 1;
      oDataRate = varargin{2};
     otherwise
      error(['Analyser: process. Unknown string argument ''', str, '''']);
    end
  else
    error(['Analyser: process. Unknown argument ''', var, '''']);
  end
end

      
% Set synch flag
obj = set(obj, 'synch', synch);

wBar = [];
if ~isempty(wH) && isa(wH, 'function_handle')
  % Must be a handle to a progress function
  wBar = wH;
end

% Right off the bat, error out if uncalibrated
if ~estimate & isnan(fH.calCoeff)
  error(['Analyser: process: Calibration coeffecient for file ', ...
         fH.realName, ' not found.  Please calibrate before ' ...
         'proceeding.']);
end

% First setup some of the settings
% Note: Technically, this should go into its own method at the end
% of the Analyser constructor.  Same goes for the synchronisation
% setup further below

% if ~isempty(gcbo) && ~calibrate
%   [obj, fH] = settings(obj, fH);
% end

% If windowLength and overlap is not specified by default or
% otherwise, assume params from the filehandle
if (obj.windowLength == -1)
  % fH -> obj
  obj.windowLength = fH.windowLength;
else
  % obj -> fH
  fH.windowLength = obj.windowLength;
end

if (obj.overlap.size == -1)
  % fH -> obj
  obj.overlap.size = fH.overlap;
  obj.overlap.type = 'samples';
else
  % obj -> fH
  fH.overlap = getOverlap(obj);  
end

% This is the total number of windows we are going to process
nWindows = getNumWindows(obj);

% Fix up output sample data
if synch
  % for TimeDomain
  outputSamples = ceil(obj.samples*oDataRate/obj.fs);
  obj           = set(obj, 'outputSamples', outputSamples);

  % Setup for Frequency domain Analysers
  if strcmp(get(obj, 'type'), 'FrequencyDomain')
    offset  = ceil(get(obj, 'fs') / oDataRate);
    
    % Overwrite overlap
    obj.overlap.size = obj.windowLength - offset;
    obj.overlap.type = 'samples';
    
    fH.overlap = getOverlap(obj);

    % Re-jig number of windows
    nWindows = outputSamples;
  end
  
  % Set the data rate
  obj = set(obj, 'outputDataRate', oDataRate);

else
  if strcmp(get(obj, 'type'), 'TimeDomain')
    obj = set(obj, 'outputDataRate', get(obj, 'fs'));
    obj = set(obj, 'outputSamples', get(obj, 'samples'));
  elseif strcmp(get(obj, 'type'), 'Raw')
    odr = get(obj, 'outputDataRate'); 
    if odr == get(obj,'fs') % works EXCEPT for special case where fs is odr
      obj = set(obj, 'outputDataRate', 100);
    end
    osamp = ceil(get(obj,'outputDataRate') * (get(obj,'samples')/ get(obj,'fs'))); 
    obj = set(obj, 'outputSamples', osamp);    
  else
    obj = set(obj, 'outputDataRate', getWindowRate(obj));
    obj = set(obj, 'outputSamples', nWindows);
 
  end
end

if estimate
  % Run twice
  if nWindows > 2
    numWindows = 2;
  else
    % The windowLength is bigger than the data so just run it once
    numWindows = 1;
  end
else
  % Go with the correct number of windows
  if ~strcmp(obj.type,'Raw') % if 'raw' we will take in the whole file.
    numWindows = nWindows;
  else
      numWindows = 1;      
  end
      
end

if ~isempty(wBar)
  % Initialise the wait bar
  wBarTotal = ...
      1 + ...           % allocate
      1 + ...           % preprocess
      numWindows + ...  % process loop
      1;                % construct data objects
  wBarStepSize = 1/wBarTotal;
  wBarProgress = 0;
end

% Declare memory for the Output structure
if vLvl, tic; end

% Do not allocate memory if Raw mode is used. 
if ~strcmp(get(obj, 'type'), 'Raw')    
  dataBuffer = allocOutputDataStorage(obj);  
end
  % Update progress
  if ~isempty(wBar), 
    wBarProgress = wBarProgress + wBarStepSize;
    wBar(wBarProgress);
  end
  
if vLvl
  tictoc = toc;
  aTime  = aTime + tictoc;
end

if (vLvl | estimate) && ~strcmp(get(obj, 'type'), 'Raw')   
  sz = 0;
  dataBufFnames = fieldnames(dataBuffer);
  for i=1:length(dataBufFnames)
    bf = getfield(dataBuffer, dataBufFnames{i});
    sz = sz + bf.sizeMB();
  end
end

if vLvl
  fprintf('\n %-10s : %.5fs  %2.2fMB\n', 'Alloc', tictoc, sz);
end

% Create the windowing and prefilter functions
if vLvl, tic; end
  winFunc     = createWindowFunc(obj); % take almost no time
  preFiltFunc = [];
  if ismethod(obj, 'createPreFilterFunc');
    preFiltFunc = createPreFilterFunc(obj);
  end
  % See if processWindow is a function handles
  processWindowFH = processWindow(obj, 1);
  if ~isa(processWindowFH, 'function_handle')
    % Cache an empty handle so that we call the regular
    % processWindow method 
    processWindowFH = [];
  end
  
  % Time vector
  tVector = zeros(numWindows, 1);
  
  % Update progress
  if ~isempty(wBar), 
    wBarProgress = wBarProgress + wBarStepSize;
    wBar(wBarProgress);
  end

if vLvl
  tictoc = toc;
  aTime  = aTime + tictoc;
end

if vLvl
  fprintf(' %-10s : %.5fs\n\n', 'PreFilt', tictoc);
end

% Preferences
prefs = getPsysound3Prefs;

synchFunc = [];

% Create a struct to use as a conduit to assignOutputs;
% s = struct('centerLoc',    [], ...
%            'centerTpoint', [], ...
%            'beginData',    [], ...
%            'endData',      []);

% We just got started!
done  = false;

% Turn off annoying log of zero warning
if ~isempty(gcbo)
  logZeroWarn    = warning('off', 'MATLAB:log:logOfZero');
  divideZeroWarn = warning('off', 'MATLAB:divideByZero');
end

% This is the main process loop
for index = 1:numWindows
  % Reset loop time
  lTime = 0;
  if vLvl == 1, fprintf('.'); end
  
  if vLvl | estimate, tic; end
  % Read next block of data
  if strcmp(obj.type,'Raw')
    [fH, done] = readData(fH,1);
  else
    [fH, done] = readData(fH);
  end
  
  if vLvl | estimate
    tictoc = toc;
    lTime  = lTime + tictoc;
    if vLvl > 1
      fprintf('[Window %d of %d]\n', index, numWindows);
      fprintf(' %-10s :\t%.5f\n', 'Read', tictoc);
    end
  end

  % Consistency checking, if we're done, then we *must* be
  % processing the very last window
  if done && (index ~= numWindows)
    error('Analyser: process: There is a problem with windowing');
  end

  % MultiChannel support
	windowDataRaw = fH.data;
  if ~isMultiChannel(obj) && prefs.combineChannels
    switch prefs.multiChannelType
     case 1
      % Average
      windowDataRaw = mean(fH.data, 2);
     case 2
      % Sum
      windowDataRaw = sum(fH.data, 2);
     case 3
      % Select
      chan =  prefs.multiChannelSelect;
      if chan > obj.channels
        error('Multichannel preference is wrong');
      end
      
      windowDataRaw = fH.data(:, chan);
      
     otherwise
      error(['Unrecognized multichannel option ''', ...
             num2str(prefs.multiChannelType), ''' encountered']);
    end
  end

  % xxx - HACK for SLM.  If this scheme proves useful, we should
  %       make it more official. Note this will only be effective
  %       when the windowlength is big enough wrt the time constant
  %       of the SLM integrator, otherwise the ramp-up will vary
  %       according to the block size. - Farhan
  if isa(obj, 'SLM') && index == 1
    % Make the first window symmetric in data rather than zero pad
   % windowDataRaw = [windowDataRaw(end:-1:fH.winDataStart);
   %                  windowDataRaw(fH.winDataStart:end)];
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % WINDOWING AND PRE-PROCESSING STAGE %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if vLvl | estimate, tic; end
    % Apply the window
    if length(winFunc()) < 2 && min(size(windowDataRaw)) > 1
        windowDataRaw = windowDataRaw .* winFunc();
        % This is most likely just a multiplication by one, but I'll leave
        % it in anyway. 
    else
        windowDataRaw = windowDataRaw .* repmat(winFunc(), 1, min(size(windowDataRaw)));
    end    
    
    % Prefiltering (weightings)
    if ~isempty(preFiltFunc)
      windowDataRaw = preFiltFunc(windowDataRaw);
    end
    if vLvl | estimate
      tictoc = toc;
      lTime  = lTime + tictoc;
      if vLvl > 1
        fprintf(' %-10s :\t\t%.5f\n', 'PreProcess', tictoc);
    end
  end
  
  % This is the actual process (the algorithm part) for this Analyser
  if vLvl | estimate, tic; end
    % processWindow will either be a cached function handle or the
    % actual method
    if ~isempty(processWindowFH)
      % Call via function handle
      windowDataProcessed = processWindowFH(windowDataRaw);
    else
      % Call method
      windowDataProcessed = processWindow(obj, windowDataRaw);
    end
  if vLvl | estimate
    tictoc = toc;
    lTime  = lTime + tictoc;
    if vLvl > 1
      fprintf(' %-10s :\t\t%.5f\n', 'Process', tictoc);
    end
  end
  
  % Keep track of the time here
  tVector(index) = fH.tPoint;

  % Create the synchronising function handles, if needed
  if synch && isempty(synchFunc)
    % xxx get rate
    if iscell(windowDataProcessed)
      for si = 1:length(windowDataProcessed)
        synchFunc{si} = createSynchronisingFunc(obj, oDataRate, si);
      end
    else
      synchFunc = createSynchronisingFunc(obj, oDataRate);
    end
  end

  % Fill in the outputs
  if vLvl | estimate, tic; end
    % Populate struct
    % s.centerLoc    = fH.loc;
    % s.beginData    = fH.winDataStart;
    % s.endData      = fH.winDataEnd;
    s.centerTpoint = fH.tPoint;
    
    % Keep only the actual data
    if strcmp(get(obj, 'type'), 'TimeDomain')
      % If not first window, truncate some of the beginning
      if index > 1
        beginData = fH.winDataStart + obj.windowOffset;
      else
        beginData = fH.winDataStart;
      end
      
      % If not last window, truncate some of the end
      if index < numWindows
        if obj.windowOffset
          endData = fH.winDataEnd - obj.windowOffset;
        else
          endData = fH.winDataEnd;
        end
      else
        endData = fH.winDataEnd;
      end
      
      % Create the range
      chunk = (beginData:endData);
    else
      % Suck in the whole lot
      chunk = [];
    end % timedomain
    
    if iscell(windowDataProcessed)
      % Special handling for LoudnessCF
      if ~isnumeric(windowDataProcessed{1})
        continue;
      end
      
      % Loop over each cell
      for i=1:length(windowDataProcessed)
        if ~isempty(chunk)
          windowDataProcessed{i} = windowDataProcessed{i}(chunk);
        else
          windowDataProcessed{i} = windowDataProcessed{i};
        end
        
        % Synchronise
        if ~isempty(synchFunc)
          windowDataProcessed{i} = synchFunc{i}(windowDataProcessed{i}, ...
                                                index == 1,             ...
                                                index == numWindows);
        end
      end
    else
      % Just the one array
      if ~isempty(chunk)
        windowDataProcessed = windowDataProcessed(chunk);
      end
      
      % Synchronise
      if ~isempty(synchFunc)
        windowDataProcessed = synchFunc(windowDataProcessed, ...
                                        index == 1,          ...
                                        index == numWindows);
      end
    end % iscell

  if vLvl | estimate
    tictoc = toc;
    lTime  = lTime + tictoc;
    if vLvl > 1
      fprintf(' %-10s :\t\t\t%.5f\n', 'Downsample', tictoc);
    end
  end
  
  % Fill in the outputs
  if vLvl | estimate, tic; end

  if ~strcmp(get(obj, 'type'), 'Raw')   
    % Call the subclass method  
    obj = assignOutputs(obj, windowDataProcessed, dataBuffer, s);  
  else
    % if Raw Mode is used then windowDataProcessed should 
    % go straight to constructDataObjects
  end
  
    % Update progress
    if ~isempty(wBar), 
      wBarProgress = wBarProgress + wBarStepSize;
      wBar(wBarProgress);
    end
    
  if vLvl | estimate
    tictoc = toc;
    lTime  = lTime + tictoc;
    if vLvl > 1
      fprintf(' %-10s :\t\t\t%.5f\n\n', 'Assign', tictoc);
    end
  end
  
  % Update date pTime
  pTime = [pTime, lTime];

end % for index...

% Reset warning state
if ~isempty(gcbo)
  warning(logZeroWarn);
  warning(divideZeroWarn);
end

if vLvl
  fprintf('\n %-10s : %.2fs\n\n', 'Total process', sum(pTime));
end

% Construct data objects
if vLvl, tic; end
  if ~estimate
    if ~strcmp(get(obj, 'type'), 'Raw')   
      obj = constructDataObjects(obj, dataBuffer, tVector);
    else
      obj = constructDataObjects(obj, windowDataProcessed, tVector);
    end
    if synch
      % Truncate for synchronisation
      for k=1:length(obj.output)
        dObj = obj.output{k};
        % Only fix up timeseries objects
        oSamps = get(obj, 'outputSamples');
        if isa(dObj, 'tSeries')
          % Only if following the output data rate
          if dObj.TimeInfo.Increment == 1/oDataRate
            % if the samples are not already the right length
            if dObj.TimeInfo.Length ~= oSamps
              % Go ahead and truncate
              obj.output{k} = setlength(dObj, oSamps);
            end
          end
        else
          if isa(dObj, 'tSpectrum') && ...
                getTimeIncrement(dObj) == 1/oDataRate
            % Go ahead and truncate
            obj.output{k} = setlength(dObj, oSamps);
          end
        end
      end
    end
  end

  % Update progress
  if ~isempty(wBar), 
    wBarProgress = wBarProgress + wBarStepSize;
    wBar(wBarProgress);
  end

if vLvl
  tictoc = toc;
  fprintf(' %-10s : %.2fs\n\n', 'Data objects', tictoc);
end

% Assign output
if estimate
  % Return the time and memory esimates
  out(1) = aTime;
  out(2) = pTime(end) * nWindows;
  out(3) = sz;
else
  % Return the processed object
  out = obj;
end
  
% end process
