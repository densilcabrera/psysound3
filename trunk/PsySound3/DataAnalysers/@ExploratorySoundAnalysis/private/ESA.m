function filemat = ESA(varargin)
% Build Soundfile from grains.
obj = varargin{1};
dataObj = varargin{2};
ax = varargin{3};
ax1 = ax{1};
ax2 = ax{2};
axTag1 = get(ax{1},'Tag');
axTag2 = get(ax{2},'Tag');
plotType = varargin{4};
decimateToLength =[];
if length(varargin)>4
  decimateToLength = varargin{5};
end

timestep     = diff(dataObj.Time);             % Time Increment 
timestep     = timestep(1);                    % 
windowLength = floor(timestep * obj.fs);       % Get WindowLength
if mod(windowLength,2)>0
  windowLength = windowLength - 1;
end
[file,fs,bits] = wavread(obj.filename);        % load in wavefile
file = file(:,1);
filemat  = cut(file, windowLength, timestep, obj.fs); % make windowed matrix from sound file
[r,c]    = size(filemat);
smallestColumns = min([c length(dataObj.data)]); % get smallest length; data or number of windows
data     = dataObj.data(1:smallestColumns);                  % Get data from object (chop to smallestColumns)
timeAxis = dataObj.Time(1:smallestColumns);
TimeInfo = dataObj.TimeInfo;                   % Get TimeInfo

switch plotType
  case 'StemAndLeaf'
    filemat  = stemLeaf(filemat(:,1:smallestColumns),data);
  case 'CumulativeDistribution'
    filemat  = sortData(filemat(:,1:smallestColumns),data);
    if ~isempty(decimateToLength)
      filemat = decimateData(filemat, TimeInfo, decimateToLength);
    end
  case 'AuditoryBoxplot'
    [filemat,numbers] = fiveNumbers(filemat(:,1:smallestColumns),data);
end

filemat  = windowMix(filemat,windowLength,0.3);    % Overlap and add the sorted windows
sound(filemat./max(filemat),obj.fs);           % Play Sound
fileLength = (length(filemat)-1)/obj.fs;

% Round up and down to nearest 10
mindata = floor((min(data)/10))*10;
maxdata = ceil((max(data)/10))*10;

switch plotType
	case 'CumulativeDistribution' 
		if length(varargin)>2
      axes(ax1);
			plot(timeAxis, data); 
      title('Original Timeseries Data');
      axis([0 max(timeAxis) mindata maxdata]);
      set(ax1,'Tag',axTag1);
      ylabel(dataObj.DataInfo.Unit);
			xlabel('Time (s)');
      axes(ax2);
      stairs(timeAxis, sort(data)); 
      title('Cumulative Distribution');
      axis([0 max(timeAxis) mindata maxdata]);
			set(ax2,'Tag',axTag2);
		  ylabel(dataObj.DataInfo.Unit);
      xlabel('Time (s)');
      aiffwrite(['CDF-' obj.filename '.aif'],floor((filemat./(max(filemat)+0.1))*32767),obj.fs);
		end
	case 'StemAndLeaf' 
	
	case 'AuditoryBoxplot'	
    	if length(varargin)>2
      axes(ax1);
			plot(timeAxis, data); 
      title('Original Timeseries Data');
      axis([0 max(timeAxis) mindata maxdata]);
      set(ax1,'Tag',axTag1);
      ylabel(dataObj.DataInfo.Unit);
      xlabel('Time (s)');
      axes(ax2);
      bar(numbers); 
      title('Min, 25th, Median, 75th, Max');
      axis([0 6 mindata maxdata]);
			set(ax2,'Tag',axTag2);
		  ylabel(dataObj.DataInfo.Unit);
		end
end
				 
function aiffwrite(aiffile,y,Fs,Format)
%AIFFWRITE  save AIFF  format sound files.
%   AIFFWRITE(aiffile,y,Fs,Format) saves a .AIFF format file specified 
%       by 'aiffile'.
%       The Sample Frequency is given by Fs and the number of channels
%       equals to the number of columns of y. Format is either 16 (default)
%       or 8 and indicates the bits per sample to be written.
%
%   Note: The samples have to be  in the range [-32768:32767]
%         they are NOT scaled in any fashion 


if nargin~=3 &  nargin~=4
  error('AIFFWRITE takes as arguments:\n The filename sample matrix, Sample  Frequency and Bist per sample 8 or 16!');
end

if nargin ==3
   Format=16;
end

%if findstr(aiffile,'.')==[]
%	aiffile=[aiffile,'.aiff'];
%end
notend = 1;
comread = 0;
ssndread = 0;
if Format == 16
  typ='short';
else
  typ='char';
end

if min(size(y)) > 4
 fprintf('Writing file with more than 4 channels is not allowed\n');
end
if size(y,1) > size(y,2) 
transpose=1;
else
transpose=0;
end

len=46+size(y,1)*size(y,2)*Format/8;

fprintf('Writing file with %d  channels\n',min(size(y)));

fid=fopen(aiffile,'wb','b');
if fid ~= -1 
	% write aiff chunk
	fwrite(fid,'FORM','char');
	fwrite(fid,len,'long');
	fwrite(fid,'AIFF','char');
        
	% write Common chunk
	fwrite(fid,'COMM','char');
	fwrite(fid,18,'long');
        fwrite(fid,min(size(y)),'short');           % Channel
	fwrite(fid,max(size(y)),'ulong');           % Frames
	fwrite(fid,Format,'short');              % bits per sample


	    if 1
	      % Following char matrix is 10 IEEE-Extended float for 44100 !!
	      Fs = 44100;	      
	      fwrite(fid,[ 64 14 172 68 0 0 0 0 0 0 ],'char');
	    else
	      Fs = abs(Fs);	      
	      expon=floor(log(Fs)/log(2));
	      himant = Fs / 2^(expon) ;
	      
	      fwrite(fid,expon+16383 ,'short');
	      mul=128;	      
	      for i=1:8		
          tt(i)  = floor(himant*mul);
          himant = himant*mul -tt(i) ;
          mul=256;
        end
	      fwrite (fid,tt,'unsigned char');
	    end
            disp(sprintf('Rate       : %.0f', Fs))

	fwrite(fid,'SSND','char');
	fwrite(fid,8+size(y,1)*size(y,2)*Format/8,'long');
	fwrite(fid,0,'ulong');
	fwrite(fid,0,'ulong');
	if transpose ==1
    fwrite(fid,round(y'),typ);
  else
    fwrite(fid,round(y),typ);
	end
%        writeFS(fid,Fs);
	fclose(fid);
end



if fid == -1
	error(['Can''t open AIFF file >',aiffile,'< for output!']);
end;

