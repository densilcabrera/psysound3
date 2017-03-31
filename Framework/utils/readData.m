function [fileHandle, done] = readData(varargin)
% READDATA  Read Audio file data
%    FILEHANDLE = READDATA with no arguments will prompt the user
%    to select a file from the list of all supported types, converts
%    it to a WAV file and writes to a temp location
%
%    FILEHANDLE = READDATA(FILENAME) initialises the FILEHANDLE
%    with the file FILENAME and reads the first block
%
%    FILEHANDLE = READDATA(FILEHANDLE) reads the next block of data
%
%
% xxx - we should probably convert this to use nested functions and
%       write specific set functions for better error reporting

% Output vars
fileHandle = struct([]);
done       = false;

% local vars
fH             = [];
askForFileName = 0;
nameToHandle   = 0;
fileNames      = {};
fileName       = '';
pathNams       = {};
pathName       = '';

if nargin>1
    raw = 1;
else
    raw = 0;
end

% Parse inputs and setup flags
switch nargin
 case 0
  % Prompt user for file
  askForFileName = 1;
  nameToHandle   = 1;
 case {1,2}
  % A file name is passed in, we need to set up the fileHandle
  arg1 = varargin{1};

  if ischar(arg1) | iscell(arg1)
    % cell-ify so that the code below works
    if ischar(arg1), arg1 = {arg1}; end
    
    % Input argument can be a list
    for i=1:length(arg1)
      [pathName, fileName, ext] = fileparts(arg1{i});
      pathNames{i} = pathName;
      fileNames{i} = [fileName, ext];
    end
    nameToHandle = 1;
  else
    % We may want to check the integrity of the fileHandle
    fH = arg1;
  end
 
 otherwise
  error('Unknown readData argument');

end

% Get file name from dialog
if askForFileName
  [fileName, pathName] = getFileNameFromDialog;
end

% Setup the fileHandle
if nameToHandle
  len = length(fileNames);
  for i=1:len
    fileName = fileNames{i};
    pathName = pathNames{i};
    
    % At this stage we should have a valid file name
    ftemp.realName = fullfile(pathName, fileName);
    ftemp.name     = fullfile(pathName, fileName);
  
    % See if we need to convert using sox
    ftemp = setupWavFileName(ftemp, pathName, fileName);
  
    % Initialise fields
    if i == 1
      fH    = initFileHandleWithDefaults(ftemp);
    else
      fH(i) = initFileHandleWithDefaults(ftemp);
    end
  end
else
  % A previously initialised fileHandle was passed in so read the
  % next block of data from file
  [fH, done] = readNextBlock(fH,raw);
end

% Assign output
fileHandle = fH;

% end of readData main function

%%%%%%%%%%%%%%%%%%%%%%%
% Local sub-functions %
%%%%%%%%%%%%%%%%%%%%%%%
%
% Initialise the file handle with defaults
%
function fileHandle = initFileHandleWithDefaults(fH)

fileHandle = struct([]);

% Setup default parameters
DWINDOWLENGTH = 2^17; % 131072 samples
                      % This works out to be 1 Mb worth of doubles
                      % which corresponds to approx 3s @ 44.1 KHz
                      % Note: This is for each channel

% Add location and window count fields
fH.loc          = 0;  % Uninitialised data buffer
fH.windowLength = DWINDOWLENGTH;
  
% Get sample and channel info.
info = audioinfo(fH.name);
fH.samples = info.TotalSamples;
fH.channels = info.NumChannels;
fH.sampleRate = info.SampleRate;
fH.bitsPerSample = info.BitsPerSample;

% The memory for the data will never be declared by readData as
% such.  The call to wavread creates it and transfers ownership
% upon assignment.
fH.data          = []; % no data as yet
  
if exist('OPTS.info', 'var')
  fH.info = OPTS.info;
else
  fH.info = [];
end
  
% Variables that are to do with various indicies
fH.tPoint     = 0; % time point of the center of window i.e. time
                   % point of loc

fH.startIndex = 0; % Where in the data array does the window
                   % begin. Note that this always starts of negative

% Start and end indicies within a window of the actual data -
% i.e. non-zero paddd
fH.winDataStart = 0;
fH.winDataEnd   = 0;

% Overlap
fH.overlap = 0; % the overlap ammount is set to zero samples

% Calibration
fH.calCoeff = NaN; % Denote 'uncalibrated' status

% Assign outputs
fileHandle = fH;

% This is a nested functi
% end initFileHandleWithDefaults

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Reads the next block of data from the wav file
%
function [fileHandle, done] = readNextBlock(fH,raw)

done = false;

% check if window length is an even number
if mod(fH.windowLength, 2)
  error('readData: WindowLength must be even!');
end

% check the file is real and not a link... or anything else !
if exist(fH.name, 'file') ~= 2
  error(['File ' fH.name ' does not exist']);
end

% This is how much the window moves forward by
offset = fH.windowLength - fH.overlap;

% Convenient var
halfWindow = fH.windowLength/2;

% Point to the center of window
if (fH.loc == 0)
  % Very first read
  fH.loc = 1;
else
  % Advance current location
  fH.loc = fH.loc + offset;
end

if ~raw 
    % Figure out the start and end indicies
    startIndex = fH.loc - halfWindow;
    endIndex   = startIndex + fH.windowLength - 1;
else
    startIndex = fH.loc;
    endIndex = startIndex + fH.windowLength - 1;
end
    
% Cache the startIndex
fH.startIndex = startIndex;

padInFront = [];
pad        = 0;
if startIndex < 1
  % Zero pad the front
  pad        = abs(startIndex) + 1;
  padInFront = zeros(pad, fH.channels);
  startIndex = 1;
end

% This is where the data in the window begins
fH.winDataStart = pad + 1;

padAtRear  = [];
pad        = 0;
if endIndex > fH.samples
  % Zero pad the end
  pad       = endIndex - fH.samples;
  padAtRear = zeros(pad, fH.channels);
  endIndex  = fH.samples;
end

% This is where the data in the window ends
fH.winDataEnd = fH.windowLength - pad;

% Uncomment for manual testing
% [fH.loc size(padInFront, 1) startIndex endIndex size(padAtRear, 1)]
% [fH.loc fH.startIndex endIndex fH.winDataStart fH.winDataEnd]

% Read data from file, padding as neccessary
fH.data = [padInFront; ... 
           audioread(fH.name, [startIndex endIndex]); ... % formerly wavread
           padAtRear];

% Consistecy checking - startIndex must always be inside the
%                       input data
if startIndex > fH.samples
  % This means that our window count is wrong somewhere
  error('readData : startIndex cannot walk off the end of the file!');
elseif (size(fH.data, 1) ~= fH.windowLength)
  error('readData : size of data is not windowLength');
end

% Check if the next window is going to contain any data
if (fH.startIndex + offset) > fH.samples
  done = true;
end

% Set times for Analysers to pick up. This is the time point right
% before the next sample.
% Subtract 1 sample so that time starts from 0 not from the first
% sample
fH.tPoint = (fH.loc - 1) / fH.sampleRate;

% calibrate using the in-built calibration coefficient
fH.data = fH.data * fH.calCoeff;

% Assign output
fileHandle = fH;

% end readNextBlock

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Setup the filename in the file handle of the wav file
% If the input file is not already a wav file then we convert it
% using sox
%
function fH = setupWavFileName(fH, pathName, fileName)
% Here we only try sox if wavread errors

[~, ~, ext] = fileparts(fH.name);
if(strcmpi(ext, '.wav') == false)
  % File must be converted to wav.
  % This is where the converted wav file will live
  tempPath = tempdir;
    
  fH.realName = fullfile(pathName, fileName);
  fH.name     = fullfile(tempPath, [fileName, '.temp.wav']);
    
  % xxx Make sure the quotes work on PC
  str = [getFullPathToSox ' "' fH.realName '" "' fH.name,'"']; 
  
  % Run the sox command
  [s, w] = system(str);
  
  % Make sure sox succeeded
  if s ~= 0; 
      fH.name  = fullfile(pathName, fileName);
      disp('Your file does not work with Matlab''s file reading utility. '); 
  end
end
% end setupWavFileName

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Open a dialog for the user to select file
%
function [fileName, pathName] = getFileNameFromDialog
% probe sox to find out which files can be opened
fmtStr = getSupportedFormats;

% open the ui gui to get a file
[fileName, pathName] = uigetfile(fmtStr, 'Please select an audio file');

if ~ischar(fileName) % check we chose a file name
  error('No file chosen'); % none chosen so return
end
% end getFileNameFromDialog

% EOF
