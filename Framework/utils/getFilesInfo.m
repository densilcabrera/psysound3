function files = getFilesInfo
% GETFILESINFO 
%  
% Find out basic info about all supported files in the directory. 
%

lerr  = lasterr;

% get all supported formats
try
filetypes = getSupportedFormats;
catch
% If we fail just accept wave files.
filetypes{1, 1} = ['*.wav'];
filetypes{1, 2} = ['All Wave files'];
end

% loop through finding all files in each type. Place in 1 big struct
len = size(filetypes, 1);
k   = 1;
for i = 1:len
  d = dir(filetypes{i, 1});
  if ~isempty(d)
    dlen = length(d);
    files(k:k+dlen-1) = d;
    k = k+dlen;
  end
end

% if files does not exist then we found nothing, so just return
if ~exist('files', 'var')
  files = [];
  return;
end

% We now have a list of all wav and sox-supported files
len = length(files);

% Create the waitbar
wBar = waitbar(0, 'Collecting audio files, please wait ....');
pH   = findobj(wBar, 'Type', 'patch');
set(pH, 'FaceColor', [0 0 1]);

i = 1;
while i <= len
  % Build the full name to the wav file
  fName = fullfile(pwd, files(i).name);
  
  % update the waitbar
  wBar = waitbar(i/len, wBar);
  
  try
    % Create fileHandle. 
    fileHandle = readData(fName);
  catch
    % If there is an error, remove the file, silently ignore
    % and process the rest of the files
    files(i) = [];
    len      = len-1;
    
    % Restore lasterr
    lasterr(lerr);
    continue
  end
  
  Length = 0;
  if fileHandle.sampleRate > 0
    Length = fileHandle.samples/fileHandle.sampleRate;
  end
  
  % Populate appropriate fields
  files(i).Fs   = fileHandle.sampleRate;
  files(i).Bits = fileHandle.bitsPerSample;
  files(i).Length = Length;
  
  if Length < 60
    Milliseconds = floor(mod(Length,1)*1000);
    Seconds      = floor(Length);
    LengthStr    = sprintf('%i s %i ms',Seconds,Milliseconds);
  else
    Seconds   = floor(mod(Length,60));
    Minutes   = floor(Length/60);
    LengthStr = sprintf('%i min %i s', Minutes, Seconds);
  end
  
  files(i).LengthStr = LengthStr;
  files(i).Channels = fileHandle.channels;
  files(i).CalFile = []; 
  
  % Increment index
  i = i + 1;
end

delete(wBar);

% EOF
