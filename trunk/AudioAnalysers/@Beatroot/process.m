function out = process(obj, fH, wH, varargin)
% PROCESS  Generic process method that is the workhorse of the
%          Analyser
%
% Overloaded for beatroot
%
%   OBJ = PROCESS(OBJ, FH) - Nominal usage. Calls the java binary directly
%
%   OUT = PROCESS(OBJ, FH, 'estimate') 
%                               - Gives time and memory estimates for
%                                 the Analyser
%                               Where:
%                               - OUT(1) is the time estimate &
%                               - OUT(2) is the memory size of the
%                                        data buffers required 
%
%

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
      % We are in the process of calibration, set the coeffecient to
      % one
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

filename = get(obj,'filename');
textFilename = [tempdir 'beatroot.txt'];
analyserDirectory = fileparts(mfilename('fullpath'));

try
	% Send the file to the beatroot java executable.
	system(['java -cp ' analyserDirectory '/beatroot-0.5.3.jar at.ofai.music.beatroot.BeatRoot -o ' textFilename ' ' filename]);
catch
	disp('An error has occurred while sending the file to the beatroot java executable.') 
end

try
	% Read in the tempfile. 
	beats = textread(textFilename);
catch
	disp('An error has occurred while reading the file output by the beatroot java executable.') 
end

% format for TimeSeries
tsB = createDataObject('tSeries',ones(length(beats),1));
tsB.Time = beats;
tsB.DataInfo.Unit = '';
for i = 1:length(beats);
	beatsName(i) = {num2str(beats(i))};
  beatsCell(i) = {beats(i)};
end
tsB = addevent(tsB,beatsName,beatsCell); % add multiple events - chord changes and their names
tsB.Name          = 'Beats'; 
output{1} = tsB;

beatsDiff = 60*(1./diff(beats));
tsD = createDataObject('tSeries',[beatsDiff; beatsDiff(end)]);
tsD.Time = beats;
tsD.DataInfo.Unit = 'BPM';
tsD.Name          = 'Tempo'; 
output{2} = tsD;

obj = set(obj,'output', output);
out = obj;

% end process
