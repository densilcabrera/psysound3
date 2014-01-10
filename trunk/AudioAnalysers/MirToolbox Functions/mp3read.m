function [Y,FS,NBITS,OPTS] = mp3read(FILE,N,MONO,DOWNSAMP,DELAY)
% MP3READ   Read MP3 audio file via use of external binaries.
%   Y = MP3READ(FILE) reads an mp3-encoded audio file into the
%     vector Y just like wavread reads a wav-encoded file (one channel 
%     per column).  Extension ".mp3" is added if FILE has none.
%     Also accepts other formats of wavread, such as
%   Y = MP3READ(FILE,N) to read just the first N sample frames (N
%     scalar), or the frames from N(1) to N(2) if N is a two-element vector.  
%   Y = MP3READ(FILE,FMT) or Y = mp3read(FILE,N,FMT) 
%     with FMT as 'native' returns int16 samples instead of doubles; 
%     FMT can be 'double' for default behavior (to exactly mirror the
%     syntax of wavread).
%
%   [Y,FS,NBITS,OPTS] = MP3READ(FILE...) returns extra information:
%     FS is the sampling rate,  NBITS is the bit depth (always 16), 
%     OPTS.fmt is a format info string; OPTS has multiple other
%     fields, see WAVREAD.
%
%   SIZ = MP3READ(FILE,'size') returns the size of the audio data contained
%     in the file in place of the actual audio data, returning the
%     2-element vector SIZ=[samples channels].
%
%   [Y...] = MP3READ(FILE,N,MONO,DOWNSAMP,DELAY) extends the
%     WAVREAD syntax to allow access to special features of the
%     mpg123 engine:  MONO = 1 forces output to be mono (by
%     averaging stereo channels); DOWNSAMP = 2 or 4 downsamples by 
%     a factor of 2 or 4 (thus FS returns as 22050 or 11025
%     respectively for a 44 kHz mp3 file); DELAY controls how many
%     "warm up" samples to drop at the start of the file; the
%     default value of 2257 makes an mp3write/mp3read loop for a 44
%     kHz mp3 file be as close as possible to being temporally
%     aligned; specify as 0 to prevent discard of initial samples.
%
%   Example:
%   To read an mp3 file as doubles at its original width and sampling rate:
%     [Y,FS] = mp3read('piano.mp3');
%   To read the first 1 second of the same file, downsampled by a
%   factor of 4, cast to mono, using the default filename
%   extension:
%     [Y,FS4] = mp3read('piano', FS/4, 1, 4);
%
%   Note: Because the mp3 format encodes samples in blocks of 26 ms (at
%   44 kHz), and because of the "warm up" period of the encoder,
%   the file length may not be exactly what you expect.
%
%   Note: requires external binaries mpg123 and mp3info; you
%   can find binaries for several platforms at:
%     http://labrosa.ee.columbia.edu/matlab/mp3read.html
%
%   See also mp3write, wavread.

% 2003-07-20 dpwe@ee.columbia.edu  This version calls mpg123.
% 2004-08-31 Fixed to read whole files correctly
% 2004-09-08 Uses mp3info to get info about mp3 files too
% 2004-09-18 Reports all mp3info fields in OPTS.fmt; handles MPG2LSF sizes
%            + added MONO, DOWNSAMP flags, changed default behavior.
% 2005-09-28 Fixed bug reading full-rate stereo as 1ch (thx bjoerns@vjk.dk)
% 2006-09-17 Chop off initial 2257 sample delay (for 44.1 kHz mp3)
%            so read-write loop doesn't get progressively delayed.
%            You can suppress this with a 5th argument of 0.
% 2007-02-04 Added support for FMT argument to match wavread
%            Added automatic selection of binary etc. to allow it
%            to work cross-platform without editing prior to
%            submitting to Matlab File Exchange
% 2007-07-23 Tweaks to 'size' mode so it exactly agrees with read data.

% find our baseline directory
path = fileparts(which('mp3read'));

% %%%%% Directory for temporary file (if needed)
% % Try to read from environment, or use /tmp if it exists, or use CWD
tmpdir = getenv('TMPDIR');
if isempty(tmpdir) || exist(tmpdir,'file')==0
  tmpdir = '/tmp';
end
if exist(tmpdir,'file')==0
  tmpdir = '';
end
% ensure it exists
%if length(tmpdir) > 0 && exist(tmpdir,'file')==0
%  mkdir(tmpdir);
%end

%%%%%% Command to delete temporary file (if needed)
rmcmd = 'rm';

%%%%%% Location of the binaries - attempt to choose automatically
%%%%%% (or edit to be hard-coded for your installation)
ext = lower(computer);
if ispc
  ext = 'exe';
  rmcmd = 'del';
end
mpg123 = fullfile(path,['mpg123.',ext]);
mp3info = fullfile(path,['mp3info.',ext]);

%%%%% Process input arguments
if nargin < 2
  N = 0;
end

% Check for FMT spec (per wavread)
FMT = 'double';
if ischar(N)
  FMT = lower(N);
  N = 0;
end

if length(N) == 1
  % Specified N was upper limit
  N = [1 N];
end
if nargin < 3
  forcemono = 0;
else
  % Check for 3rd arg as FMT
  if ischar(MONO)
    FMT = lower(MONO);
    MONO = 0;
  end
  forcemono = (MONO ~= 0);
end
if nargin < 4
  downsamp = 1;
else
  downsamp = DOWNSAMP;
end
if downsamp ~= 1 && downsamp ~= 2 && downsamp ~= 4
  error('DOWNSAMP can only be 1, 2, or 4');
end
if nargin < 5
  mpg123delay44kHz = 2257;  % empirical delay of lame/mpg123 loop
  delay = round(mpg123delay44kHz/downsamp);
else
  delay = DELAY;
end

if strcmp(FMT,'native') == 0 && strcmp(FMT,'double') == 0 && ...
      strcmp(FMT,'size') == 0
  error(['FMT must be ''native'' or ''double'' (or ''size''), not ''',FMT,'''']);
end


%%%%%% Constants
NBITS=16;

%%%%% add extension if none (like wavread)
[path,file,ext] = fileparts(FILE);
if isempty(ext)
  FILE = [FILE, '.mp3'];
end

%%%%%% Probe file to find format, size, etc. using "mp3info" utility
cmd = ['"',mp3info, '" -r m -p "%Q %u %b %r %v * %C %e %E %L %O %o %p" "', FILE,'"'];
% Q = samprate, u = #frames, b = #badframes (needed to get right answer from %u) 
% r = bitrate, v = mpeg version (1/2/2.5)
% C = Copyright, e = emph, E = CRC, L = layer, O = orig, o = mono, p = pad
w = mysystem(cmd);
% Break into numerical and ascii parts by finding the delimiter we put in
starpos = findstr(w,'*');
nums = str2num(w(1:(starpos - 2)));
strs = tokenize(w((starpos+2):end));

SR = nums(1);
nframes = nums(2);
nchans = 2 - strcmp(strs{6}, 'mono');
layer = length(strs{4});
bitrate = nums(4)*1000;
mpgv = nums(5);
% Figure samples per frame, after
% http://board.mp3-tech.org/view.php3?bn=agora_mp3techorg&key=1019510889
if layer == 1
  smpspfrm = 384;
elseif SR < 32000 && layer ==3
  smpspfrm = 576;
  if mpgv == 1
    error('SR < 32000 but mpeg version = 1');
  end
else
  smpspfrm = 1152;
end

OPTS.fmt.mpgBitrate = bitrate;
OPTS.fmt.mpgVersion = mpgv;
% fields from wavread's OPTS
OPTS.fmt.nAvgBytesPerSec = bitrate/8;
OPTS.fmt.nSamplesPerSec = SR;
OPTS.fmt.nChannels = nchans;
OPTS.fmt.nBlockAlign = smpspfrm/SR*bitrate/8;
OPTS.fmt.nBitsPerSample = NBITS;
OPTS.fmt.mpgNFrames = nframes;
OPTS.fmt.mpgCopyright = strs{1};
OPTS.fmt.mpgEmphasis = strs{2};
OPTS.fmt.mpgCRC = strs{3};
OPTS.fmt.mpgLayer = strs{4};
OPTS.fmt.mpgOriginal = strs{5};
OPTS.fmt.mpgChanmode = strs{6};
OPTS.fmt.mpgPad = strs{7};
OPTS.fmt.mpgSampsPerFrame = smpspfrm;

if SR == 16000 && downsamp == 4
  error('mpg123 will not downsample 16 kHz files by 4 (only 2)');
end

if downsamp == 1
  downsampstr = '';
else
  downsampstr = [' -',num2str(downsamp)];
end
FS = SR/downsamp;

if forcemono == 1
  nchans = 1;
  chansstr = ' -m';
else
  chansstr = '';
end

% Size-reading version
if strcmp(FMT,'size') == 1
   Y = [floor(smpspfrm*nframes/downsamp)-delay, nchans];
else

  % Temporary file to use
  tmpfile = fullfile(tmpdir, ['tmp',num2str(round(1000*rand(1))),'.wav']);

  skipx = 0;
  skipblks = 0;
  skipstr = '';
  sttfrm = N(1)-1;

  % chop off transcoding delay?
  %sttfrm = sttfrm + delay;  % empirically measured
  % no, we want to *decode* those samples, then drop them
  % so delay gets added to skipx instead
  
  if sttfrm > 0
    skipblks = floor(sttfrm*downsamp/smpspfrm);
    skipx = sttfrm - (skipblks*smpspfrm/downsamp);
    skipstr = [' -k ', num2str(skipblks)];
  end
  skipx = skipx + delay;
  
  lenstr = '';
  endfrm = -1;
  decblk = 0;
  if length(N) > 1
    endfrm = N(2);
    if endfrm > sttfrm
      decblk = ceil((endfrm+delay)*downsamp/smpspfrm) - skipblks + 10;   
      % we read 10 extra blks (+10) to cover the case where up to 10 bad 
      % blocks are included in the part we are trying to read (it happened)
      lenstr = [' -n ', num2str(decblk)];
      % This generates a spurious "Warn: requested..." if reading right 
      % to the last sample by index (or bad blks), but no matter.
    end
 end

  % Run the decode
  cmd=['"',mpg123,'"', downsampstr, chansstr, skipstr, lenstr, ...
       ' -q -w "', tmpfile,'"  "',FILE,'"'];
  %w = 
  mysystem(cmd);

  % Load the data
  Y = wavread(tmpfile);

%  % pad delay on to end, just in case
%  Y = [Y; zeros(delay,size(Y,2))];
%  % no, the saved file is just longer
  
  if decblk > 0 && length(Y) < decblk*smpspfrm/downsamp
    % This will happen if the selected block range includes >1 bad block
    disp(['Warn: requested ', num2str(decblk*smpspfrm/downsamp),' frames, returned ',num2str(length(Y))]);
  end
  
  % Delete tmp file
  mysystem([rmcmd,' "', tmpfile,'"']);
  
  % debug
%  disp(['sttfrm=',num2str(sttfrm),' endfrm=',num2str(endfrm),' skipx=',num2str(skipx),' delay=',num2str(delay),' len=',num2str(length(Y))]);
  
  % Select the desired part
  if skipx+endfrm-sttfrm > length(Y)
      endfrm = length(Y)+sttfrm-skipx;
  end
  
  if endfrm > sttfrm
    Y = Y(skipx+(1:(endfrm-sttfrm)),:);
  elseif skipx > 0
    Y = Y((skipx+1):end,:);
  end
  
  % Convert to int if format = 'native'
  if strcmp(FMT,'native')
    Y = int16((2^15)*Y);
  end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w = mysystem(cmd)
% Run system command; report error; strip all but last line
[s,w] = system(cmd);
if s ~= 0 
  error(['unable to execute ',cmd,' (',w,')']);
end
% Keep just final line
w = w((1+max([0,findstr(w,10)])):end);
% Debug
%disp([cmd,' -> ','*',w,'*']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function a = tokenize(s)
% Break space-separated string into cell array of strings
% 2004-09-18 dpwe@ee.columbia.edu
a = [];
p = 1;
n = 1;
l = length(s);
nss = findstr([s(p:end),' '],' ');
for ns = nss
  % Skip initial spaces
  if ns == p
    p = p+1;
  else
    if p <= l
      a{n} = s(p:(ns-1));
      n = n+1;
      p = ns+1;
    end
  end
end
    
