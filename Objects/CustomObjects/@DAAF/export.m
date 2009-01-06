function obj = export(obj,varargin)
% SOUND method for DAAF Object

name = varargin{1};
if strcmp(class(name),'double') 
  name = ['percentile' num2str(name)];
end
  
dot = strfind(obj.AudioFilename,'.');

switch nargin
  case 1
    wavwrite(obj.OutputAudio,obj.FS,[obj.AudioFilename(1:dot-1) name obj.Name '.wav']);
  case 2
    % scaledData= floor((obj.OutputAudio ./ (max(max(obj.OutputAudio)+0.1))*32767));
	aiffwrite([obj.AudioFilename(1:dot-1) name  strrep(obj.Name,' ','') '.aif'],floor(obj.OutputAudio*32767),obj.FS);
  case 3
    % if there's three then the second varargin is a cell array to be concatenated.
    objArr =  varargin{2};
    audio = [];
    for i = 1:length(objArr)
      audio = [audio; zeros(obj.FS*0.5,1)];
      audio = [audio; objArr{i}.OutputAudio];
    end
    aiffwrite([obj.AudioFilename(1:dot-1) name strrep(obj.Name,' ','') 'Set' '.aif'],floor(audio*32767),obj.FS);
end


if nargin == 4
 ax = varargin{3};
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

%fprintf('Writing file with %d  channels\n',min(size(y)));

disp(['\sound[inlinesound,channels=1,encoding=Signed]{}{' aiffile '}']); 

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


	    if( Fs == 0)
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

	      fwrite (fid,tt,'uchar');

	    end
       %     disp(sprintf('Rate       : %.0f', Fs))

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

